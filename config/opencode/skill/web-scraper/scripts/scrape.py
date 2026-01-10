#!/usr/bin/env python3
"""
Web Scraper Tool

Recursively scrapes web pages, extracting text content and following links.
Features concurrent URL processing, deduplication, content filtering, and
proper directory hierarchy storage.

Requirements:
    pip install aiohttp beautifulsoup4 lxml aiofiles
"""

import argparse
import asyncio
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Set, Dict, Optional, List
from urllib.parse import urljoin, urlparse, urlunparse
from datetime import datetime

try:
    import aiohttp
    from bs4 import BeautifulSoup
    import aiofiles
except ImportError as e:
    print(f"Error: Missing required dependency: {e}", file=sys.stderr)
    print("Install with: pip install aiohttp beautifulsoup4 lxml aiofiles", file=sys.stderr)
    sys.exit(1)


class WebScraper:
    """Concurrent web scraper with content extraction and filtering."""

    def __init__(
        self,
        output_dir: str,
        max_depth: int = 2,
        max_pages: Optional[int] = None,
        max_concurrent: int = 10,
        same_domain_only: bool = True,
        allowed_domains: Optional[List[str]] = None,
        user_agent: str = "Mozilla/5.0 (compatible; WebScraper/1.0)",
        timeout: int = 30,
        verbose: bool = False,
    ):
        """
        Initialize the web scraper.

        Args:
            output_dir: Directory to save scraped content
            max_depth: Maximum link depth to follow (0 = start URL only)
            max_pages: Maximum number of pages to scrape (None = unlimited)
            max_concurrent: Maximum concurrent requests
            same_domain_only: Only follow links on the same domain
            allowed_domains: List of allowed domains (overrides same_domain_only)
            user_agent: User-Agent header to use
            timeout: Request timeout in seconds
            verbose: Enable verbose logging
        """
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

        self.max_depth = max_depth
        self.max_pages = max_pages
        self.max_concurrent = max_concurrent
        self.same_domain_only = same_domain_only
        self.allowed_domains = set(allowed_domains) if allowed_domains else set()
        self.user_agent = user_agent
        self.timeout = timeout
        self.verbose = verbose

        # Tracking
        self.visited_urls: Set[str] = set()
        self.queued_urls: Set[str] = set()
        self.pages_scraped = 0
        self.errors: Dict[str, str] = {}

        # Semaphore for concurrent control
        self.semaphore = asyncio.Semaphore(max_concurrent)

        # Metadata
        self.metadata = {
            "start_time": datetime.now().isoformat(),
            "pages_scraped": 0,
            "errors": {},
        }

    def normalize_url(self, url: str) -> str:
        """Normalize URL by removing fragments and trailing slashes."""
        parsed = urlparse(url)
        # Remove fragment
        normalized = urlunparse((
            parsed.scheme,
            parsed.netloc,
            parsed.path.rstrip('/') or '/',
            parsed.params,
            parsed.query,
            ''  # Remove fragment
        ))
        return normalized

    def is_allowed_domain(self, url: str, start_domain: str) -> bool:
        """Check if URL is from an allowed domain."""
        parsed = urlparse(url)
        domain = parsed.netloc

        if self.allowed_domains:
            return domain in self.allowed_domains

        if self.same_domain_only:
            return domain == start_domain

        return True

    def url_to_filepath(self, url: str) -> Path:
        """Convert URL to a safe filesystem path."""
        parsed = urlparse(url)

        # Create directory structure from domain and path
        domain = parsed.netloc
        path = parsed.path.strip('/')

        if not path:
            path = 'index'

        # Add query hash if present
        if parsed.query:
            query_hash = hashlib.md5(parsed.query.encode()).hexdigest()[:8]
            path = f"{path}_q{query_hash}"

        # Replace unsafe characters
        path = re.sub(r'[<>:"|?*]', '_', path)

        # Build full path
        full_path = self.output_dir / domain / path

        # Ensure it has .txt extension
        if not full_path.suffix:
            full_path = full_path.with_suffix('.txt')
        elif full_path.suffix not in ['.txt', '.html', '.md']:
            full_path = Path(str(full_path) + '.txt')

        return full_path

    def extract_text_content(self, html: str, url: str) -> Dict[str, str]:
        """
        Extract clean text content from HTML.

        Returns dict with 'title', 'text', and 'metadata'.
        """
        soup = BeautifulSoup(html, 'lxml')

        # Remove unwanted elements
        unwanted_tags = [
            'script', 'style', 'nav', 'footer', 'header',
            'aside', 'iframe', 'noscript', 'svg'
        ]
        for tag in unwanted_tags:
            for element in soup.find_all(tag):
                element.decompose()

        # Remove comments
        for comment in soup.find_all(string=lambda text: isinstance(text, type(soup))):
            comment.extract()

        # Extract title
        title = soup.title.string if soup.title else urlparse(url).path

        # Extract main content
        # Try to find main content area first
        main_content = soup.find('main') or soup.find('article') or soup.find('body')

        if main_content:
            text = main_content.get_text(separator='\n', strip=True)
        else:
            text = soup.get_text(separator='\n', strip=True)

        # Clean up whitespace
        lines = [line.strip() for line in text.split('\n')]
        lines = [line for line in lines if line]  # Remove empty lines

        # Remove common unwanted patterns
        filtered_lines = []
        unwanted_patterns = [
            r'^(accept|reject)\s+(cookies?|all)$',
            r'^cookie\s+settings?$',
            r'^privacy\s+policy$',
            r'^terms\s+(of\s+service|and\s+conditions)$',
            r'^\s*\d+\s*$',  # Just numbers
            r'^[←→↑↓]+$',  # Just arrows
        ]

        for line in lines:
            # Skip if matches unwanted patterns
            if any(re.match(pattern, line.lower()) for pattern in unwanted_patterns):
                continue
            # Skip very short lines that are likely UI elements
            if len(line) < 3:
                continue
            filtered_lines.append(line)

        text = '\n'.join(filtered_lines)

        # Extract metadata
        description = ''
        meta_desc = soup.find('meta', attrs={'name': 'description'})
        if meta_desc and meta_desc.get('content'):
            description = meta_desc['content']

        return {
            'title': str(title).strip(),
            'text': text,
            'description': description,
        }

    def extract_links(self, html: str, base_url: str) -> Set[str]:
        """Extract and normalize all links from HTML."""
        soup = BeautifulSoup(html, 'lxml')
        links = set()

        for anchor in soup.find_all('a', href=True):
            href = anchor['href']

            # Skip certain link types
            if href.startswith(('#', 'javascript:', 'mailto:', 'tel:')):
                continue

            # Make absolute URL
            absolute_url = urljoin(base_url, href)

            # Only include http/https URLs
            if absolute_url.startswith(('http://', 'https://')):
                normalized = self.normalize_url(absolute_url)
                links.add(normalized)

        return links

    async def fetch_page(self, session: aiohttp.ClientSession, url: str) -> Optional[str]:
        """Fetch a single page with error handling."""
        try:
            async with self.semaphore:
                if self.verbose:
                    print(f"  Fetching: {url}")

                async with session.get(
                    url,
                    timeout=aiohttp.ClientTimeout(total=self.timeout),
                    allow_redirects=True,
                ) as response:
                    # Only process successful HTML responses
                    if response.status != 200:
                        self.errors[url] = f"HTTP {response.status}"
                        return None

                    content_type = response.headers.get('Content-Type', '')
                    if 'text/html' not in content_type:
                        self.errors[url] = f"Not HTML: {content_type}"
                        return None

                    html = await response.text()
                    return html

        except asyncio.TimeoutError:
            self.errors[url] = "Timeout"
            if self.verbose:
                print(f"  ✗ Timeout: {url}")
        except aiohttp.ClientError as e:
            self.errors[url] = f"Client error: {str(e)}"
            if self.verbose:
                print(f"  ✗ Error: {url} - {e}")
        except Exception as e:
            self.errors[url] = f"Unexpected error: {str(e)}"
            if self.verbose:
                print(f"  ✗ Unexpected error: {url} - {e}")

        return None

    async def save_page(self, url: str, content_data: Dict[str, str]) -> None:
        """Save page content to disk."""
        filepath = self.url_to_filepath(url)
        filepath.parent.mkdir(parents=True, exist_ok=True)

        # Create formatted content
        output = f"""URL: {url}
Title: {content_data['title']}
Scraped: {datetime.now().isoformat()}

{'='*80}

{content_data['text']}
"""

        # Save asynchronously
        async with aiofiles.open(filepath, 'w', encoding='utf-8') as f:
            await f.write(output)

        if self.verbose:
            print(f"  ✓ Saved: {filepath}")

    async def scrape_url(
        self,
        session: aiohttp.ClientSession,
        url: str,
        depth: int,
        start_domain: str,
    ) -> Set[str]:
        """
        Scrape a single URL and return discovered links.

        Returns set of new URLs to queue.
        """
        # Mark as visited
        self.visited_urls.add(url)

        # Fetch page
        html = await self.fetch_page(session, url)
        if not html:
            return set()

        # Extract content
        content_data = self.extract_text_content(html, url)

        # Save content
        await self.save_page(url, content_data)

        self.pages_scraped += 1
        print(f"[{self.pages_scraped}] {url[:80]}")

        # Extract links if we haven't reached max depth
        new_links = set()
        if depth < self.max_depth:
            links = self.extract_links(html, url)

            for link in links:
                # Skip if already visited or queued
                if link in self.visited_urls or link in self.queued_urls:
                    continue

                # Check domain restrictions
                if not self.is_allowed_domain(link, start_domain):
                    continue

                new_links.add(link)

        return new_links

    async def scrape(self, start_urls: List[str]) -> None:
        """
        Main scraping loop with concurrent processing.

        Args:
            start_urls: List of starting URLs to scrape
        """
        # Normalize start URLs
        start_urls = [self.normalize_url(url) for url in start_urls]

        # Get start domain from first URL
        start_domain = urlparse(start_urls[0]).netloc

        # Initialize queue with (url, depth) tuples
        queue = [(url, 0) for url in start_urls]
        self.queued_urls.update(start_urls)

        # Create aiohttp session
        headers = {'User-Agent': self.user_agent}
        connector = aiohttp.TCPConnector(limit=self.max_concurrent)

        async with aiohttp.ClientSession(headers=headers, connector=connector) as session:
            while queue:
                # Check max pages limit
                if self.max_pages and self.pages_scraped >= self.max_pages:
                    print(f"\nReached max pages limit ({self.max_pages})")
                    break

                # Get batch of URLs to process
                batch_size = min(self.max_concurrent, len(queue))
                batch = queue[:batch_size]
                queue = queue[batch_size:]

                # Process batch concurrently
                tasks = [
                    self.scrape_url(session, url, depth, start_domain)
                    for url, depth in batch
                ]

                results = await asyncio.gather(*tasks)

                # Add new links to queue
                for new_links in results:
                    for link in new_links:
                        if link not in self.queued_urls:
                            # Get depth from parent + 1
                            parent_depth = batch[results.index(new_links)][1]
                            queue.append((link, parent_depth + 1))
                            self.queued_urls.add(link)

        # Save metadata
        await self.save_metadata()

    async def save_metadata(self) -> None:
        """Save scraping metadata."""
        self.metadata['end_time'] = datetime.now().isoformat()
        self.metadata['pages_scraped'] = self.pages_scraped
        self.metadata['total_visited'] = len(self.visited_urls)
        self.metadata['errors'] = self.errors

        metadata_file = self.output_dir / '_metadata.json'
        async with aiofiles.open(metadata_file, 'w') as f:
            await f.write(json.dumps(self.metadata, indent=2))

        print(f"\n{'='*80}")
        print(f"Scraping complete!")
        print(f"  Pages scraped: {self.pages_scraped}")
        print(f"  Total visited: {len(self.visited_urls)}")
        print(f"  Errors: {len(self.errors)}")
        print(f"  Output directory: {self.output_dir}")
        print(f"  Metadata: {metadata_file}")

        if self.errors and self.verbose:
            print(f"\nErrors:")
            for url, error in list(self.errors.items())[:10]:
                print(f"  {url[:60]}: {error}")
            if len(self.errors) > 10:
                print(f"  ... and {len(self.errors) - 10} more")


