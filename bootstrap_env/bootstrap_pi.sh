#!/bin/bash

set -e  # Exit on error

echo "=========================================="
echo "Pi by Earendil Works - Node.js Installer"
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
PI_DIR="$HOME/pi-workspace"
CONFIG_FILE="$PI_DIR/pi/config.json"

# Verify Node version
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
echo -e "${GREEN}Node.js $NODE_VERSION installed.${NC}"
echo -e "${GREEN}npm $NPM_VERSION installed.${NC}"

# Step 2: Prepare Workspace
echo -e "${YELLOW}[2/5] Preparing workspace...${NC}"
mkdir -p "$PI_DIR"
cd "$PI_DIR"

# Clone if not already present
if [ ! -d "pi" ]; then
    git clone https://github.com/earendil-works/pi.git
fi

cd "$PI_DIR/pi"

# Step 3: Install Dependencies
echo -e "${YELLOW}[3/5] Installing Pi dependencies...${NC}"
npm install

# Step 4: Create Configuration File
echo -e "${YELLOW}[4/5] Creating Pi configuration...${NC}"

# Pi usually looks for config in .pi/ or config.json in the root
# We'll create it in the root and also check .pi/ directory
mkdir -p .pi

cat > "$CONFIG_FILE" <<EOF
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

echo -e "${BLUE}Configuration saved to: $CONFIG_FILE${NC}"

# Also copy to .pi/ directory if that's where Pi expects it
cp "$CONFIG_FILE" ".pi/config.json"
echo -e "${BLUE}Configuration also copied to: .pi/config.json${NC}"

# Step 5: Verify and Test
echo -e "${YELLOW}[5/5] Verifying installation...${NC}"

# Check if the pi command is available (it should be in node_modules/.bin)
if [ -f "node_modules/.bin/pi" ]; then
    echo -e "${GREEN}✅ Pi binary found: node_modules/.bin/pi${NC}"
else
    echo -e "${RED}❌ Pi binary not found. Check npm install output.${NC}"
    exit 1
fi

# Verify config JSON
if node -e "JSON.parse(require('fs').readFileSync('$CONFIG_FILE', 'utf8'))" 2>/dev/null; then
    echo -e "${GREEN}✅ Configuration file is valid JSON.${NC}"
else
    echo -e "${RED}❌ Configuration file is invalid JSON.${NC}"
    exit 1
fi

# Verify connectivity to llama-cpp
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
echo "  1. Navigate to the Pi directory:"
echo "     cd $PI_DIR/pi"
echo ""
echo "  2. Run Pi (try one of these):"
echo "     npx pi"
echo "     ./node_modules/.bin/pi"
echo ""
echo "  3. If Pi asks for a model, select the one matching:"
echo "     $LLAMA_MODEL_ID"
echo ""
echo "⚠️  Troubleshooting:"
echo "   - If 'npx pi' fails, try: node ./node_modules/pi/bin/pi.js"
echo "   - Check config: cat config.json"
echo "   - Check connectivity: curl $LLAMA_BASE_URL/models"
echo "=========================================="

