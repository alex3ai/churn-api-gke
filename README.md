🤖 API de Predição de Churn com FastAPI e Docker
Este projeto implementa uma solução de ponta a ponta para um problema clássico de negócio: a predição de churn (cancelamento de serviço) de clientes em uma empresa de telecomunicações. O projeto abrange desde a análise exploratória dos dados até o deploy de um modelo de Machine Learning como uma API web robusta e conteinerizada.
🎯 1. O Problema de Negócio
A rotatividade de clientes (churn) é uma métrica crítica para empresas de serviço por assinatura, como as de telecomunicações. Adquirir um novo cliente custa significativamente mais do que reter um existente.
O objetivo deste projeto é construir um serviço de Machine Learning que possa:
Prever com alta acurácia se um cliente está propenso a cancelar seu contrato.
Disponibilizar essa predição em tempo real através de uma API, permitindo que outros sistemas (CRM, plataformas de marketing, etc.) tomem ações proativas para reter o cliente.
📊 2. Análise e Insights dos Dados (EDA)
A análise exploratória (realizada no notebook Análise_churn_telco_customer.ipynb) revelou insights cruciais que guiaram a modelagem:
Dataset Desbalanceado: Aproximadamente 26.5% dos clientes na base de dados cancelaram o serviço. Isso exigiu o uso de técnicas como a estratificação na divisão dos dados e a escolha da métrica ROC AUC como principal avaliador de performance.
Fatores Comportamentais vs. Demográficos: A análise demonstrou que o comportamento do cliente é muito mais preditivo do que seus dados demográficos.
Principais Indicadores de Churn:
Tipo de Contrato: Clientes com contrato "Mês a Mês" têm uma taxa de churn drasticamente maior.
Método de Pagamento: Pagamento via "Cheque Eletrônico" está associado a um churn mais elevado.
Tempo de Contrato (Tenure): Clientes mais novos (baixo Tenure_Months) são mais propensos a cancelar.
Serviços de Proteção: Clientes sem serviços como Online_Security, Online_Backup e Tech_Support tendem a sair mais.
⚙️ 3. Metodologia de Machine Learning
Para garantir um fluxo de trabalho robusto e replicável (princípios de MLOps), foi utilizada uma Pipeline do Scikit-learn.
Pré-processamento (ColumnTransformer):
Variáveis Numéricas (Tenure_Months, Monthly_Charges, etc.): Passaram por uma padronização utilizando StandardScaler.
Variáveis Categóricas (Contract, Payment_Method, etc.): Foram transformadas usando OneHotEncoder para converter as categorias em formato numérico.
Modelagem e Avaliação:
Foram avaliados três modelos distintos: Regressão Logística, Random Forest e LightGBM.
O LightGBM foi selecionado como o modelo final devido à sua excelente performance e eficiência, atingindo uma pontuação ROC AUC de 0.85 nos dados de teste, indicando um ótimo poder preditivo.
Interpretabilidade do Modelo:
As features mais importantes para o modelo LightGBM foram Tenure_Months, Monthly_Charges e Contract, confirmando os insights da análise exploratória.
🚀 4. Tecnologias Utilizadas
Python 3.9+
Análise e Modelagem: Pandas, Scikit-learn, LightGBM, Joblib
API: FastAPI (para alta performance) e Uvicorn
Containerização: Docker e Docker Compose
Validação de Dados: Pydantic
📂 5. Estrutura do Projeto
code
Code
/
|-- artifacts/            # Armazena o pipeline treinado (pipeline_lgbm.pkl)
|-- app/                  # Código fonte da API FastAPI
|   |-- main.py
|-- .dockerignore         # Arquivos a serem ignorados pelo Docker
|-- Dockerfile            # Instruções para construir a imagem Docker
|-- requirements.txt      # Dependências Python do projeto
|-- README.md             # Esta documentação
|-- Análise_churn_telco_customer.ipynb  # Notebook com a análise e treinamento do modelo
💻 6. Como Executar a API Localmente
Pré-requisitos:
Git
Docker instalado e em execução.
Passos:
Clone o repositório:
code
Bash
git clone https://github.com/SEU_USUARIO/NOME_DO_REPOSITORIO.git
cd NOME_DO_REPOSITORIO
Construa a imagem Docker:
Este comando lê o Dockerfile e monta a imagem da nossa aplicação com todas as dependências.
code
Bash
docker build -t churn-api .
Execute o container:
Este comando inicia um container a partir da imagem, mapeando a porta 8000 da sua máquina para a porta 8000 do container.
code
Bash
docker run -d -p 8000:8000 --name churn-app churn-api
A API está pronta!
Você pode verificar se o container está rodando com docker ps.
📖 7. Endpoints da API
Após iniciar o container, a API estará acessível em http://localhost:8000.
GET / - Health Check
Endpoint para verificar se a API está no ar e funcionando.
URL: http://localhost:8000
Resposta de Sucesso (200 OK):
code
JSON
{
  "status": "ok",
  "message": "API de Predição de Churn está no ar!"
}
POST /predict - Predição de Churn
Recebe os dados de um cliente em formato JSON e retorna a predição de churn e a probabilidade de confiança.
URL: http://localhost:8000/predict
Corpo da Requisição (Exemplo):
code
JSON
{
  "Gender": "Female",
  "Senior_Citizen": "No",
  "Partner": "Yes",
  "Dependents": "No",
  "Tenure_Months": 1,
  "Phone_Service": "No",
  "Multiple_Lines": "Phone_service",
  "Internet_Service": "DSL",
  "Online_Security": "No",
  "Online_Backup": "Yes",
  "Device_Protection": "No",
  "Tech_Support": "No",
  "Streaming_TV": "No",
  "Streaming_Movies": "No",
  "Contract": "Month-to-month",
  "Paperless_Billing": "Yes",
  "Payment_Method": "Electronic_check",
  "Monthly_Charges": 29.85,
  "Total_Charges": 29.85
}
Resposta de Sucesso (200 OK):
code
JSON
{
  "predicao": "Sim",
  "probabilidade_de_confianca": "62.34%"
}
📄 Documentação Interativa (Swagger)
O FastAPI gera automaticamente uma documentação interativa. Você pode acessá-la para visualizar todos os endpoints e testá-los diretamente pelo navegador:
URL: http://localhost:8000/docs
🔮 8. Próximos Passos
Este projeto serve como uma base sólida. As próximas etapas para evoluí-lo seriam:
Otimização de Hiperparâmetros: Utilizar GridSearchCV ou RandomizedSearchCV para encontrar os melhores parâmetros para o LightGBM e potencialmente aumentar a performance.
CI/CD: Implementar um pipeline de Integração e Entrega Contínua (usando GitHub Actions, por exemplo) para automatizar testes e deploys.
Deploy na Nuvem: Publicar a imagem Docker em um serviço como Google Cloud Run, AWS Fargate ou Azure Container Instances para tornar a API publicamente acessível.
Monitoramento: Adicionar logging e monitoramento para acompanhar a performance do modelo e da API em produção.