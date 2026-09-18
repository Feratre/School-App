from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import json
import os
import glob

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
RISULTATI_DIR = os.path.join(BASE_DIR, "risultati")

@app.get("/api/compiti")
def get_compiti():
    compiti_file = os.path.join(RISULTATI_DIR, "tutti_i_compiti.json")
    if os.path.exists(compiti_file):
        with open(compiti_file, "r", encoding="utf-8") as f:
            return json.load(f)
    return []

@app.get("/api/verifiche")
def get_verifiche():
    verifiche = []
    # Trova tutti i file che iniziano con verifica_
    for file_path in glob.glob(os.path.join(RISULTATI_DIR, "verifica_*.json")):
        with open(file_path, "r", encoding="utf-8") as f:
            try:
                data = json.load(f)
                if isinstance(data, list):
                    verifiche.extend(data)
                else:
                    verifiche.append(data)
            except:
                pass
    return verifiche

@app.get("/api/trascrizioni")
def get_trascrizioni():
    # Mocking trascrizioni on the NAS for now
    return [
        {"id": "tr_1", "titolo": "Lezione Fisica - Elettrostatica", "data": "14-09-2026", "materia": "Fisica", "durata": "45 min"},
        {"id": "tr_2", "titolo": "Lezione Matematica - Goniometria", "data": "15-09-2026", "materia": "Matematica", "durata": "50 min"}
    ]

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
