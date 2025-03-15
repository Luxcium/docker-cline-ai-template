#!/bin/bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to replace placeholders in a file
replace_placeholders() {
    local file="$1"
    echo -e "${BLUE}Processing: ${file}${NC}"
    
    # Replace placeholders with provided values
    sed -i "s/{{projectName}}/${PROJECT_NAME}/g" "$file"
    sed -i "s/{{projectDescription}}/${PROJECT_DESCRIPTION}/g" "$file"
    sed -i "s/{{authorName}}/${AUTHOR_NAME}/g" "$file"
    sed -i "s/{{authorEmail}}/${AUTHOR_EMAIL}/g" "$file"
    sed -i "s/{{repositoryUrl}}/${REPOSITORY_URL}/g" "$file"
    sed -i "s/{{license}}/${LICENSE}/g" "$file"
    sed -i "s/{{port}}/${PORT}/g" "$file"
    
    # Handle Docker support sections
    if [ "$DOCKER_SUPPORT" = "true" ]; then
        sed -i "s/{{#if dockerSupport}}//" "$file"
        sed -i "s/{{\/if}}//" "$file"
    else
        sed -i "/{{#if dockerSupport}}/,/{{\/if}}/d" "$file"
    fi
}

# Function to process all files in a directory recursively
process_directory() {
    local dir="$1"
    
    # Process each file in the directory
    for file in "$dir"/*; do
        if [ -f "$file" ]; then
            replace_placeholders "$file"
        elif [ -d "$file" ]; then
            process_directory "$file"
        fi
    done
}

# Function to initialize git repository
init_git() {
    echo -e "${BLUE}Initializing Git repository...${NC}"
    git init
    git add .
    git commit -m "Initial commit"
    echo -e "${GREEN}Git repository initialized${NC}"
}

# Function to setup development environment
setup_dev_environment() {
    echo -e "${BLUE}Setting up development environment...${NC}"
    
    # Create VSCode directory
    mkdir -p .vscode
    
    # Setup Docker if enabled
    if [ "$DOCKER_SUPPORT" = "true" ]; then
        echo -e "${BLUE}Setting up Docker environment...${NC}"
        # Docker setup logic here
    fi
    
    echo -e "${GREEN}Development environment configured${NC}"
}

# Main bootstrap function
bootstrap() {
    echo -e "${BLUE}🚀 Starting project bootstrap...${NC}"
    
    # Ensure required variables are set
    if [ -z "$PROJECT_NAME" ] || [ -z "$PROJECT_DESCRIPTION" ]; then
        echo -e "${RED}Error: PROJECT_NAME and PROJECT_DESCRIPTION must be set${NC}"
        exit 1
    fi
    
    # Process template files
    process_directory "$(pwd)"
    
    # Initialize Git repository
    init_git
    
    # Setup development environment
    setup_dev_environment
    
    echo -e "${GREEN}✨ Project ${PROJECT_NAME} has been bootstrapped successfully!${NC}"
}

# Default values
export PROJECT_NAME="{{projectName}}"
export PROJECT_DESCRIPTION="{{projectDescription}}"
export AUTHOR_NAME="{{authorName}}"
export AUTHOR_EMAIL="{{authorEmail}}"
export REPOSITORY_URL="{{repositoryUrl}}"
export LICENSE="{{license}}"
export DOCKER_SUPPORT="{{dockerSupport}}"
export PORT="{{port}}"

# Execute bootstrap
bootstrap
