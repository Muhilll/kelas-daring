import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kelas_daring/endpoint.dart';

class EditKelas extends StatefulWidget {
  final int id;
  const EditKelas({required this.id, super.key});

  @override
  State<EditKelas> createState() => _EditKelasState();
}

class _EditKelasState extends State<EditKelas> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController jenisController = TextEditingController();

  Future<detailKelas> fetchDetailKelas() async {
    String idKelas = widget.id.toString();
    String url = EndPoint.url+'get-kelas-detail?id=' + idKelas;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final detail = detailKelas.fromJson(jsonData['data']);
          namaController.text = detail.namaKelas;
          deskripsiController.text = detail.deskripsi;
          jenisController.text = detail.jenis;
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

  Future<void> editKelas(BuildContext context) async {
    String url = EndPoint.url+'edit-kelas';

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
          'deskripsi': deskripsiController.text,
          'jenis': jenisController.text
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
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 27),
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Edit Kelas',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<detailKelas>(
        future: fetchDetailKelas(),
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
                        labelText: 'Nama kelas',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: TextField(
                      controller: deskripsiController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    alignment: Alignment.center,
                    child: const Text(
                      "Jenis Kelas",
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  RadioExample(jenisController: jenisController),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        editKelas(context);
                      },
                      child: const Text(
                        'Update',
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

enum SingingCharacter { publik, private }

class RadioExample extends StatefulWidget {
  final TextEditingController jenisController;
  const RadioExample({required this.jenisController, super.key});

  @override
  State<RadioExample> createState() => _RadioExampleState();
}

class _RadioExampleState extends State<RadioExample> {
  SingingCharacter? _character;

  @override
  void initState() {
    super.initState();
    if (widget.jenisController.text == "Public") {
      _character = SingingCharacter.publik;
    } else if (widget.jenisController.text == "Private") {
      _character = SingingCharacter.private;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ListTile(
            title: const Text(
              'Public',
              style: TextStyle(fontSize: 15),
            ),
            leading: Radio<SingingCharacter>(
              value: SingingCharacter.publik,
              groupValue: _character,
              onChanged: (SingingCharacter? value) {
                setState(() {
                  _character = value;
                  widget.jenisController.text = "Public";
                });
              },
            ),
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('Private', style: TextStyle(fontSize: 15)),
            leading: Radio<SingingCharacter>(
              value: SingingCharacter.private,
              groupValue: _character,
              onChanged: (SingingCharacter? value) {
                setState(() {
                  _character = value;
                  widget.jenisController.text = "Private";
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

class detailKelas {
  final int id;
  final String namaKelas;
  final String id_user;
  final String deskripsi;
  final String jenis;

  detailKelas({
    required this.id,
    required this.namaKelas,
    required this.id_user,
    required this.deskripsi,
    required this.jenis,
  });

  factory detailKelas.fromJson(Map<String, dynamic> json) {
    return detailKelas(
      id: json['id'],
      namaKelas: json['nama'],
      id_user: json['id_user'],
      deskripsi: json['deskripsi'],
      jenis: json['jenis'],
    );
  }
}
