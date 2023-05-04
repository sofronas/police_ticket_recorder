import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:sqflite/sqflite.dart';

const List<String> listOfParabaseis = <String>[
  'Ζώνη',
  'Κράνος',
  'ΚΤΕΟ',
  'Κινητό',
  'Παιδικό Κάθισμα',
  'Ερυθρός Σηματοδότης',
  'Ταχύτητα',
  'Λ.Ε.Α.',
  'Αναστροφή',
  'Αντίθετη Κίνηση',
  'Μονόδρομος',
  'Στάθμευση',
  'Στέρηση Διπλώματος',
  'Ασφάλεια',
  'Φιμέ',
  'Μέθη',
  'Κίνηση Σε Αυτοκινητόδρομο',
  'Διόδια',
];
const List<int> listOfArticles = <int>[
  12,
  33,
  4,
  34,
  94,
  13,
  6,
  20,
  16,
  81,
  42,
  29,
  17,
  93,
];

const List<int> listOfImeres = <int>[10, 20, 60, 120, 180, 5];
const List<int> listOfImeresStoixeion = <int>[10, 20, 60, 120, 180, 5];

class AddNewParabasi extends StatefulWidget {
  // const AddNewParabasi({Key? key}) : super(key: key);

  const AddNewParabasi({
    required this.database,
    required this.item,
    Key? key,
  }) : super(key: key);

  final Database database;
  final Map<String, dynamic> item;

  @override
  _AddNewParabasiState createState() => _AddNewParabasiState();
}

class _AddNewParabasiState extends State<AddNewParabasi> {
  final quill.QuillController _quillController = quill.QuillController.basic();
  final TextEditingController _imerominiaParabasisController =
      TextEditingController();
  String? epilogiParabasis;
  int? selectedArticle;
  int _selectedImeresDiplomatos = 10;
  int _selectedImeresStoixeion = 10;

  bool _afairesiDiplomatos = false;
  bool _afairesiStoixeion = false;
  int _imeresDiplomatos = 10;
  int _imeresStoixeion = 10;

