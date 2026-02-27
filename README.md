# Media Strategy Generator

A comprehensive FastAPI-based service that analyzes media briefs and generates structured media strategy summaries using LangGraph and advanced LLM technology. Features a unified Docker deployment with both MCP Server and Chat Orchestrator running in a single container.

## Quick Start

```bash
# Start everything for development (recommended)
make alldev

# Access the services
# Frontend: http://localhost:3001
# Orchestrator API: http://localhost:8000
# MCP Server: http://localhost:8001
```

**`make alldev`** starts all services with hot reload. Press Ctrl+C to stop, or use `make alldev-stop`.

For production-like builds, use `make docker-compose-up` (builds frontend first).

The API will be available at:
- **Orchestrator**: http://localhost:8000 (main user-facing API)
- **Interactive Docs**: http://localhost:8000/docs
- **PostgreSQL**: localhost:5432

## Features

- **RESTful API**: FastAPI-based web service with automatic OpenAPI documentation
- **Chat Orchestrator**: Conversational interface with session management
- **Document Processing**: Accepts PDF, DOCX, TXT, CSV files
- **Streaming Support**: Real-time updates via Server-Sent Events (SSE)
- **MCP Protocol**: Model Context Protocol for tool invocation
- **Unified Docker**: Single container deployment with supervisord
- **Production Ready**: Comprehensive testing, logging, and monitoring

## Architecture

The system uses a **unified container architecture** with two services communicating via MCP protocol:

```
┌─────────────────────────────────────┐
│  Unified Container (app)            │
│                                     │
│  ┌──────────────────────────────┐  │
│  │  Supervisord Process Manager │  │
│  │                              │  │
│  │  ┌────────────────────────┐ │  │
│  │  │ MCP Server             │ │  │
│  │  │ Port: 8001 (internal)  │ │  │
│  │  └────────────────────────┘ │  │
│  │                              │  │
│  │  ┌────────────────────────┐ │  │
│  │  │ Orchestrator           │ │  │
│  │  │ Port: 8000 (exposed)   │ │  │
│  │  └────────────────────────┘ │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
         │
         │ Port 8000 (external access)
         ▼
    User/Client
```

**Key Components:**

1. **MCP Server** (Internal - Port 8001)
   - Provides media strategy generation tools via MCP protocol
   - Processes uploaded files and generates strategies
   - Only accessible from within the container

2. **Orchestrator** (External - Port 8000)
   - Main user-facing API with chat interface
   - Manages user sessions and conversation history
   - Calls MCP tools via internal HTTP communication
   - Exposed to host on port 8000

### Technical Stack

- **FastAPI**: Modern async web framework
- **LangGraph**: Multi-step workflow orchestration
- **MCP Protocol**: Tool invocation via Model Context Protocol
- **Supervisord**: Process management for unified deployment
- **PostgreSQL**: Database for persistence
- **LLM Processing**: OpenAI or Snowflake Cortex models

## Prerequisites

