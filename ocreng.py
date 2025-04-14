import fitz  # PyMuPDF

def extract_text_from_pdf_en(pdf_path: str):
    doc = fitz.open(pdf_path)
    results = {}

    search_config = {
        "ชื่อ": ("Name", 200),
        "เลขที่": ("No.", 50),
        "หมู่": ("Moo", 50),
        "ซอย": ("Soi", 50),
        "ถนน": ("Road", 200),
        "ตำบล": ("Sub-district", 200),
        "อำเภอ": ("District", 200),
        "จังหวัด": ("Province", 200),
        "รหัสไปรษณีย์": ("Postcode", 200),
    }

    ignore_words_subdis = {"ตำบล", "ตำ", "บล", "ตบล"}
    ignore_words_dis = {"Sub-district", "Sub", "-", "district"}

    for page_num, page in enumerate(doc, start=1):
        print(f"\n--- หน้า {page_num} ---")

        subdis_y_positions = []

        for label_thai, (keyword_eng, box_width) in search_config.items():
            instances = page.search_for(keyword_eng)

            for kw in instances:
                rect_after = fitz.Rect(kw.x1, kw.y0, kw.x1 + box_width, kw.y1)
                text_after = page.get_textbox(rect_after).strip()

                if label_thai == "ตำบล":
                    subdis_y_positions.append(kw.y0)
                    words = [w for w in text_after.split() if w not in ignore_words_subdis]
                    if words:
                        results[label_thai] = words[0]

                elif label_thai == "อำเภอ":
                    if any(abs(kw.y0 - y) < 5 for y in subdis_y_positions):
                        continue
                    words = [w for w in text_after.split() if w not in ignore_words_dis]
                    if words:
                        results[label_thai] = words[0]

                else:
                    results[label_thai] = text_after

    return results
