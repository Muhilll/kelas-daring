import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kelas_daring/endpoint.dart';
import 'package:kelas_daring/login_page.dart';

const List<String> list = <String>[
  'Teknik Informatika',
  'Sistem Infromasi',
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

void clearForm() {
  nimController.clear();
  namaController.clear();
  jurusanController.clear();
  jkelController.clear();
  alamatController.clear();
  nohpController.clear();
  passController.clear();
  conPassController.clear();
}

Future<void> registerUser(BuildContext context) async {
  String url = EndPoint.url+'register';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'nim': nimController.text,
        'nama': namaController.text,
        'id_jurusan': jurusanController.text,
        'jkel': jkelController.text,
        'alamat': alamatController.text,
        'no_hp': nohpController.text,
        'email': emaILController.text,
        'password': passController.text
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup successfull')),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      final errorMessage = jsonDecode(response.body)['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signup failed: $e')),
    );
  }
}

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    clearForm();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 27),
        centerTitle: true,
        title: const Text(
          'Signup Form',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        // Tambahkan SingleChildScrollView di sini
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
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: TextField(
                  controller: passController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: TextField(
                  controller: conPassController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Signup'),
                onPressed: () {
                  if (nimController.text.isEmpty ||
                      namaController.text.isEmpty ||
                      jurusanController.text == "0" ||
                      alamatController.text.isEmpty ||
                      nohpController.text.isEmpty ||
                      passController.text.isEmpty ||
                      conPassController.text.isEmpty) {
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
                      registerUser(context);
                    }
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: const Text('Already have an account? Login now!'),
              ),
            ],
          ),
        ),
      ),
    );
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
  } else if (pil == "Sistem Infromasi") {
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
