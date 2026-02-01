#!/usr/bin/env bash
# Extract Arc browser data for migration to Zen browser
# Outputs: spaces, tabs, bookmarks, extensions, settings

set -euo pipefail

ARC_DATA="$HOME/Library/Application Support/Arc"
OUTPUT_DIR="$HOME/.local/share/arc-export"
mkdir -p "$OUTPUT_DIR"

echo "=== Arc Browser Data Extraction ==="
echo "Output directory: $OUTPUT_DIR"
echo

# ============================================================================
# Extract Extensions
# ============================================================================
echo "1. Extracting extensions..."

get_extension_name() {
    local ext_dir="$1"
    local manifest=$(find "$ext_dir" -name "manifest.json" -type f | head -1)
    if [ -z "$manifest" ]; then
        echo "Unknown"
        return
    fi

    local name=$(jq -r '.name // .short_name // "Unknown"' "$manifest" 2>/dev/null)

    # If name is a message reference, try to resolve it
    if [[ "$name" == __MSG_* ]]; then
        local msg_key="${name#__MSG_}"
        msg_key="${msg_key%__}"
        local locale_dir=$(dirname "$manifest")/_locales

        # Try en, en_US, then any available locale
        for loc in en en_US; do
            local msg_file="$locale_dir/$loc/messages.json"
            if [ -f "$msg_file" ]; then
                local resolved=$(jq -r ".[\"$msg_key\"].message // empty" "$msg_file" 2>/dev/null)
                if [ -n "$resolved" ]; then
                    echo "$resolved"
                    return
                fi
            fi
        done

        # Try first available locale
        local first_locale=$(find "$locale_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1)
        if [ -n "$first_locale" ]; then
            local msg_file="$first_locale/messages.json"
            if [ -f "$msg_file" ]; then
                local resolved=$(jq -r ".[\"$msg_key\"].message // empty" "$msg_file" 2>/dev/null)
                if [ -n "$resolved" ]; then
                    echo "$resolved"
                    return
                fi
            fi
        fi
    fi

    echo "$name"
}

extensions_json="[]"
for ext_dir in "$ARC_DATA/User Data/Default/Extensions/"*/; do
    [ -d "$ext_dir" ] || continue
    ext_id=$(basename "$ext_dir")
    [ "$ext_id" = "Temp" ] && continue

    ext_name=$(get_extension_name "$ext_dir")
    manifest=$(find "$ext_dir" -name "manifest.json" -type f | head -1)

    if [ -n "$manifest" ]; then
        version=$(jq -r '.version // "unknown"' "$manifest" 2>/dev/null)
        description=$(jq -r '.description // ""' "$manifest" 2>/dev/null | head -c 200)

        # Resolve description if it's a message reference
        if [[ "$description" == __MSG_* ]]; then
            description=""
        fi

        # Get Chrome Web Store URL
        store_url="https://chrome.google.com/webstore/detail/${ext_id}"

        extensions_json=$(echo "$extensions_json" | jq --arg id "$ext_id" --arg name "$ext_name" --arg ver "$version" --arg desc "$description" --arg url "$store_url" \
            '. + [{"id": $id, "name": $name, "version": $ver, "description": $desc, "store_url": $url}]')
    fi
done

echo "$extensions_json" | jq '.' > "$OUTPUT_DIR/extensions.json"
echo "  Found $(echo "$extensions_json" | jq 'length') extensions"

# ============================================================================
# Extract Spaces (Arc's profiles/workspaces)
# ============================================================================
echo "2. Extracting spaces (profiles)..."

sidebar_file="$ARC_DATA/StorableSidebar.json"
if [ -f "$sidebar_file" ]; then
    # Extract space data with names
    jq '[.sidebar.containers[1].spaces[] | select(type == "object") | {
        id: .id,
        title: .title,
        profile: (if .profile.default == true then "default" elif .profile.custom then .profile.custom._0.directoryBasename else "unknown" end),
        containerIDs: .containerIDs
    }]' "$sidebar_file" > "$OUTPUT_DIR/spaces.json" 2>/dev/null || echo "[]" > "$OUTPUT_DIR/spaces.json"

    space_count=$(jq 'length' "$OUTPUT_DIR/spaces.json")
    echo "  Found $space_count spaces:"
    jq -r '.[] | "    - \(.title) (\(.profile))"' "$OUTPUT_DIR/spaces.json"
fi

# ============================================================================
# Extract Tabs from LiveData
# ============================================================================
echo "3. Extracting tabs from live data..."

livedata_file="$ARC_DATA/StorableLiveData.json"
if [ -f "$livedata_file" ]; then
    # Extract all tabs from all profiles
    jq '[.liveDataPerProfile[] | select(type == "object") |
        .items[]? |
        select(.url != null) |
        .url._0
    ] | unique' "$livedata_file" > "$OUTPUT_DIR/tabs.json" 2>/dev/null || echo "[]" > "$OUTPUT_DIR/tabs.json"

    tab_count=$(jq 'length' "$OUTPUT_DIR/tabs.json")
    echo "  Found $tab_count unique tab URLs"
fi

# ============================================================================
# Extract Pinned Items from Sidebar
# ============================================================================
echo "4. Extracting pinned items..."

# The sidebar items are stored separately, we need to look at the full sidebar structure
jq '{
    items: [.sidebar.containers[1].items[] | select(type == "object")],
    itemCount: (.sidebar.containers[1].items | length)
}' "$sidebar_file" > "$OUTPUT_DIR/sidebar-items.json" 2>/dev/null || echo '{"items":[],"itemCount":0}' > "$OUTPUT_DIR/sidebar-items.json"

