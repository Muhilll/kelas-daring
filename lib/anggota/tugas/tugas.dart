import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kelas_daring/anggota/tugas/detail-pengumpulan.dart';
import 'package:kelas_daring/anggota/tugas/detail-tugas.dart';
import 'package:kelas_daring/endpoint.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TugasPageAnggota extends StatefulWidget {
  final int id;
  const TugasPageAnggota({required this.id, super.key});

  @override
  State<TugasPageAnggota> createState() => _TugasPageAnggotaState();
}

class _TugasPageAnggotaState extends State<TugasPageAnggota> {
  List<Tugas> dataTugas = [];
  late Future<agtKelas> futureAgtKelas;
  int id_pengumpulan = 0;
  String tanggal = "";


  Future<List<Tugas>> fetchTugas(BuildContext context) async {
    final String url = EndPoint.url+'pemilik/get-tugas?id=' + widget.id.toString();
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          List<dynamic> data = jsonData['data'];
          return data.map((item) => Tugas.fromJson(item)).toList();
        } else {
          throw Exception('Gagal memuat data tugas kelas.');
        }
      } else {
        throw Exception('Gagal terhubung ke server.');
      }
    } catch (e) {
      print('Error: $e'); // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat tugas Kelas')),
      );
      return [];
    }
  }

  Future<bool> ceking(
      BuildContext context, int id_tugas, int id_agtkelas) async {
    String url = EndPoint.url+'cek-tugas?id_tugas=${id_tugas}&id_agtkelas=${id_agtkelas}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          id_pengumpulan = jsonData['id_pengumpulan'];
          tanggal = jsonData['tanggal'];
          return jsonData['bisa'];
        } else {
          throw Exception('Gagal memuat data tugas');
        }
      } else {
        throw Exception('Gagal terhubung ke API');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return false;
    }
  }

  void cekTugas(int id_tugas, int id_agtkelas) async {
    bool bisa = await ceking(context, id_tugas, id_agtkelas);

    if (bisa) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailTugasPageAnggota(
            id_tugas: id_tugas,
            id_agtkelas: id_agtkelas,
          ),
        ),
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPengumpulan(id: id_pengumpulan, tanggal: tanggal,)));
    }
  }

  Future<agtKelas> fetchAgtKelas(BuildContext context) async {
    final SharedPreferences prefsIdUser = await SharedPreferences.getInstance();
    String id_user = prefsIdUser.getString('idUser') ?? "";
    String url = EndPoint.url+'get-data-agtkelas';
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

  Future<void> updateTugas() async {
      final result = await fetchTugas(context);

      if (mounted) {
        setState(() {
          dataTugas = result;
          futureAgtKelas = fetchAgtKelas(context);;
        });
      }
  }

  @override
  void initState() {
    super.initState();
    updateTugas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: dataTugas.isEmpty
          ? Center(child: Text('Tidak ada data'))
          : ListView.builder(
              itemCount: dataTugas.length,
              itemBuilder: (context, index) {
                final tugas = dataTugas[index];
                return FutureBuilder<agtKelas>(
                  future: futureAgtKelas,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(); 
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.hasData) {
                      final agtkelas = snapshot.data!;
                      return InkWell(
                        onTap: () {
                          cekTugas(tugas.id, agtkelas.id);
                        },
                        child: TugasItem(
                          nama: tugas.nama,
                          tgl_mulai: tugas.tgl_mulai,
                          tgl_selesai: tugas.tgl_selesai,
                        ),
                      );
                    }
                    return Text('No data available');
                  },
                );
              },
            ),
    );
  }
}

class Tugas {
  final int id;
  final int id_kelas;
  final String nama;
  final String tgl_mulai;
  final String tgl_selesai;

  Tugas({
    required this.id,
    required this.id_kelas,
    required this.nama,
    required this.tgl_mulai,
    required this.tgl_selesai,
  });

  factory Tugas.fromJson(Map<String, dynamic> json) {
    return Tugas(
      id: json['id'],
      id_kelas: json['id_kelas'],
      nama: json['nama'],
      tgl_mulai: json['tgl_mulai'],
      tgl_selesai: json['tgl_selesai'],
    );
  }
}

class TugasItem extends StatelessWidget {
  final String nama;
  final String tgl_mulai;
  final String tgl_selesai;

  const TugasItem(
      {Key? key,
      required this.nama,
      required this.tgl_mulai,
      required this.tgl_selesai})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Image.asset('images/check.png', width: 30, height: 30),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center, // Menyelaraskan teks di tengah
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(tgl_mulai),
                Text('Batas Pengumpulan: ' + tgl_selesai)
              ],
            ),
          ),
        ],
      ),
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
