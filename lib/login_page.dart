import 'package:flutter/material.dart';
import 'package:kelas_daring/endpoint.dart';
import 'package:kelas_daring/home.dart';
import 'package:kelas_daring/register_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final TextEditingController nimController = TextEditingController();
final TextEditingController passController = TextEditingController();

void clearForm() {
  nimController.clear();
  passController.clear();
}

Future<void> loginUser(BuildContext context) async {
  String url = EndPoint.url+'login';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'nim': nimController.text,
        'password': passController.text
      }),
    );

    if (response.statusCode == 200) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLogin', true);

      final String idUser = jsonDecode(response.body)['idUser'].toString();
      final SharedPreferences prefsIdUser = await SharedPreferences.getInstance();
      prefsIdUser.setString('idUser', idUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successfull")),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePages()));
    } else {
      final errorMessage = jsonDecode(response.body)['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: $e')),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    clearForm();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Login Form',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: TextField(
                controller: nimController,
                decoration: const InputDecoration(
                  labelText: 'Nim',
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
              child: ElevatedButton(
                onPressed: () {
                  if (nimController.text.isEmpty ||
                      passController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Isi nim dan password terlebih dahulu!')),
                    );
                  } else {
                    loginUser(context);
                  }
                },
                child: const Text(
                  'Login',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => RegisterPage()));
              },
              child: const Text("Don't have an account? Signup now!"),
            ),
          ],
        ),
      ),
    );
  }
}