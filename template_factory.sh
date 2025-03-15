#!/bin/bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base directory for templates
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to validate template source
validate_template_source() {
    local template="$1"
    local template_dir="${TEMPLATE_DIR}/templates/${template}"
    
    echo -e "${BLUE}Validating template source...${NC}"
    
    local errors=0
    local required_files=(
        "bootstrap.sh"
        ".gitignore"
        "README.md"
        "Dockerfile"
    )
    
    # Check template directory exists
    if [ ! -d "$template_dir" ]; then
        echo -e "${RED}Error: Template directory '$template' not found${NC}"
        return 1
    fi
    
    # Check required template files
    for file in "${required_files[@]}"; do
        if [ ! -f "${template_dir}/${file}" ]; then
            echo -e "${RED}Error: Missing required template file: ${file}${NC}"
            errors=$((errors + 1))
        elif [ ! -r "${template_dir}/${file}" ]; then
            echo -e "${RED}Error: Cannot read template file: ${file}${NC}"
            errors=$((errors + 1))
        fi
    done
    
    # Check bootstrap.sh is executable
    if [ ! -x "${template_dir}/bootstrap.sh" ]; then
        echo -e "${RED}Error: bootstrap.sh must be executable${NC}"
        errors=$((errors + 1))
    fi
    
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}Template validation successful${NC}"
        return 0
    else
        echo -e "${RED}Template validation failed with $errors errors${NC}"
        return 1
    fi
}

# Function to prepare project structure
prepare_project_structure() {
    local project_dir="$1"
    
    echo -e "${BLUE}Preparing project structure...${NC}"
    
    # Create required directories
    local directories=(
        "memory-bank"
        ".vscode"
        "src"
        "tests"
    )
    
    for dir in "${directories[@]}"; do
        mkdir -p "${project_dir}/${dir}" || {
            echo -e "${RED}Error: Failed to create directory: ${dir}${NC}"
            return 1
        }
    done
    
    # Initialize .vscode settings
    cat > "${project_dir}/.vscode/settings.json" << EOF
{
    "workbench.iconTheme": "material-icon-theme",
    "editor.formatOnSave": true,
    "editor.renderWhitespace": "boundary",
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewLine": true,
    "files.trimFinalNewlines": true,
    "markdownlint.config": {
        "MD013": false,
        "MD024": {
            "allow_different_nesting": true
        }
    }
}
EOF
    
    # Create initial .clinerules
    cat > "${project_dir}/.clinerules" << EOF
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

## Version Information

* Version: 1.0.0
* Last Updated: $(date +%Y-%m-%d)
* Auto-Update: Enabled
* Learning Mode: Active
EOF
    
    echo -e "${GREEN}Project structure prepared successfully${NC}"
    return 0
}

# Function to run tests for the generated project
run_tests() {
    local project_dir="$1"
    local template="$2"
    
    echo -e "\n${BLUE}Running tests for ${template} template...${NC}"
    
    # Run unit tests
    if [ -f "$TEMPLATE_DIR/tests/unit/test_${template}_bootstrap.sh" ]; then
        echo -e "${BLUE}Running unit tests...${NC}"
        bash "$TEMPLATE_DIR/tests/unit/test_${template}_bootstrap.sh" "$project_dir"
    fi
    
    # Run integration tests
    if [ -f "$TEMPLATE_DIR/tests/integration/test_template_initialization.sh" ]; then
        echo -e "${BLUE}Running integration tests...${NC}"
        bash "$TEMPLATE_DIR/tests/integration/test_template_initialization.sh" "$project_dir" "$template"
    fi
    
    # Run e2e tests
    if [ -f "$TEMPLATE_DIR/tests/e2e/test_user_workflow.sh" ]; then
        echo -e "${BLUE}Running end-to-end tests...${NC}"
        bash "$TEMPLATE_DIR/tests/e2e/test_user_workflow.sh" "$project_dir" "$template"
    fi
}

