FROM python:3.10-slim

WORKDIR /code

# --- CORREÇÃO CRÍTICA AQUI ---
# O LightGBM precisa do libgomp1 para funcionar.
# Atualizamos o sistema e instalamos a biblioteca.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*
# -----------------------------

# Adicione esta linha para quebrar o cache (mude a data/hora se precisar de novo)
ENV REFRESHED_AT=2024-11-24_V2

COPY requirements.txt .

# Instala as dependências Python
RUN pip install --no-cache-dir -r requirements.txt

COPY ./app /code/app
COPY ./artifacts /code/artifacts

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]