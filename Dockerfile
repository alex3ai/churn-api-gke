# --- ESTÁGIO 1: O "Builder" ---
# Usamos uma imagem Python completa para instalar as dependências
FROM python:3.11-slim AS builder

# Define o diretório de trabalho
WORKDIR /usr/src/app

# Define a variável de ambiente para não gerar arquivos .pyc (Sintaxe corrigida)
ENV PYTHONDONTWRITEBYTECODE=1
# Garante que o output do python não seja bufferizado (Sintaxe corrigida)
ENV PYTHONUNBUFFERED=1

# Instala o pipenv para gerenciar dependências de forma mais robusta (opcional, mas bom)
# RUN pip install --upgrade pip

# Copia o arquivo de dependências e instala
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt


# --- ESTÁGIO 2: O "Final" ---
# Usamos uma imagem "slim" que é muito menor
FROM python:3.11-slim AS final
# Instala a dependência de sistema (OpenMP)
RUN apt-get update && apt-get install -y libgomp1 && rm -rf /var/lib/apt/lists/*

# Cria um usuário não-root para rodar a aplicação (mais seguro)
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Define o diretório de trabalho
WORKDIR /home/appuser/app

# Copia as dependências pré-compiladas do estágio "builder"
COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .

# Instala as dependências a partir dos arquivos locais (muito mais rápido)
RUN pip install --no-cache /wheels/*

# Copia os artefatos e o código da aplicação
COPY ./artifacts ./artifacts
COPY ./app ./app

# --- CORREÇÃO ADICIONADA AQUI ---
# Copia o modelo (pipeline) que estava faltando para DENTRO da pasta 'app'
COPY artifacts/pipeline_lgbm.pkl ./app/

# Expõe a porta que a API vai usar
EXPOSE 8000
USER appuser
# Comando para iniciar a API quando o container for executado
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]