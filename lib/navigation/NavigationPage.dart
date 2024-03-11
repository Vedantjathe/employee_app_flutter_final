import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erp/centerexpense/CenterExpensePage.dart';
import 'package:erp/dashboard/Dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import '../auth/LoginPage.dart';
import '../controller/dbProvider.dart';
import '../db/UserDao.dart';
import '../individual/drawer_profile_page.dart';
import '../individual/individual_expense.dart';
import '../individual/ledger.dart';
import '../individual_expense_approval/individual_expense_approval_page.dart';
import '../models/User.dart';
import '../ticket/ticketPage.dart';
import '../utils/ColorConstants.dart';
import '../utils/dialog_util.dart';

//checking

class NavigationPage extends StatefulWidget {
  const NavigationPage({required Key key, required this.user})
      : super(key: key);

  final User user;

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int bottomSelectedIndex = 0;

  //GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool appBarVisible = true;

  late StreamSubscription subscription;
  bool isDeviceConnected = true;
  bool isAlertSet = false;

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    if (centerExpense) {
      return [
        BottomNavigationBarItem(
          label: 'Dashboard',
          backgroundColor: ColorConstants.purpul500Color,
          icon: Image.asset(
            "assets/dashboard.png",
            scale: 3.8,
          ),
          activeIcon: Image.asset(
            "assets/dashboard_selected.png",
            scale: 3.8,
          ),
        ),
        BottomNavigationBarItem(
          label: 'Expense',
          backgroundColor: ColorConstants.purpul500Color,
          icon: Image.asset(
            "assets/expense.png",
            scale: 3.8,
          ),
          activeIcon: Image.asset(
            "assets/expense_selected.png",
            scale: 3.8,
          ),
        ),
      ];
    } else {
      return [
        BottomNavigationBarItem(
          label: 'Expense',
          backgroundColor: ColorConstants.purpul500Color,
          icon: Image.asset(
            "assets/expense.png",
            scale: 3.8,
          ),
          activeIcon: Image.asset(
            "assets/expense_selected.png",
            scale: 3.8,
          ),
        ),
        BottomNavigationBarItem(
          label: 'Ledger',
          backgroundColor: ColorConstants.purpul500Color,
          icon: Image.asset(
            "assets/ledger.png",
            scale: 3.8,
          ),
          activeIcon: Image.asset(
            "assets/ledger_selected.png",
            scale: 3.8,
          ),
        ),
        BottomNavigationBarItem(
          label: 'Approval',
          backgroundColor: ColorConstants.purpul500Color,
          icon: Image.asset("assets/ic_approval.png", scale: 3.8),
          activeIcon: Image.asset(
            "assets/ic_approval_selected.png",
            scale: 3.8,
          ),
        ),
      ];
    }
  }

  late final UserDao userDao;
  User? user;
  String? _loginMode = "Individual";
  bool centerExpense = true;
  List<String> pageName = ['Dashboard', 'Expense', 'Approval'];

  String appBarTitle = 'Dashboard'; // Initialize with the default title

  void updateAppBarTitle(int index) {
    setState(() {
      bottomSelectedIndex = index;
      switch (index) {
        case 0:
          appBarTitle = centerExpense ? 'DASHBOARD' : "INDIVIDUAL EXPENSES";
          break;
        case 1:
          appBarTitle = centerExpense ? 'EXPENSES' : 'LEDGER';
          break;
        case 2:
          appBarTitle = 'EXPENSE MANAGER APPROVAL';
          break;
        // Add more cases as needed
      }
    });
  }

  void helpDialog() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(children: [
                Align(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      "Help",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 21,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(5, 20, 22, 5),
                    child: InkWell(
                      child: Image.asset(
                        'assets/ic_action_close.png',
                        color: Colors.cyan,
                        height: 24,
                        width: 24,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                )
              ]),
              const Text(
                textAlign: TextAlign.center,
                "Please call on any following number",
                style: TextStyle(
                    color: ColorConstants.purpul500Color,
                    fontSize: 18,
                    fontFamily: 'Segoe',
                    fontWeight: FontWeight.normal),
              ),
              InkWell(
                onTap: () async {
                  /*const url = "tel://02068146814";
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }*/
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        textAlign: TextAlign.center,
                        "02068146814",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 18,
                            fontFamily: 'Segoe',
                            fontWeight: FontWeight.normal),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Image.asset(
                        'assets/ic_action_call.png',
                        height: 18,
                        width: 18,
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  /*const url = "tel://02046954695";
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }*/
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        textAlign: TextAlign.center,
                        "02046954695",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 18,
                            fontFamily: 'Segoe',
                            fontWeight: FontWeight.normal),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Image.asset(
                        'assets/ic_action_call.png',
                        height: 18,
                        width: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const Text(
                textAlign: TextAlign.center,
                "Please mail us your message",
                style: TextStyle(
                    color: ColorConstants.purpul500Color,
                    fontSize: 18,
                    fontFamily: 'Segoe',
                    fontWeight: FontWeight.normal),
              ),
              InkWell(
                onTap: () async {
                  /*const url = "mailto:enquiry@krsnadiagnostics.com";
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }*/
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        textAlign: TextAlign.center,
                        "enquiry@krsnadiagnostics.com",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 18,
                            fontFamily: 'Segoe',
                            fontWeight: FontWeight.normal),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Image.asset(
                        'assets/ic_action_mail.png',
                        height: 18,
                        width: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const Text(
                textAlign: TextAlign.center,
                "Please whatsapp us your message",
                style: TextStyle(
                    color: ColorConstants.purpul500Color,
                    fontSize: 18,
                    fontFamily: 'Segoe',
                    fontWeight: FontWeight.normal),
              ),
              InkWell(
                onTap: () async {
                  /*const url = "whatsapp://send?phone=919623396233" + "&text=hi";
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }*/
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        textAlign: TextAlign.center,
                        "919623396233",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 18,
                            fontFamily: 'Segoe',
                            fontWeight: FontWeight.normal),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Image.asset(
                        'assets/ic_action_whatsapp.png',
                        height: 18,
                        width: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20)
            ],
          );
        });
  }

  @override
  void initState() {
    userDao = Provider.of<DBProvider>(context, listen: false).dao;
    user ??= widget.user;
    subscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        isDeviceConnected = await InternetConnectionChecker().hasConnection;
        if (!isDeviceConnected && isAlertSet == false) {
          if (!mounted) return;
          showNoInternetDialogBox(context, onPressAction);
          setState(() => isAlertSet = true);
        }
      },
    );
    super.initState();
    getConnectivity();
    bottomSelectedIndex = 0;
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: _getBody(),
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => // Ensure Scaffold is in context
              GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
              child: Image.asset(
                "assets/drawer_icon.png",
                width: 24,
                height: 24,
              ),
            ),
          ),
        ),
        leadingWidth: 48,
        centerTitle: true,
        title: Text(
          appBarTitle.toUpperCase(),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Segoe',
              fontWeight: FontWeight.normal),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0XFF3A9FBE), Color(0XFF17E1DA)]),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 48, bottom: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0XFF3A9FBE), Color(0XFF17E1DA)]),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/app_icon_circle.png'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: Text(
                      user == null ? "" : user!.username.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      user == null ? "" : user!.usertype,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Builder(
                    builder: (context) => // Ensure Scaffold is in context
                        Container(
                      margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white,
                          width: 2, // Specify the border width here
                        ),
                      ),
                      child: MaterialButton(
                        onPressed: () async {
                          setState(() {
                            if (centerExpense) {
                              _loginMode = 'Center Manager';
                              centerExpense = false;
                            } else {
                              _loginMode = 'Individual';
                              centerExpense = true;
                            }
                            bottomSelectedIndex = 0;

                            Scaffold.of(context).closeDrawer();
                          });
                          updateAppBarTitle(0);
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: Text(
                            _loginMode!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 60.0, vertical: 10.0),
                    leading: const Icon(
                      Icons.person_4_outlined,
                      size: 40,
                      color: Color(0xff1CBDB7),
                    ),
                    title: const Text(
                      'Profile',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.normal),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DrawerProfilePage(
                                  user: user!,
                                )),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 60.0, vertical: 6.0),
                    leading: const Icon(
                      CupertinoIcons.tickets_fill,
                      size: 40,
                      color: Color(0xff1CBDB7),
                    ),
                    title: const Text(
                      ' Ticket  ',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.normal),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TicketPage(
                                  user: user!,
                                )),
                      );
                    },
                  ),
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(20),
                        height: 50,
                        width: 200,
                        decoration: BoxDecoration(
                            color: ColorConstants.purpul500Color,
                            borderRadius: BorderRadius.circular(10)),
                        child: MaterialButton(
                          onPressed: () async {
                            await userDao.DeleteAllUser();
                            if (!mounted) return;
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (rout) => false);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                child: Image.asset(
                                  "assets/ic_action_logout.png",
                                  width: 26,
                                  height: 26,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                child: Text(
                                  'Log Out',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Text(
                          textAlign: TextAlign.center,
                          "For any query drop mail at\nsupport@krsnaadiagnostics.com",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Segoe',
                              fontWeight: FontWeight.normal),
                        ),
                      )
                    ],
                  ),
                )),
          ],
        ),
      ),
      bottomNavigationBar: Stack(children: <Widget>[
        Positioned(
          child: BottomNavigationBar(
            currentIndex: bottomSelectedIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedItemColor: const Color(0XFF2EBEC7),
            unselectedItemColor: const Color(0XFF484C52),
            onTap: (index) {
              updateAppBarTitle(index);
            },
            items: buildBottomNavBarItems(),
          ),
        ),
      ]),
    );
  }

  getConnectivity() async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    checkInternetCondition();
  }

  onPressAction() async {
    Navigator.pop(context, 'Cancel');
    setState(() => isAlertSet = false);
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    checkInternetCondition();
  }

  checkInternetCondition() async {
    if (!isDeviceConnected && isAlertSet == false) {
      if (!mounted) return;
      showNoInternetDialogBox(context, onPressAction);
      setState(() => isAlertSet = true);
    }
  }

  _getBody() {
    List centerPages = [const Dashboard(), const CenterExpensePage()];
    List indiPages = [
      const ExpensesPage2(),
      const LedgerPage(),
      const IndividualExpenseApproval(),
    ];
    return centerExpense
        ? centerPages[bottomSelectedIndex]
        : indiPages[bottomSelectedIndex];
  }
}
