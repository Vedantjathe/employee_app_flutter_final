import 'package:flutter/material.dart';

import '../db/UserDao.dart';
import '../models/User.dart';

class DrawerProfilePage extends StatefulWidget {
  final User user;
  const DrawerProfilePage({super.key, required this.user});

  @override
  State<DrawerProfilePage> createState() => _DrawerProfilePageState();
}

class _DrawerProfilePageState extends State<DrawerProfilePage> {
  late final UserDao userDao;

  late User user;
  @override
  void initState() {
    // TODO: implement initState
    user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: 'Segoe',
            fontWeight: FontWeight.normal,
          ),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
        toolbarHeight: mediaQuery.size.height * 0.08,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xff3A9FBE),
                Color(0xff17E1DA),
              ],
              // colors: <Color> [Color.fromARGB(100, 58, 159, 190),
              //   Color.fromARGB(100, 23, 225,218),
              // ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, false); // This will pop the current route
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(8),
              child: Image.asset('assets/app_icon_circle.png'),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    "User Name",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    user.username ?? "",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                    //softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "User Type",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    user.usertype ?? "",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Department",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    user.department ?? "",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "User Id",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    user.userid ?? "",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
//
// class DrawerProfilePage extends StatelessWidget {
//   const DrawerProfilePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return
//
//
