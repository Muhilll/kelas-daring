import 'package:flutter/material.dart';
import 'package:kelas_daring/anggota/kelas/kelas.dart';
import 'package:kelas_daring/user/kelas.dart';
import 'package:kelas_daring/login_page.dart';
import 'package:kelas_daring/pemilik/kelas/kelas.dart';
import 'package:kelas_daring/user/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePages extends StatefulWidget {
  @override
  _HomePagesState createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  Widget _currentBody = UserKelasPage();

  void _changePage(Widget newPage) {
    setState(() {
      _currentBody = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Aplikasi Kelas Daring',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 27,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        backgroundColor: Colors.blue,
      ),
      body: _currentBody,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                textAlign: TextAlign.center,
                'Kelas Daring Digital',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(
                    Icons.manage_search_outlined,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text('Kelas Tersedia'),
                  )
                ],
              ),
              onTap: () {
                _changePage(UserKelasPage());
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.list_alt_outlined),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text('Kelas Diikuti'),
                  )
                ],
              ),
              onTap: () {
                _changePage(KelasPageAnggota());
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.auto_awesome_mosaic_outlined),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text('Kelas Saya'),
                  )
                ],
              ),
              onTap: () {
                _changePage(KelasPagePemilik());
                Navigator.pop(context);
              },
            ),
            Container(
              width: double.infinity,
              height: 0.5,
              color: Colors.black,
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.person_outline),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text('Profile'),
                  )
                ],
              ),
              onTap: () {
                _changePage(ProfilePage());
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.logout_outlined),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text('Logout'),
                  )
                ],
              ),
              // selected: ,
              onTap: () {
                logout(context);
              },
            ),
            // Tambahkan menu lain di sini...
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