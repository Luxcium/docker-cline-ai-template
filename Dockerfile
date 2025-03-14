# Base image
FROM debian:bullseye-slim

# System dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Working directory
WORKDIR /app

# Create memory-bank directory
RUN mkdir -p memory-bank

# Install markdown linting tools
RUN npm install -g markdownlint-cli

# Default command
CMD ["bash"]
