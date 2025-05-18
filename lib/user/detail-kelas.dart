import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kelas_daring/endpoint.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailKelas extends StatefulWidget {
  int id;
  UserDetailKelas({required this.id, super.key});

  @override
  State<UserDetailKelas> createState() => _UserDetailKelasState();
}

class _UserDetailKelasState extends State<UserDetailKelas> {
  late Future<detailKelas> detailFuture;

  Future<detailKelas> fetchDetailKelas(BuildContext context) async {
    String url = EndPoint.url + 'get-kelas-detail?id=' + widget.id.toString();
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

  Future<void> gabungKelas(BuildContext context) async {
    String url = EndPoint.url + 'gabung-kelas';
    final SharedPreferences prefsIdUser = await SharedPreferences.getInstance();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'id_kelas': widget.id.toString(),
          'id_user': prefsIdUser.getString('idUser') ?? '',
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfull')),
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
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  void initState() {
    super.initState();
    detailFuture = fetchDetailKelas(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.blue,
            iconTheme: const IconThemeData(color: Colors.white)),
        body: FutureBuilder<detailKelas>(
            future: fetchDetailKelas(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text('Tidak ada data'));
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              snapshot.data!.namaKelas,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Deskripsi',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              snapshot.data!.deskripsi,
                              style: const TextStyle(color: Colors.black),
                              softWrap: true,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                gabungKelas(context);
                              },
                              style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.blue),
                              ),
                              child: const Text(
                                'Gabung',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const Text('Detail Kelas');
              }
            }));
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
