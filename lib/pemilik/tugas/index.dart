import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kelas_daring/endpoint.dart';
import 'package:kelas_daring/pemilik/tugas/buat-tugas.dart';
import 'package:kelas_daring/pemilik/tugas/detail-tugas.dart';

class TugasPage extends StatefulWidget {
  final int id;
  const TugasPage({required this.id, super.key});

  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  List<Tugas> dataTugas = [];

  Future<List<Tugas>> fetchTugas(BuildContext context) async {
    final String url = EndPoint.url+'pemilik/get-tugas?id='+widget.id.toString();
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

  Future<void> updateTugas() async {
    final result = await fetchTugas(context);
    if(mounted){
      setState(() {
        dataTugas = result;
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
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailTugasPage(id: tugas.id,),
                ),
              );
            },
            child: TugasItem(
              nama: tugas.nama,
              tgl_mulai: tugas.tgl_mulai,
              tgl_selesai: tugas.tgl_selesai,
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormBuatTugas(id: widget.id),
            ),
          );

          if (result == true) {
            updateTugas();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
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

  const TugasItem({
    Key? key,
    required this.nama,
    required this.tgl_mulai,
    required this.tgl_selesai
  }) : super(key: key);

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
              mainAxisAlignment: MainAxisAlignment.center, // Menyelaraskan teks di tengah
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(tgl_mulai),
                Text('Batas Pengumpulan: '+tgl_selesai)
              ],
            ),
          ),
        ],
      ),
    );
  }
}