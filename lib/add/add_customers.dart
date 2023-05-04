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

class AddNewCustomer extends StatefulWidget {
  const AddNewCustomer({required this.database, Key? key}) : super(key: key);

  final Database database;

  @override
  _AddNewCustomerState createState() => _AddNewCustomerState();
}

class _AddNewCustomerState extends State<AddNewCustomer> {
  final TextEditingController _nameFieldController = TextEditingController();
  final TextEditingController _surnameFieldController = TextEditingController();
  final TextEditingController _patronumoFieldController =
      TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  final TextEditingController _homeFieldController = TextEditingController();
  final TextEditingController _phoneFieldController = TextEditingController();
  final TextEditingController _emailFieldController = TextEditingController();
  final TextEditingController _afmFieldController = TextEditingController();
  String listDOIstring = listDOI.first;
  final TextEditingController _arOximatosFieldController =
      TextEditingController();
  final TextEditingController _arDiplomatosFieldController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Εισαγωγή Παραβάτη'),
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
                'Φόρμα Εισαγωγής Δεδομένων',
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
                      await txn.rawInsert(
                          'INSERT INTO customers(name, surname, patronumo, imerominia_genisis, home, phone, email, afm, doi, ar_oximatos, ar_diplomatos) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
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
                            arDiplomatos
                          ]);
                    });
                    Navigator.pop(context);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Αποθήκευση Νέου Παραβάτη'),
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
