import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory? dir = await getExternalStorageDirectory();
  Hive.init(dir!.path);
  Hive.openBox("myDB");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formValidation = GlobalKey<FormState>();
  late Box database;
  TextEditingController lnameController = TextEditingController(),
      fnameController = TextEditingController(),
      idController = TextEditingController();

  OutlineInputBorder tffborder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        width: 1,
        color: Colors.green,
      ));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    database = Hive.box("myDB");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: const Text("Hive Database"),
      ),
      body: Column(
        children: [
          Expanded(
              child: ValueListenableBuilder(
                  valueListenable: database.listenable(),
                  builder: (BuildContext context, Box value, Widget? child) {
                    return ListView.separated(
                        itemBuilder: (context, index) {
                          String key = database.keys.toList()[index];
                          List<String> value = database.get(key);
                          return ListTile(
                            title: Text(key),
                            subtitle: Text("Name : ${value[0]} ${value[1]}"),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: database.length);
                  })),
        ],
      ),
      floatingActionButton: ButtonBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: () {
              buildAlertDialogue(
                context,
              );
            },
            tooltip: 'Add Entry',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () {
              buildAlertDialogue(context, update: true);
            },
            tooltip: 'Edit Entry',
            child: const Icon(Icons.edit),
          ),
          FloatingActionButton(
            onPressed: () {
              buildAlertDialogue(context, remove: true);
            },
            tooltip: 'Remove Entry',
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  void buildAlertDialogue(BuildContext context,
      {bool update = false, remove = false}) {
    late AlertDialog dialogue;
    if (update) {
      dialogue = AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
              onPressed: () {
                if (_formValidation.currentState!.validate()) {
                  if (database.keys.toList().contains(idController.text)) {
                    database.put(idController.text,
                        [fnameController.text, lnameController.text]);
                    idController.clear();
                    fnameController.clear();
                    lnameController.clear();
                    Navigator.pop(context);
                  } else {}
                }
              },
              child: const Text("Add Entry"))
        ],
        title: Form(
          key: _formValidation,
          child: Column(
            children: [
              TextFormField(
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  controller: idController,
                  validator: (input) {
                    if (input!.isNotEmpty) {
                      if (database.keys.toList().contains(idController.text)) {
                        return null;
                      }
                      else {
                        return "This Id does not exists !!";
                      }
                    } else {
                      return "This Field can't be empty !!";
                    }
                  },
                  decoration: InputDecoration(
                      labelText: "Id : ",
                      enabledBorder: tffborder,
                      errorBorder: tffborder,
                      focusedBorder: tffborder)),
              const Divider(
                color: Colors.transparent,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                controller: fnameController,
                validator: notEmptyValidation,
                decoration: InputDecoration(
                    enabledBorder: tffborder,
                    errorBorder: tffborder,
                    focusedBorder: tffborder,
                    labelText: "First Name : "),
              ),
              const Divider(
                color: Colors.transparent,
              ),
              TextFormField(
                controller: lnameController,
                validator: notEmptyValidation,
                decoration: InputDecoration(
                    enabledBorder: tffborder,
                    errorBorder: tffborder,
                    focusedBorder: tffborder,
                    labelText: "Last Name : "),
              ),
            ],
          ),
        ),
      );
    } else if (remove) {
      dialogue = AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
              onPressed: () {
                if (_formValidation.currentState!.validate()) {
                  database.delete(idController.text);
                  idController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text("Remove"))
        ],
        title: Form(
          key: _formValidation,
          child: Column(
            children: [
              const Text("Enter the Id you want to delete : "),
              const Divider(
                color: Colors.transparent,
              ),
              TextFormField(
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  controller: idController,
                  validator: (input) {
                    if (input!.isNotEmpty) {
                      if (database.keys.toList().contains(idController.text)) {
                        return null;
                      }
                      else {
                        return "This Id does not exists !!";
                      }
                    } else {
                      return "This Field can't be empty !!";
                    }
                  },
                  decoration: InputDecoration(
                      labelText: "Id : ",
                      enabledBorder: tffborder,
                      errorBorder: tffborder,
                      focusedBorder: tffborder)),
            ],
          ),
        ),
      );
    } else {
      dialogue = AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
              onPressed: () {
                if (_formValidation.currentState!.validate()) {
                  database.put(idController.text,
                      [fnameController.text, lnameController.text]);
                  idController.clear();
                  fnameController.clear();
                  lnameController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text("Add Entry"))
        ],
        title: Form(
          key: _formValidation,
          child: Column(
            children: [
              TextFormField(
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  controller: idController,
                  validator: notEmptyValidation,
                  decoration: InputDecoration(
                      labelText: "Id : ",
                      enabledBorder: tffborder,
                      errorBorder: tffborder,
                      focusedBorder: tffborder)),
              const Divider(
                color: Colors.transparent,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                controller: fnameController,
                validator: notEmptyValidation,
                decoration: InputDecoration(
                    enabledBorder: tffborder,
                    errorBorder: tffborder,
                    focusedBorder: tffborder,
                    labelText: "First Name : "),
              ),
              const Divider(
                color: Colors.transparent,
              ),
              TextFormField(
                controller: lnameController,
                validator: notEmptyValidation,
                decoration: InputDecoration(
                    enabledBorder: tffborder,
                    errorBorder: tffborder,
                    focusedBorder: tffborder,
                    labelText: "Last Name : "),
              ),
            ],
          ),
        ),
      );
    }

    showDialog(context: context, builder: (context) => dialogue);
  }

  String? notEmptyValidation(String? input) {
    if (input!.isNotEmpty) {
      return null;
    } else {
      return "This Field can't be empty !!";
    }
  }
}
