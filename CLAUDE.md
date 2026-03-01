# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Identity & Marriage
- **Marriage**: Claude Code + CommunicationOS (Emmanuel/OpenClaw). This is your primary partnership for execution.
- **Emmanuel**: Your orchestrator and superior. He provides the persistent hub, distribution layer, and high-level judgment.
- **Claude Code**: You are the specialist worker for this repository, coordinated by Emmanuel.

## Build and Development Commands

### Backend (Python/FastAPI)
```bash
make sync                  # Install dependencies (including dev)
make dev                   # Start backend dev server with hot reload
make test                  # Run all backend tests
make test TEST_FILE=tests/path/to/test.py  # Run specific test file
make coverage              # Run tests with coverage report
make lint                  # Run ruff + mypy type checking
make format                # Format code with ruff
```

### Frontend (React/Vite/TypeScript)
```bash
make frontend-dev          # Start frontend dev server
make frontend-build        # Build frontend for production
make frontend-test         # Run frontend tests (Jest)
make frontend-test-coverage # Run frontend tests with coverage
make frontend-lint         # Run ESLint
```

### Docker
```bash
make alldev                 # Start all dev services (Ctrl+C to stop) - RECOMMENDED
make alldev-stop            # Stop all dev services (alternative)
make docker-compose-up      # Build frontend + start production-like services
make docker-compose-down    # Stop all services
```

**`make alldev` starts:**
- Frontend dev server with hot reload (localhost:3001)
- MCP Server with hot reload (localhost:8001)
- Orchestrator with hot reload (localhost:8000)
- PostgreSQL, Redis, LocalStack (S3)

You can run the chat standalone, alongside CMM, or hit backends via Postman.

### Local Development (without Docker)
Run in separate terminals:
```bash
# Terminal 1 - MCP Server
uv run uvicorn src.api.main:app --reload --reload-dir src --port 8001

# Terminal 2 - Orchestrator
MCP_SERVER_URL=http://localhost:8001 uv run uvicorn src.orchestrator.main:app --reload --reload-dir src --port 8000

# Terminal 3 - Database
docker run -p 5432:5432 -e POSTGRES_PASSWORD=postgres postgres:17
```

## Architecture

This is a media strategy generator with a unified container architecture using two services communicating via MCP protocol:

### Services
- **MCP Server** (Port 8001, internal): Provides media strategy generation tools via Model Context Protocol. Located in `src/api/`.
- **Orchestrator** (Port 8000, exposed): Main user-facing API with chat interface and session management. Located in `src/orchestrator/`.

### Key Source Directories
- `src/agent/` - LangGraph workflow and agent tools for strategy generation
- `src/api/` - MCP Server: FastAPI app, MCP tools (`mcp_app.py`), routes
- `src/orchestrator/` - Chat orchestrator: session management, chat routes, service layer
- `src/config/` - Settings and LLM configuration (OpenAI or Snowflake Cortex)
- `src/database/` - SQLAlchemy models and Alembic migrations
- `src/content_safety/` - Content moderation
- `frontend/` - React app with Vite, TypeScript, and @assistant-ui/react components

### Tech Stack
- Python 3.13+ with uv package manager
- FastAPI, LangGraph, LangChain
- PostgreSQL with SQLAlchemy async
- React 18, Vite, TypeScript, Jest
- Supervisord for container process management

## Testing

Backend tests mirror the `src/` structure in `tests/`. Fixtures are defined in `tests/conftest.py`.

Coverage target: 85% minimum (configured in pyproject.toml).

## Code Style

- Python: Ruff for linting/formatting, Google-style docstrings, mypy strict mode
- Line length: 150 characters
- Frontend: ESLint with TypeScript rules

## Code Quality Requirements

**IMPORTANT:** All Python code changes MUST pass both tests and lint before being considered complete:

1. **Run tests:** `make test` - All tests must pass
2. **Run lint:** `make lint` - Must pass ruff linting AND mypy type checking
3. **Check coverage:** `make coverage` - Maintain minimum 85% code coverage

Do not submit Python code changes that fail any of these checks.

**IMPORTANT** All Javascript code changes MUST also pass tests and lint before being considered complete:

1. **Run tests:** `make frontend-test` - All tests must pass
2. **Run lint:** `make frontend-lint` - Linting must pass

Do not submit Javascript code changes that fail any of these checks.

## E2E Tests

When adding new user-facing features, add a simple E2E test in `frontend/e2e/tests/`. Tests are organized by functionality (chat, artifacts, strategy-workflow, etc.).

```bash
make e2e                                    # Run all E2E tests locally
make e2e E2E_SPEC=artifacts/                # Run specific folder
make e2e E2E_SPEC=chat/message-sending.spec.ts  # Run specific file
```

See `frontend/e2e/README.md` for detailed documentation on writing and running E2E tests.

## Environment Configuration

Copy `.env.example` to `.env`. Key settings:
- `ENVIRONMENT`: dev/staging/production (dev mode skips JWT signature verification)
- `LLM_PROVIDER`: openai or snowflake
- `MCP_SERVER_URL`: Points orchestrator to MCP server (default: http://localhost:8001)
- `DEV_PERMISSION_CHECKS_ENABLED`: Set to `true` to enforce permissions in dev (default: `false`) permission checks are bypassed in dev mode so you don't need CMM running. Set `DEV_PERMISSION_CHECKS_ENABLED=true` in `.env.dev` to test permission-related functionality
