#!/bin/bash
# =====================================================
# OVERSEER PINATA AUTO-DEPLOY MODULE
# Uploads Hugo /public folder to IPFS via Pinata API
# =====================================================

# CONFIG — Replace with your Pinata API keys
export PINATA_API_KEY="fbb4e4ac5ffcbbaa47f3"
export PINATA_SECRET_KEY="9c09b649d7b3e9a01c0c930de9fd91d3cac6790b06f6fae7963e4315e8601f5e"
PUBLIC_DIR="/c/Users/Nefs/Projects/CompendiumSite/public"
LOG_FILE="/c/Users/Nefs/Projects/CompendiumSite/pinata_deploy_log.txt"

# STEP 1: Build Hugo site
echo "[1/4] Building Hugo site..." -e 34
cd /c/Users/Nefs/Projects/CompendiumSite
C:/Program\ Files/Hugo/hugo.exe --gc --minify
echo "[1/4] Hugo build complete." -e 32

# STEP 2: Collect all files from /public
echo "[2/4] Collecting files from /public..." -e 34
FILES=$(find "$PUBLIC_DIR" -type f)
TOTAL_FILES=$(echo "$FILES" | wc -l)
echo "[2/4] Found $TOTAL_FILES files." -e 32

# STEP 3: Build multipart form and upload via API
echo "[3/4] Uploading to Pinata API..." -e 34

BOUNDARY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Create temp directory for multipart
TEMP_DIR=$(mktemp -d)
OPTIONS_JSON='{"wrapWithDirectory": true}'
echo "$OPTIONS_JSON" > "$TEMP_DIR/options.txt"

# Create multipart boundary
echo "" > "$TEMP_DIR/boundary.txt"
echo "$BOUNDARY" > "$TEMP_DIR/boundary.txt"

# Build multipart body
{
  # Start multipart
  echo --"$BOUNDARY"
  echo "Content-Disposition: form-data; name=\"pinataOptions\""
  echo ""
  cat "$TEMP_DIR/options.txt"
  echo ""
  
  # Add each file
  echo "$FILES" | while read -r file; do
    [ -z "$file" ] && continue
    REL_PATH="${file#$PUBLIC_DIR/}"
    FILE_BYTES=$(base64 -i "$file")
    
    echo ""
    echo "--$BOUNDARY"
    echo "Content-Disposition: form-data; name=\"file\"; filename=\"$REL_PATH\""
    echo "Content-Type: application/octet-stream"
    echo ""
    echo "$FILE_BYTES" | base64 -d
  done
  
  # End multipart
  echo ""
  echo --"$BOUNDARY"--
} > "$TEMP_DIR/body.txt"

# Convert to proper multipart format
cat "$TEMP_DIR/body.txt" > "$TEMP_DIR/final_body.txt"

# Upload via cURL
URL="https://api.pinata.cloud/pinning/pinFileToIPFS"
HEADERS="pinata_api_key: $PINATA_API_KEY
pinata_secret_api_key: $PINATA_SECRET_KEY"

RESPONSE=$(curl -s -X POST "$URL" \
  -H "Content-Type: multipart/form-data; boundary=$BOUNDARY" \
  -H "$HEADERS" \
  --data-binary "@$TEMP_DIR/body.txt")

# Extract CID
CID=$(echo "$RESPONSE" | grep -o '"IpfsHash":"[^"]*"' | cut -d'"' -f4)

if [ -n "$CID" ]; then
  echo "[3/4] Upload complete! CID: $CID" -e 32
  
  # STEP 4: Log result
  echo "$TIMESTAMP | CID: $CID | Files: $TOTAL_FILES" >> "$LOG_FILE"
  echo "[4/4] Done." -e 32
  
  # OUTPUT
  echo ""
  echo "========================================" -e 36
  echo "  DEPLOYMENT SUCCESSFUL" -e 36
  echo "========================================" -e 36
  echo "  CID: $CID"
  echo "  Gateway: https://teal-calm-roundworm-152.mypinata.cloud/ipfs/$CID"
  echo "  Files uploaded: $TOTAL_FILES"
  echo "  Logged to: $LOG_FILE"
  echo "========================================" -e 36
else
  echo "[ERROR] Upload failed!" -e 31
  echo "$RESPONSE"
fi

# Cleanup
rm -rf "$TEMP_DIR"
