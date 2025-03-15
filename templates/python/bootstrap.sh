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

# Function to initialize conda environment
init_conda_env() {
    echo -e "${BLUE}Setting up conda environment...${NC}"
    
    # Check if conda is available
    if ! command -v conda &> /dev/null; then
        echo -e "${RED}Error: conda is not installed or not in PATH${NC}"
        return 1
    }
    
    # Create conda environment from environment.yml
    if [ -f "environment.yml" ]; then
        conda env create -f environment.yml
        echo -e "${GREEN}Conda environment created${NC}"
    else
        echo -e "${RED}Error: environment.yml not found${NC}"
        return 1
    fi
}

# Function to initialize memory bank
init_memory_bank() {
    echo -e "${BLUE}Initializing memory bank...${NC}"
    
    # Create memory bank directory
    mkdir -p memory-bank
    
    # Create core memory bank files
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

This project enforces:

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

## Purpose

[Describe the main purpose and goals of the project]

## Stakeholders

* Author: ${AUTHOR_NAME} <${AUTHOR_EMAIL}>
* Repository: ${REPOSITORY_URL}

## Core Features

[List key features and functionality]
EOF

    cat > memory-bank/systemPatterns.md << EOF
# System Patterns

## Directory Structure

\`\`\`
src/
├── __init__.py
└── main.py
tests/
└── test_main.py
\`\`\`

## Development Patterns

* Clean code principles
* Test-driven development
* Type hints usage
* Documentation strings

## Framework Components

[List major components and their relationships]

## Quality Assurance

* Documentation standards
* Code quality (PEP 8)
* Testing practices (pytest)
* Workspace validation
EOF

    cat > memory-bank/techContext.md << EOF
# Technical Context

## Development Environment

### Requirements

* Python 3.8+
* Conda package manager
* Git version control system
$([ "$DOCKER_SUPPORT" = "true" ] && echo "* Docker engine")
* Development tools
* pytest framework

### Core Components

* Python application structure
* Conda environment management
* Documentation system
* Memory bank structure
$([ "$DOCKER_SUPPORT" = "true" ] && echo "* Docker integration")
* Workspace validation

## Configuration

* Project: ${PROJECT_NAME}
* License: ${LICENSE}
$([ "$DOCKER_SUPPORT" = "true" ] && echo "* Port: ${PORT}")
EOF

    cat > memory-bank/activeContext.md << EOF
# Active Context

## Current Focus

Initial project setup and configuration

## Recent Changes

* Project initialization
* Conda environment setup
* Memory bank setup
* Documentation structure
$([ "$DOCKER_SUPPORT" = "true" ] && echo "* Docker configuration")

## Next Steps

1. Review and update documentation
2. Implement core features
3. Setup development environment
4. Write initial tests
EOF

    cat > memory-bank/progress.md << EOF
# Development Progress

## Completed

* Project initialization
* Memory bank setup
* Documentation structure
* Conda environment configuration

## In Progress

* Initial development setup
* Environment configuration

## Pending

* Core feature implementation
* Testing setup
* Documentation review
EOF

    echo -e "${GREEN}Memory bank initialized${NC}"
}

# Function to setup development environment
setup_dev_environment() {
    echo -e "${BLUE}Setting up development environment...${NC}"
    
    # Create VSCode directory
    mkdir -p .vscode
    
    # Create workspace validation settings
    cat > .vscode/settings.json << EOF
{
    "workbench.iconTheme": "material-icon-theme",
    "editor.formatOnSave": true,
    "editor.renderWhitespace": "boundary",
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewLine": true,
    "files.trimFinalNewlines": true,
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.formatting.provider": "black",
    "python.testing.pytestEnabled": true,
    "markdownlint.config": {
        "MD013": false,
        "MD024": {
            "allow_different_nesting": true
        }
    }
}
EOF
    
    # Create .clinerules file
    cat > .clinerules << EOF
# ${PROJECT_NAME} Rules & Configuration

## Learning & Knowledge Retention

### Learning Directives

* LEARN_MODE: "continuous"
* MEMORY_PERSISTENCE: "enabled"
* CONTEXT_LAYERING: "enabled"
* PATTERN_RECOGNITION: "active"
* WORKSPACE_MONITORING: "active"

### State Management

\`\`\`json
{
  "state_tracking": {
    "project_decisions": true,
    "architectural_patterns": true,
    "user_preferences": true,
    "workspace_validation": {
      "enabled": true,
      "auto_fix": true,
      "real_time": true
    }
  }
}
\`\`\`

## Python-Specific Rules

* Use type hints
* Follow PEP 8 style guide
* Write docstrings for all public functions
* Maintain test coverage

## Version Information

* Version: 1.0.0
* Last Updated: $(date +%Y-%m-%d)
* Auto-Update: Enabled
* Learning Mode: Active
EOF
    
    # Setup Docker if enabled
    if [ "$DOCKER_SUPPORT" = "true" ]; then
        echo -e "${BLUE}Setting up Docker environment...${NC}"
        if [ ! -f "docker-compose.yml" ]; then
            cat > docker-compose.yml << EOF
version: '3.8'
services:
  app:
    build: .
    ports:
      - "${PORT}:${PORT}"
    volumes:
      - .:/app
    environment:
      - PYTHONPATH=/app
EOF
        fi
    fi
    
    echo -e "${GREEN}Development environment configured${NC}"
}

# Function to validate workspace
validate_workspace() {
    echo -e "${BLUE}Validating workspace...${NC}"
    
    local errors=0
    
    # Check required directories
    for dir in "memory-bank" ".vscode" "src" "tests"; do
        if [ ! -d "$dir" ]; then
            echo -e "${RED}Error: Missing required directory: $dir${NC}"
            errors=$((errors + 1))
        fi
    done
    
    # Check required files
    for file in ".clinerules" ".vscode/settings.json" \
        "memory-bank/projectbrief.md" "memory-bank/productContext.md" \
        "memory-bank/systemPatterns.md" "memory-bank/techContext.md" \
        "memory-bank/activeContext.md" "memory-bank/progress.md" \
        "environment.yml" "pyproject.toml" "src/__init__.py" "src/main.py" \
        "tests/__init__.py" "tests/test_main.py"; do
        if [ ! -f "$file" ]; then
            echo -e "${RED}Error: Missing required file: $file${NC}"
            errors=$((errors + 1))
        fi
    done
    
    # Check Docker files if enabled
    if [ "$DOCKER_SUPPORT" = "true" ]; then
        for file in "docker-compose.yml" "Dockerfile"; do
            if [ ! -f "$file" ]; then
                echo -e "${RED}Error: Missing Docker file: $file${NC}"
                errors=$((errors + 1))
            fi
        done
    fi
    
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}Workspace validation successful${NC}"
        return 0
    else
        echo -e "${RED}Workspace validation failed with $errors errors${NC}"
        return 1
    fi
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
    
    # Initialize conda environment
    init_conda_env || {
        echo -e "${RED}Bootstrap failed: Could not create conda environment${NC}"
        exit 1
    }
    
    # Initialize memory bank
    init_memory_bank
    
    # Setup development environment
    setup_dev_environment
    
    # Validate workspace
    validate_workspace || {
        echo -e "${RED}Bootstrap failed: Workspace validation errors${NC}"
        exit 1
    }
    
    echo -e "${GREEN}✨ Project ${PROJECT_NAME} has been bootstrapped successfully!${NC}"
    
    # Display next steps
    echo -e "\n${BLUE}Next Steps:${NC}"
    echo -e "1. Activate conda environment: conda activate ${PROJECT_NAME}"
    echo -e "2. Review and update memory bank documentation"
    echo -e "3. Configure development environment settings"
    echo -e "4. Begin implementing core features"
    if [ "$DOCKER_SUPPORT" = "true" ]; then
        echo -e "5. Test Docker configuration with 'docker-compose up'"
    fi
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
