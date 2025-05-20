import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kelas_daring/endpoint.dart';
import 'package:kelas_daring/endpointFile.dart';
import 'package:kelas_daring/pemilik/pengumuman/buat-pengumuman.dart';
import 'package:kelas_daring/pemilik/pengumuman/edit-pengumuman.dart';
import 'package:url_launcher/url_launcher.dart';

class PengumumanPage extends StatefulWidget {
  final int id;
  const PengumumanPage({required this.id, super.key});

  @override
  State<PengumumanPage> createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  List<Pengumuman> dataPengumuman = [];

  Future<List<Pengumuman>> fetchPengumuman(BuildContext context) async {
    final String url =
        EndPoint.url + 'pemilik/get-pengumuman?id=${widget.id.toString()}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          List<dynamic> data = jsonData['data'];
          return data.map((item) => Pengumuman.fromJson(item)).toList();
        } else {
          throw Exception('Gagal memuat data pengumuman.');
        }
      } else {
        throw Exception('Gagal terhubung ke server.');
      }
    } catch (e) {
      print('Error: $e'); // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat pengumuman')),
      );
      return [];
    }
  }

  void editPengumuman(BuildContext context, int id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPengumuman(id: id),
      ),
    );

    if (result == true) {
      setState(() {
        updatePengumuman();
      });
    }
  }

  void hapusPengumuman(BuildContext context, int id) {
    String url = EndPoint.url + 'hapus-pengumuman?id=' + id.toString();
    try {
      http.delete(Uri.parse(url));
      setState(() {
        updatePengumuman();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void showKonfirmasiHapus(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content:
              const Text('Apakah Anda yakin ingin menghapus pengumuman ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                hapusPengumuman(context, id);
                Navigator.of(context).pop();
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updatePengumuman() async {
    final result = await fetchPengumuman(context);
    if (mounted) {
      setState(() {
        dataPengumuman = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    updatePengumuman();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: dataPengumuman.isEmpty
            ? Center(child: Text('Tidak ada data'))
            : ListView.builder(
                itemCount: dataPengumuman.length,
                itemBuilder: (context, index) {
                  final pengumuman = dataPengumuman[index];
                  return PengumumanItem(
                    nama: pengumuman.nama,
                    desk: pengumuman.desk,
                    materi: EndPointFile.url + pengumuman.file,
                    id: pengumuman.id,
                    onEdit: (id) => {editPengumuman(context, id)},
                    onHapus: (id) => {showKonfirmasiHapus(context, id)},
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormBuatPengumuman(id: widget.id),
              ),
            );

            if (result == true) {
              updatePengumuman();
            }
          },
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ));
  }
}

class Pengumuman {
  final int id;
  final int id_kelas;
  final String nama;
  final String desk;
  final String file;

  Pengumuman(
      {required this.id,
      required this.id_kelas,
      required this.nama,
      required this.desk,
      required this.file});

  factory Pengumuman.fromJson(Map<String, dynamic> json) {
    return Pengumuman(
        id: json['id'],
        id_kelas: json['id_kelas'],
        nama: json['nama'],
        desk: json['desk'],
        file: json['file'] ?? '');
  }
}

class PengumumanItem extends StatelessWidget {
  final String nama;
  final String desk;
  final String materi;
  final int id;
  final Function(int id) onEdit;
  final Function(int id) onHapus;

  const PengumumanItem(
      {Key? key,
      required this.nama,
      required this.desk,
      required this.materi,
      required this.id,
      required this.onEdit,
      required this.onHapus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.all(5),
        width: double.infinity,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Image.asset('images/pengumuman3.jpg',
                  fit: BoxFit.cover, width: double.infinity),
            ),
            Positioned(
              right: 0,
              bottom: 55,
              child: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_outlined,
                  color: Colors.white,
                ),
                onSelected: (String value) {
                  if (value == 'edit') {
                    onEdit(id);
                  } else if (value == 'hapus') {
                    // Aksi untuk Hapus
                    onHapus(id);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'hapus',
                    child: Text('Hapus'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    child: Text(
                      desk,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (materi != EndPointFile.url)
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.cyan),
                      ),
                      onPressed: () async {
                        await launchUrl(
                          Uri.parse(materi),
                        );
                      },
                      child: const Text(
                        'Materi',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
