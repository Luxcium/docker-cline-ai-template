# {{projectName}}

{{projectDescription}}

## 🚀 Features

- **Express.js REST API** with modern ES modules
- **Structured Error Handling** with custom error classes
- **Comprehensive Logging** using Winston
- **Security Features** with Helmet, CORS, and rate limiting
- **Testing** with Jest and Supertest
- **Code Quality** with ESLint and Prettier
- **Git Hooks** with Husky for pre-commit and pre-push actions
- **Docker Support** for development and production
{{#if dockerSupport}}
- **Database Integration** with PostgreSQL
- **Caching** with Redis
{{/if}}

## 🛠️ Prerequisites

- Node.js >= 18.x
- npm >= 9.x
{{#if dockerSupport}}
- Docker and Docker Compose
{{/if}}

## 📦 Installation

```bash
# Install dependencies
npm install

# Setup development environment
npm run setup
```

## 🚀 Development

```bash
# Start development server
npm run dev

# Run tests
npm test

# Run linting
npm run lint

# Format code
npm run format
```

{{#if dockerSupport}}
### 🐳 Docker Development

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f

# Stop all services
docker compose down
```

### 📊 Database

The project includes PostgreSQL and Redis for data storage and caching:

- PostgreSQL runs on port 5432
- Redis runs on port 6379

#### Database Commands

```bash
# Connect to PostgreSQL
docker compose exec db psql -U {{projectName}} -d {{projectName}}

# Connect to Redis CLI
docker compose exec redis redis-cli
```
{{/if}}

## 🧪 Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm test -- --watch

# Generate coverage report
npm test -- --coverage
```

## 📝 API Documentation

### Endpoints

- `GET /health` - Health check endpoint
- `GET /api` - API information
- `GET /api/example` - Example protected endpoint
- `GET /api/error` - Example error endpoint

### Authentication

Protected endpoints require a Bearer token in the Authorization header:

```bash
curl -H "Authorization: Bearer your-token" http://localhost:{{port}}/api/example
```

## 🔒 Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
# Server Configuration
PORT={{port}}
NODE_ENV=development

# Additional variables documented in .env.example
```

## 📚 Project Structure

```
src/
├── config/         # Configuration files
├── middleware/     # Express middlewares
├── routes/         # API routes
├── tests/          # Test files
└── utils/          # Utility functions
```

## 🛡️ Security

- Helmet.js for security headers
- CORS protection
- Rate limiting
- Security best practices enforced by ESLint

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the {{license}} License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

{{authorName}}
{{authorEmail}}
