FROM python:3.10-slim
WORKDIR /code
COPY requirements.txt .
RUN pip install --upgrade pip
RUN cat requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copia as pastas
COPY ./app /code/app
COPY ./artifacts /code/artifacts

# Inicia a API
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]