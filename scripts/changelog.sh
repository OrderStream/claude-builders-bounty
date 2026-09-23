#!/bin/bash
# changelog.sh - Auto-generates a structured CHANGELOG.md from git history

# Get the last git tag, or fallback to the very first commit if no tags exist
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD 2>/dev/null)

if [ -z "$LAST_TAG" ]; then
    RANGE="HEAD"
else
    RANGE="${LAST_TAG}..HEAD"
fi

# Initialize categories
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""

# Read commits and categorize them based on Conventional Commits format
while IFS= read -r line; do
    if [[ -z "$line" ]]; then continue; fi
    
    if echo "$line" | grep -qiE "^(feat|add)"; then
        ADDED="${ADDED}- ${line}\n"
    elif echo "$line" | grep -qiE "^(fix|bug)"; then
        FIXED="${FIXED}- ${line}\n"
    elif echo "$line" | grep -qiE "^(remove|drop|delete)"; then
        REMOVED="${REMOVED}- ${line}\n"
    else
        CHANGED="${CHANGED}- ${line}\n"
    fi
done <<< "$(git log $RANGE --pretty=format:"%s (%h)" 2>/dev/null)"

# Write the formatted output directly to CHANGELOG.md
{
    echo "# 📝 Changelog"
    echo "*Changes since ${LAST_TAG:-"initial commit"}*"
    echo ""
    echo "### ✨ Added"
    echo -e "${ADDED:-"- None"}"
    echo "### 🐛 Fixed"
    echo -e "${FIXED:-"- None"}"
    echo "### ♻️ Changed"
    echo -e "${CHANGED:-"- None"}"
    echo "### 🗑️ Removed"
    echo -e "${REMOVED:-"- None"}"
} > CHANGELOG.md

echo "✅ CHANGELOG.md has been generated successfully!"
