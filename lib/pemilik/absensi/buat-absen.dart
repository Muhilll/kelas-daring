import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kelas_daring/endpoint.dart';

final TextEditingController namaController = TextEditingController();

class FormBuatAbsensi extends StatefulWidget {
  final int id;
  const FormBuatAbsensi({required this.id, super.key});

  @override
  State<FormBuatAbsensi> createState() => _FormBuatAbsensiState();
}

class _FormBuatAbsensiState extends State<FormBuatAbsensi> with RestorationMixin {
  final RestorableTimeOfDay _selectedTime =
      RestorableTimeOfDay(const TimeOfDay(hour: 0, minute: 0));

  late final RestorableRouteFuture<TimeOfDay?> _restorableTimePickerRouteFuture =
      RestorableRouteFuture<TimeOfDay?>(
    onComplete: _selectTime,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _timePickerRoute,
        arguments: _selectedTime.value.hour * 60 + _selectedTime.value.minute,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<TimeOfDay> _timePickerRoute(
      BuildContext context, Object? arguments) {
    final initialTimeInMinutes = arguments as int;
    return DialogRoute<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return TimePickerDialog(
          restorationId: 'time_picker_dialog',
          initialTime: TimeOfDay(
            hour: initialTimeInMinutes ~/ 60,
            minute: initialTimeInMinutes % 60,
          ),
        );
      },
    );
  }

  void _selectTime(TimeOfDay? newSelectedTime) {
    if (newSelectedTime != null) {
      setState(() {
        _selectedTime.value = newSelectedTime;
      });
    }
  }

  Future<void> buatAbsensi(BuildContext context) async {
    String url = EndPoint.url+'pemilik/buat-absensi';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'id_kelas': widget.id.toString(),
          'nama': namaController.text,
          'batas': "${_selectedTime.value.hour.toString().padLeft(2, '0')}:${_selectedTime.value.minute.toString().padLeft(2, '0')}",
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Absensi berhasil dibuat')),
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
        SnackBar(content: Text('Gagal membuat absensi: $e')),
      );
    }
  }

  @override
  String? get restorationId => 'form_buat_absensi';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedTime, 'selected_time');
    registerForRestoration(
        _restorableTimePickerRouteFuture, 'time_picker_route_future');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 27),
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Buat Absensi Baru',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Absensi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Batas Waktu: ${_selectedTime.value.hour.toString().padLeft(2, '0')}:${_selectedTime.value.minute.toString().padLeft(2, '0')}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _restorableTimePickerRouteFuture.present();
                  },
                  child: const Text('Pilih Waktu'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (namaController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lengkapi data terlebih dahulu!')),
                  );
                } else {
                  buatAbsensi(context);
                }
              },
              child: const Text('Buat'),
            ),
          ],
        ),
      ),
    );
  }
}