import 'package:flutter/material.dart';
import 'package:kelas_daring/anggota/absensi/submit.dart';
import 'package:http/http.dart' as http;
import 'package:kelas_daring/endpoint.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

agtKelas? currentAgtKelas;

class AbsensiAnggota extends StatefulWidget {
  int id;
  AbsensiAnggota({required this.id, super.key});

  @override
  State<AbsensiAnggota> createState() => _AbsensiAnggotaState();
}

class _AbsensiAnggotaState extends State<AbsensiAnggota> {
  List<Absensi> dataAbsensi = [];
  late Future<agtKelas> futureAgtKelas;

  Future<List<Absensi>> fetchAbsensi(BuildContext context) async {
    final String url =
        EndPoint.url + 'anggota/get-absensi?id_kelas=${widget.id.toString()}';
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

  Future<agtKelas> fetchAgtKelas(BuildContext context) async {
    final SharedPreferences prefsIdUser = await SharedPreferences.getInstance();
    String id_user = prefsIdUser.getString('idUser') ?? "";
    String url = EndPoint.url + 'get-data-agtkelas';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'id_kelas': widget.id.toString(),
          'id_user': id_user,
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          return agtKelas.fromJson(jsonData['data']);
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

  Future<void> updateAbsensi() async {
    final result = await fetchAbsensi(context);
    final agt = await fetchAgtKelas(context);

    for (var absen in result) {
      final res = await http.post(
        Uri.parse(EndPoint.url + 'anggota/cek-kehadiran'),
        body: {
          'id_absensi': absen.id.toString(),
          'id_agtkelas': agt.id.toString(),
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        absen.sudahAbsen = data['sudah_absen'] == true;
      }
    }

    if (mounted) {
      setState(() {
        dataAbsensi = result;
        currentAgtKelas = agt;
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
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text("Tanggal: " + absensi.tgl),
                              Text("Batas: " + absensi.batas)
                            ]),
                        Row(
                          children: [
                            SizedBox(width: 5),
                            ElevatedButton(
                              onPressed: absensi.sudahAbsen
                                  ? null
                                  : () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SubmitKehadiran(
                                            id_absensi: absensi.id,
                                            id_agtkelas: currentAgtKelas!.id,
                                          ),
                                        ),
                                      );
                                      // Jika result == true, artinya user sudah submit, maka refresh data
                                      if (result == true) {
                                        updateAbsensi();
                                      }
                                    },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.disabled)) {
                                      return Colors.grey;
                                    }
                                    return Colors.blue;
                                  },
                                ),
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
    );
  }
}

class Absensi {
  final int id;
  final int id_kelas;
  final String nama;
  final String tgl;
  final String batas;
  bool sudahAbsen;

  Absensi({
    required this.id,
    required this.id_kelas,
    required this.nama,
    required this.tgl,
    required this.batas,
    this.sudahAbsen = false,
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

class agtKelas {
  final int id;
  final int id_kelas;
  final int id_user;

  agtKelas({
    required this.id,
    required this.id_kelas,
    required this.id_user,
  });

  factory agtKelas.fromJson(Map<String, dynamic> json) {
    return agtKelas(
      id: json['id'],
      id_kelas: json['id_kelas'],
      id_user: json['id_user'],
    );
  }
}
