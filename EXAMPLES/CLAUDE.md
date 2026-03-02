# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

```bash
# Common commands (fill in for your project)
# make dev               # Start dev server with hot reload
# make test              # Run all tests
# make test FILE=path    # Run specific test file
# make lint              # Run linter and type checker
# make format            # Auto-format code
# make build             # Build for production
# docker compose up      # Start all services
```
## Architecture

Describe the high-level architecture of the project.

### Services
- List services, ports, and what each one does

### Key Source Directories
- `src/` - Application source code
- `tests/` - Test files (mirror src/ structure)
- `frontend/` - Frontend application (if applicable)

### Tech Stack
- Language, framework, package manager
- Database, cache, message queue (if applicable)
- Frontend framework, bundler (if applicable)
## Testing

- Test runner and framework used
- Where test files live and naming conventions
- How fixtures and test utilities are organized
- Coverage target (e.g., 85% minimum)
## Code Style

- Linter and formatter used
- Docstring style (Google, NumPy, etc.)
- Line length limit
- Type checking strictness
## Code Quality Requirements

**IMPORTANT:** All code changes MUST pass both tests and lint before being considered complete:

1. **Run tests** - All tests must pass
2. **Run lint** - Must pass linting and type checking
3. **Check coverage** - Maintain minimum coverage target

Do not submit code changes that fail any of these checks.
## Environment Configuration

- Copy `.env.example` to `.env` for local development
- Key environment variables and what they control
- How to set up local services (database, cache, etc.)
