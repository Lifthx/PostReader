import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/services.dart'; 

class UploadEngPage extends StatefulWidget {
  const UploadEngPage({super.key});

  @override
  State<UploadEngPage> createState() => _UploadEngPageState();
}

class _UploadEngPageState extends State<UploadEngPage> {
  FilePickerResult? _result;
  PlatformFile? _selectedFile;
  Uint8List? _selectedBytes;
  String? _selectedFileName;
  String _resultText = '';
  bool _isLoading = false;

  final apiUrl = 'http://127.0.0.1:8000'; 

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _result = result;
        _selectedFile = result.files.first;
        _selectedBytes = result.files.first.bytes;
        _selectedFileName = result.files.first.name;
      });
    }
  }

  Future<void> _uploadPDF(String lang) async {
    if (_selectedFile == null && _selectedBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกไฟล์ PDF ก่อน')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _resultText = ''; // clear
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/upload_pdf?lang=$lang'),
      );

      
      request.fields['lang'] = lang; 

      // check web or mobile bro
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          _selectedBytes!,
          filename: _selectedFileName ?? 'document.pdf',
          contentType: MediaType('application', 'pdf'),
        ));
      } else {
        if (_selectedFile != null && _selectedFile!.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'file',
            _selectedFile!.path!,
            contentType: MediaType('application', 'pdf'),
          ));
        } else {
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            _selectedBytes!,
            filename: _selectedFileName ?? 'document.pdf',
            contentType: MediaType('application', 'pdf'),
          ));
        }
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      print("Response Body: $respStr"); 

      final respJson = jsonDecode(respStr);

      if (!mounted) return;

      setState(() {
        // แยกบรรทัด 
        if (response.statusCode == 200) {
          Map<String, dynamic> extractedData = respJson['data'];
          _resultText = extractedData.entries
              .map((entry) => '${entry.key}: ${entry.value}')
              .join('\n'); 
        } else {
          _resultText = 'ผิดพลาด: ${respJson['error'] ?? 'ไม่ทราบสาเหตุ'}';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resultText = 'เกิดข้อผิดพลาด: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  
  Future<void> _copyToClipboard() async {
    if (_resultText.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _resultText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('คัดลอกข้อความแล้ว')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OCR ภาษาอังกฤษ', style: GoogleFonts.prompt()),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: _pickPDF,
                  child: const Text('เลือกไฟล์ PDF ภาษาอังกฤษ'),
                ),
                const SizedBox(height: 16),
                if (_selectedFileName != null)
                  Text(
                    'ไฟล์ที่เลือก: $_selectedFileName',
                    style: GoogleFonts.prompt(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _uploadPDF('en'),
                  child: const Text('ดึงข้อความเลย !'),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _resultText.isNotEmpty
                              ? _resultText
                              : 'ไม่มีข้อความที่ดึงได้',
                          style: GoogleFonts.prompt(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        if (_resultText.isNotEmpty)
                          FilledButton(
                            onPressed: _copyToClipboard,
                            child: const Text('คัดลอกข้อความ'),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
