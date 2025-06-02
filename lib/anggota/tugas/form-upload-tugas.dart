import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kelas_daring/endpoint.dart';

class FormUploadTugas extends StatefulWidget {
  final int id_tugas, id_agtkelas;
  FormUploadTugas({
    required this.id_tugas,
    required this.id_agtkelas,
    super.key,
  });

  @override
  State<FormUploadTugas> createState() => _FormUploadTugasState();
}

class _FormUploadTugasState extends State<FormUploadTugas> {
  File? selectedFile;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'ppt', 'docx', 'pptx'],
    );
    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> uploadTugas(BuildContext context) async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada file yang dipilih')),
      );
      return;
    }

    String url = EndPoint.url+'proses-upload-tugas';
    var request = http.MultipartRequest('POST', Uri.parse(url));

    try {
      request.fields['id_tugas'] = widget.id_tugas.toString();
      request.fields['id_agtkelas'] = widget.id_agtkelas.toString();
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        selectedFile!.path,
      ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tugas berhasil diupload')),
        );
        Navigator.pop(context, true);
      } else {
        try {
          final errorData = jsonDecode(responseBody);
          final errorMessage = errorData['message'] ?? 'Terjadi kesalahan';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        } catch (e) {
          final errorData = jsonDecode(responseBody);
          final errorMessage = errorData['message'] ?? 'Terjadi kesalahan';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $errorMessage')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Upload Tugas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                      text: selectedFile != null
                          ? selectedFile!.path.split('/').last
                          : "Belum ada file yang dipilih",
                    ),
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'File Tugas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: pickFile,
                  child: const Text('Pilih File'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => uploadTugas(context),
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}