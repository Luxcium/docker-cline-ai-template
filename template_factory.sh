#!/bin/bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base directory for templates
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to create output directory.${NC}"
        exit 1
    fi
    
    # Copy template files
    cp -r "${TEMPLATE_DIR}/templates/${template}/." "$OUTPUT_DIR/"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to copy template files.${NC}"
        exit 1
    fi
    
    # Make scripts executable
    if [ -f "${OUTPUT_DIR}/bootstrap.sh" ]; then
        chmod +x "${OUTPUT_DIR}/bootstrap.sh"
    fi
    if [ -f "${OUTPUT_DIR}/setup.sh" ]; then
        chmod +x "${OUTPUT_DIR}/setup.sh"
    fi
    
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
    })
    
    echo -e "\n${GREEN}✨ Project created successfully at ${OUTPUT_DIR}${NC}"
    echo -e "${BLUE}Next steps:${NC}"
    echo -e "  1. cd ${OUTPUT_DIR}"
    echo -e "  2. Follow the instructions in README.md to start development\n"
}

# Main function
main() {
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
    
    create_project "$template"
}

# Execute main function
main