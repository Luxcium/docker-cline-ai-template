# Containerized Python Template

A container-first Python project template ensuring consistent development and production 
environments through Docker and Conda.

## Features

* FastAPI-based REST API
* Conda environment management
* Docker containerization
* Automated testing with pytest
* Code quality tools (black, isort, flake8)
* Pre-commit hooks

## Prerequisites

* Docker installed on your system
* No other dependencies required (everything runs in the container)

## Getting Started

### Building the Container

```shell
docker build -t python-template .
```

### Running the Application

```shell
docker run -p 8000:8000 python-template
```

The API will be available at [http://localhost:8000](http://localhost:8000)

### API Documentation

Once running, view the interactive API documentation at:

* [Swagger UI](http://localhost:8000/docs)
* [ReDoc](http://localhost:8000/redoc)

## Development

### Running Tests

```shell
docker run --rm python-template conda run -n python-template pytest
```

### Code Quality Checks

The project uses pre-commit hooks to maintain code quality. The following tools are 
configured:

* black - Code formatting
* isort - Import sorting
* flake8 - Style guide enforcement

Pre-commit hooks are automatically run inside the container.

## Project Structure

```text
templates/python/
│── src/                    # Source code
│   ├── main.py            # FastAPI application
│── tests/                  # Unit tests
│── Dockerfile             # Container configuration
│── environment.yml        # Conda dependencies
│── .pre-commit-config.yaml # Code quality hooks
│── README.md              # Project documentation
│── .gitignore            # Git ignore rules
```

## Working with the Container

### Interactive Shell

To get an interactive shell inside the container:

```shell
docker run -it --rm python-template conda run -n python-template bash
```

### Running One-Off Commands

To run a specific command inside the container:

```shell
docker run --rm python-template conda run -n python-template <command>
```

Example (running tests):

```shell
docker run --rm python-template conda run -n python-template pytest
```

## API Endpoints

The template includes a basic CRUD API for demonstration:

* `GET /` - Root endpoint (Hello World)
* `GET /items` - List all items
* `GET /items/{item_id}` - Get a specific item
* `POST /items` - Create a new item
* `PUT /items/{item_id}` - Update an item
* `DELETE /items/{item_id}` - Delete an item

## Development Workflow

1. All development happens inside the container
2. No virtual environments or dependencies on the host machine
3. Use Docker for all operations (building, testing, running)
4. Code changes are reflected immediately due to volume mounting

## Notes

* The container uses Conda for dependency management
* All Python execution happens inside the container
* No need for local Python installation or virtual environments
* Pre-commit hooks ensure code quality
* Tests run inside the container for consistency