# Function to initialize memory bank
init_memory_bank() {
    local project_dir="$1"
    
    echo -e "${BLUE}Initializing memory bank...${NC}"
    
    local memory_bank_dir="${project_dir}/memory-bank"
    
    # Create memory bank files with initial content
    cat > "${memory_bank_dir}/projectbrief.md" << EOF
# Project Overview

## Purpose

${PROJECT_DESCRIPTION}

## Core Components

* Memory Bank System
* Documentation Standards
* Project Structure
* $([ "$DOCKER_SUPPORT" = "true" ] && echo "Docker Configuration")

## Development Guidelines

1. Documentation standards
2. Memory bank maintenance
3. Systematic updates
4. Workspace diagnostic validation
EOF
    
    cat > "${memory_bank_dir}/productContext.md" << EOF
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
    
    cat > "${memory_bank_dir}/systemPatterns.md" << EOF
# System Patterns

## Directory Structure

[Document the project's directory organization]

## Development Patterns

[Document key development patterns and practices]

## Framework Components

[List major components and their relationships]

## Quality Assurance

* Documentation standards
* Code quality
* Testing practices
* Workspace validation
EOF
    
    cat > "${memory_bank_dir}/techContext.md" << EOF
# Technical Context

## Development Environment

### Requirements

* Git version control system
$([ "$DOCKER_SUPPORT" = "true" ] && echo "* Docker engine")
* Development tools
* Testing framework

### Core Components

* Documentation system
* Memory bank structure
$([ "$DOCKER_SUPPORT" = "true" ] && echo "* Docker integration")
* Workspace validation

## Configuration

* Project: ${PROJECT_NAME}
* License: ${LICENSE}
$([ "$DOCKER_SUPPORT" = "true" ] && echo "* Port: ${PORT}")
EOF
    
    cat > "${memory_bank_dir}/activeContext.md" << EOF
# Active Context

## Current Focus

Initial project setup and configuration

## Recent Changes

* Project initialization
* Memory bank setup
* Documentation structure
$([ "$DOCKER_SUPPORT" = "true" ] && echo "* Docker configuration")

## Next Steps

1. Review and update documentation
2. Implement core features
3. Setup development environment
EOF
    
    cat > "${memory_bank_dir}/progress.md" << EOF
# Development Progress

## Completed

* Project initialization
* Memory bank setup
* Documentation structure

## In Progress

* Initial development setup
* Environment configuration

## Pending

* Core feature implementation
* Testing setup
* Documentation review
EOF
    
    echo -e "${GREEN}Memory bank initialized successfully${NC}"
    return 0
}

# Function to setup Docker configuration
setup_docker() {
    local project_dir="$1"
    
    if [ "$DOCKER_SUPPORT" = "true" ]; then
        echo -e "${BLUE}Setting up Docker configuration...${NC}"
        
        # Create docker-compose.yml if it doesn't exist
        if [ ! -f "${project_dir}/docker-compose.yml" ]; then
            cat > "${project_dir}/docker-compose.yml" << EOF
version: '3.8'
services:
  app:
    build: .
    ports:
      - "${PORT}:${PORT}"
    volumes:
      - .:/app
    environment:
      - NODE_ENV=development
EOF
        fi
        
        # Ensure Dockerfile exists
        if [ ! -f "${project_dir}/Dockerfile" ]; then
            cp "${TEMPLATE_DIR}/templates/base/Dockerfile" "${project_dir}/Dockerfile"
        fi
        
        echo -e "${GREEN}Docker configuration completed${NC}"
    fi
}

# Function to validate generated project
validate_project() {
    local project_dir="$1"
    local template="$2"
    
    echo -e "\n${BLUE}Validating project structure...${NC}"
    
    local errors=0
    
    # Check for required directories
    for dir in "memory-bank" ".vscode"; do
        if [ ! -d "${project_dir}/${dir}" ]; then
            echo -e "${RED}Error: Missing required directory: ${dir}${NC}"
            errors=$((errors + 1))
        fi
    done
    
    # Check for required memory bank files
    for file in "projectbrief.md" "productContext.md" "systemPatterns.md" \
        "techContext.md" "activeContext.md" "progress.md"; do
        if [ ! -f "${project_dir}/memory-bank/${file}" ]; then
            echo -e "${RED}Error: Missing memory bank file: ${file}${NC}"
            errors=$((errors + 1))
        fi
    done
    
    # Check for required config files
    if [ ! -f "${project_dir}/.clinerules" ]; then
        echo -e "${RED}Error: Missing .clinerules file${NC}"
        errors=$((errors + 1))
    fi
    
    if [ ! -f "${project_dir}/.vscode/settings.json" ]; then
        echo -e "${RED}Error: Missing VSCode settings${NC}"
        errors=$((errors + 1))
    fi
    
    # Template-specific validation
    case "$template" in
        node)
            for file in "package.json" "jest.config.js" ".eslintrc.json"; do
                if [ ! -f "${project_dir}/${file}" ]; then
                    echo -e "${RED}Error: Missing Node.js file: ${file}${NC}"
                    errors=$((errors + 1))
                fi
            done
            ;;
        python)
            for file in "pyproject.toml" "environment.yml"; do
                if [ ! -f "${project_dir}/${file}" ]; then
                    echo -e "${RED}Error: Missing Python file: ${file}${NC}"
                    errors=$((errors + 1))
                fi
            done
            ;;
    esac
    
    if [ "$DOCKER_SUPPORT" = "true" ]; then
        for file in "docker-compose.yml" "Dockerfile"; do
            if [ ! -f "${project_dir}/${file}" ]; then
                echo -e "${RED}Error: Missing Docker file: ${file}${NC}"
                errors=$((errors + 1))
            fi
        done
    fi
    
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}Project validation successful${NC}"
        return 0
    else
        echo -e "${RED}Project validation failed with $errors errors${NC}"
        return 1
    fi
}

