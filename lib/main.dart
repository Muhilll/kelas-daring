import 'package:flutter/material.dart';
import 'package:kelas_daring/user/kelas.dart';
import 'package:kelas_daring/home.dart';
import 'landing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'pemilik/kelas/kelas.dart';
import 'pemilik/kelas/buat-kelas.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  bool isLogin = await checkLoginStatus();
  
  runApp(MyApp(isLogin: isLogin));
}

Future<bool> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();  
  return prefs.getBool('isLogin') ?? false;
}

class MyApp extends StatelessWidget {
  final bool isLogin;
  MyApp({required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login dan Register',
      initialRoute: '/home',
      routes: {
        '/landing': (context) => Landing(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePages(),
        '/kelas-pemilik': (context) => KelasPagePemilik(),
        '/form-buat-kelas': (context) => FormBuatKelas(), 
        '/kelas-anggota': (context) => UserKelasPage(),
      },
    );
  }
}