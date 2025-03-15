#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Setting up {{projectName}}...${NC}"

# Create necessary directories
echo -e "\n${BLUE}📁 Creating project directories...${NC}"
mkdir -p logs
mkdir -p src/tests

# Initialize Git hooks
echo -e "\n${BLUE}🔧 Setting up Git hooks...${NC}"
npm install husky --save-dev
npx husky install
npx husky add .husky/pre-commit "npm run lint"
npx husky add .husky/pre-push "npm test"

# Install dependencies
echo -e "\n${BLUE}📦 Installing dependencies...${NC}"
if [ -f "package.json" ]; then
    npm install
else
    echo -e "${RED}❌ package.json not found${NC}"
    exit 1
fi

# Create .env file from example if it doesn't exist
echo -e "\n${BLUE}📝 Setting up environment variables...${NC}"
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    cp .env.example .env
    echo -e "${GREEN}✅ Created .env file from .env.example${NC}"
fi

{{#if dockerSupport}}
# Docker setup
echo -e "\n${BLUE}🐳 Setting up Docker environment...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo "Please install Docker to use containerized development"
else
    docker compose build
    echo -e "${GREEN}✅ Docker environment configured${NC}"
fi
{{/if}}

# Initialize test setup
echo -e "\n${BLUE}🧪 Setting up testing environment...${NC}"
cat > src/tests/example.test.js << 'EOF'
describe('Example Test', () => {
  it('should pass', () => {
    expect(true).toBe(true);
  });
});
EOF

# Set up VS Code settings
echo -e "\n${BLUE}⚙️ Configuring VS Code settings...${NC}"
mkdir -p .vscode
cat > .vscode/settings.json << EOF
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "javascript.format.enable": false,
  "editor.defaultFormatter": "esbenp.prettier-vscode"
}
EOF

# Create first git commit
echo -e "\n${BLUE}📝 Creating initial commit...${NC}"
git add .
git commit -m "🎉 Initial commit"

echo -e "\n${GREEN}✨ Setup complete!${NC}"
echo -e "\n${BLUE}Next steps:${NC}"
echo -e "1. Review the .env file and update values as needed"
{{#if dockerSupport}}
echo -e "2. Run 'docker compose up' to start the development environment"
{{else}}
echo -e "2. Run 'npm run dev' to start the development server"
{{/if}}
echo -e "3. Visit http://localhost:{{port}} to see your app"

# Make the script executable
chmod +x setup.sh
