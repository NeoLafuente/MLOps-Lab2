.ONESHELL:
SHELL := /bin/bash

VENV ?= .venv
UV_INSTALL_SCRIPT = https://astral.sh/uv/install.sh
UV_BIN = $(HOME)/.local/bin/uv

.PHONY: help install test format lint refactor all

help:
	@echo "Available commands:"
	@echo "  make install   - Install uv and sync dependencies"
	@echo "  make test      - Run tests with pytest and coverage"
	@echo "  make format    - Format code with black"
	@echo "  make lint      - Lint code with pylint"
	@echo "  make refactor  - Run format and lint"
	@echo "  make all       - Run install, format, lint, and test"
	@echo "  make help      - Show this help message"
	@echo ""
	@echo "To manually activate the virtual environment, run:"
	@echo "  source $(VENV)/bin/activate"

install:
	curl -LsSf $(UV_INSTALL_SCRIPT) | sh
	$(UV_BIN) sync
	source $(VENV)/bin/activate
	echo "Virtual environment activated at: $$(which python)"

test:
	source $(VENV)/bin/activate
	python -m pytest tests/ -vv --cov=mylib --cov=api --cov=cli 

format:
	source $(VENV)/bin/activate
	black mylib/*.py cli/*.py api/*.py

lint:
	source $(VENV)/bin/activate
	pylint --disable=R,C --ignore-patterns=test_.*\.py mylib/*.py cli/*.py api/*.py

refactor: format lint

all: install format lint test