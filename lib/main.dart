import 'dart:async';
import 'dart:io';

import 'package:erp/controller/dbProvider.dart';
import 'package:erp/db/ErpDatabase.dart';
import 'package:erp/utils/MyHttpOverrides.dart';
import 'package:erp/utils/StringConstants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/LoginPage.dart';
import 'db/UserDao.dart';
import 'navigation/NavigationPage.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final krsnaaDatabase =
      await $FloorErpDatabase.databaseBuilder(StringConstants.DBNAME).build();
  final userDao = krsnaaDatabase.personDao;
  HttpOverrides.global = MyHttpOverrides();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<DBProvider>(
        create: (context) => DBProvider(krsnaaDatabase, userDao),
      )
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  builder() async {
    ErpDatabase pharmacyDatabase =
        await $FloorErpDatabase.databaseBuilder(StringConstants.DBNAME).build();
    UserDao userDao = pharmacyDatabase.personDao;
    Timer(
        const Duration(seconds: 3),
        () => userDao.findAllPersons().then((value) => {
              if (value.isNotEmpty)
                {
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return NavigationPage(
                        key: const Key("value"), user: value[0]);
                  }), (r) {
                    return false;
                  })
                }
              else
                {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginPage())),
                }
            }));
  }

  @override
  void initState() {
    super.initState();
    builder();
  }

  void startTimer() {}

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        body: SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,

      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: <Widget>[
            Expanded(
                flex: 6,
                child: Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/krsnaa_img.png',
                    height: 160.0,
                    width: 160.0,
                  ),
                )),
            Expanded(
                flex: 1,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  margin: const EdgeInsets.only(bottom: 10, top: 60),
                  alignment: Alignment.bottomCenter,
                  child: const Text(
                    "www.KrsnaaDiagnostics.com",
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Segoe',
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                  ),
                )),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    ));
  }
}
