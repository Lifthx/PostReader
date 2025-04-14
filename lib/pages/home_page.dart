import 'package:flutter/material.dart';
import 'th.dart';
import 'eng.dart';
import 'showtext.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text('OCR PostReader', style: GoogleFonts.prompt()),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.text_snippet_outlined,
                size: 80, color: Colors.indigo),
            const SizedBox(height: 24),
            Text(
              'OCR ดึงข้อมูลจ่าหน้าไปรษณีย์',
              style:
                  GoogleFonts.prompt(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UploadEngPage()),
                );
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child:
                  Text('ภาษาอังกฤษ', style: GoogleFonts.prompt(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UploadThaPage()),
                );
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: Text('ภาษาไทย', style: GoogleFonts.prompt(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShowTextPage()),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text('ข้อความ', style: GoogleFonts.prompt(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
