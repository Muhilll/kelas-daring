import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kelas_daring/anggota/kelas/detail-kelas.dart';
import 'package:kelas_daring/endpoint.dart';
import 'package:kelas_daring/pemilik/absensi/absen.dart';
import 'package:kelas_daring/pemilik/agt-kelas/agt.dart';
import 'package:kelas_daring/pemilik/kelas/edit-kelas.dart';
import 'package:kelas_daring/pemilik/pengumuman/pengumuman.dart';
import 'package:kelas_daring/pemilik/tugas/index.dart';

class DetailKelas extends StatefulWidget {
  final int id_kelas;
  const DetailKelas({required this.id_kelas, super.key});

  @override
  State<DetailKelas> createState() => _DetailKelasState();
}

class _DetailKelasState extends State<DetailKelas> {
  late Future<detailKelas> detailFuture;

  @override
  void initState() {
    super.initState();



    detailFuture = fetchDetailKelas(context);
  }

  Future<detailKelas> fetchDetailKelas(BuildContext context) async {
    String url = EndPoint.url+'get-kelas-detail?id=' + widget.id_kelas.toString();
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          return detailKelas.fromJson(jsonData['data']);
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

  void editKelas(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditKelas(id: widget.id_kelas),
      ),
    );

    if (result == true) {
      setState(() {
        detailFuture = fetchDetailKelas(context);
      });
    }
  }

  hapusKelas(BuildContext context) {
    String url =  EndPoint.url+'hapus-kelas?id=' + widget.id_kelas.toString();
    try {
      http.delete(Uri.parse(url));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void showKonfirmasiHapus(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus kelas ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                hapusKelas(context);
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true); // Tindakan kembali
            },
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white, size: 27),
          backgroundColor: Colors.blue,
          title: FutureBuilder<detailKelas>(
            future: fetchDetailKelas(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('-', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white));
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                return Text(
                  snapshot.data!.namaKelas,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                );
              } else {
                return const Text('Detail Kelas');
              }
            },
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == 'edit') {
                  editKelas(context);
                } else if (value == 'hapus') {
                  showKonfirmasiHapus(context);
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
          ],
        ),
        body: NavigationExample(id: widget.id_kelas),
      ),
    );
  }
}

class NavigationExample extends StatefulWidget {
  final int id;

  const NavigationExample({required this.id, super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}


class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.announcement_outlined,
              color: Colors.blue,
            ),
            icon: Icon(Icons.announcement_outlined),
            label: 'Pengumuman',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.wysiwyg_outlined,
              color: Colors.blue,
            ),
            icon: Icon(Icons.wysiwyg_outlined),
            label: 'Absensi',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.assignment_outlined,
              color: Colors.blue,
            ),
            icon: Icon(Icons.assignment_outlined),
            label: 'Tugas',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.people_alt_outlined,
              color: Colors.blue,
            ),
            icon: Icon(Icons.people_alt_outlined),
            label: 'Anggota',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        PengumumanPage(id: widget.id),

        AbsensiPemilik(id: widget.id),

        TugasPage(id: widget.id),
        
        AgtPage(id: widget.id)
      ][currentPageIndex],
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
