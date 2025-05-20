import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kelas_daring/endpoint.dart';

final TextEditingController namaController = TextEditingController();
final TextEditingController deskController = TextEditingController();

class FormBuatPengumuman extends StatefulWidget {
  final int id;
  const FormBuatPengumuman({required this.id, super.key});

  @override
  State<FormBuatPengumuman> createState() => _FormBuatPengumumanState();
}

class _FormBuatPengumumanState extends State<FormBuatPengumuman> {
  File? selectedFile;

  void clearForm() {
    namaController.clear();
    deskController.clear();
    selectedFile = null;
  }

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

  Future<void> buatPengumuman(BuildContext context) async {
    String url = EndPoint.url + 'buat-pengumuman';
    var request = http.MultipartRequest('POST', Uri.parse(url));

    try {
      request.fields['id_kelas'] = widget.id.toString();
      request.fields['nama'] = namaController.text;
      request.fields['desk'] = deskController.text;
      if (selectedFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          selectedFile!.path,
        ));
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil membuat pengumuman!')),
        );
        Navigator.pop(context, true);
      } else {
        final errorMessage = responseBody.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $errorMessage')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    clearForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 27),
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Buat Pengumuman baru',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Pengumuman',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: deskController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickFile,
              child: const Text('Pilih File'),
            ),
            if (selectedFile != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'File dipilih: ${selectedFile!.path.split('/').last}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (namaController.text.isEmpty ||
                    deskController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Lengkapi data terlebih dahulu!')),
                  );
                } else {
                  buatPengumuman(context);
                }
              },
              child: const Text('Buat'),
            ),
          ],
        ),
      ),
    );
  }
}
