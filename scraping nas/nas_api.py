from fastapi import FastAPI, UploadFile, File
import shutil
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
UPLOAD_DIR = os.path.abspath(os.path.join(BASE_DIR, "../../notebook_transcription/versione_nas/audio_uploads"))
os.makedirs(UPLOAD_DIR, exist_ok=True)
TRASCRIZIONI_DIR = os.path.abspath(os.path.join(BASE_DIR, "../../notebook_transcription/versione_nas/trascrizioni"))
os.makedirs(TRASCRIZIONI_DIR, exist_ok=True)

@app.get("/api/compiti")
def get_compiti():
    compiti = []
    # Trova tutti i file dei compiti
    for file_path in glob.glob(os.path.join(RISULTATI_DIR, "compiti_*.json")):
        # Evita di duplicare se c'è un file "tutti_i_compiti" vecchio
        if "tutti_i" in file_path:
            continue
        with open(file_path, "r", encoding="utf-8") as f:
            try:
                data = json.load(f)
                if isinstance(data, list):
                    compiti.extend(data)
                else:
                    compiti.append(data)
            except:
                pass
    return compiti

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
    trascrizioni = []
    # Trova tutti i file JSON delle trascrizioni
    for file_path in glob.glob(os.path.join(TRASCRIZIONI_DIR, "*.json")):
        with open(file_path, "r", encoding="utf-8") as f:
            try:
                data = json.load(f)
                if isinstance(data, list):
                    trascrizioni.extend(data)
                else:
                    trascrizioni.append(data)
            except:
                pass
    return trascrizioni


@app.post("/api/upload-audio")
async def upload_audio(file: UploadFile = File(...)):
    try:
        file_path = os.path.join(UPLOAD_DIR, file.filename)
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        return {"status": "success", "filename": file.filename, "path": file_path}
    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
