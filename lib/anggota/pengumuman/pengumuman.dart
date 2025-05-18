import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kelas_daring/endpoint.dart';
class PengumumanPageAnggota extends StatefulWidget {
  final int id;
  const PengumumanPageAnggota({required this.id, super.key});

  @override
  State<PengumumanPageAnggota> createState() => _PengumumanPageAnggotaState();
}

class _PengumumanPageAnggotaState extends State<PengumumanPageAnggota> {
  List<Pengumuman> dataPengumuman = [];

  Future<List<Pengumuman>> fetchPengumuman(BuildContext context) async {
    final String url = EndPoint.url+'pemilik/get-pengumuman?id=${widget.id.toString()}';
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

  Future<void> updatePengumuman() async {
    final result = await fetchPengumuman(context);
    if(mounted){
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
                  id: pengumuman.id,
                );
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

class PengumumanItem extends StatelessWidget {
  final String nama;
  final String desk;
  final int id;

  const PengumumanItem({
    Key? key,
    required this.nama,
    required this.desk,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.all(5),
        width: double.infinity,
        height: 100,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Image.asset('images/pengumuman3.jpg',
                  fit: BoxFit.cover, width: double.infinity),
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        desk,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
