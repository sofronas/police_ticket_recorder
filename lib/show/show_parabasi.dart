import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';

class ShowParabasi extends StatefulWidget {
  const ShowParabasi({
    required this.database,
    required this.item,
    required this.numberParabasi,
    Key? key,
  }) : super(key: key);

  final Database database;
  final Map<String, dynamic> item;
  final int numberParabasi;

  @override
  _ShowParabasiState createState() => _ShowParabasiState();
}

class _ShowParabasiState extends State<ShowParabasi> {
  late List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> text = [];
  quill.QuillController _quillController = quill.QuillController.basic();

  @override
  void initState() {
    super.initState();
    _getParabaseis();
  }

  Future<void> _getParabaseis() async {
    final results = await widget.database.rawQuery(
        'SELECT * FROM parabaseis WHERE id = ${widget.numberParabasi}');

    setState(() {
      _data = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if _data is not empty before accessing its elements
    if (_data.isNotEmpty) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(_data[0]['date']);
      String dateTimeString =
          "${dateTime.day}/${dateTime.month}/${dateTime.year}";

      // text = jsonDecode(_data[0]['keimeno']);
      String keimenoString = _data[0]['keimeno'];
      List<Map<String, dynamic>> textList =
          List<Map<String, dynamic>>.from(jsonDecode(keimenoString));

      _quillController = quill.QuillController(
        document: quill.Document.fromJson(textList),
        selection: const TextSelection.collapsed(offset: 0),
      );

      return Scaffold(
        appBar: AppBar(
          title: const Text('Προβολής Παράβασης'),
          centerTitle: true,
          leading: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ),
        body: Center(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              const SizedBox(height: 16.0),
              ListTile(
                title: const Text(
                  'Παράβαση:',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  _data[0]['parabasi'].toString(),
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              ListTile(
                title: const Text(
                  'Ημερομηνία Παράβασης:',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  dateTimeString,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              ListTile(
                title: const Text(
                  'Άρθρο:',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: _data[0]['article'] == 17
                    ? Text(
                        "${_data[0]['article']} Νόμου 2170/93",
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    : Text(
                        _data[0]['article'].toString(),
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
              ),
              ListTile(
                title: const Text(
                  'Έγινε Αφαίρεση Διπλώματος:',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  _data[0]['diploma'] == 0
                      ? "ΟΧΙ"
                      : "ΝΑΙ ${_data[0]['imeres_dipl'].toString() == 5 ? "για ${_data[0]['imeres_dipl']} χρόνια" : "για ${_data[0]['imeres_dipl']} ημέρες"}",
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              ListTile(
                title: const Text(
                  'Έγινε Αφαίρεση Στοιχείων:',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  _data[0]['stoixeia'] == 0
                      ? "ΟΧΙ"
                      : "ΝΑΙ ${_data[0]['imeres_stoixeion'].toString() == 5 ? "για ${_data[0]['imeres_stoixeion']} χρόνια" : "για ${_data[0]['imeres_stoixeion']} ημέρες"}",
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: LimitedBox(
                            maxHeight:
                                300, // set the maximum height in logical pixels
                            child: quill.QuillEditor.basic(
                              controller: _quillController,
                              readOnly: true,
                            ),
                          )),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    } else {
      // Show a loading indicator while data is being fetched
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
