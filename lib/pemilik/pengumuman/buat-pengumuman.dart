import 'package:flutter/material.dart';
import 'dart:convert';
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
  void clearForm() {
    namaController.clear();
    deskController.clear();
  }

  Future<void> buatPengumuman(BuildContext context) async {
    String url = EndPoint.url + 'buat-pengumuman';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'id_kelas': widget.id.toString(),
          'nama': namaController.text,
          'desk': deskController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfull')),
        );
        Navigator.pop(context, true);
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    clearForm();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 27),
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          textAlign: TextAlign.center,
          'Buat Pengumuman baru',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pengumuman',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: TextField(
                controller: deskController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: () {
                  if (namaController.text.isEmpty || deskController.text.isEmpty ) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Lengkapi data terlebih dahulu!')),
                    );
                  } else {
                    buatPengumuman(context);
                  }
                },
                child: const Text(
                  'Buat',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}