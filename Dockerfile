FROM python:3.10-slim

WORKDIR /code
ENV REFRESHED_AT=2025-11-24
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia as pastas
COPY ./app /code/app
COPY ./artifacts /code/artifacts

# Inicia a API
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]