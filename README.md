[![CI](https://github.com/NeoLafuente/MLOps-Lab2/actions/workflows/CI.yml/badge.svg)](https://github.com/NeoLafuente/MLOps-Lab2/actions/workflows/CI.yml)

# MLOps Lab 1–3

This repository contains material and code developed across Labs 1–3 of an MLOps course. It is structured to progressively introduce packaging, automation, testing, reproducibility, and deployment interfaces (CLI / API).

## Goals

- Provide a minimal Python package (`mylib`) as a base for experimentation.
- Practice dependency management and reproducible environments.
- Add automated testing and continuous integration.
- Expose functionality via a Command Line Interface (CLI) and (optionally) an API layer.
- Use templates to scaffold new components consistently.

## Repository Structure

```
.
├── .github/           # CI workflows and automation configuration
├── .gitignore         # Ignore patterns for Git
├── .python-version    # Pinned Python version (for pyenv / uv)
├── LICENSE            # Project license
├── Makefile           # Developer convenience commands
├── README.md          # Project documentation (this file)
├── pyproject.toml     # Build system + project metadata + dependencies
├── uv.lock            # Locked dependency versions (reproducibility)
├── mylib/             # Core Python package code
├── cli/               # CLI entry points / scripts
├── api/               # API (e.g., FastAPI/Flask) application files
├── templates/         # Reusable code or configuration templates
└── tests/             # Test suite (unit / integration)
```

### Key Directories

- `mylib/`: The Python package containing reusable logic. Import it in other layers instead of duplicating code.
- `cli/`: Command-line tools that orchestrate tasks (data processing, training, evaluation). They should call functions from `mylib`.
- `api/`: Web interface (if implemented) to serve models or utilities (e.g., prediction endpoints).
- `templates/`: Scaffolding examples (new modules, configs, etc.).
- `tests/`: Automated tests ensuring correctness and enabling refactoring.

## Environment & Dependencies

This project uses `pyproject.toml` for metadata and dependency declarations and a `uv.lock` file (produced by [uv](https://github.com/astral-sh/uv) or a similar tool) to pin exact versions for reproducibility.

Recommended setup:

```bash
# Ensure you have the correct Python version
cat .python-version          # e.g., 3.xx

# (Option 1) Using uv
uv sync                      # Install all dependencies from lock file

# (Option 2) Using pyenv + pip
pyenv install $(cat .python-version)
pyenv local $(cat .python-version)
python -m venv .venv
source .venv/bin/activate
pip install -e .
```

## Makefile Workflow

The `Makefile` provides shortcuts. Common patterns (check with `make help` if available):

- `make install` – Install the package and dependencies.
- `make test` – Run the test suite.
- `make lint` – Run static analysis / style checks.
- `make format` – Auto-format code.
- `make clean` – Remove build artifacts.

(Exact targets depend on the current Makefile contents.)

## Using the Package

Once installed:

```python
import mylib
# Use functions/classes inside the package
```

If the CLI is configured (e.g., via an entry point), you can run:

```bash
python -m cli.some_command --option value
# or (if exposed via console_scripts)
mylab-cli --help
```

## API Service (Optional)

If the `api/` directory contains a web app (e.g., FastAPI):

```bash
uvicorn api.main:app --reload
# Visit: http://localhost:8000
```

Adjust the module path (`api.main:app`) to match the actual application file.

## Testing

Run tests (via Makefile or directly):

```bash
pytest -q
```

Keep tests small, deterministic, and focused on public interfaces in `mylib`, CLI commands, and (if present) API endpoints.

## Continuous Integration

A GitHub Actions workflow (see `.github/workflows/CI.yml`) runs automatically on pushes / pull requests to:

- Install dependencies
- Run linting / formatting checks
- Execute the test suite
- Report status via the CI badge above

## Extending the Project

1. Add new reusable logic in `mylib/`.
2. Expose functionality through:
   - CLI commands in `cli/`
   - API endpoints in `api/`
3. Add or adapt templates in `templates/` for consistency.
4. Write tests in `tests/` before (or alongside) implementation.
5. Run `make test` locally; ensure CI passes before merging.

## Suggested Conventions

- Keep business logic decoupled from I/O (CLI/API) layers.
- Prefer pure functions with clear inputs/outputs.
- Document public functions with docstrings.
- Use type hints for clarity.
- Keep dependencies minimal.

## Versioning & Release

The `pyproject.toml` contains the project version. Increment it following semantic versioning (e.g., `MAJOR.MINOR.PATCH`).

## License

Distributed under the terms of the license found in [LICENSE](LICENSE).