# ============================================================================
# Extract Bookmarks (Chrome format)
# ============================================================================
echo "5. Extracting bookmarks..."

bookmarks_file="$ARC_DATA/User Data/Default/Bookmarks"
if [ -f "$bookmarks_file" ]; then
    # Extract bookmarks in a cleaner format
    jq 'def extract_bookmarks:
        if type == "object" then
            if .type == "url" then
                [{name: .name, url: .url, date_added: .date_added}]
            elif .children then
                .children | map(extract_bookmarks) | flatten
            else
                []
            end
        else
            []
        end;
    .roots | to_entries | map(.value | extract_bookmarks) | flatten' "$bookmarks_file" > "$OUTPUT_DIR/bookmarks.json" 2>/dev/null || echo "[]" > "$OUTPUT_DIR/bookmarks.json"

    bookmark_count=$(jq 'length' "$OUTPUT_DIR/bookmarks.json")
    echo "  Found $bookmark_count bookmarks"
else
    echo "  No bookmarks file found"
    echo "[]" > "$OUTPUT_DIR/bookmarks.json"
fi

# ============================================================================
# Extract Settings (Preferences)
# ============================================================================
echo "6. Extracting preferences..."

prefs_file="$ARC_DATA/User Data/Default/Preferences"
if [ -f "$prefs_file" ]; then
    # Extract relevant settings
    jq '{
        search: {
            default_provider: .default_search_provider_data.template_url,
            short_name: .default_search_provider_data.short_name
        },
        download: {
            default_directory: .download.default_directory,
            prompt_for_download: .download.prompt_for_download
        },
        homepage: .homepage,
        startup: {
            urls: .session.startup_urls,
            restore_on_startup: .session.restore_on_startup
        }
    }' "$prefs_file" > "$OUTPUT_DIR/preferences.json" 2>/dev/null || echo "{}" > "$OUTPUT_DIR/preferences.json"
fi

# ============================================================================
# Extract Archive (Closed tabs history)
# ============================================================================
echo "7. Extracting archive/history..."

archive_file="$ARC_DATA/StorableArchiveItems.json"
if [ -f "$archive_file" ]; then
    jq '[to_entries[] |
        select(.key != "version") |
        .value |
        if type == "object" then
            to_entries[] |
            .value |
            if type == "array" then
                .[] |
                select(.savedURL != null) |
                {url: .savedURL, title: .savedTitle, timestamp: .archiveTimestamp}
            else empty end
        else empty end
    ] | sort_by(.timestamp) | reverse | .[0:200]' "$archive_file" > "$OUTPUT_DIR/archive.json" 2>/dev/null || echo "[]" > "$OUTPUT_DIR/archive.json"

    archive_count=$(jq 'length' "$OUTPUT_DIR/archive.json")
    echo "  Found $archive_count archived items (showing up to 200)"
fi

# ============================================================================
# Create Zen Browser Compatible Extensions List
# ============================================================================
echo "8. Creating Firefox/Zen extension mapping..."

# Map Chrome extension IDs to Firefox addon equivalents where known
cat > "$OUTPUT_DIR/zen-extensions-mapping.json" << 'EOF'
{
  "known_mappings": {
    "cjpalhdlnbpafiamejdnhcphjbkeiagm": {"firefox": "ublock-origin", "name": "uBlock Origin"},
    "dbepggeogbaibhgnhhndojpepiihcmeb": {"firefox": "vimium-ff", "name": "Vimium"},
    "eimadpbcbfnmbkopoojfekhnkhdbieeh": {"firefox": "darkreader", "name": "Dark Reader"},
    "aeblfdkhhhdcdjpifhhbdiojplfjncoa": {"firefox": "1password-x-password-manager", "name": "1Password"},
    "hlepfoohegkhhmjieoechaddaejaokhf": {"firefox": "refined-github-", "name": "Refined GitHub"},
    "fmkadmapgofadopljbjfkapdkoienihi": {"firefox": "react-devtools", "name": "React Developer Tools"},
    "lmhkpmbekcpmknklioeibfkpmmfibljd": {"firefox": "reduxdevtools", "name": "Redux DevTools"},
    "gppongmhjkpfnbhagpmjfkannfbllamg": {"firefox": "wappalyzer", "name": "Wappalyzer"}
  },
  "note": "Extensions without Firefox equivalents need manual research"
}
EOF

# ============================================================================
# Summary Report
# ============================================================================
echo
echo "=== Extraction Complete ==="
echo "Output files in: $OUTPUT_DIR"
echo
ls -lh "$OUTPUT_DIR"
echo
echo "=== Summary ==="
echo "Extensions: $(jq 'length' "$OUTPUT_DIR/extensions.json")"
echo "Spaces: $(jq 'length' "$OUTPUT_DIR/spaces.json")"
echo "Tabs: $(jq 'length' "$OUTPUT_DIR/tabs.json")"
echo "Bookmarks: $(jq 'length' "$OUTPUT_DIR/bookmarks.json")"
echo "Archive: $(jq 'length' "$OUTPUT_DIR/archive.json")"
echo
echo "=== Extensions List ==="
jq -r '.[] | "  - \(.name) (\(.id))"' "$OUTPUT_DIR/extensions.json"
echo
echo "=== Spaces ==="
jq -r '.[] | "  - \(.title) (profile: \(.profile))"' "$OUTPUT_DIR/spaces.json"
