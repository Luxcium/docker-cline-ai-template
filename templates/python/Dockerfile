FROM continuumio/miniconda3

WORKDIR /app

# Copy dependency file first for layer caching
COPY environment.yml .
RUN conda env create -f environment.yml

# Use the conda environment
SHELL ["conda", "run", "-n", "python-template", "/bin/bash", "-c"]

# Copy source code
COPY src/ src/
COPY tests/ tests/

# Expose port for FastAPI
EXPOSE 8000

# Start FastAPI server with uvicorn
CMD ["conda", "run", "--no-capture-output", "-n", "python-template", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
