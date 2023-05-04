import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'package:intro_screen_onboarding_flutter/intro_app.dart';

import 'edit/edit_customer.dart';
import 'show/show_customer.dart';
import 'theme/model_theme.dart';
import 'intro/intro.dart';
import 'add/add_customers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  await WindowManager.instance.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1300, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool? introScreenValue = prefs.getBool('firstTimeLoad');

  if (introScreenValue == null) {
    // It means there is not set (so it is first time)
    await prefs.setBool('firstTimeLoad', true);
  }

  if (introScreenValue == true || introScreenValue == null) {
    // It means it's the first time the app is being loaded, so show IntroScreen
    await prefs.setBool('firstTimeLoad', false);
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setTitle('Αρχείο Παραβάσεων');
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      await windowManager.show();
      await windowManager.focus();
    });
    runApp(const IntroApp());
  } else {
    // The app has been loaded before, so show MyApp directly
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setTitle('Αρχείο Παραβάσεων');
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      await windowManager.show();
      await windowManager.focus();
    });

    runApp(const MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<Map<String, dynamic>> _data;
  late List<Map<String, dynamic>> _filteredData;
  final TextEditingController _searchController = TextEditingController();
  late Database _db;
  bool deleteConfirmed = false;

  @override
  void initState() {
    super.initState();
    _data = [];
    _filteredData = [];
    _loadData();
  }

  void _loadData() async {
    // Open the database file
    final databaseFactory = databaseFactoryFfi;
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    String appDocPath = appDirectory.path;
    String dir = Directory.current.path;
    // final String databasePath = '${appDirectory.path}/databasedb.db';
    final String databasePath = '${dir}/databasedb.db';
    _db = await databaseFactory.openDatabase(databasePath,
        options: OpenDatabaseOptions(
          onCreate: (db, version) {
            // Create the customers table
            db.execute('''CREATE TABLE IF NOT EXISTS customers (
                      id INTEGER PRIMARY KEY AUTOINCREMENT, 
                      name TEXT NOT NULL, 
                      surname TEXT NOT NULL,
                      patronumo TEXT NOT NULL,
                      imerominia_genisis INTEGER NOT NULL,
                      home TEXT NOT NULL,
                      phone TEXT NOT NULL,
                      email TEXT NOT NULL,
                      afm TEXT NOT NULL,
                      doi TEXT NOT NULL,
                      ar_oximatos TEXT NOT NULL,
                      ar_diplomatos TEXT NOT NULL
                  )
              ''');
            db.execute('''CREATE TABLE IF NOT EXISTS parabaseis (
                      id INTEGER PRIMARY KEY AUTOINCREMENT,
                      id_customer INTEGER,
                      date INTEGER,
                      parabasi TEXT,
                      article INTEGER,
                      diploma INTEGER,
                      imeres_dipl INTEGER,
                      stoixeia INTEGER,
                      imeres_stoixeion INTEGER,
                      keimeno TEXT
                  )
              ''');
          },
          version: 1,
        ));

    // Retrieve the data from the database
    final results = await _db.rawQuery('SELECT * FROM customers');
    setState(() {
      _data = results;
      _filteredData = results;
    });
  }

  void _filterData(String query) {
    setState(() {
      _filteredData = _data
          .where((item) =>
              item['name'].toLowerCase().contains(query.toLowerCase()) ||
              item['surname'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _addCustomer(Map<String, dynamic> customer) async {
    // Insert the new customer into the database
    await _db.insert('customers', customer);

    // Update the data lists with the new customer data
    final newData = await _db.rawQuery('SELECT * FROM customers');
    setState(() {
      _data = newData;
      _filteredData = newData;
    });
  }

  @override
  void dispose() {
    _db.close(); // Close the database connection
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowManager.setTitleBarStyle(TitleBarStyle.normal);
    return ChangeNotifierProvider(
      create: (_) => ModelTheme(),
      child: Consumer<ModelTheme>(
          builder: (context, ModelTheme themeNotifier, child) {
        return MaterialApp(
          theme: themeNotifier.isDark
              ? ThemeData(
                  brightness: Brightness.dark,
                )
              : ThemeData(
                  brightness: Brightness.light,
                  primaryColor: Colors.blue,
                  primarySwatch: Colors.blue),
          debugShowCheckedModeBanner: false,
          home: Navigator(onGenerateRoute: (RouteSettings settings) {
            return MaterialPageRoute<void>(builder: (BuildContext context) {
              if (_data.isEmpty) {
                return Scaffold(
                  appBar: AppBar(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('Αρχείο Παραβάσεων'),
                    centerTitle: true,
                    actions: <Widget>[
                      IconButton(
                          icon: Icon(themeNotifier.isDark
                              ? Icons.nightlight_round
                              : Icons.wb_sunny),
                          onPressed: () {
                            themeNotifier.isDark
                                ? themeNotifier.isDark = false
                                : themeNotifier.isDark = true;
                          })
                    ],
                  ),
                  body: const Center(
                      child: Text(
                    'Δεν υπάρχει μέχρι στιγμής κανένας παράβατης!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )),
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddNewCustomer(database: _db),
                        ),
                      );
                      final newData =
                          await _db.rawQuery('SELECT * FROM customers');
                      setState(() {
                        _data = newData;
                        _filteredData = newData;
                        // print(_data);
                      });
                      _filterData(_searchController.text);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Προσθήκη Παραβάτη"),
                  ),
                );
              } else {
                return Scaffold(
                  appBar: AppBar(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('Αρχείο Παραβάσεων'),
                    centerTitle: true,
                    actions: <Widget>[
                      IconButton(
                          icon: Icon(themeNotifier.isDark
                              ? Icons.nightlight_round
                              : Icons.wb_sunny),
                          onPressed: () {
                            themeNotifier.isDark
                                ? themeNotifier.isDark = false
                                : themeNotifier.isDark = true;
                          })
                    ],
                  ),
                  body: Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Αναζήτηση',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: _filterData,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _filteredData.length,
                            itemBuilder: (BuildContext context, int index) {
                              final item = _filteredData[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: const Icon(Icons.account_circle),
                                      title: Text(
                                          item['name'] + " " + item['surname']),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        const SizedBox(width: 8),
                                        TextButton(
                                            child:
                                                const Text('ΔΙΑΓΡΑΦΗ ΠΑΡΑΒΑΤΗ'),
                                            onPressed: () async {
                                              bool deleteConfirmed =
                                                  await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Διαγραφή Παραβάτη"),
                                                    content: const Text(
                                                        "Είσαι σίγουρος;"),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false),
                                                        child: const Text(
                                                            "Ακύρωση"),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true),
                                                        child: const Text(
                                                            "Διαγραφή Παραβάτη"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                              // Delete the record from the database if confirmed
                                              if (deleteConfirmed == true) {
                                                await _db.delete('customers',
                                                    where: 'id = ?',
                                                    whereArgs: [item['id']]);
                                                // Refresh the list of records
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: const Text(
                                                        'Έγινε Διαγραφή του Παραβάτη'),
                                                  ),
                                                );

                                                _loadData();
                                              }
                                            }),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          child: const Text(
                                              'ΕΠΕΞΕΡΓΑΣΙΑ ΣΤΟΙΧΕΙΩΝ'),
                                          onPressed: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditCustomer(
                                                  database: _db,
                                                  item: item,
                                                ),
                                              ),
                                            );
                                            final newData = await _db.rawQuery(
                                                'SELECT * FROM customers');
                                            setState(() {
                                              _data = newData;
                                              _filteredData = newData;
                                            });
                                            _filterData(_searchController.text);
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          child:
                                              const Text('ΠΡΟΒΟΛΗ ΣΤΟΙΧΕΙΩΝ'),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ShowCustomer(
                                                        database: _db,
                                                        item: item),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddNewCustomer(database: _db),
                        ),
                      );
                      final newData =
                          await _db.rawQuery('SELECT * FROM customers');
                      setState(() {
                        _data = newData;
                        _filteredData = newData;
                        // print(_data);
                      });
                      _filterData(_searchController.text);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Προσθήκη Παραβάτη"),
                  ),
                );
              }
            });
          }),
        );
      }),
    );
  }
}
