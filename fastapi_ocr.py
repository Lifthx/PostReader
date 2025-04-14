from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import ORJSONResponse
from pymongo import MongoClient
from pathlib import Path
import datetime
from ocrthai import extract_text_from_pdf_th
from ocreng import extract_text_from_pdf_en

app = FastAPI()

# CORS setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Upload folder
UPLOAD_FOLDER = Path("uploads")
UPLOAD_FOLDER.mkdir(exist_ok=True)

# MongoDB setup
client = MongoClient("mongodb://localhost:27017/")
db = client["OCR"]
collection = db["data"]

@app.post("/upload_pdf")
async def upload_pdf(
    file: UploadFile = File(...),
    lang: str = Form(...)  # รับค่าจาก Form
):
    # ตรวจสอบว่าได้รับ lang หรือไม่
    if not lang:
        return {"error": "Missing 'lang' field in the request."}

    if not file.filename.endswith(".pdf"):
        return {"error": "Invalid file type. Please upload a PDF."}

    pdf_path = UPLOAD_FOLDER / file.filename
    with pdf_path.open("wb") as f:
        f.write(await file.read())

    # เรียกใช้ฟังก์ชันตามภาษา
    if lang == "en":
        extracted_data = extract_text_from_pdf_en(str(pdf_path))
    elif lang == "th":
        extracted_data = extract_text_from_pdf_th(str(pdf_path))

    last_doc = collection.find_one(sort=[("id", -1)])
    next_id = (last_doc["id"] + 1) if last_doc and "id" in last_doc else 1

    document = {
        "id": next_id,
        "filename": file.filename,
        "lang": lang,
        "data": extracted_data,
        "uploaded_at": datetime.datetime.utcnow()
    }

    collection.insert_one(document)

    return {"message": "PDF uploaded and processed successfully", "data": extracted_data}

@app.get("/get_ocr_texts", response_class=ORJSONResponse)
def get_ocr_texts():
    data = list(collection.find({}, {"_id": 0}))
    return ORJSONResponse(content=data)
