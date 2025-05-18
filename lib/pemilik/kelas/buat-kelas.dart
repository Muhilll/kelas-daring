import 'package:flutter/material.dart';
import 'package:kelas_daring/endpoint.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final TextEditingController namaController = TextEditingController();
final TextEditingController deskripsiController = TextEditingController();
final TextEditingController jenisController = TextEditingController();

void clearForm() {
  namaController.clear();
  deskripsiController.clear();
  jenisController.clear();
}

Future<void> buatKelas(BuildContext context) async {
  String url = EndPoint.url+'buat-kelas';
  final SharedPreferences prefsIdUser = await SharedPreferences.getInstance();

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'nama': namaController.text,
        'id_user': prefsIdUser.getString('idUser') ?? '',
        'deskripsi': deskripsiController.text,
        'jenis': jenisController.text
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

class FormBuatKelas extends StatelessWidget {
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
          'Buat kelas baru',
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
            Container(
              child: const RadioExample(),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: () {
                  if (namaController.text.isEmpty ||
                      deskripsiController.text.isEmpty ||
                      jenisController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Lengkapi data terlebih dahulu!')),
                    );
                  } else {
                    buatKelas(context);
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

enum SingingCharacter { publik, private }

class RadioExample extends StatefulWidget {
  const RadioExample({super.key});

  @override
  State<RadioExample> createState() => _RadioExampleState();
}

class _RadioExampleState extends State<RadioExample> {
  SingingCharacter? _character;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
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
                    jenisController.text = "Public";
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
                    jenisController.text = "Private";
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
