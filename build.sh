#!/bin/bash
# cc-menubar build script
# Compiles the menubar app into a single binary with swiftc.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/.build"
BINARY="$BUILD_DIR/cc-menubar"
SOURCES=("$SCRIPT_DIR"/Sources/*.swift)

echo "▶ Building cc-menubar..."
echo "  sources: ${SOURCES[*]}"
echo "  output:  $BINARY"

mkdir -p "$BUILD_DIR"

swiftc \
    -O \
    -framework Cocoa \
    -framework Foundation \
    -target arm64-apple-macosx13.0 \
    "${SOURCES[@]}" \
    -o "$BINARY"

chmod +x "$BINARY"

echo ""
echo "✅ Build complete"
echo "  binary: $BINARY"
echo "  size:   $(du -sh "$BINARY" | cut -f1)"
echo ""
echo "Run it:"
echo "  $BINARY &"
echo ""
echo "Or install as a login-item LaunchAgent:"
echo "  bash install.sh"