async def main_async(args):
    """Async main function."""
    scraper = WebScraper(
        output_dir=args.output,
        max_depth=args.depth,
        max_pages=args.max_pages,
        max_concurrent=args.concurrent,
        same_domain_only=not args.follow_external,
        allowed_domains=args.allowed_domains,
        user_agent=args.user_agent,
        timeout=args.timeout,
        verbose=args.verbose,
    )

    print(f"Starting web scraper...")
    print(f"  Start URLs: {', '.join(args.urls)}")
    print(f"  Output directory: {args.output}")
    print(f"  Max depth: {args.depth}")
    print(f"  Max pages: {args.max_pages or 'unlimited'}")
    print(f"  Concurrent requests: {args.concurrent}")
    print(f"  Same domain only: {not args.follow_external}")
    if args.allowed_domains:
        print(f"  Allowed domains: {', '.join(args.allowed_domains)}")
    print(f"\n{'='*80}\n")

    await scraper.scrape(args.urls)


def main():
    parser = argparse.ArgumentParser(
        description="Concurrent web scraper with content extraction and filtering",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Scrape a single page
  %(prog)s https://example.com output/

  # Scrape with depth 2 (follow 2 levels of links)
  %(prog)s https://example.com output/ --depth 2

  # Limit to 100 pages
  %(prog)s https://example.com output/ --depth 3 --max-pages 100

  # Allow external links
  %(prog)s https://example.com output/ --depth 2 --follow-external

  # Specify allowed domains
  %(prog)s https://example.com output/ --allowed-domains example.com docs.example.com

  # Increase concurrency for faster scraping
  %(prog)s https://example.com output/ --depth 2 --concurrent 20

  # Verbose mode
  %(prog)s https://example.com output/ --depth 2 --verbose
        """
    )

    parser.add_argument(
        'urls',
        nargs='+',
        help='Starting URL(s) to scrape'
    )
    parser.add_argument(
        'output',
        help='Output directory for scraped content'
    )

    # Crawling options
    crawl_group = parser.add_argument_group('crawling options')
    crawl_group.add_argument(
        '-d', '--depth',
        type=int,
        default=2,
        help='Maximum link depth to follow (0 = start URLs only, default: 2)'
    )
    crawl_group.add_argument(
        '-m', '--max-pages',
        type=int,
        help='Maximum number of pages to scrape (default: unlimited)'
    )
    crawl_group.add_argument(
        '-c', '--concurrent',
        type=int,
        default=10,
        help='Maximum concurrent requests (default: 10)'
    )

    # Domain filtering
    domain_group = parser.add_argument_group('domain filtering')
    domain_group.add_argument(
        '-f', '--follow-external',
        action='store_true',
        help='Follow links to external domains (default: same domain only)'
    )
    domain_group.add_argument(
        '-a', '--allowed-domains',
        nargs='+',
        metavar='DOMAIN',
        help='List of allowed domains (overrides --follow-external)'
    )

    # Request options
    request_group = parser.add_argument_group('request options')
    request_group.add_argument(
        '-u', '--user-agent',
        default='Mozilla/5.0 (compatible; WebScraper/1.0)',
        help='User-Agent header (default: Mozilla/5.0 compatible)'
    )
    request_group.add_argument(
        '-t', '--timeout',
        type=int,
        default=30,
        help='Request timeout in seconds (default: 30)'
    )

    # Output options
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Enable verbose output'
    )

    args = parser.parse_args()

    # Run async main
    try:
        asyncio.run(main_async(args))
    except KeyboardInterrupt:
        print("\n\nScraping interrupted by user")
        sys.exit(1)


if __name__ == '__main__':
    main()
