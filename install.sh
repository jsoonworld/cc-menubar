#!/usr/bin/env bash
# cc-menubar installer
# Usage: bash install.sh [--install-dir <path>]
#
# Default install path: ~/Applications/cc-menubar/
# LaunchAgent:          ~/Library/LaunchAgents/io.github.sangrokjung.cc-menubar.plist

set -euo pipefail

# ── colored output helpers ─────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ── paths ──────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${HOME}/Applications/cc-menubar"

# arg parsing (--install-dir)
while [[ $# -gt 0 ]]; do
    case "$1" in
        --install-dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: bash install.sh [--install-dir <path>]"
            echo "Default install path: ~/Applications/cc-menubar"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# The binary may live next to this script (release archive) or under .build/ (fresh build).
if [[ -f "${SCRIPT_DIR}/cc-menubar" ]]; then
    BINARY_SRC="${SCRIPT_DIR}/cc-menubar"
elif [[ -f "${SCRIPT_DIR}/.build/cc-menubar" ]]; then
    BINARY_SRC="${SCRIPT_DIR}/.build/cc-menubar"
else
    BINARY_SRC="${SCRIPT_DIR}/cc-menubar"
fi
BINARY_DST="${INSTALL_DIR}/cc-menubar"
PLIST_TEMPLATE="${SCRIPT_DIR}/io.github.sangrokjung.cc-menubar.plist.template"
LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"
PLIST_DST="${LAUNCH_AGENTS_DIR}/io.github.sangrokjung.cc-menubar.plist"
LABEL="io.github.sangrokjung.cc-menubar"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " cc-menubar installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── 1. prerequisites ───────────────────────────
info "Checking prerequisites..."

if [[ "$(uname)" != "Darwin" ]]; then
    error "cc-menubar is macOS only."
    exit 1
fi

if [[ ! -f "${BINARY_SRC}" ]]; then
    error "Binary not found: ${BINARY_SRC}"
    error "Run ./build.sh first, or run this installer from the release folder."
    exit 1
fi

if [[ ! -f "${PLIST_TEMPLATE}" ]]; then
    warn "plist template missing: ${PLIST_TEMPLATE}"
    warn "Skipping LaunchAgent registration — register it manually."
    SKIP_LAUNCHAGENT=1
else
    SKIP_LAUNCHAGENT=0
fi

success "Prerequisites OK"

# ── 2. strip Gatekeeper quarantine (unsigned binary) ──
info "Removing quarantine attribute from unsigned binary..."

if xattr -l "${BINARY_SRC}" 2>/dev/null | grep -q "com.apple.quarantine"; then
    xattr -d com.apple.quarantine "${BINARY_SRC}" 2>/dev/null || true
    success "Quarantine attribute removed"
else
    info "No quarantine attribute — skipping"
fi

# ── 3. install the binary ──────────────────────
info "Installing binary: ${BINARY_DST}"

mkdir -p "${INSTALL_DIR}"
cp -f "${BINARY_SRC}" "${BINARY_DST}"
chmod +x "${BINARY_DST}"

# re-strip quarantine (cp may inherit it)
xattr -d com.apple.quarantine "${BINARY_DST}" 2>/dev/null || true

success "Binary installed: ${BINARY_DST}"

# ── 4. create + load the LaunchAgent ───────────
if [[ "${SKIP_LAUNCHAGENT:-0}" == "1" ]]; then
    warn "LaunchAgent registration skipped"
else
    info "Creating LaunchAgent plist..."

    mkdir -p "${LAUNCH_AGENTS_DIR}"

    # substitute the __INSTALL_DIR__ placeholder (BSD sed / macOS)
    sed "s|__INSTALL_DIR__|${INSTALL_DIR}|g" "${PLIST_TEMPLATE}" > "${PLIST_DST}"

    success "plist created: ${PLIST_DST}"

    # unload any existing daemon
    if launchctl list "${LABEL}" &>/dev/null; then
        info "Unloading existing LaunchAgent..."
        launchctl unload "${PLIST_DST}" 2>/dev/null || true
    fi

    info "Registering LaunchAgent..."
    if launchctl load -w "${PLIST_DST}"; then
        success "LaunchAgent registered — cc-menubar starts on login"
    else
        error "LaunchAgent registration failed"
        error "Load it manually: launchctl load -w ${PLIST_DST}"
        exit 1
    fi
fi

# ── 5. summary ─────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Installation complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Installed:   ${BINARY_DST}"
if [[ "${SKIP_LAUNCHAGENT:-0}" == "0" ]]; then
    echo "  LaunchAgent: ${PLIST_DST}"
fi
echo ""
echo "  If the menubar icon (⚡) does not appear, start it manually:"
echo "    ${BINARY_DST} &"
echo ""
echo "  To uninstall:"
echo "    launchctl unload ${PLIST_DST}"
echo "    rm -rf ${INSTALL_DIR}"
echo "    rm ${PLIST_DST}"
echo ""

# ── 6. Gatekeeper note ─────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " ⚠️  Unsigned app"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  cc-menubar is not signed with an Apple Developer certificate."
echo "  If Gatekeeper blocks it, allow it with one of:"
echo ""
echo "  A (recommended — Terminal):"
echo "    xattr -d com.apple.quarantine ${BINARY_DST}"
echo ""
echo "  B (System Settings):"
echo "    System Settings → Privacy & Security → under the Security section,"
echo "    click \"Open Anyway\" for cc-menubar."
echo ""
