import joblib
import json
import pandas as pd
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os
import logging

# --- Configuração do Logging ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# 1. Inicializa o aplicativo FastAPI
app = FastAPI(
    title="API de Predição de Churn",
    description="Uma API para prever a probabilidade de um cliente cancelar um serviço com base em seus dados.",
    version="1.0.3" # Versão ajustada para GKE
)

# --- Carregamento dos Artefatos ---
try:
    # O main.py está em /code/app
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    
    # Os artefatos estão em /code/artifacts (voltando um nível de 'app')
    ARTIFACTS_DIR = os.path.join(BASE_DIR, "../artifacts")
    MODEL_PATH = os.path.join(ARTIFACTS_DIR, 'pipeline_lgbm.pkl')
    
    if not os.path.exists(MODEL_PATH):
        raise FileNotFoundError(f"Arquivo 'pipeline_lgbm.pkl' não encontrado em: {MODEL_PATH}")

    model = joblib.load(MODEL_PATH)
    logging.info(f"{MODEL_PATH} carregado com sucesso. API pronta.")

except Exception as e:
    logging.error(f"Erro crítico ao carregar 'pipeline_lgbm.pkl': {e}")
    # Importante: Se o modelo falhar, a API não deve subir (fail fast)
    raise RuntimeError(f"Falha ao carregar o artefato de ML: {e}")


# 2. Definindo o Schema de Entrada com Pydantic
class CustomerData(BaseModel):
    Gender: str
    Senior_Citizen: str 
    Partner: str
    Dependents: str
    Tenure_Months: int
    Phone_Service: str
    Multiple_Lines: str
    Internet_Service: str
    Online_Security: str
    Online_Backup: str
    Device_Protection: str
    Tech_Support: str
    Streaming_TV: str
    Streaming_Movies: str
    Contract: str
    Paperless_Billing: str
    Payment_Method: str
    Monthly_Charges: float
    Total_Charges: float
    
    class Config:
        json_schema_extra = {
            "example": {
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
        }

# 3. Endpoint de "Health Check"
@app.get("/", tags=["Health_Check"])
def read_root():
    return {"status": "ok", "message": "API de Predição de Churn está no ar (GKE)!"}

# 4. Endpoint de Predição
@app.post("/predict", tags=["Prediction"])
def predict_churn(data: CustomerData):
    """
    Recebe os dados de um cliente e retorna a predição de churn.
    """
    try:
        # 1. Converter os dados de entrada em um DataFrame do Pandas
        input_df = pd.DataFrame([data.model_dump()])

        # 2. Fazer a Predição
        prediction = model.predict(input_df)[0]
        probability = model.predict_proba(input_df)[0]

        # 3. Formatar a Resposta
        churn_status = "Sim" if prediction == 1 else "Não"
        confidence = probability[prediction]
        
        return {
            "predicao": churn_status,
            "probabilidade_de_confianca": f"{confidence:.2%}" 
        }

    except Exception as e:
        logging.error(f"Erro durante a predição: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Erro interno no servidor: {e}")