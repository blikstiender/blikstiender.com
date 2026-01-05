#!/usr/bin/env bash

# Check that every markdown file in the writing directory has proper front matter and structure.
# Required front matter: tags, slug, date, description, title
# Required structure: title heading followed by date after front matter
#
# You best believe my friend Claude wrote this puppy up in no time. No way in cold hell I
# would/could write bash like this myself, sadly.

set -euo pipefail

WEBSITE_DIR="$( cd "$(dirname "$0")/.." >/dev/null 2>&1 ; pwd -P )"
WRITING_DIR="$WEBSITE_DIR/content/writing"

all_passed=true

# Check required front matter fields exist
check_front_matter() {
    local file="$1"
    local errors=()

    # Check front matter exists (starts with ---)
    if ! head -1 "$file" | grep -q "^---$"; then
        errors+=("missing front matter")
    else
        # Extract front matter (between first and second ---)
        front_matter=$(sed -n '1,/^---$/p' "$file" | tail -n +2)

        for field in tags slug date description title; do
            if ! echo "$front_matter" | grep -q "^${field}:"; then
                errors+=("missing front matter field: $field")
            fi
        done
    fi

    # Return errors via stdout
    printf '%s\n' "${errors[@]}"
}

# Check for title heading followed by date after front matter.
# This check is easier to implement due to the way "Bear Theme" is set up - this was easier than
# just overriding the blog theme itself. Plus I like the flexibility.
check_title_and_date() {
    local file="$1"
    local errors=()

    # Get content after front matter (skip first line ---, then skip until next ---)
    content_after_fm=$(tail -n +2 "$file" | sed '1,/^---$/d')

    # First non-empty line should be a title (# ...)
    first_line=$(echo "$content_after_fm" | grep -m1 "^#" || true)
    if [[ -z "$first_line" ]]; then
        errors+=("missing title heading after front matter")
    fi

    # Second non-empty line should be a date (*date*)
    second_line=$(echo "$content_after_fm" | grep -m1 "^\*" || true)
    if [[ -z "$second_line" ]] || ! echo "$second_line" | grep -qE "^\*[A-Za-z]+ [0-9]+, [0-9]+\*$"; then
        errors+=("missing or malformed date line after title (expected format: *Month DD, YYYY*)")
    fi

    # Return errors via stdout
    printf '%s\n' "${errors[@]}"
}

for file in "$WRITING_DIR"/*/*.md; do
    # Skip _index.md files
    if [[ "$(basename "$file")" == "_index.md" ]]; then
        continue
    fi

    # Extract title from front matter for display
    title=$(grep -m1 "^title:" "$file" | sed 's/^title:[[:space:]]*//' | sed 's/^["'"'"']//' | sed 's/["'"'"']$//')

    if [[ -z "$title" ]]; then
        title="(no title found)"
    fi

    # Collect all errors
    errors=()

    while IFS= read -r err; do
        [[ -n "$err" ]] && errors+=("$err")
    done < <(check_front_matter "$file")

    while IFS= read -r err; do
        [[ -n "$err" ]] && errors+=("$err")
    done < <(check_title_and_date "$file")

    # Print result
    if [[ ${#errors[@]} -eq 0 ]]; then
        echo "✓ $title"
    else
        echo "✗ $title"
        for err in "${errors[@]}"; do
            echo "    - $err"
        done
        all_passed=false
    fi
done

if $all_passed; then
    echo ""
    echo "All checks passed!"
    exit 0
else
    echo ""
    echo "Some checks failed."
    exit 1
fi
