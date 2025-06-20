#!/bin/bash

# FlexDocs Sync Script
# Double-click to pull files, or run with 'push' to upload

API_URL="https://your-flexdocs-site.netlify.app/.netlify/functions/api"
API_KEY="demo-key-123"
PROJECT_ROOT="$(dirname "$0")"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}FlexDocs Sync Script${NC}"
echo "Project root: $PROJECT_ROOT"
echo ""

if [ "$1" = "push" ]; then
    # Push mode - upload all CLAUDE*.md files
    echo -e "${BLUE}Scanning for CLAUDE*.md files...${NC}"
    
    # Create JSON array of files
    json_files="["
    first=true
    
    while IFS= read -r -d '' file; do
        # Get relative path
        rel_path="${file#$PROJECT_ROOT/}"
        
        # Read file content
        content=$(cat "$file" | jq -Rs .)
        
        if [ "$first" = true ]; then
            first=false
        else
            json_files+=","
        fi
        
        json_files+="{\"path\":\"$rel_path\",\"content\":$content}"
        echo "  Found: $rel_path"
    done < <(find "$PROJECT_ROOT" -name "CLAUDE*.md" -type f -print0)
    
    json_files+="]"
    
    # Upload files
    echo -e "\n${BLUE}Uploading files...${NC}"
    
    response=$(curl -s -X POST "$API_URL/files" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $API_KEY" \
        -d "{\"files\":$json_files}")
    
    if echo "$response" | grep -q "results"; then
        echo -e "${GREEN}✓ Files uploaded successfully!${NC}"
    else
        echo -e "${RED}✗ Upload failed${NC}"
        echo "$response"
    fi
    
else
    # Pull mode - download all files
    echo -e "${BLUE}Downloading files from cloud...${NC}"
    
    response=$(curl -s -X GET "$API_URL/files" \
        -H "x-api-key: $API_KEY")
    
    if echo "$response" | grep -q "files"; then
        # Parse and save files
        echo "$response" | jq -r '.files[] | @base64' | while read -r file_data; do
            # Decode the file data
            file_json=$(echo "$file_data" | base64 -d)
            
            # Extract path and content
            path=$(echo "$file_json" | jq -r '.path')
            content=$(echo "$file_json" | jq -r '.content')
            
            # Create full path
            full_path="$PROJECT_ROOT/$path"
            
            # Create directory if needed
            mkdir -p "$(dirname "$full_path")"
            
            # Write file
            echo "$content" > "$full_path"
            echo -e "  ${GREEN}✓${NC} Downloaded: $path"
        done
        
        echo -e "\n${GREEN}✓ All files downloaded successfully!${NC}"
    else
        echo -e "${RED}✗ Download failed${NC}"
        echo "$response"
    fi
fi

echo -e "\n${BLUE}Done!${NC}"

# Keep terminal open on macOS when double-clicked
if [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
    read -p "Press Enter to close..."
fi