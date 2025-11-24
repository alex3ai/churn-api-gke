# --- ESTÁGIO 1: Builder (Compilação) ---
# Usamos a mesma versão do Python que você usou para treinar (3.9 para segurança)
FROM python:3.9-slim AS builder

WORKDIR /build

# Variáveis para otimizar o Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Instala dependências e gera wheels
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /build/wheels -r requirements.txt


# --- ESTÁGIO 2: Final (Execução) ---
FROM python:3.9-slim AS final

# 1. Instala dependências de SO (LightGBM precisa de libgomp1)
RUN apt-get update && \
    apt-get install -y --no-install-recommends libgomp1 && \
    rm -rf /var/lib/apt/lists/*

# 2. Cria usuário não-root (Segurança)
# Isso impede que hackers tenham acesso root se invadirem o container
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# 3. Define o diretório de trabalho padrão
WORKDIR /code

# 4. Copia as dependências compiladas do estágio anterior
COPY --from=builder /build/wheels /wheels
COPY --from=builder /build/requirements.txt .

# 5. Instala os pacotes Python
RUN pip install --no-cache /wheels/*

# 6. Copia a aplicação mantendo a estrutura original
# IMPORTANTE: Copiamos 'app' e 'artifacts' como irmãos.
# O Python dentro de 'app/main.py' vai usar '../artifacts' para achar o modelo.
COPY ./app /code/app
COPY ./artifacts /code/artifacts

# 7. Ajusta permissões para o usuário restrito
# O usuário 'appuser' precisa ser dono dos arquivos para ler/executar
RUN chown -R appuser:appgroup /code

# 8. Muda para o usuário seguro
USER appuser

# 9. Expõe a porta e roda
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]