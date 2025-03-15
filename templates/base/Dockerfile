# Base development image
FROM {{baseImage}}

# Create app directory
WORKDIR /app

{{#if dockerSupport}}
# Copy package files
COPY package*.json ./

# Install dependencies
RUN {{packageManager}} install

# Copy project files
COPY . .

# Build if needed
RUN {{buildCommand}}

# Expose port
EXPOSE {{port}}

# Start command
CMD {{startCommand}}
{{/if}}

# Default environment
ENV NODE_ENV=development

# Install global development tools
RUN {{globalInstallCommand}}

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser -m appuser
USER appuser

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:{{port}}/health || exit 1
