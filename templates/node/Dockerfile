# Stage 1: Development
FROM node:{{nodeVersion}}-alpine AS development

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source
COPY . .

# Expose port
EXPOSE {{port}}

# Start development server
CMD ["npm", "run", "dev"]

# Stage 2: Production Build
FROM node:{{nodeVersion}}-alpine AS builder

WORKDIR /app

COPY package*.json ./

# Install dependencies with only production dependencies
RUN npm ci --only=production

COPY . .

# Stage 3: Production Runtime
FROM node:{{nodeVersion}}-alpine AS production

WORKDIR /app

# Copy package files
COPY package*.json ./

# Copy built assets from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE {{port}}

# Set production environment
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget --no-verbose --tries=1 --spider http://localhost:{{port}}/health || exit 1

# Start production server
CMD ["npm", "start"]
