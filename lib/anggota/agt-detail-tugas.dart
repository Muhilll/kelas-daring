import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:kelas_daring/anggota/tugas/form-upload-tugas.dart';
import 'package:kelas_daring/endpoint.dart';
import 'package:path_provider/path_provider.dart';


class AgtDetailTugasPage extends StatefulWidget {
  final int id;
  const AgtDetailTugasPage({required this.id, super.key});

  @override
  State<AgtDetailTugasPage> createState() => _AgtDetailTugasPageState();
}

class _AgtDetailTugasPageState extends State<AgtDetailTugasPage> {
  List<Pengumpulan> dataPengumpulan = [];

  Future<List<Pengumpulan>> fetchPengumpulan(BuildContext context) async {
    final String url = EndPoint.url+'data-pengumpulan-tugas?id=' + widget.id.toString();
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          List<dynamic> data = jsonData['data'];
          return data.map((item) => Pengumpulan.fromJson(item)).toList();
        } else {
          throw Exception('Gagal memuat data pengumpulan tugas.');
        }
      } else {
        throw Exception('Gagal terhubung ke server.');
      }
    } catch (e) {
      print('Error: $e'); // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat pengumpulan tugas')),
      );
      return [];
    }
  }

  Future<void> downloadTugas(BuildContext context, int id) async {
    final String url = EndPoint.url+'pemilik/download-tugas?id=$id';
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/tugas_$id.pdf';

      Dio dio = Dio();
      final response = await dio.download(url, filePath);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File berhasil diunduh: $filePath')),
        );
      } else {
        throw Exception('Gagal mendownload file');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendownload file: $e')),
      );
    }
  }

  Future<void> updatePengumpulan() async {
    final result = await fetchPengumpulan(context);
    if(mounted){
      setState(() {
        dataPengumpulan = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    updatePengumpulan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Daftar Pengumpulan Tugas',
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: dataPengumpulan.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: dataPengumpulan.length,
                itemBuilder: (context, index) {
                  final pengumpulan = dataPengumpulan[index];
                  return PengumpulanItem(
                      id: pengumpulan.id,
                      nama: pengumpulan.nama,
                      tgl: pengumpulan.tgl,
                      submitTugas: (id) => {FormUploadTugas(id_tugas: 1, id_agtkelas: 1)});
                },
              ));
  }
}

class Pengumpulan {
  final int id;
  final String nama;
  final String file;
  final String tgl;

  Pengumpulan({
    required this.id,
    required this.nama,
    required this.file,
    required this.tgl,
  });

  factory Pengumpulan.fromJson(Map<String, dynamic> json) {
    return Pengumpulan(
      id: json['id'],
      nama: json['nama'],
      file: json['file'],
      tgl: json['tgl'],
    );
  }
}

class PengumpulanItem extends StatelessWidget {
  final int id;
  final String nama;
  final String tgl;
  final Function(int id) submitTugas;

  const PengumpulanItem(
      {Key? key,
      required this.id,
      required this.nama,
      required this.tgl,
      required this.submitTugas})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('images/member_class.png', width: 30, height: 30),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(left: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(tgl),
                  ],
                ),
              ),
            ],
          ),
          TextButton(
            style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.blue)),
            onPressed: () async {
              await submitTugas(id); // Unduh file berdasarkan ID
            },
            child: const Text(
              'Lihat',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}