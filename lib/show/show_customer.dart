import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:sqlite_example/theme/mytheme_preference.dart';
import '../add/add_new_parabasi.dart';
import '../edit/edit_parabasi.dart';
import 'show_parabasi.dart';

class ShowCustomer extends StatefulWidget {
  const ShowCustomer({
    required this.database,
    required this.item,
    Key? key,
  }) : super(key: key);

  final Database database;
  final Map<String, dynamic> item;

  @override
  _ShowCustomerState createState() => _ShowCustomerState();
}

class _ShowCustomerState extends State<ShowCustomer>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabBar _tabBar;
  late List<Map<String, dynamic>> _data = [];
  final MyThemePreferences _preferences = MyThemePreferences();
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _getTheme();

    _tabController = TabController(length: 2, vsync: this);
    _tabBar = TabBar(
      controller: _tabController,
      tabs: const [
        Tab(
          icon: Icon(Icons.info),
          text: "Στοιχεία Παραβάτη",
        ),
        Tab(
          icon: Icon(Icons.history),
          text: "Ιστορικό Παραβάσεων",
        ),
      ],
      indicatorColor: Colors.black,
    );

    _getParabaseis();
  }

  void _getTheme() async {
    bool isDark = await _preferences.getTheme();
    setState(() {
      _isDark = isDark;
    });
  }

  Future<void> _getParabaseis() async {
    final results = await widget.database.rawQuery(
        'SELECT * FROM parabaseis WHERE id_customer = ${widget.item['id']} ORDER BY date ASC');
    setState(() {
      _data = results;
    });
  }

  Widget _buildList() {
    if (_data.isEmpty) {
      return const Center(child: Text('Δεν έχει ακόμη παράβαση!'));
    }

    return ListView.builder(
      itemCount: _data.length,
      itemBuilder: (BuildContext context, int index) {
        final record = _data[index];
        final idParabasis = record['id'];
        final subject = record['parabasi'];
        final dateTime = DateTime.fromMillisecondsSinceEpoch(record['date']);
        final date = DateFormat('dd/MM/yyyy').format(dateTime);
        return Card(
          child: ListTile(
            title: Text(date),
            subtitle: Text(
              '$subject',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    // Show a dialog box to confirm deletion
                    bool deleteConfirmed = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Διαγραφή Παράβασης;"),
                          content: const Text("Είσαι σίγουρος;"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Ακύρωση"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Διαγραφή Παράβασης"),
                            ),
                          ],
                        );
                      },
                    );
                    // Delete the record from the database if confirmed
                    if (deleteConfirmed == true) {
                      await widget.database.delete('parabaseis',
                          where: 'id = ?', whereArgs: [record['id']]);
                      // Refresh the list of records
                      await _getParabaseis();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditParabasi(
                          database: widget.database,
                          item: widget.item,
                          numberParabasi: idParabasis,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowParabasi(
                          database: widget.database,
                          item: widget.item,
                          numberParabasi: idParabasis,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
        widget.item['imerominia_genisis'] * 1000);
    String bod = DateFormat('dd/MM/yyyy').format(dateTime);

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.item['name'] + " " + widget.item['surname']),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: _tabBar.preferredSize,
            child: Material(
              color: Colors.grey,
              child: _tabBar,
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Stoixeia Parabati
          Center(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 100,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    color: _isDark
                                        ? Colors.black
                                        : Colors.grey.shade200,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.person),
                                        SizedBox(width: 5),
                                        Text("Όνομα"),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: widget.item['name'] == null
                                        ? const Text("-")
                                        : Text(widget.item['name']),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    color: _isDark
                                        ? Colors.black
                                        : Colors.grey.shade200,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.person_outline),
                                        SizedBox(width: 5),
                                        Text("Πατρώνυμο"),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: widget.item['patronumo'] == null
                                        ? const Text("-")
                                        : Text(widget.item['patronumo']),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    color: _isDark
                                        ? Colors.black
                                        : Colors.grey.shade200,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.person_outline),
                                        SizedBox(width: 5),
                                        Text("Επώνυμο"),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: widget.item['surname'] == null
                                        ? const Text("-")
                                        : Text(widget.item['surname']),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 100,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    color: _isDark
                                        ? Colors.black
                                        : Colors.grey.shade200,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.calendar_today),
                                        SizedBox(width: 5),
                                        Text("Ημερομηνία Γέννησης"),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: widget.item['imerominia_genisis'] ==
                                            null
                                        ? const Text("-")
                                        : Text(bod),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    color: _isDark
                                        ? Colors.black
                                        : Colors.grey.shade200,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.home),
                                        SizedBox(width: 5),
                                        Text("Διεύθυνση Κατοικίας"),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: widget.item['home'] == null
                                        ? const Text("-")
                                        : Text(widget.item['home']),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 100,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    color: _isDark
                                        ? Colors.black
                                        : Colors.grey.shade200,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.phone),
                                        SizedBox(width: 5),
                                        Text("Τηλέφωνο Επικοινωνίας"),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: widget.item['phone'] == null
                                        ? const Text("-")
                                        : Text(widget.item['phone']),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    color: _isDark
                                        ? Colors.black
                                        : Colors.grey.shade200,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.email),
                                        SizedBox(width: 5),
                                        Text("Email"),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: widget.item['email'] == null
                                        ? const Text("-")
                                        : Text(widget.item['email']),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 100,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    color: _isDark
                                        ? Colors.black
                                        : Colors.grey.shade200,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.onetwothree),
                                        SizedBox(width: 5),
                                        Text("Α.Φ.Μ."),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: widget.item['afm'] == null
                                        ? const Text("-")
                                        : Text(widget.item['afm']),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    color: _isDark
                                        ? Colors.black
                                        : Colors.grey.shade200,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.label),
                                        SizedBox(width: 5),
                                        Text("Δ.Ο.Υ."),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: widget.item['doi'] == null
                                        ? const Text("-")
                                        : Text(widget.item['doi']),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 100,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    color: _isDark
                                        ? Colors.black
                                        : Colors.grey.shade200,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.car_rental_sharp),
                                        SizedBox(width: 5),
                                        Text("Αριθμός κυκλοφορίας οχήματος"),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: widget.item['ar_oximatos'] == null
                                        ? const Text("-")
                                        : Text(widget.item['ar_oximatos']),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    color: _isDark
                                        ? Colors.black
                                        : Colors.grey.shade200,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.note),
                                        SizedBox(width: 5),
                                        Text("Αριθμός Διπλώματος"),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: widget.item['ar_diplomatos'] == null
                                        ? const Text("-")
                                        : Text(widget.item['ar_diplomatos']),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Istoriko Parabaseon
          _buildList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewParabasi(
                database: widget.database,
                item: widget.item,
              ),
            ),
          ).then((value) {
            _getParabaseis();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