# Welcome message
echo -e "${BLUE}🚀 Docker-Cline AI Template Factory 🚀${NC}"
echo -e "${BLUE}=======================================${NC}\n"

# Function to list available templates
list_templates() {
    echo -e "${BLUE}Available templates:${NC}"
    echo -e "${GREEN}1. base${NC} - Basic project structure with Docker support"
    echo -e "${GREEN}2. node${NC} - Node.js project with Jest for testing"
    echo -e "${GREEN}3. python${NC} - Python project with pytest and conda environment"
    echo
}

# Function to prompt for template selection
select_template() {
    while true; do
        read -p "Select template (1-3): " selection
        case $selection in
            1) echo "base"; return 0 ;;
            2) echo "node"; return 0 ;;
            3) echo "python"; return 0 ;;
            *) echo -e "${RED}Invalid selection. Please enter 1, 2, or 3.${NC}" ;;
        esac
    done
}

# Function to prompt for project details
gather_project_details() {
    # Project name (required)
    while true; do
        read -p "Project name: " PROJECT_NAME
        if [[ -z "$PROJECT_NAME" ]]; then
            echo -e "${RED}Error: Project name cannot be empty.${NC}"
        elif [[ "$PROJECT_NAME" =~ [^a-zA-Z0-9_-] ]]; then
            echo -e "${RED}Error: Project name can only contain letters, numbers, hyphens, and underscores.${NC}"
        else
            break
        fi
    done
    
    # Project description
    read -p "Project description (optional): " PROJECT_DESCRIPTION
    PROJECT_DESCRIPTION="${PROJECT_DESCRIPTION:-A project generated with the Docker-Cline AI Template Factory}"
    
    # Author name
    read -p "Author name (optional): " AUTHOR_NAME
    AUTHOR_NAME="${AUTHOR_NAME:-Docker-Cline User}"
    
    # Author email
    read -p "Author email (optional): " AUTHOR_EMAIL
    AUTHOR_EMAIL="${AUTHOR_EMAIL:-user@example.com}"
    
    # Repository URL
    read -p "Repository URL (optional): " REPOSITORY_URL
    REPOSITORY_URL="${REPOSITORY_URL:-https://github.com/user/$PROJECT_NAME}"
    
    # License
    read -p "License (default: MIT): " LICENSE
    LICENSE="${LICENSE:-MIT}"
    
    # Docker support
    while true; do
        read -p "Enable Docker support? (y/n, default: y): " docker_support
        docker_support="${docker_support:-y}"
        if [[ "$docker_support" =~ ^[Yy]$ ]]; then
            DOCKER_SUPPORT="true"
            break
        elif [[ "$docker_support" =~ ^[Nn]$ ]]; then
            DOCKER_SUPPORT="false"
            break
        else
            echo -e "${RED}Please enter y or n.${NC}"
        fi
    done
    
    # Port number (if Docker enabled)
    if [[ "$DOCKER_SUPPORT" == "true" ]]; then
        read -p "Port number (default: 3000): " PORT
        PORT="${PORT:-3000}"
    else
        PORT="3000"
    fi
    
    # Output directory
    read -p "Output directory (default: ./$PROJECT_NAME): " OUTPUT_DIR
    OUTPUT_DIR="${OUTPUT_DIR:-./$PROJECT_NAME}"
}

