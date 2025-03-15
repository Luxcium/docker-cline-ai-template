#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

replace_placeholders() {
local file="$1"
echo -e "${BLUE}Processing: ${file}${NC}"
sed -i "s/{{projectName}}/${PROJECT_NAME}/g" "$file"
sed -i "s/{{projectDescription}}/${PROJECT_DESCRIPTION}/g" "$file"
sed -i "s/{{authorName}}/${AUTHOR_NAME}/g" "$file"
sed -i "s/{{authorEmail}}/${AUTHOR_EMAIL}/g" "$file"
sed -i "s/{{repositoryUrl}}/${REPOSITORY_URL}/g" "$file"
sed -i "s/{{license}}/${LICENSE}/g" "$file"
sed -i "s/{{port}}/${PORT}/g" "$file"
if [ "$DOCKER_SUPPORT" = "true" ]; then
    sed -i "s/{{#if dockerSupport}}//" "$file"
    sed -i "s/{{\/if}}//" "$file"
else
    sed -i "/{{#if dockerSupport}}/,/{{\/if}}/d" "$file"
fi
}

process_directory() {
local dir=$1
for file in "$dir"/*; do
    if [ -f "$file" ]; then
        replace_placeholders "$file"
    elif [ -d "$file" ]; then
        process_directory "$file"
    fi
done
}

init_git() {
git init
git add .
git commit -m "Initial commit"
echo -e "${GREEN}Git repository initialized${NC}"
}

init_conda_env() {
if ! command -v conda &> /dev/null; then
    echo -e "${RED}Error: conda not installed${NC}"
    return 1
fi
if [ -f "environment.yml" ]; then
    conda env create -f environment.yml || return 1
else
    echo -e "${RED}Error: environment.yml not found${NC}"
    return 1
fi
}

init_memory_bank() {
mkdir -p memory-bank
cat > memory-bank/projectbrief.md << EOF
# Project Overview

## Purpose
${PROJECT_DESCRIPTION}

## Core Components
* Python Application
* Memory Bank System
* Documentation Standards
* Project Structure
* Conda Environment Management
* $([ "$DOCKER_SUPPORT" = "true" ] && echo "Docker Configuration")

## Development Guidelines
1. Documentation standards
2. Memory bank maintenance
3. Systematic updates
4. Python best practices
5. Workspace diagnostic validation
EOF

cat > memory-bank/productContext.md << EOF
# Product Context

## Overview
${PROJECT_NAME} - ${PROJECT_DESCRIPTION}

## Stakeholders
* Author: ${AUTHOR_NAME} <${AUTHOR_EMAIL}>
* Repository: ${REPOSITORY_URL}
EOF
echo -e "${GREEN}Memory bank initialized${NC}"
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

# Main execution
init_git
init_conda_env
init_memory_bank
process_directory "$(pwd)"
