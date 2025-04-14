import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowTextPage extends StatefulWidget {
  const ShowTextPage({super.key});

  @override
  State<ShowTextPage> createState() => _ShowTextPageState();
}

class _ShowTextPageState extends State<ShowTextPage> {
  List<dynamic> _texts = [];
  String? _selectedFile;
  Map<String, List<Map<String, dynamic>>> groupedFiles = {};
  Map<String, dynamic>? _selectedText;
  bool _isLoading = true;

  final apiUrl = 'http://127.0.0.1:8000';

  @override
  void initState() {
    super.initState();
    _fetchTexts();
  }

  Future<void> _fetchTexts() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/get_ocr_texts'));
      if (response.statusCode == 200) {
        setState(() {
          _texts = jsonDecode(utf8.decode(response.bodyBytes));
          _isLoading = false;
          _groupFiles();
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _groupFiles() {
    groupedFiles = {};
    for (var text in _texts) {
      String fileName = text['filename'];
      groupedFiles.putIfAbsent(fileName, () => []).add(text);
    }
  }

  String _formatData(Map<String, dynamic> text) {
    final data = text['data'];
    if (data == null || data is! Map) return 'ไม่มีข้อมูล';

    final buffer = StringBuffer();
    data.forEach((key, value) {
      buffer.writeln('$key: $value');
    });

    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final fileNames = ['กรุณาเลือกไฟล์'] + groupedFiles.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('ดูข้อความ OCR', style: GoogleFonts.prompt()),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เลือกไฟล์ที่ต้องการดู:',
                    style: GoogleFonts.prompt(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: _selectedFile,
                    hint: const Text('กรุณาเลือกไฟล์'),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFile = newValue;
                        _selectedText = groupedFiles[_selectedFile]?.first;
                      });
                    },
                    items: groupedFiles.keys
                        .map<DropdownMenuItem<String>>((String fileName) {
                      return DropdownMenuItem<String>(
                        value: fileName,
                        child: Text(fileName),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  if (_selectedText != null)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'ข้อมูล OCR:',
                                style: GoogleFonts.prompt(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SelectableText(
                                _formatData(_selectedText!),
                                style: GoogleFonts.prompt(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final text = _formatData(_selectedText!);
                                    Clipboard.setData(
                                        ClipboardData(text: text));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('คัดลอกข้อความเรียบร้อยแล้ว'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy),
                                  label: const Text('คัดลอกข้อความ'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
