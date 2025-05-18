import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kelas_daring/endpoint.dart';

class KehadiranPemilik extends StatefulWidget {
  int id_absensi;
  KehadiranPemilik({required this.id_absensi, super.key});

  @override
  State<KehadiranPemilik> createState() => _KehadiranPemilikState();
}

class _KehadiranPemilikState extends State<KehadiranPemilik> {
  List<User> dataUser = [];

  Future<List<User>> fetchKehadiran(BuildContext context) async {
    final String url = EndPoint.url+'pemilik/get-kehadiran?id_absensi=' + widget.id_absensi.toString();
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          List<dynamic> data = jsonData['data'];
          return data.map((item) => User.fromJson(item)).toList();
        } else {
          throw Exception('Gagal memuat data anggota kelas.');
        }
      } else {
        throw Exception('Gagal terhubung ke server.');
      }
    } catch (e) {
      print('Error: $e'); // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat Anggota Kelas')),
      );
      return [];
    }
  }

  Future<void> updateUser() async {
    final result = await fetchKehadiran(context);
    if (mounted) {
      setState(() {
        dataUser = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    updateUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white, size: 27),
          backgroundColor: Colors.blue,
        ),
        body: dataUser.isEmpty
            ? Center(child: Text('Tidak ada data'))
            : ListView.builder(
                itemCount: dataUser.length,
                itemBuilder: (context, index) {
                  final user = dataUser[index];
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset('images/member.png',
                                width: 40, height: 40),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 7),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.nama,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(user.no_hp),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }));
  }
}

class User {
  final int id;
  final String nama;
  final String no_hp;

  User({
    required this.id,
    required this.nama,
    required this.no_hp,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nama: json['nama'],
      no_hp: json['no_hp'],
    );
  }
}

class KehadiranItem extends StatelessWidget {
  final int id;
  final String nama;
  final String no_hp;

  const KehadiranItem(
      {Key? key, required this.id, required this.nama, required this.no_hp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Image.asset('images/member.png', width: 40, height: 40),
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
                Text(no_hp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
