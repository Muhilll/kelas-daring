import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kelas_daring/endpoint.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class DetailPengumpulan extends StatefulWidget {
  int id;
  String tanggal;
  DetailPengumpulan({required this.id, required this.tanggal, super.key});

  @override
  State<DetailPengumpulan> createState() => _DetailPengumpulanState();
}

class _DetailPengumpulanState extends State<DetailPengumpulan> {

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

        final result = await OpenFile.open(filePath);

        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal membuka file: ${result.message}')),
          );
        }
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

  Future<void> hapusTugas(BuildContext context, int id) async {
    String url = EndPoint.url+'hapus-pengumpulan-tugas?id_pengumpulan=' + id.toString();
    try {
      http.delete(Uri.parse(url));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sukses Menghapus File Tugas')),
      );
      Navigator.pop(context);
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
          title: const Text('Konfirmasi'),
          content:
              const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                hapusTugas(context, id);
                Navigator.of(context).pop();
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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tanggal Pengumpulan: \n'+widget.tanggal,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        showKonfirmasiHapus(context, widget.id);
                      },
                      style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.red)),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () async {
                        downloadTugas(context, widget.id);
                      },
                      style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                      child: const Text(
                        'Lihat',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
