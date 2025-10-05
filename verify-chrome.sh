#!/bin/bash
# Verify Chrome/Chromium installation in bytebot-desktop

echo "🔍 Checking Chrome/Chromium installation in bytebot-desktop..."
echo ""

# Check if container is running
if ! docker ps | grep -q bytebot-desktop; then
    echo "❌ bytebot-desktop container is not running!"
    echo "   Run: docker-compose up -d"
    exit 1
fi

# Check architecture
ARCH=$(docker exec bytebot-desktop dpkg --print-architecture)
echo "📦 Architecture: $ARCH"
echo ""

# Check for Chrome/Chromium
if docker exec bytebot-desktop test -f /usr/bin/google-chrome; then
    VERSION=$(docker exec bytebot-desktop google-chrome --version 2>/dev/null || echo "Unable to get version")
    echo "✅ Chrome/Chromium is installed!"
    echo "   Binary: /usr/bin/google-chrome"
    echo "   Version: $VERSION"
    echo ""
    
    # Check symlink
    REAL_PATH=$(docker exec bytebot-desktop readlink -f /usr/bin/google-chrome)
    echo "   Real path: $REAL_PATH"
else
    echo "❌ Chrome/Chromium is NOT installed!"
    echo "   The build may have failed. Check logs with: docker logs bytebot-desktop"
fi

echo ""
echo "📝 To view desktop and test Chrome:"
echo "   Open: http://localhost:9990/vnc"
echo "   Look for Chrome/Chromium icon on desktop"
