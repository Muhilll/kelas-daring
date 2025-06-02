import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kelas_daring/anggota/absensi/absen.dart';
import 'package:kelas_daring/anggota/agt-kelas/agt.dart';
import 'package:kelas_daring/anggota/pengumuman/pengumuman.dart';
import 'package:kelas_daring/anggota/tugas/tugas.dart';
import 'package:kelas_daring/endpoint.dart';
import 'package:kelas_daring/pemilik/agt-kelas/agt.dart';
import 'package:shared_preferences/shared_preferences.dart';

int id_kelas = 0;

class DetailKelasAnggota extends StatefulWidget {
  final int id;
  const DetailKelasAnggota({required this.id, super.key});

  @override
  State<DetailKelasAnggota> createState() => _DetailKelasAnggotaState();
}

class _DetailKelasAnggotaState extends State<DetailKelasAnggota> {
  late Future<detailKelas> detailFuture;

  @override
  void initState() {
    super.initState();
    detailFuture = fetchDetailKelas(context);
  }

  Future<detailKelas> fetchDetailKelas(BuildContext context) async {
    id_kelas = widget.id;
    String url = EndPoint.url + 'get-kelas-detail?id=' + id_kelas.toString();
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

  Future<void> keluarDariKelas() async {
    bool konfirmasi = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah kamu yakin ingin keluar dari kelas ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Keluar"),
          ),
        ],
      ),
    );

    if (!konfirmasi) return;

    try {
      String url = EndPoint.url + 'out-kelas';
      final SharedPreferences prefsIdUser =
          await SharedPreferences.getInstance();
      String id_user = prefsIdUser.getString('idUser') ?? "";
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_kelas': id_kelas.toString(),
          'id_user': id_user,
        }),
      );

      final data = json.decode(response.body);

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil keluar dari kelas")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal keluar dari kelas')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
                return const Text('-',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white));
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
                if (value == 'keluar') {
                  keluarDariKelas();
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'keluar',
                  child: Text('Keluar'),
                ),
              ],
            )
          ],
        ),
        body: const NavigationExample(),
      ),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

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
        PengumumanPageAnggota(id: id_kelas),
        AbsensiAnggota(id: id_kelas),
        TugasPageAnggota(id: id_kelas),
        AgtPageAnggota(id: id_kelas)
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
