import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kelas_daring/endpoint.dart';

final TextEditingController namaController = TextEditingController();
final TextEditingController deskController = TextEditingController();

class EditPengumuman extends StatefulWidget {
  final int id;
  const EditPengumuman({required this.id, super.key});

  @override
  State<EditPengumuman> createState() => _EditPengumumanState();
}

class _EditPengumumanState extends State<EditPengumuman> {
  void clearForm() {
    namaController.clear();
    deskController.clear();
  }

  Future<Pengumuman> fetchDetailPengumuman() async {
    String url = EndPoint.url+'get-pengumuman-detail?id=' + widget.id.toString();
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final detail = Pengumuman.fromJson(jsonData['data']);
          namaController.text = detail.nama;
          deskController.text = detail.desk;
          return detail;
        } else {
          throw Exception('Failed to load kelas data');
        }
      } else {
        throw Exception('Failed to connect to API');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  Future<void> editPengumuman(BuildContext context) async {
    String url = EndPoint.url+'edit-pengumuman';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'id': widget.id.toString(),
          'nama': namaController.text,
          'desk': deskController.text,
        }),
      );

      if (response.statusCode == 200) {
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
      body: FutureBuilder<Pengumuman>(
        future: fetchDetailPengumuman(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Tidak ada data'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Padding(
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
                        if (namaController.text.isEmpty ||
                            deskController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Lengkapi data terlebih dahulu!')),
                          );
                        } else {
                          editPengumuman(context);
                        }
                      },
                      child: const Text(
                        'Edit',
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Data tidak ditemukan.'));
          }
        },
      ),
    );
  }
}

class Pengumuman {
  final int id;
  final int id_kelas;
  final String nama;
  final String desk;

  Pengumuman({
    required this.id,
    required this.id_kelas,
    required this.nama,
    required this.desk,
  });

  factory Pengumuman.fromJson(Map<String, dynamic> json) {
    return Pengumuman(
      id: json['id'],
      id_kelas: json['id_kelas'],
      nama: json['nama'],
      desk: json['desk'],
    );
  }
}
