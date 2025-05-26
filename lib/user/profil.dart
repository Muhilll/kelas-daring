import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kelas_daring/endpoint.dart';
import 'package:kelas_daring/user/edit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<user> detailFuture;

  Future<user> fetchDetailuser(BuildContext context) async {
    SharedPreferences prefsIdUser = await SharedPreferences.getInstance();
    String id = prefsIdUser.getString('idUser').toString();
    String url = EndPoint.url+'user/get-profil?id_user=' + id;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['success'] == true) {
          final List<dynamic> userList = jsonData['data'];
          if (userList.isNotEmpty) {
            return user.fromJson(userList[0]);
          } else {
            throw Exception('No user data found');
          }
        } else {
          throw Exception('Failed to load user data');
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

  void initState() {
    super.initState();
    detailFuture = fetchDetailuser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<user>(
            future: detailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.all(10.0),
                  child: ListView(
                    children: [
                      const SizedBox(height: 20),
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Nim:\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t" +
                                        snapshot.data!.nim,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Nama:\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t" +
                                        snapshot.data!.nama,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Jurusan:\t\t\t\t\t\t\t\t\t\t\t\t\t" +
                                        snapshot.data!.jurusan,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Jenis Kelamin:\t\t\t" +
                                        snapshot.data!.jkel,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "No Hp:\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t" +
                                        snapshot.data!.no_hp,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Email:\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t" +
                                        snapshot.data!.email,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditPage()));

                                      if (result == true) {
                                        setState(() {
                                          detailFuture =
                                              fetchDetailuser(context);
                                        });
                                      }
                                    },
                                    style: const ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            Colors.blue)),
                                    child: const Text(
                                      'Edit',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return const Text('Profil');
              }
            }));
  }
}

class user {
  final int id;
  final String nim;
  final String nama;
  final String jurusan;
  final String jkel;
  final String alamat;
  final String no_hp;
  final String email;

  user({
    required this.id,
    required this.nim,
    required this.nama,
    required this.jurusan,
    required this.jkel,
    required this.alamat,
    required this.no_hp,
    required this.email,
  });

  factory user.fromJson(Map<String, dynamic> json) {
    return user(
      id: json['id'],
      nim: json['nim'],
      nama: json['nama'],
      jurusan: json['jurusan'],
      jkel: json['jkel'],
      alamat: json['alamat'],
      no_hp: json['no_hp'],
      email: json['email'],
    );
  }
}
