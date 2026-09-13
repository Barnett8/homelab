#!/bin/bash

set -e  # Exit on error

echo "=========================================="
echo "Pi by Earendil Works - Installer"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration Values
LLAMA_BASE_URL="http://192.168.0.102:8080/v1"
LLAMA_MODEL_ID="unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_XL"
PI_AGENT_DIR="$HOME/.pi/agent"
MODELS_FILE="$PI_AGENT_DIR/models.json"
KEYBINDINGS_FILE="$PI_AGENT_DIR/keybindings.json"
NPM_PREFIX="$HOME/.local"
PI_BIN_DIR="$NPM_PREFIX/bin"

# Install Pi non-interactively
# We call npm directly (rather than piping install.sh through sh) so this
# never blocks on a confirmation prompt. This mirrors exactly what the
# official installer runs when npm's global prefix isn't writable.
echo -e "${YELLOW}Installing Pi...${NC}"

if ! command -v node >/dev/null 2>&1; then
    echo -e "${RED}❌ Node.js not found. Run bootstrap_apt.sh (or install Node \u226520.6.0) first.${NC}"
    exit 1
fi

npm install -g --ignore-scripts --min-release-age=0 --prefix "$NPM_PREFIX" @earendil-works/pi-coding-agent

# Ensure the install location is on PATH, now and in future shells
echo -e "${YELLOW}Configuring PATH...${NC}"

PATH_LINE="export PATH=\"$PI_BIN_DIR:\$PATH\""
if ! grep -qsF "$PATH_LINE" "$HOME/.bashrc" 2>/dev/null; then
    echo "$PATH_LINE" >> "$HOME/.bashrc"
    echo -e "${BLUE}Added $PI_BIN_DIR to PATH in ~/.bashrc${NC}"
else
    echo -e "${BLUE}~/.bashrc already has $PI_BIN_DIR on PATH${NC}"
fi

# Apply to this script's current shell too, so verification below works
# without requiring a restart.
export PATH="$PI_BIN_DIR:$PATH"

if ! command -v pi >/dev/null 2>&1; then
    echo -e "${RED}❌ pi command not found even after updating PATH. Check $PI_BIN_DIR exists.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Pi installed: $(pi --version 2>/dev/null || echo 'version check unavailable')${NC}"

# Write custom provider config
echo -e "${YELLOW}Configuring llama-cpp provider...${NC}"
mkdir -p "$PI_AGENT_DIR"

cat > "$MODELS_FILE" <<EOF
{
  "providers": {
    "llama-cpp": {
      "baseUrl": "$LLAMA_BASE_URL",
      "api": "openai-completions",
      "apiKey": "none",
      "models": [
        {
          "id": "$LLAMA_MODEL_ID",
          "reasoning": true,
          "thinkingLevelMap": {
            "minimal": null,
            "low": "low",
            "medium": "medium",
            "high": null,
            "xhigh": "xhigh"
          }
        }
      ]
    }
  }
}
EOF

echo -e "${BLUE}Provider config saved to: $MODELS_FILE${NC}"

# Install packages and customize keybindings
echo -e "${YELLOW}Installing packages and keybindings...${NC}"

pi install git:github.com/DietrichGebert/ponytail
pi install npm:@aprimediet/permission-modes

cat > "$KEYBINDINGS_FILE" <<'EOF'
{
  "app.thinking.cycle": [
    "alt+t"
  ]
}
EOF

echo -e "${BLUE}Packages installed (ponytail, permission-modes); thinking keybind set to alt+t${NC}"

# Verify
echo -e "${YELLOW}Verifying setup...${NC}"

if node -e "JSON.parse(require('fs').readFileSync('$MODELS_FILE', 'utf8')); JSON.parse(require('fs').readFileSync('$KEYBINDINGS_FILE', 'utf8'))" 2>/dev/null; then
    echo -e "${GREEN}✅ models.json and keybindings.json are valid JSON.${NC}"
else
    echo -e "${RED}❌ models.json is invalid JSON.${NC}"
    exit 1
fi

echo -e "${YELLOW}Checking connectivity to $LLAMA_BASE_URL...${NC}"
if curl -s --max-time 5 "$LLAMA_BASE_URL/models" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Connection to model server successful!${NC}"
else
    echo -e "${RED}⚠️  Could not reach $LLAMA_BASE_URL. Ensure llama-cpp is running.${NC}"
fi

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo "To use Pi:"
echo ""
echo "  1. Run it from any directory (new shells pick up PATH automatically):"
echo "     pi"
echo ""
echo "  2. Select your model with /model, matching:"
echo "     $LLAMA_MODEL_ID"
echo ""
echo "⚠️  Troubleshooting:"
echo "   - If 'pi' isn't found in a shell that predates this script, run:"
echo "     source ~/.bashrc"
echo "   - Check provider config: cat $MODELS_FILE
  - Check installed packages: pi list"
echo "   - Check connectivity: curl $LLAMA_BASE_URL/models"
echo "   - Global settings live at: $PI_AGENT_DIR/settings.json"
echo "=========================================="