# Function to create project from template
create_project() {
    local template="$1"
    
    echo -e "\n${BLUE}Creating project from ${template} template...${NC}"
    
    # Validate template source first
    validate_template_source "$template" || {
        echo -e "${RED}Template validation failed. Cannot proceed with project creation.${NC}"
        exit 1
    }
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR" || {
        echo -e "${RED}Error: Failed to create output directory.${NC}"
        exit 1
    }
    
    # Prepare project structure
    prepare_project_structure "$OUTPUT_DIR" || {
        echo -e "${RED}Error: Failed to prepare project structure.${NC}"
        exit 1
    }
    
    # Copy template files
    cp -r "${TEMPLATE_DIR}/templates/${template}/." "$OUTPUT_DIR/" || {
        echo -e "${RED}Error: Failed to copy template files.${NC}"
        exit 1
    }
    
    # Make scripts executable
    chmod +x "${OUTPUT_DIR}/bootstrap.sh" 2>/dev/null || true
    chmod +x "${OUTPUT_DIR}/setup.sh" 2>/dev/null || true
    
    # Initialize memory bank
    init_memory_bank "$OUTPUT_DIR" || {
        echo -e "${RED}Error: Failed to initialize memory bank.${NC}"
        exit 1
    }
    
    # Setup Docker configuration if enabled
    setup_docker "$OUTPUT_DIR"
    
    # Export environment variables for bootstrap script
    export PROJECT_NAME
    export PROJECT_DESCRIPTION
    export AUTHOR_NAME
    export AUTHOR_EMAIL
    export REPOSITORY_URL
    export LICENSE
    export DOCKER_SUPPORT
    export PORT
    
    echo -e "${BLUE}Running initialization script...${NC}"
    
    # Run appropriate initialization script
    (cd "$OUTPUT_DIR" && {
        if [ -f "setup.sh" ]; then
            ./setup.sh
        elif [ -f "bootstrap.sh" ]; then
            ./bootstrap.sh
        else
            echo -e "${YELLOW}Warning: No initialization script found. Manual setup may be required.${NC}"
        fi
    }) || {
        echo -e "${RED}Error: Initialization script failed.${NC}"
        exit 1
    }
}

# Function to print template factory banner
print_banner() {
    echo -e "${BLUE}"
    echo "╔═════════════════════════════════════════════════╗"
    echo "║        Docker-Cline AI Template Factory         ║"
    echo "║                                                 ║"
    echo "║  Generate production-ready project templates    ║"
    echo "║  with built-in memory bank and test framework   ║"
    echo "╚═════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

# Main function
main() {
    print_banner
    list_templates
    local template=$(select_template)
    echo -e "${GREEN}Selected template: ${template}${NC}\n"
    
    echo -e "${BLUE}Please provide details for your project:${NC}"
    gather_project_details
    
    echo -e "\n${BLUE}Project Details:${NC}"
    echo -e "  Template:           ${template}"
    echo -e "  Name:               ${PROJECT_NAME}"
    echo -e "  Description:        ${PROJECT_DESCRIPTION}"
    echo -e "  Author:             ${AUTHOR_NAME} <${AUTHOR_EMAIL}>"
    echo -e "  Repository:         ${REPOSITORY_URL}"
    echo -e "  License:            ${LICENSE}"
    echo -e "  Docker Support:     ${DOCKER_SUPPORT}"
    if [[ "$DOCKER_SUPPORT" == "true" ]]; then
        echo -e "  Port:               ${PORT}"
    fi
    echo -e "  Output Directory:   ${OUTPUT_DIR}"
    
    # Confirm creation
    echo
    read -p "Create project? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Project creation cancelled.${NC}"
        exit 1
    fi
    
    # Create project
    create_project "$template"
    
    # Validate project structure
    validate_project "$OUTPUT_DIR" "$template" || {
        echo -e "${RED}Project creation failed: Validation errors${NC}"
        exit 1
    }
    
    # Run tests
    run_tests "$OUTPUT_DIR" "$template"
    
    # Display success message with next steps
    echo -e "\n${GREEN}✨ Project created successfully!${NC}"
    echo -e "\n${BLUE}Next Steps:${NC}"
    echo -e "1. cd ${OUTPUT_DIR}"
    echo -e "2. Review the memory bank documentation in memory-bank/"
    echo -e "3. Configure development environment"
    echo -e "4. Start implementing your features"
    if [ "$DOCKER_SUPPORT" = "true" ]; then
        echo -e "5. Test your Docker setup with: docker-compose up"
    fi
}

# Execute main function with error handling
{
    main
} || {
    echo -e "\n${RED}Template factory encountered an error. Please check the output above.${NC}"
    exit 1
}
