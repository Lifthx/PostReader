import fitz  # PyMuPDF

def extract_text_from_pdf_th(pdf_path: str):
    doc = fitz.open(pdf_path)
    results = {}

    ignore_words_subdis_th = {"ตำบล", "ตำ", "บล", "ตบล"}
    ignore_words_dis_th = {"อำเภอ", "เภอ", "อเภอ"}

    for page_num, page in enumerate(doc, start=1):
        print(f"\n--- หน้า {page_num} ---")

        subdis_y_positions = []

        name_instances = page.search_for("ชื่อ")
        number_instances = page.search_for("เลขที่")
        mu_instances = page.search_for("หมู่")
        soi_instances = page.search_for("ซอย")
        road_instances = page.search_for("ถนน")
        subdis_instances = page.search_for("ตำบล")
        dis_instances = page.search_for("อำเภอ")
        province_instances = page.search_for("จังหวัด")
        postnumber = page.search_for("รหัสไปรษณีย์")

        for kw in name_instances:
            rect_after = fitz.Rect(kw.x1, kw.y0, kw.x1 + 200, kw.y1)
            text_after = page.get_textbox(rect_after)
            results["ชื่อ"] = text_after.strip()

        for kw in number_instances:
            rect_after = fitz.Rect(kw.x1 + 1, kw.y0 + 1, kw.x1 + 60, kw.y1)
            text_after = page.get_textbox(rect_after)
            results["เลขที่"] = text_after.strip()

        for kw in mu_instances:
            rect_after = fitz.Rect(kw.x1, kw.y0, kw.x1 + 50, kw.y1)
            text_after = page.get_textbox(rect_after)
            results["หมู่"] = text_after.strip()

        for kw in soi_instances:
            rect_after = fitz.Rect(kw.x1, kw.y0, kw.x1 + 50, kw.y1)
            text_after = page.get_textbox(rect_after)
            results["ซอย"] = text_after.strip()

        for kw in road_instances:
            rect_after = fitz.Rect(kw.x1, kw.y0, kw.x1 + 200, kw.y1)
            text_after = page.get_textbox(rect_after)
            results["ถนน"] = text_after.strip()

        found_values2 = set()
        for kw in subdis_instances:
            rect_after = fitz.Rect(kw.x1, kw.y0, kw.x1 + 200, kw.y1)
            text_after = page.get_textbox(rect_after).strip()

            if text_after:
                words_after = text_after.split()
                filtered = [word for word in words_after if word not in ignore_words_subdis_th]
                if filtered:
                    value = filtered[0]
                    if value not in found_values2:
                        results["ตำบล"] = value
                        found_values2.add(value)

        found_values = set()
        for kw in dis_instances:
            rect_after = fitz.Rect(kw.x1, kw.y0, kw.x1 + 200, kw.y1)
            text_after = page.get_textbox(rect_after).strip()

            if text_after:
                words_after = text_after.split()
                filtered = [word for word in words_after if word not in ignore_words_dis_th]
                if filtered:
                    value = filtered[0]
                    if value not in found_values:
                        results["อำเภอ"] = value
                        found_values.add(value)

        for kw in province_instances:
            rect_after = fitz.Rect(kw.x1, kw.y0, kw.x1 + 200, kw.y1)
            text_after = page.get_textbox(rect_after)
            results["จังหวัด"] = text_after.strip()

        for kw in postnumber:
            rect_after = fitz.Rect(kw.x1, kw.y0, kw.x1 + 200, kw.y1)
            text_after = page.get_textbox(rect_after)
            results["รหัสไปรษณีย์"] = text_after.strip()

    return results
