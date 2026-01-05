#!/usr/bin/env bash

# Interactive script to create a new writing post with Hugo.

set -euo pipefail

WEBSITE_DIR="$( cd "$(dirname "$0")/.." >/dev/null 2>&1 ; pwd -P )"
cd "$WEBSITE_DIR"

echo "Creating a new writing post..."
echo ""

# Get the title to generate the slug
read -rp "Title (for slug generation): " title

# Get the date (default to today)
today=$(date +%Y-%m-%d)
read -rp "Date [$today]: " date_input
date=${date_input:-$today}

# Generate slug from date and title
slug_title=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
slug="${date}-${slug_title}"

# Create the post using Hugo
hugo new "writing/${slug}/index.md"

echo ""
echo "Created: content/writing/${slug}/index.md"
echo "Don't forget to fill in the description and tags!"
