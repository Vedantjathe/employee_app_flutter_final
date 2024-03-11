import 'dart:convert';

import 'package:erp/controller/dbProvider.dart';
import 'package:erp/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../db/UserDao.dart';
import '../models/User.dart';
import '../navigation/NavigationPage.dart';
import '../utils/ColorConstants.dart';
import '../utils/Dialogs.dart';
import '../utils/StringConstants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
//  final loginViewModel viewModel = loginViewModel();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? errorTextMobile = "", errorTextAAdhar = "", errorMessage = "";
  bool _errorAAsharFlag = false,
      _errorMobileFlag = false,
      _errorMessageFlag = false;
  bool passwordVisible = false;

  late final UserDao userDao;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    passwordVisible = true;
    // emailController.text='P0020';
    // passwordController.text='P0020';
    userDao = Provider.of<DBProvider>(context, listen: false).dao;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.1),
            child: Center(
              child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  width: screenWidth * 0.50,
                  height: screenHeight * 0.22,
                  child: Image.asset('assets/krsnaa_img.png')),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Padding(
            //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
            padding: const EdgeInsets.only(
                left: 28.0, right: 28.0, top: 4, bottom: 0),
            child: Focus(
              onFocusChange: ((value) {
                setState(() {
                  if (!value) {
                    if (emailController.text.trim().isEmpty) {
                      errorTextMobile = "Please Enter Employee ID";
                      _errorMobileFlag = true;
                    } else {
                      errorTextMobile = "";
                      _errorMobileFlag = false;
                    }
                  }
                });
              }),
              child: TextField(
                controller: emailController,
                maxLength: 7,
                inputFormatters: [
                  FilteringTextInputFormatter(RegExp(r'[a-zA-Z0-9]'),
                      allow: true)
                ],
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        const BorderSide(color: Color(0xFF3A9FBE), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        const BorderSide(color: Color(0xFF3A9FBE), width: 1),
                  ),
                  fillColor: const Color(0xFFFFFFFF),
                  filled: true,
                  counterText: "",
                  hintText: "Employee ID",
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 20, 20, 20),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      setState(() {
                        errorTextMobile = "";
                        _errorMobileFlag = false;
                        _errorMobileFlag = false;
                        errorMessage = "";
                        _errorMessageFlag = false;
                      });
                    } else {
                      setState(() {
                        errorTextMobile = "Please Enter Employee ID";
                        _errorMobileFlag = true;
                        _errorMobileFlag = false;
                        errorMessage = "";
                        _errorMessageFlag = false;
                      });
                    }
                  });
                },
              ),
            ),
          ),
          Row(
            children: [
              Visibility(
                visible: _errorMobileFlag,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.fromLTRB(50, 10, 0, 0),
                  child: Text(
                    errorTextMobile!,
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: 'Segoe',
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 28.0, right: 28.0, top: 4.0, bottom: 0),
            //padding: EdgeInsets.symmetric(horizontal: 15),
            child: Focus(
              onFocusChange: ((value) {
                setState(() {
                  if (!value) {
                    if (emailController.text.trim().isEmpty) {
                      errorTextMobile = "Please Enter Employee ID";
                      _errorMobileFlag = true;
                    } else if (passwordController.text.isEmpty) {
                      errorTextMobile = "";
                      _errorMobileFlag = false;
                      _errorAAsharFlag = true;
                      errorTextAAdhar = "Please Enter Password";
                    } else {
                      errorTextMobile = "";
                      errorTextAAdhar = "";
                      _errorMobileFlag = false;
                      _errorAAsharFlag = false;
                    }
                  } else {
                    if (emailController.text.trim().isEmpty) {
                      errorTextMobile = "Enter Your Employee ID";
                      _errorMobileFlag = true;
                    } else {
                      errorTextMobile = "";
                      errorTextAAdhar = "";
                      _errorMobileFlag = false;
                      _errorAAsharFlag = false;
                    }
                  }
                });
              }),
              child: TextField(
                obscureText: passwordVisible,
                controller: passwordController,
                maxLength: 20,
                onSubmitted: (value) async {
                  await _loginUser();
                },
                decoration: InputDecoration(
                  hintText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(
                        () {
                          passwordVisible = !passwordVisible;
                        },
                      );
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        const BorderSide(color: Color(0xFF3A9FBE), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        const BorderSide(color: Color(0xFF3A9FBE), width: 1),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFFFFFF),
                  counterText: "",
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 22, 20, 22),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _errorMobileFlag = false;
                      errorTextAAdhar = "";
                      _errorAAsharFlag = true;
                      errorMessage = "";
                      _errorMessageFlag = false;
                    });
                  } else {
                    setState(() {
                      _errorMobileFlag = false;
                      errorTextAAdhar = "Please Enter Password";
                      errorMessage = "";
                      _errorMessageFlag = false;
                    });
                  }
                },
              ),
            ),
          ),
          Row(
            children: [
              Visibility(
                visible: _errorAAsharFlag,
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.fromLTRB(50, 10, 0, 0),
                  child: Text(
                    errorTextAAdhar!,
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: 'Segoe',
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),
            height: 50,
            width: 200,
            decoration: BoxDecoration(
                color: const Color(0xFF14BBC0),
                borderRadius: BorderRadius.circular(10)),
            child: MaterialButton(
              onPressed: () async {
                await _loginUser();
              },
              child: const Text(
                'LOGIN',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          Visibility(
            visible: _errorMessageFlag,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    overflow: TextOverflow.ellipsis,
                    fontFamily: 'Segoe',
                    fontWeight: FontWeight.normal),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void login(String email, password) async {
    try {
      Dialogs.showLoadingDialog(context);
      //HttpClient httpClient = new HttpClient();
      //httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      Response response = await post(
          Uri.parse(
              '${StringConstants.BASE_URL}LIS_UserPermission_API/User_Login'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'authKey': StringConstants.AUTHKEY,
            'userId': email,
            'password': password
          }));
      if (!mounted) return;
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        if (data['lisResult'].toString() == 'True') {
          var user = User(
              username: data['username'].toString(),
              usertype: data['usertype'].toString(),
              assignedRole: data['assignedRole'].toString(),
              userid: data['userid'].toString(),
              userDepartment: data['userDepartment'].toString(),
              isUnBlockedForBilling: data['isUnBlockedForBilling'].toString(),
              locationID: data['locationID'].toString(),
              department: data['department'].toString(),
              designation: data['designation'] != null
                  ? data['designation'].toString()
                  : "");
          await userDao.insertPerson(user);
          Fluttertoast.showToast(
              msg: "Login Successful",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
          if (!mounted) return;

          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return NavigationPage(key: const Key("value"), user: user);
          }), (r) {
            return false;
          });
        } else {
          setState(() {
            errorMessage = 'Please Enter Valid Employee ID & Password';
            _errorMessageFlag = true;
          });
        }
      } else {
        errorMessage = 'Server not responding. Please try later';
        _errorMessageFlag = true;
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        _errorMessageFlag = true;
      });

      logger.i(e.toString());
    }
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
                  Uri url = Uri(path: "tel://02068146814");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch ${url.path}';
                  }
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
                  Uri url = Uri(path: "tel://02046954695");

                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
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
                  Uri url = Uri(path: "mailto:enquiry@krsnadiagnostics.com");

                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
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
                  Uri url =
                      Uri(path: "whatsapp://send?phone=919623396233&text=hi");

                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
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

  _loginUser() async {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    // bool net = await ConnectivityUtils.hasConnection();
    if (hasConnection) {
      setState(() {
        _errorMobileFlag = false;
        if (emailController.text.trim().isEmpty) {
          errorTextMobile = "Please Enter Your Employee ID";
          _errorMobileFlag = true;
        } else if (passwordController.text.isEmpty) {
          errorTextMobile = "";
          _errorMobileFlag = false;
          _errorAAsharFlag = true;
          errorTextAAdhar = "Please Enter Your Password";
        } else {
          errorTextMobile = "";
          errorTextAAdhar = "";
          _errorMobileFlag = false;
          _errorAAsharFlag = false;
          login(emailController.text, passwordController.text);
        }
      });
    } else {
      Fluttertoast.showToast(
          msg: "No Internet Connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