- Python 3.13+
- [uv](https://docs.astral.sh/uv/) package manager
- Docker & Docker Compose (for containerized deployment)
- OpenAI API key OR Snowflake Cortex credentials

## Installation

### Local Development

1. **Install dependencies** using uv:

```bash
uv sync --group dev
```

2. **Environment Setup**:

```bash
cp .env.example .env
```

Configure your `.env` file:

```bash
# Environment
ENVIRONMENT=dev  # dev, staging, or production

# LLM Provider
LLM_PROVIDER=openai  # 'openai' or 'snowflake'

# OpenAI Configuration (if using openai)
OPENAI_API_KEY=sk-your-api-key-here

# Snowflake Configuration (if using snowflake)
SNOWFLAKE_USERNAME=your-username
SNOWFLAKE_ACCOUNT=your-account.snowflakecomputing.com
SNOWFLAKE_PRIVATE_KEY_PATH=/path/to/private_key.p8
SNOWFLAKE_PRIVATE_KEY_PASSPHRASE=your-passphrase
SNOWFLAKE_ROLE=your-role
SNOWFLAKE_DATABASE=your-database
SNOWFLAKE_SCHEMA=your-schema
SNOWFLAKE_WAREHOUSE=your-warehouse

# Database
DATABASE_HOST=postgres
DATABASE_URL=postgresql://postgres:postgres@postgres:5432/media_strategy_generator

# Auth (staging/production)
AUTH0_DOMAIN=your-domain.auth0.com
API_AUDIENCE=your-api-audience

# Server
HOST=0.0.0.0
PORT=8000
LOG_LEVEL=INFO

# File Upload
MAX_FILE_SIZE_MB=10

# MCP Server URL (for orchestrator)
MCP_SERVER_URL=http://localhost:8001
```

## Running the Application

### Development with Hot Reload (Recommended)

The easiest way to run everything for development:

```bash
make alldev
```

This starts all services with hot reload:
- **Frontend**: http://localhost:3001 (Vite dev server)
- **Orchestrator**: http://localhost:8000 (main API)
- **MCP Server**: http://localhost:8001 (internal tools API)
- **PostgreSQL**: localhost:5433
- **Redis**: localhost:6380
- **LocalStack S3**: localhost:4566

Press **Ctrl+C** to stop all services gracefully, or use `make alldev-stop`.

**Features:**
- Run the chat standalone at localhost:3001
- Run the chat alongside CMM (point CMM to localhost:8000)
- Hit both Python backends via Postman on ports 8001 & 8000
- Hot reload for both Python and JavaScript changes

### Production-like Docker Compose

For testing production builds:

**Terminal 1 - MCP Server:**
```bash
uv run uvicorn src.api.main:app --reload --reload-dir src --port 8001
```

**Terminal 2 - Orchestrator:**
```bash
MCP_SERVER_URL=http://localhost:8001 uv run uvicorn src.orchestrator.main:app --reload --reload-dir src --port 8000
```

**Terminal 3 - Database:**
```bash
docker run -p 5432:5432 -e POSTGRES_PASSWORD=postgres postgres:17
```

## API Usage

### Health Check

```bash
curl http://localhost:8000/health
```

Response:
```json
{
  "status": "healthy",
  "version": "1.0.0"
}
```

### Chat Orchestrator (Conversational Interface)

Start a new chat session:

```bash
curl -X POST http://localhost:8000/v1/chat \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "message=Hello, what can you help me with?"
```

Response:
```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "message": "Hello! I'm Compass, your intelligent assistant for digital advertising and media strategy...",
  "files": [],
  "tool_calls": null
}
```

Continue conversation:

```bash
curl -X POST http://localhost:8000/v1/chat \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "session_id=550e8400-e29b-41d4-a716-446655440000" \
  -F "message=Generate a media strategy for a luxury watch brand"
```

### File Upload Support

Upload documents (PDF, DOCX, TXT, CSV) to your chat session:

```bash
curl -X POST http://localhost:8000/v1/chat \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "message=Generate a strategy from this brief" \
  -F "files=@/path/to/campaign_brief.pdf"
```

**Supported File Types:**
- PDF (`.pdf`) - Extracted page by page
- DOCX (`.docx`) - Full text extraction
- TXT (`.txt`) - Plain text
- CSV (`.csv`) - Parsed row by row

**Key Features:**
- Files persist in session across multiple chat turns
- Upload multiple files at once or incrementally
- Agent automatically uses files when generating strategies
- Maximum file size: 10MB (configurable)

## Authentication

### Development Mode

In development (`ENVIRONMENT=dev`), structure-only JWT validation is used (no signature verification).

Test JWT token:
```
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJGYWtlIEJhc2lzIFBsYXRmb3JtIiwiaWF0IjoxNjcxNTY0NzM4LCJleHAiOjQ4NTg3NzQ3NjYsInVpZCI6ImFlNjExNDA1LTRmZjItNWFkNC04YTZmLWM2MTAwZjY1OWZlOSIsInJvbGUiOiJhZ2VuY3lfYWRtaW4iLCJhZ2VuY3kiOnsiaWQiOiIxZWEwYmI5Ny0xYThjLTUxOTgtOWYzYi1mMjg1MjA0ZDAyYjciLCJuYW1lIjoiRnVuIEFnZW5jeSJ9LCJhdWQiOlsiaHR0cHM6Ly9wbGF0Zm9ybS5iYXNpcy5uZXQiXSwic3ViIjoiYXV0aDB8OTI3ZmFjOGZhMTkzYjZlNjk0MjIzYmJhIiwidXNlciI6eyJmaXJzdF9uYW1lIjoiRnVuIiwibGFzdF9uYW1lIjoiQWRtaW4ifSwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCBhZGRyZXNzIHBob25lIG9mZmxpbmVfYWNjZXNzIn0.pvEwx4jyomYSQQgft7hAc_LMAzEBKYT3J-NR_cNuEe30gfkt1jSeVeHm0vEy9FcJwO8ZBuAOoElGCc6P3vMNwQ
```

### Production Mode

In staging/production, JWTs are validated against Auth0 using RS256 signature verification.

Required environment variables:
```bash
AUTH0_DOMAIN=your-auth0-domain.auth0.com
API_AUDIENCE=your-api-audience-identifier
```

## Docker Management

### Check service status:
```bash
docker compose exec app supervisorctl status
```

Expected output:
```
mcp-server                       RUNNING   pid 123, uptime 0:01:23
orchestrator                     RUNNING   pid 124, uptime 0:01:22
```

### View logs:
```bash
# All logs
docker compose logs -f app

# Filter by service
docker compose logs -f app | grep "mcp-server"
docker compose logs -f app | grep "orchestrator"
```

### Restart a specific service:
```bash
docker compose exec app supervisorctl restart mcp-server
docker compose exec app supervisorctl restart orchestrator
```

### Stop everything:
```bash
docker compose down
```

## Development

### Makefile Commands

```bash
# Dependencies
make sync              # Install all dependencies

# Development
make dev               # Start backend dev server with hot reload
make frontend-dev      # Start frontend dev server
make frontend-build    # Build frontend for production
make frontend-build-dev # Build frontend for development

# Testing
make test              # Run backend unit tests
make coverage          # Run backend tests with coverage
make frontend-test     # Run frontend tests
make frontend-test-coverage # Run frontend tests with coverage
make frontend-lint     # Run frontend linter

# Code Quality
make lint              # Run backend linting and type checking
make format            # Format backend code

# Docker
make docker-compose-up    # Build frontend + start all services (RECOMMENDED)
make docker-compose-down  # Stop all services
make docker-build         # Build Docker image only
make docker-run           # Run Docker container standalone
```

### Testing

```bash
# Run all tests
make test

# Run specific test file
uv run pytest tests/config/test_settings.py

# Run with coverage
make coverage

# Watch mode (auto re-run on changes)
make test_watch
```

**Current Test Status:**
- ✅ **Backend: 368/368 tests passing** (100% pass rate)
- ✅ **Backend: 90.06% code coverage** (exceeds 90% target)
- ✅ **Frontend: 268/268 tests passing** (100% pass rate)
- ✅ **Frontend: 60.25% code coverage**
- ✅ Comprehensive integration and unit tests

### Code Quality

```bash
# Linting
make lint

# Format code
make format
```

## Project Structure

```
src/
├── api/                    # MCP Server (Port 8001)
│   ├── main.py            # Entry point
│   ├── mcp_app.py         # MCP tools
│   ├── app.py             # FastAPI app
│   ├── routes.py          # API routes
│   └── models.py          # Pydantic models
├── orchestrator/          # Orchestrator Service (Port 8000)
│   ├── main.py           # Entry point
│   ├── app.py            # FastAPI app
│   ├── routes.py         # Chat endpoint
│   ├── chat_session.py   # Session management
│   └── services/         # Service layer
├── agent/                 # Strategy Generation
│   ├── graph.py          # LangGraph workflow
│   ├── tools.py          # Agent tools
│   └── utils/            # Utilities
├── config/               # Configuration
│   ├── settings.py       # Settings management
│   ├── models.py         # LLM configuration
│   └── snowflake.py      # Snowflake setup
├── database/             # Database layer
│   ├── database_manager.py
│   ├── models/
│   └── migrations/
└── utils/                # Shared utilities

frontend/                 # React Frontend (Vite + TypeScript)
├── src/
│   ├── api/             # API client
│   ├── components/      # React components
│   ├── hooks/           # Custom hooks
│   └── App.tsx          # Main app
├── dist/                # Built frontend (not in Git)
└── package.json

tests/                    # Backend test suite (368 tests, 90.06% coverage)
docker-compose.yml        # Docker Compose configuration
Dockerfile                # Unified container Dockerfile
supervisord.conf          # Process management
Makefile                  # Build and deployment commands
```

## Environment Variables Reference

**Core:**
- `ENVIRONMENT`: Environment mode (dev, staging, production)
- `LLM_PROVIDER`: LLM provider (openai, snowflake)
- `HOST`: Server bind address (default: 0.0.0.0)
- `PORT`: Server port (default: 8000)
- `LOG_LEVEL`: Logging level (DEBUG, INFO, WARNING, ERROR)
- `MAX_FILE_SIZE_MB`: Max file upload size in MB (default: 10)

**OpenAI:**
- `OPENAI_API_KEY`: OpenAI API key (required if LLM_PROVIDER=openai)

**Snowflake Cortex:**
- `SNOWFLAKE_USERNAME`: Snowflake username
- `SNOWFLAKE_ACCOUNT`: Snowflake account identifier
- `SNOWFLAKE_PRIVATE_KEY_PATH`: Path to private key file
- `SNOWFLAKE_PRIVATE_KEY_PASSPHRASE`: Private key passphrase
- `SNOWFLAKE_ROLE`: Snowflake role
- `SNOWFLAKE_DATABASE`: Snowflake database
- `SNOWFLAKE_SCHEMA`: Snowflake schema
- `SNOWFLAKE_WAREHOUSE`: Snowflake warehouse

**Database:**
- `DATABASE_HOST`: PostgreSQL host (default: postgres)
- `DATABASE_URL`: Full database connection string

**Authentication:**
- `AUTH0_DOMAIN`: Auth0 domain (required for staging/production)
- `API_AUDIENCE`: Auth0 API audience

**MCP:**
- `MCP_SERVER_URL`: MCP server URL (default: http://localhost:8001)

**Monitoring (Optional):**
- `LANGSMITH_API_KEY`: LangSmith API key for tracing
- `LANGCHAIN_TRACING_V2`: Enable LangChain tracing (true/false)
- `LANGCHAIN_PROJECT`: LangSmith project name
- `DD_TRACE_ENABLED`: Enable Datadog tracing (true/false)
- `DD_AGENT_HOST`: Datadog agent host
- `JSON_LOGS_ENABLED`: Enable JSON logging (true/false)

## Observability

### Datadog APM

Optional Datadog tracing and logging (disabled by default):

```bash
# Enable in .env
DD_TRACE_ENABLED=true
JSON_LOGS_ENABLED=true
DD_AGENT_HOST=localhost
DD_TRACE_AGENT_PORT=8126
```

Features:
- Application performance traces
- JSON-structured logs
- Service/Environment/Version tagging

### LangSmith Tracing

Optional LangSmith monitoring:

```bash
LANGSMITH_API_KEY=lsv2...
LANGCHAIN_TRACING_V2=true
LANGCHAIN_PROJECT=media-strategy-generator
```

## Production Deployment

### Security Considerations

1. **MCP Server**: Internal only (not exposed)
2. **JWT Authentication**: Full signature verification enabled
3. **Environment Variables**: Use secrets management
4. **File Uploads**: Implement virus scanning
5. **Rate Limiting**: Add per-user/session limits

### Scaling

The unified container architecture provides:
- **Simplicity**: Single container deployment
- **Resource Sharing**: Efficient resource usage
- **Health Monitoring**: Container fails if either service goes down
- **Easy Rollback**: Single artifact to manage

For high-traffic scenarios, consider:
- Separate container deployments with load balancing
- PostgreSQL connection pooling
- Redis for session storage
- Object storage (S3/GCS) for file uploads

## Troubleshooting

### Services not starting
```bash
# Check supervisord status
docker compose exec app supervisorctl status

# View supervisor logs
docker compose exec app cat /var/log/supervisor/supervisord.log
```

### Permission errors
Ensure proper ownership in Dockerfile:
```bash
chown -R app:app /app
chown -R app:app /var/log/supervisor /var/run
```

### Database connection issues
```bash
# Check PostgreSQL is healthy
docker compose ps postgres

# Test connection
docker compose exec postgres psql -U postgres -d media_strategy_generator
```

### File upload issues
- Check `MAX_FILE_SIZE_MB` setting
- Verify file type is supported (PDF, DOCX, TXT, CSV)
- Ensure multipart/form-data headers

## Contributing

1. Install dev dependencies: `make sync`
2. Run tests: `make test`
3. Check coverage: `make coverage`
4. Lint code: `make lint`
5. Format code: `make format`

## License

MIT

## Support

For issues and questions:
- Check the troubleshooting section above
- Review logs: `docker compose logs -f app`
- Check supervisord status: `docker compose exec app supervisorctl status`
