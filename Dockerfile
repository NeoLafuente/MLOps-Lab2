# Multi-stage Dockerfile (uv-based dependency install)
# Build:  docker build -t mlops-lab2:latest .
# Run:    docker run --rm -p 8000:8000 -e APP_MODULE="api.api:app" mlops-lab2:latest

# Base used by both stages (keeps image lineage consistent)
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_SYSTEM_PYTHON=1

WORKDIR /app

# Builder stage: install build dependencies and install project deps into system site-packages
FROM base AS builder

# Install system build deps only in builder
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
COPY uv.lock* /app/  # if no lock exists, this COPY will be ignored

# Install project dependencies into system environment
# Note: If you don't use 'uv', replace this with your preferred install command (pip/poetry/hatch)
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