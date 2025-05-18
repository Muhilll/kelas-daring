import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kelas_daring/endpoint.dart';

class SubmitKehadiran extends StatefulWidget {
  final int id_absensi, id_agtkelas;
  const SubmitKehadiran({required this.id_absensi, required this.id_agtkelas, super.key});

  @override
  State<SubmitKehadiran> createState() => _SubmitKehadiranState();
}

class _SubmitKehadiranState extends State<SubmitKehadiran> {
  String? selectedKeterangan;
  final List<String> keteranganOptions = ['Hadir', 'Izin', 'Alpha'];

  Future<void> submitKehadiran(BuildContext context) async {
    String url = EndPoint.url+'submit-kehadiran';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'id_absensi': widget.id_absensi.toString(),
          'id_agtkelas': widget.id_agtkelas.toString(),
          'keterangan': selectedKeterangan ?? '',
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kehadiran berhasil disubmit')),
        );
        Navigator.pop(context, true);
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mensubmit kehadiran: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 27),
        backgroundColor: Colors.blue,
        title: const Text(
          'Submit Kehadiran',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              value: selectedKeterangan,
              items: keteranganOptions
                  .map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedKeterangan = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Keterangan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedKeterangan == null || selectedKeterangan!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pilih keterangan terlebih dahulu!')),
                  );
                } else {
                  submitKehadiran(context);
                }
              },
              style: const ButtonStyle(
                                    backgroundColor:
                                        WidgetStatePropertyAll(Colors.blue)),
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}