import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

const List<String> listDOI = <String>[
  'ΔΟΥ ΚΑΛΑΜΑΤΑΣ',
  'ΔΟΥ ΤΡΙΠΟΛΗΣ',
  'ΔΟΥ ΑΓΙΩΝ ΑΝΑΡΓΥΡΩΝ',
  'ΔΟΥ ΕΛΕΥΣΙΝΑΣ',
  'ΔΟΥ ΠΑΤΡΑΣ',
  'ΔΟΥ ΗΛΕΙΑΣ',
  'ΑΛΛΟ',
];

class EditCustomer extends StatefulWidget {
  const EditCustomer({required this.database, required this.item, Key? key})
      : super(key: key);

  final Database database;
  final Map<String, dynamic> item;

  @override
  _EditCustomerState createState() => _EditCustomerState();
}

class _EditCustomerState extends State<EditCustomer> {
  late List<Map<String, dynamic>> _data = [];

  TextEditingController _nameFieldController = TextEditingController();
  TextEditingController _surnameFieldController = TextEditingController();
  TextEditingController _patronumoFieldController = TextEditingController();
  TextEditingController _birthdateController = TextEditingController();

  TextEditingController _homeFieldController = TextEditingController();
  TextEditingController _phoneFieldController = TextEditingController();
  TextEditingController _emailFieldController = TextEditingController();
  TextEditingController _afmFieldController = TextEditingController();
  String listDOIstring = listDOI.first;
  TextEditingController _arOximatosFieldController = TextEditingController();
  TextEditingController _arDiplomatosFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getParabati();
  }

  Future<void> _getParabati() async {
    final results = await widget.database
        .rawQuery('SELECT * FROM customers WHERE id = ${widget.item['id']}');
    setState(() {
      _data = results;
      _nameFieldController = TextEditingController(text: _data[0]['name']);
      _surnameFieldController =
          TextEditingController(text: _data[0]['surname']);
      _patronumoFieldController =
          TextEditingController(text: _data[0]['patronumo']);
      _birthdateController = TextEditingController(
          text: DateFormat('dd/MM/yyyy').format(
              DateTime.fromMillisecondsSinceEpoch(
                  _data[0]['imerominia_genisis'] * 1000)));
      _homeFieldController = TextEditingController(text: _data[0]['home']);
      _phoneFieldController = TextEditingController(text: _data[0]['phone']);
      _emailFieldController = TextEditingController(text: _data[0]['email']);
      _afmFieldController = TextEditingController(text: _data[0]['afm']);
      listDOIstring = listDOI[listDOI.indexOf(_data[0]['doi'])];
      _arOximatosFieldController =
          TextEditingController(text: _data[0]['ar_oximatos']);
      _arDiplomatosFieldController =
          TextEditingController(text: _data[0]['ar_diplomatos']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Επεξεργασία στοιχείων Παραβάτη'),
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
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              const Text(
                'Φόρμα Επεξεργασίας Δεδομένων',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameFieldController,
                          decoration: const InputDecoration(
                            labelText: 'Όνομα*',
                            icon: Icon(Icons.person),
                          ),
                        ),
                        TextField(
                          controller: _surnameFieldController,
                          decoration: const InputDecoration(
                            labelText: 'Επώνυμο*',
                            icon: Icon(Icons.person_outline),
                          ),
                        ),
                        TextField(
                          controller: _patronumoFieldController,
                          decoration: const InputDecoration(
                            labelText: 'Πατρώνυμο *',
                            icon: Icon(Icons.person_4),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              _birthdateController.text =
                                  DateFormat('dd/MM/yyyy').format(date);
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _birthdateController,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9/]')),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Ημερομηνία γέννησης',
                                hintText: 'dd/MM/yyyy',
                                icon: Icon(Icons.calendar_today),
                              ),
                            ),
                          ),
                        ),
                        TextField(
                          controller: _phoneFieldController,
                          maxLength: 10,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Τηλέφωνο *',
                            icon: Icon(Icons.phone),
                          ),
                        ),
                        TextField(
                          controller: _homeFieldController,
                          decoration: const InputDecoration(
                            labelText: 'Διεύθυνση Κατοικίας *',
                            icon: Icon(Icons.home),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: _afmFieldController,
                          maxLength: 9,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Α.Φ.Μ. *',
                            icon: Icon(Icons.onetwothree),
                          ),
                        ),
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Λίστα με όλες τις ΔΟΥ *',
                            icon: Icon(Icons.label),
                            border: InputBorder.none,
                          ),
                          child: DropdownButton<String>(
                            value: listDOIstring,
                            onChanged: (String? value) {
                              // This is called when the user selects an item.
                              setState(() {
                                listDOIstring = value!;
                              });
                            },
                            items: listDOI
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                        TextField(
                          controller: _emailFieldController,
                          decoration: const InputDecoration(
                            labelText: 'Email *',
                            icon: Icon(Icons.email),
                          ),
                        ),
                        TextField(
                          controller: _arOximatosFieldController,
                          decoration: const InputDecoration(
                            labelText: 'Αριθμός Κυκλοφορίας Οχήματος *',
                            icon: Icon(Icons.car_rental_sharp),
                          ),
                        ),
                        TextField(
                          controller: _arDiplomatosFieldController,
                          decoration: const InputDecoration(
                            labelText: 'Αριθμός Διπλώματος *',
                            icon: Icon(Icons.note),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  final String name = _nameFieldController.text.trim();
                  final String surname = _surnameFieldController.text.trim();
                  final String patronumo =
                      _patronumoFieldController.text.trim();
                  final String home = _homeFieldController.text.trim();
                  final String phone = _phoneFieldController.text.trim();
                  final String email = _emailFieldController.text.trim();
                  final String afm = _afmFieldController.text.trim();
                  final String doi = listDOIstring;
                  final String arOximatos =
                      _arOximatosFieldController.text.trim();
                  final String arDiplomatos =
                      _arDiplomatosFieldController.text.trim();
                  int birthdateInSeconds = 0;
                  final String genethlia = _birthdateController.text.trim();

                  if (name.isNotEmpty &&
                      surname.isNotEmpty &&
                      patronumo.isNotEmpty &&
                      genethlia.isNotEmpty &&
                      home.isNotEmpty &&
                      phone.isNotEmpty &&
                      email.isNotEmpty &&
                      afm.isNotEmpty &&
                      doi.isNotEmpty &&
                      arOximatos.isNotEmpty &&
                      arDiplomatos.isNotEmpty) {
                    final birthdate = DateFormat('dd/MM/yyyy')
                        .parse(_birthdateController.text);
                    birthdateInSeconds =
                        birthdate.millisecondsSinceEpoch ~/ 1000;
                    await widget.database.transaction((txn) async {
                      await txn.rawUpdate(
                          'UPDATE customers SET name = ?, surname = ?, patronumo = ?, imerominia_genisis = ?, home = ?, phone = ?, email = ?, afm = ?, doi = ?, ar_oximatos = ?, ar_diplomatos = ? WHERE id = ?',
                          [
                            name,
                            surname,
                            patronumo,
                            birthdateInSeconds,
                            home,
                            phone,
                            email,
                            afm,
                            doi,
                            arOximatos,
                            arDiplomatos,
                            widget.item['id']
                          ]);
                    }); // Call the callback function
                    Navigator.pop(context);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Αποθήκευση Αλλαγών'),
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
