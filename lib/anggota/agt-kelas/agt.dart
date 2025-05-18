import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kelas_daring/endpoint.dart';

class AgtPageAnggota extends StatefulWidget {
  final int id;
  const AgtPageAnggota({required this.id, super.key});

  @override
  State<AgtPageAnggota> createState() => _AgtPageAnggotaState();
}

class _AgtPageAnggotaState extends State<AgtPageAnggota> {
  List<Agt> dataAgt = [];
  User? pemilik;

  Future<User> fetchPemilikKelas(BuildContext context) async {
    String url = EndPoint.url+'get-pemilik-kelas?id_kelas=' +
        widget.id.toString();
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          return User.fromJson(jsonData['data']);
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

  Future<List<Agt>> fetchAgt(BuildContext context) async {
    final String url = EndPoint.url+'pemilik/get-agt?id=' + widget.id.toString();
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          List<dynamic> data = jsonData['data'];
          return data.map((item) => Agt.fromJson(item)).toList();
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

  Future<void> updateAgt() async {
    final result = await fetchAgt(context);
    if (mounted) {
      setState(() {
        dataAgt = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    updateAgt();
    fetchPemilikKelas(context).then((result) {
      if (mounted) {
        setState(() {
          pemilik = result;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const Text(
                    'Pengajar',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  Container(height: 2, color: Colors.blue),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 7),
                          child: Image.asset('images/owner.png',
                              width: 40, height: 40),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 9),
                          child: pemilik == null
                              ? Container()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pemilik!.nama,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    Text(pemilik!.no_hp),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Anggota Kelas',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  Container(height: 2, color: Colors.blue),
                ],
              ),
            ),
            dataAgt.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Center(child: Text('Tidak ada data')),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final listAgt = dataAgt[index];
                        return AgtItem(
                          nama: listAgt.nama,
                          no_hp: listAgt.no_hp,
                          id: listAgt.id,
                        );
                      },
                      childCount: dataAgt.length,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class Agt {
  final int id;
  final int id_user;
  final String nama;
  final String no_hp;

  Agt({
    required this.id,
    required this.id_user,
    required this.nama,
    required this.no_hp,
  });

  factory Agt.fromJson(Map<String, dynamic> json) {
    return Agt(
      id: json['id'],
      id_user: json['id_user'],
      nama: json['nama'],
      no_hp: json['no_hp'],
    );
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

class AgtItem extends StatelessWidget {
  final int id;
  final String nama;
  final String no_hp;

  const AgtItem({
    Key? key,
    required this.id,
    required this.nama,
    required this.no_hp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('images/member.png', width: 40, height: 40),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(left: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
        ],
      ),
    );
  }
}
