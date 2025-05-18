import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kelas_daring/endpoint.dart';
import 'package:kelas_daring/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> list = <String>[
  'Teknik Informatika',
  'Sistem Informasi',
  'Bisnis Digital',
  'Rekayasa Perangkat Lunak',
  'Manajemen Informatika',
  'Kewirausahaan'
];

final TextEditingController nimController = TextEditingController();
final TextEditingController namaController = TextEditingController();
final TextEditingController jurusanController = TextEditingController();
final TextEditingController jkelController = TextEditingController();
final TextEditingController alamatController = TextEditingController();
final TextEditingController emaILController = TextEditingController();
final TextEditingController nohpController = TextEditingController();
final TextEditingController passController = TextEditingController();
final TextEditingController conPassController = TextEditingController();

Future<void> editProfil(BuildContext context) async {
  SharedPreferences prefsIdUser = await SharedPreferences.getInstance();
  String id = prefsIdUser.getString('idUser').toString();
  String url = EndPoint.url+'user/edit-profil';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'id': id,
        'nim': nimController.text,
        'nama': namaController.text,
        'id_jurusan': jurusanController.text,
        'jkel': jkelController.text,
        'alamat': alamatController.text,
        'no_hp': nohpController.text,
        'email': emaILController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfull')),
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
      SnackBar(content: Text('Edit failed: $e')),
    );
  }
}

Future<void> fetchDetailuser(BuildContext context) async {
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
          final userData = user.fromJson(userList[0]);

          nimController.text = userData.nim;
          namaController.text = userData.nama;
          jurusanController.text = userData.jurusan;
          jkelController.text = userData.jkel;
          alamatController.text = userData.alamat;
          nohpController.text = userData.no_hp;
          emaILController.text = userData.email;
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
  }
}

class EditPage extends StatefulWidget {
  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  void initState() {
    super.initState();
    fetchDetailuser(context).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white, size: 27),
          centerTitle: true,
          title: const Text(
            'Edit Profil',
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: nimController,
                  decoration: const InputDecoration(
                    labelText: 'NIM',
                    border: OutlineInputBorder(),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: TextField(
                    controller: namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: const DropdownMenuExample(),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  alignment: Alignment.bottomLeft,
                  child: const Text(
                    "Jenis Kelamin",
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                Container(
                  child: const RadioExample(),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: TextField(
                    controller: alamatController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: TextField(
                    controller: nohpController,
                    decoration: const InputDecoration(
                      labelText: 'No Hp',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: TextField(
                    controller: emaILController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Simpan'),
                  onPressed: () {
                    if (nimController.text.isEmpty ||
                        namaController.text.isEmpty ||
                        jurusanController.text == "0" ||
                        jkelController.text.isEmpty ||
                        alamatController.text.isEmpty ||
                        nohpController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Lengkapi seluruh data terlebih dahulu!")),
                      );
                    } else {
                      if (passController.text != conPassController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Password dan Conform Password harus sama!")),
                        );
                      } else {
                        editProfil(context);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

class DropdownMenuExample extends StatefulWidget {
  const DropdownMenuExample({super.key});

  @override
  State<DropdownMenuExample> createState() => _DropdownMenuExampleState();
}

class _DropdownMenuExampleState extends State<DropdownMenuExample> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DropdownMenu<String>(
        hintText: "Jurusan",
        onSelected: (String? value) {
          setState(() {
            jurusanController.text = pilihJurusan(value!).toString();
          });
        },
        dropdownMenuEntries:
            list.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList(),
      ),
    );
  }
}

enum SingingCharacter { laki, perempuan }

class RadioExample extends StatefulWidget {
  const RadioExample({super.key});

  @override
  State<RadioExample> createState() => _RadioExampleState();
}

class _RadioExampleState extends State<RadioExample> {
  SingingCharacter? _character;

  @override
  void initState() {
    super.initState();
    if (jkelController.text == "Laki - laki") {
      _character = SingingCharacter.laki;
    } else if (jkelController.text == "Perempuan") {
      _character = SingingCharacter.perempuan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
              title: const Text(
                'Laki - laki',
                style: TextStyle(fontSize: 15),
              ),
              leading: Radio<SingingCharacter>(
                value: SingingCharacter.laki,
                groupValue: _character,
                onChanged: (SingingCharacter? value) {
                  setState(() {
                    _character = value;
                    jkelController.text = "Laki - laki";
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              title: const Text('Perempuan', style: TextStyle(fontSize: 15)),
              leading: Radio<SingingCharacter>(
                value: SingingCharacter.perempuan,
                groupValue: _character,
                onChanged: (SingingCharacter? value) {
                  setState(() {
                    _character = value;
                    jkelController.text = "Perempuan";
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

int pilihJurusan(String pil) {
  int kode = 0;
  if (pil == "Teknik Informatika") {
    kode = 1;
  } else if (pil == "Sistem Informasi") {
    kode = 2;
  } else if (pil == "Bisnis Digital") {
    kode = 3;
  } else if (pil == "Rekayasa Perangkat Lunak") {
    kode = 4;
  } else if (pil == "Manajemen Informatika") {
    kode = 5;
  } else if (pil == "Kewirausahaan") {
    kode = 6;
  }
  return kode;
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