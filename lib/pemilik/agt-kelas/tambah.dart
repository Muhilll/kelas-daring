import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kelas_daring/endpoint.dart';

class TambahAgtPage extends StatefulWidget {
  final int id_kelas;
  const TambahAgtPage({required this.id_kelas, super.key});

  @override
  State<TambahAgtPage> createState() => _TambahAgtPageState();
}

class _TambahAgtPageState extends State<TambahAgtPage> {
  final TextEditingController nimController = TextEditingController();
  Map<String, dynamic>? userData;
  bool isLoading = false;

  Future<void> cariUser() async {
    setState(() => isLoading = true);
    String url = EndPoint.url +'pemilik/get-user/nim?id_kelas=${widget.id_kelas}&nim=${nimController.text}';
    final response = await http.get(Uri.parse(url));

    setState(() => isLoading = false);
    final data = json.decode(response.body);
    if (data['success']) {
      setState(() {
        userData = data['data'];
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Informasi User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Nama: ${userData!['nama']}"),
              Text("NIM: ${userData!['nim']}"),
              Text("Email: ${userData!['email']}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                tambahAnggota(userData!['id']);
              },
              child: Text("Tambah Anggota"),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }
  }

  Future<void> tambahAnggota(int idUser) async {
    String url = EndPoint.url + 'pemilik/tmbh-agt';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id_kelas': widget.id_kelas,
        'id_user': idUser,
      }),
    );

    final data = json.decode(response.body);
    if (data['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berhasil menambahkan anggota')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Tambah Anggota',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nimController,
              decoration: const InputDecoration(
                labelText: 'Masukkan NIM',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : cariUser,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : const Text('Cari'),
            ),
          ],
        ),
      ),
    );
  }
}
