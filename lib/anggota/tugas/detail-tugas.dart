import 'package:flutter/material.dart';
import 'package:kelas_daring/anggota/tugas/form-upload-tugas.dart';

class DetailTugasPageAnggota extends StatefulWidget {
  int id_tugas, id_agtkelas;
  DetailTugasPageAnggota(
      {
        required this.id_tugas, 
        required this.id_agtkelas, super.key
      });
  @override
  State<DetailTugasPageAnggota> createState() => _DetailTugasPageAnggotaState();
}

class _DetailTugasPageAnggotaState extends State<DetailTugasPageAnggota> {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Card(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Tugas Akhir",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormUploadTugas(
                          id_tugas: widget.id_tugas, id_agtkelas: widget.id_agtkelas),
                    ),
                  );

                  if (result == true) {
                    Navigator.pop(context);
                  }
                },
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                child: const Text(
                  'Submit Tugas',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ],
      )),
    );
  }
}
