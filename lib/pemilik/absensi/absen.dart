import 'package:flutter/material.dart';
import 'package:kelas_daring/endpoint.dart';
import 'package:kelas_daring/pemilik/absensi/buat-absen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kelas_daring/pemilik/absensi/kehadiran.dart';

class AbsensiPemilik extends StatefulWidget {
  int id;
  AbsensiPemilik({required this.id, super.key});

  @override
  State<AbsensiPemilik> createState() => _AbsensiPemilikState();
}

class _AbsensiPemilikState extends State<AbsensiPemilik> {
  List<Absensi> dataAbsensi = [];

  Future<List<Absensi>> fetchAbsensi(BuildContext context) async {
    final String url = EndPoint.url+'pemilik/get-absensi?id_kelas=${widget.id.toString()}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          List<dynamic> data = jsonData['data'];
          return data.map((item) => Absensi.fromJson(item)).toList();
        } else {
          throw Exception('Gagal memuat data Absensi.');
        }
      } else {
        throw Exception('Gagal terhubung ke server.');
      }
    } catch (e) {
      print('Error: $e'); // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat Absensi')),
      );
      return [];
    }
  }

  Future<void> updateAbsensi() async {
    final result = await fetchAbsensi(context);
    if (mounted) {
      setState(() {
        dataAbsensi = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    updateAbsensi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: dataAbsensi.isEmpty
            ? Center(child: Text('Tidak ada data'))
            : ListView.builder(
                itemCount: dataAbsensi.length,
                itemBuilder: (context, index) {
                  final absensi = dataAbsensi[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  absensi.nama,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                Text("Tanggal: "+absensi.tgl),
                                Text("Batas: "+absensi.batas)
                              ]),
                          Row(
                            children: [
                              SizedBox(width: 5),
                              ElevatedButton(
                                  onPressed: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                KehadiranPemilik(
                                                    id_absensi: absensi.id)));
                                  },
                                  style: const ButtonStyle(
                                      backgroundColor:
                                          WidgetStatePropertyAll(Colors.blue)),
                                  child: const Text(
                                    'Lihat',
                                    style: TextStyle(color: Colors.white),
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FormBuatAbsensi(id: widget.id)));
            if (result == true) {
              setState(() {
                updateAbsensi();
              });
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

class Absensi {
  final int id;
  final int id_kelas;
  final String nama;
  final String tgl;
  final String batas;

  Absensi({
    required this.id,
    required this.id_kelas,
    required this.nama,
    required this.tgl,
    required this.batas,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) {
    return Absensi(
      id: json['id'],
      id_kelas: json['id_kelas'],
      nama: json['nama'],
      tgl: json['tgl'],
      batas: json['batas'],
    );
  }
}