# Base used by both stages (keeps image lineage consistent)
FROM python:3.13-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_SYSTEM_PYTHON=1

WORKDIR /app

# Install uv and the dependencies of the project
FROM base AS builder

# Install system build deps only in builder. TODO: remove "git \" ?
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libjpeg-dev \
    zlib1g-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv (if you use uv/uv.lock workflow)
RUN pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir uv

# Copy pyproject and lockfile first to leverage build cache
COPY pyproject.toml /app/
# Copy the lock file if exists
COPY uv.lock* /app/
# Install project dependencies into system environment
RUN uv pip install --system --no-cache .

# Runtime stage: smaller image without build tools
FROM base AS runtime

# Copy installed Python packages from builder (site-packages and binaries)
COPY --from=builder /usr/local /usr/local

# Copy application code only (avoid copying dev files)
COPY api ./api
COPY mylib ./mylib
COPY templates ./templates
COPY pyproject.toml ./pyproject.toml

# Create non-root user
RUN useradd --create-home appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

# Allow override of the app module: default assumes FastAPI app at api/api.py as 'app'
ENV APP_MODULE="api.api:app"
ENV HOST="0.0.0.0"
ENV PORT="8000"

CMD ["sh", "-c", "exec uvicorn ${APP_MODULE} --host ${HOST} --port ${PORT} --workers 1"]