  void _showDialogStoixeion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              titlePadding: const EdgeInsets.all(0),
              contentPadding: const EdgeInsets.all(20),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Θα γίνει αφαίρεση Στοιχείων;'),
                      const SizedBox(width: 10),
                      Checkbox(
                        value: _afairesiStoixeion,
                        onChanged: (newStoixeiaValue) {
                          setState(() {
                            _afairesiStoixeion = newStoixeiaValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_afairesiStoixeion)
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text('Επιλέξτε τη διάρκεια:'),
                            const SizedBox(width: 10),
                            DropdownButton<int>(
                              value: _selectedImeresStoixeion,
                              onChanged: (newStoixeiaValu) {
                                setState(() {
                                  _selectedImeresStoixeion = newStoixeiaValu!;
                                  _imeresStoixeion = newStoixeiaValu;
                                });
                              },
                              items: listOfImeresStoixeion
                                  .map<DropdownMenuItem<int>>((int valuex) {
                                return DropdownMenuItem<int>(
                                  value: valuex,
                                  child: Text(
                                    valuex == 5
                                        ? '$valuex χρόνια'
                                        : '$valuex ημέρες',
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ακύρωση'),
                  onPressed: () {
                    setState(() {
                      _afairesiStoixeion = false;
                    });
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('Αφαίρεση'),
                  onPressed: () {
                    setState(() {
                      _afairesiStoixeion = true;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
              title: AppBar(
                automaticallyImplyLeading: false,
                title: const Text(
                  'Αφαίρεση Στοιχείων',
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                backgroundColor: Colors.black,
              ),
            );
          },
        );
      },
    );
  }

  // Afairesi Diplomatos
  void _showDialogAfairesiDiplomatos(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              titlePadding: const EdgeInsets.all(0),
              contentPadding: const EdgeInsets.all(20),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Θα γίνει αφαίρεση Διπλώματος;'),
                      const SizedBox(width: 10),
                      Checkbox(
                        value: _afairesiDiplomatos,
                        onChanged: (newValue) {
                          setState(() {
                            _afairesiDiplomatos = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_afairesiDiplomatos)
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text('Επιλέξτε τη διάρκεια:'),
                            const SizedBox(width: 10),
                            DropdownButton<int>(
                              value: _selectedImeresDiplomatos,
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedImeresDiplomatos = newValue!;
                                  _imeresDiplomatos = _selectedImeresDiplomatos;
                                });
                              },
                              items: listOfImeres
                                  .map<DropdownMenuItem<int>>((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(
                                    value == 5
                                        ? '$value χρόνια'
                                        : '$value ημέρες',
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ακύρωση'),
                  onPressed: () {
                    setState(() {
                      _afairesiDiplomatos = false;
                    });
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('Αφαίρεση'),
                  onPressed: () {
                    setState(() {
                      _afairesiDiplomatos = true;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
              title: AppBar(
                automaticallyImplyLeading: false,
                title: const Text(
                  'Αφαίρεση Διπλώματος',
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                backgroundColor: Colors.redAccent,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Δημιουργία Νέας Παράβασης'),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          _imerominiaParabasisController.text =
                              DateFormat('dd/MM/yyyy').format(date);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _imerominiaParabasisController,
                            decoration: const InputDecoration(
                              labelText: 'Ημερομηνία παράβασης',
                              hintText: 'dd/MM/yyyy',
                              icon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Παράβαση',
                      ),
                      value: epilogiParabasis,
                      onChanged: (newValue) {
                        setState(() {
                          epilogiParabasis = newValue;
                        });
                      },
                      items: listOfParabaseis
                          .map<DropdownMenuItem<String>>((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Άρθρο',
                      ),
                      value: selectedArticle,
                      onChanged: (newValue) {
                        setState(() {
                          selectedArticle = newValue;
                        });
                      },
                      items: listOfArticles
                          .map<DropdownMenuItem<int>>((int option) {
                        return DropdownMenuItem<int>(
                          value: option,
                          child: Text(option.toString() == '17'
                              ? '17 Νόμου 2170/93'
                              : option.toString()),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _showDialogAfairesiDiplomatos(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.redAccent, // set the background color here
                    ),
                    child: const Text('Αφαίρεση Διπλώματος'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    child: const Text('Αφαίρεση Στοιχείων'),
                    onPressed: () {
                      _showDialogStoixeion(context);
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: quill.QuillToolbar.basic(
                              controller: _quillController,
                              showBoldButton: true,
                              showItalicButton: true,
                              showUnderLineButton: true,
                              showStrikeThrough: true,
                              showColorButton: true,
                              showBackgroundColorButton: true,
                              showListCheck: true,
                              showQuote: true,
                              showCodeBlock: true,
                              multiRowsDisplay: false,
                              showUndo: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.text,
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
                                      readOnly: false,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () async {
                  // Insert parabasi
                  final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
                  final DateTime date = inputFormat
                      .parse(_imerominiaParabasisController.text.trim());
                  final int imerominiaParabasis = date.millisecondsSinceEpoch;
                  final String parabasi = epilogiParabasis.toString();
                  final String article = selectedArticle.toString();
                  final int diploma = _afairesiDiplomatos ? 1 : 0;
                  final int imeresDiplomatos = _imeresDiplomatos;
                  final int stoixeia = _afairesiStoixeion ? 1 : 0;
                  final int imeresStoixeion = _imeresStoixeion;
                  final List<dynamic> keimenoParabasis = jsonDecode(
                      jsonEncode(_quillController.document.toDelta().toJson()));
                  final String keimenox =
                      jsonEncode(_quillController.document.toDelta().toJson());

                  await widget.database.transaction((txn) async {
                    await txn.rawInsert(
                        'INSERT INTO parabaseis(id_customer, date, parabasi, article, diploma, imeres_dipl, stoixeia, imeres_stoixeion, keimeno ) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)',
                        [
                          widget.item['id'],
                          imerominiaParabasis,
                          parabasi,
                          article,
                          diploma,
                          imeresDiplomatos,
                          stoixeia,
                          imeresStoixeion,
                          keimenox
                        ]);
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Αποθήκευση Νέας Παραβάσης'),
                    SizedBox(width: 8),
                    Icon(Icons.save),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
