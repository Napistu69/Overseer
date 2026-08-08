#!/bin/bash
# =====================================================
# IONOS FTP DEPLOYMENT
# Uploads Hugo /public folder to IONOS web root
# =====================================================

PUBLIC_DIR="/c/Users/Nefs/Projects/CompendiumSite/public"
IONOS_HOST="ftp.yourionos-host.com"
IONOS_USER="your-ftp-username"
IONOS_PASS="your-ftp-password"
IONOS_WEB_ROOT="/your-web-root-path"

echo "╔══════════════════════════════════════════════════════════╗"
echo "║   IONOS FTP DEPLOYMENT                                  ║"
echo "╚══════════════════════════════════════════════════════════╝"

# STEP 1: Build Hugo site
echo ""
echo "[1/3] Building Hugo site..."
cd /c/Users/Nefs/Projects/CompendiumSite
C:/Program\ Files/Hugo/hugo.exe --gc --minify
echo "[1/3] Build complete."

# STEP 2: Upload via lftp (resumable, parallel)
echo ""
echo "[2/3] Uploading to IONOS via lftp..."
echo "Server: $IONOS_HOST"
echo "User: $IONOS_USER"
echo "Web Root: $IONOS_WEB_ROOT"
echo ""

lftp $IONOS_HOST -u $IONOS_USER,$IONOS_PASS << EOF
set ftp:passive-mode yes
set ftp:retrieve-retries 3
mirror -R $PUBLIC_DIR $IONOS_WEB_ROOT --verbose
bye
EOF

# STEP 3: Verify upload
echo ""
echo "[3/3] Verifying upload..."
echo ""
echo "Upload complete! Files uploaded from:"
echo "  Source: $PUBLIC_DIR"
echo "  Target: ftp://$IONOS_USER@$IONOS_HOST$IONOS_WEB_ROOT"
echo ""
echo "View your site: http://napisnest.com"
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  DEPLOYMENT COMPLETE"
echo "════════════════════════════════════════════════════════════"
