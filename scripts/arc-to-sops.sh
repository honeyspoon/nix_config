#!/usr/bin/env bash
# Encrypt Arc browser data (tabs, bookmarks) into sops secrets
# This keeps your browsing history private in the git repo

set -euo pipefail

cd "$HOME/nix-config"

SECRETS_FILE="secrets/secrets.yaml"
ARC_EXPORT="$HOME/.local/share/arc-export"
AGE_KEY="$HOME/.config/sops/age/keys.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Arc Browser Data → SOPS Encryption ==="
echo

# Check prerequisites
if [ ! -f "$AGE_KEY" ]; then
    echo -e "${RED}Error: Age key not found at $AGE_KEY${NC}"
    echo "Run: mkdir -p ~/.config/sops/age && age-keygen -o ~/.config/sops/age/keys.txt"
    exit 1
fi

if [ ! -f "$SECRETS_FILE" ]; then
    echo -e "${RED}Error: Secrets file not found at $SECRETS_FILE${NC}"
    exit 1
fi

# Run extraction if data doesn't exist
if [ ! -f "$ARC_EXPORT/tabs.json" ]; then
    echo -e "${YELLOW}Arc export not found. Running extraction...${NC}"
    "$HOME/nix-config/scripts/extract-arc-data.sh"
fi

# Read the current tabs and extensions as compact JSON strings
tabs_json=$(jq -c '.' "$ARC_EXPORT/tabs.json" 2>/dev/null || echo "[]")
extensions_json=$(jq -c '.' "$ARC_EXPORT/extensions.json" 2>/dev/null || echo "[]")
spaces_json=$(jq -c '.' "$ARC_EXPORT/spaces.json" 2>/dev/null || echo "[]")
bookmarks_json=$(jq -c '.' "$ARC_EXPORT/bookmarks.json" 2>/dev/null || echo "[]")

# Count items
tab_count=$(echo "$tabs_json" | jq 'length')
ext_count=$(echo "$extensions_json" | jq 'length')
space_count=$(echo "$spaces_json" | jq 'length')
bookmark_count=$(echo "$bookmarks_json" | jq 'length')

echo "Data to encrypt:"
echo "  - Tabs: $tab_count URLs"
echo "  - Extensions: $ext_count"
echo "  - Spaces: $space_count"
echo "  - Bookmarks: $bookmark_count"
echo

# Decrypt secrets file to JSON
echo "Decrypting secrets file..."
decrypted_json=$(sops -d --output-type json "$SECRETS_FILE")

# Add/update the Arc browser data using jq
echo "Adding Arc data to secrets..."
updated_json=$(echo "$decrypted_json" | jq \
    --arg tabs "$tabs_json" \
    --arg extensions "$extensions_json" \
    --arg spaces "$spaces_json" \
    --arg bookmarks "$bookmarks_json" \
    '. + {
        arc_browser_tabs: $tabs,
        arc_browser_extensions: $extensions,
        arc_browser_spaces: $spaces,
        arc_browser_bookmarks: $bookmarks
    } | del(.sops)')

# Use a temp file that matches the sops pattern (secrets/*.yaml)
echo "Converting to YAML and encrypting..."
temp_file="secrets/arc-temp.yaml"

# Use yq (Go version) to convert JSON to YAML
echo "$updated_json" | yq -P '.' > "$temp_file"

# Encrypt the file in place using sops
sops -e -i "$temp_file"

# Replace the original secrets file
mv "$temp_file" "$SECRETS_FILE"

echo
echo -e "${GREEN}✓ Arc browser data encrypted into sops secrets${NC}"
echo
echo "Secrets added:"
echo "  - arc_browser_tabs ($tab_count URLs as JSON string)"
echo "  - arc_browser_extensions ($ext_count extensions as JSON string)"
echo "  - arc_browser_spaces ($space_count spaces as JSON string)"
echo "  - arc_browser_bookmarks ($bookmark_count bookmarks as JSON string)"
echo
echo "To verify: sops -d $SECRETS_FILE | grep arc_browser"
echo "To view tabs: sops -d --output-type json $SECRETS_FILE | jq -r '.arc_browser_tabs | fromjson'"
