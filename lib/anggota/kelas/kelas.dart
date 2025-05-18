import 'package:flutter/material.dart';
import 'package:kelas_daring/anggota/kelas/detail-kelas.dart';
import 'package:kelas_daring/endpoint.dart';
import 'package:kelas_daring/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class KelasPageAnggota extends StatefulWidget {
  @override
  _KelasPageAnggotaState createState() => _KelasPageAnggotaState();
}

class _KelasPageAnggotaState extends State<KelasPageAnggota> {
  @override

  void initState() {
    super.initState();
    updateKelas();
  }

  Future<List<Kelas>> fetchKelas(BuildContext context) async {
    SharedPreferences prefsIdUser = await SharedPreferences.getInstance();
    String id = prefsIdUser.getString('idUser').toString();
    final String url = EndPoint.url+'anggota/get-kelas?id=${id}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          List<dynamic> data = jsonData['data'];
          return data.map((item) => Kelas.fromJson(item)).toList();
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
      return [];
    }
  }

  List<Kelas> kelasList = [];

  Future<void> updateKelas() async {
    final result = await fetchKelas(context);
    if(mounted){
      setState(() {
        kelasList = result;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: kelasList.isEmpty ? Center(child: Text('Tidak ada data')) : ListView.builder(
              itemCount: kelasList.length,
              itemBuilder: (context, index) {
                final kelas = kelasList[index];
                return KelasItem(
                  title: kelas.namaKelas,
                  namaUser: kelas.pemilik,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailKelasAnggota(
                          id: kelas.id,
                        ),
                      ),
                    );
                    if (result == true) {
                      updateKelas();
                    }
                  },
                );
              },
            )
    );
  }
}

class Kelas {
  final int id;
  final String namaKelas;
  final String pemilik;

  Kelas({
    required this.id,
    required this.namaKelas,
    required this.pemilik,
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(
      id: json['id'],
      namaKelas: json['namaKelas'],
      pemilik: json['pemilik'],
    );
  }
}

class KelasItem extends StatelessWidget {
  final String title;
  final String namaUser;
  final VoidCallback onTap;

  const KelasItem({
    Key? key,
    required this.title,
    required this.namaUser,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(5),
        width: double.infinity,
        height: 100,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Image.asset(
                'images/bg_card4.jpg', // Pastikan path gambar benar
                fit: BoxFit.cover,
                width: double.infinity,
                height: 100,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Text(
                      namaUser,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('isLogin');

  final SharedPreferences prefsIdUser = await SharedPreferences.getInstance();
  await prefsIdUser.remove('idUser');

  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => LoginPage()));
}
