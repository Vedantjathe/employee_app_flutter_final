import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:erp/custom_widgets/custom_button.dart';
import 'package:erp/custom_widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../db/ErpDatabase.dart';
import '../db/UserDao.dart';
import '../logger.dart';
import '../models/User.dart';
import '../utils/ConnectivityUtils.dart';
import '../utils/Dialogs.dart';
import '../utils/StringConstants.dart';
import '../utils/util_methods.dart';

class CenterExpenseDetailPage extends StatefulWidget {
  final String? ownerID;
  final String? expenseCode;
  final String? paidBy;
  final String? expenseType;

  const CenterExpenseDetailPage(
      this.ownerID, this.expenseCode, this.paidBy, this.expenseType,
      {super.key});

  @override
  State<CenterExpenseDetailPage> createState() => _CenterExpenseDetailState();
}

class _CenterExpenseDetailState extends State<CenterExpenseDetailPage> {
  var expenseAmount = "";

  var expenseBookingDate = "";

  var expenseDateToDisplay = "";

  var accountType = "";

  var accountDescription = "";

  var expenseStatus = "";

  var expenseDescription = "";

  var paymentMode = "";

  var narration = "";
  var expFilePath = "";

  DateTime? expenseDate2;

  String? ownerID;
  String? expenseCode;
  String? paidBy;
  String? expenseType;

  ErpDatabase? krsnaaDatabase;
  UserDao? userDao;
  User? user;
  var pagePermission = false;
  _CenterExpenseDetailState();

  @override
  void initState() {
    ownerID = widget.ownerID;
    expenseCode = widget.expenseCode;
    paidBy = widget.paidBy;
    expenseType = widget.expenseType;
    builder();
    super.initState();
  }

  builder() async {
    krsnaaDatabase =
        await $FloorErpDatabase.databaseBuilder(StringConstants.DBNAME).build();
    setState(() {
      userDao = krsnaaDatabase!.personDao;
      userDao!.findAllPersons().then(
          (value) => {print(value.toString()), userPagePermission(value[0])});
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: mediaQuery.size.height * 0.08,
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: const Text(
          "Review Expense",
          style: TextStyle(
            fontSize: 21,
            color: Colors.white,
            fontFamily: 'Segoe',
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0XFFF9F9F9),
                  border: Border.all(width: 1, color: const Color(0XFFBEDCF0)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Expense Amount",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            expenseAmount,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const VerticalDivider(
                        width: 1,
                        color: Colors.grey,
                      ),
                      Column(
                        children: [
                          const Text(
                            "Expense Date",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            (expenseDateToDisplay.split(' ')[0]),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0XFFF9F9F9),
                  border: Border.all(width: 1, color: const Color(0XFFBEDCF0)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 4,
                          child: Text(
                            "Paid By",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Text(
                            ":",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Text(
                            paidBy!,
                            softWrap: true,
                            maxLines: 10,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 4,
                          child: Text(
                            "Account type",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Text(
                            ":",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Text(
                            accountType,
                            softWrap: true,
                            maxLines: 10,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 4,
                          child: Text(
                            "Account Description",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Text(
                            ":",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Text(
                            accountDescription,
                            softWrap: true,
                            maxLines: 10,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0XFFF9F9F9),
                  border: Border.all(width: 1, color: const Color(0XFFBEDCF0)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 4,
                          child: Text(
                            "Status",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Text(
                            ":",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Container(
                            child: Text(
                              expenseStatus,
                              softWrap: true,
                              maxLines: 10,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 4,
                          child: Text(
                            "Expense Type",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Text(
                            ":",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Container(
                            child: Text(
                              expenseType!,
                              softWrap: true,
                              maxLines: 10,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 4,
                          child: Text(
                            "Narration",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Text(
                            ":",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Container(
                            child: Text(
                              narration!,
                              softWrap: true,
                              maxLines: 10,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0XFFF9F9F9),
                  border:
                      Border.all(width: 1.3, color: const Color(0XFFBEDCF0)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 8,
                      width: double.infinity,
                    ),
                    const Text(
                      "Attachment",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Visibility(
                      visible: expFilePath.isNotEmpty,
                      child: Text(
                        expFilePath.split('/').last,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xff3A9FBE),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: GradientButton(
                                onPressed: showPreviewDialog,
                                label: 'Preview')),
                        SizedBox(width: 16),
                        Expanded(
                            child: GradientButton(
                                onPressed: () {
                                  downloadFile();
                                },
                                label: 'Download'))
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future userPagePermission(User usert) async {
    try {
      user = usert;
      Dialogs.showLoadingDialog(context);
      if (await ConnectivityUtils.hasConnection()) {
        Response response = await post(
          Uri.parse(
              '${StringConstants.BASE_URL}LIS_UserPermission_API/User_PagePermission'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'authKey': StringConstants.AUTHKEY,
            'userId': user!.userid,
            'pageName': "MyDashboard",
            'LocationID': user!.locationID
          }),
        ).timeout(const Duration(seconds: 24));
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body.toString());
          if (data['lisResult'].toString() == 'True') {
            if (data['visibility'].toString() == 'YES') {
              setState(() {
                pagePermission = true;
              });
              getReviewDetailsData();
            } else {
              setState(() {
                pagePermission = false;
              });

              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          } else {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
            final snackBar = SnackBar(
              content: Text(data['lisMessage'].toString()),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {
                  // Some code to undo the change.
                },
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          Navigator.of(context).pop();
          final snackBar = SnackBar(
            content: const Text('Please check internet connection'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );
        }
      } else {
        Navigator.of(context).pop();
        final snackBar = SnackBar(
          content: const Text('Please check internet connection'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on TimeoutException catch (e) {
      final snackBar = SnackBar(
        content: const Text('Please try later'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      //logger.i(e.toString());
      Navigator.of(context).pop();
      final snackBar = SnackBar(
        content: const Text('Please Contact KDL Admin'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> getReviewDetailsData() async {
    try {
      final response = await http.post(
          Uri.parse(
              '${StringConstants.BASE_URL}StaffExp/LoadExpenseDetailsByCode'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'authKey': StringConstants.AUTHKEY,
            'ownerId': ownerID,
            'expensecode': expenseCode
          }));

      final responseData = json.decode(response.body);
      final lisResult = responseData['lisResult'].toString();
      if (response.statusCode == 200) {
        if (lisResult == 'True') {
          Navigator.of(context).pop();
          var data = responseData['loadExpenseByCode_Details'][0];
          setState(() {
            expenseAmount = "\u{20B9}${data['expenseAmount']}";

            expenseDateToDisplay = DateFormat("dd-MMM-yyyy")
                .format(DateFormat("M/d/yyyy").parse(data['expenseDate']));

            expenseBookingDate = "${data['createdOn']}";

            accountType = "${data['accountTypeCode']}";

            accountDescription = "${data['accountDescription']}";

            expenseStatus = "${data['expenseStatus']}";

            expenseDescription = "${data['expenseDescription']}";

            paymentMode = "${data['paymentMode']}";
            narration = "${data['expenseDescription']}";
            expFilePath = "${data['expFilePath']}";
          });
        } else {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        Navigator.of(context).pop();
        logger.i('HTTP Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showPreviewDialog() async {
    OverlayEntry overlayEntry = OverlayEntry(builder: (_) => LoadingOverlay());
    try {
      Navigator.of(context).overlay?.insert(overlayEntry);
      File file = await loadPdfFromNetwork(
          "${StringConstants.BASE_URL.split("api/")[0]}${expFilePath.split("~/")[1]}");
      overlayEntry.remove();
      final result = await OpenFilex.open(file.path);
    } catch (e) {
      overlayEntry.remove();

      logger.e(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  downloadFile() async {
    OverlayEntry overlayEntry =
        OverlayEntry(builder: (context) => const LoadingOverlay());
    Navigator.of(context).overlay?.insert(overlayEntry);

    var url = Uri.parse(
        "${StringConstants.BASE_URL.split("api/")[0]}${expFilePath.split("~/")[1]}");

    try {
      final response = await http.get(
        url,
      );

      if (response.contentLength == 0) {
        overlayEntry.remove();
        Future.delayed(
            const Duration(seconds: 0),
            () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('File did not download .\nTry again later.'),
                    backgroundColor: Colors.red,
                  ),
                ));
        return;
      }
      String tempPath = await createFolder();
      if (tempPath == "") {
        overlayEntry.remove();
        Future.delayed(
            const Duration(seconds: 0),
            () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Storage permission needed to download file . Go to setting and turn on permission storage."),
                    backgroundColor: Colors.red,
                  ),
                ));
      } else {
        File file = File('$tempPath/${expFilePath.split('/').last}');
        /*int i = 1;
        while (file.existsSync()) {
          file = File(
              '$tempPath/${expFilePath.split('.').first}($i).${expFilePath.split('.').last}');
          i++;
        }*/
        await file.writeAsBytes(response.bodyBytes);
        // OpenFile.open(file.path);
        overlayEntry.remove();
        Future.delayed(
            const Duration(seconds: 0),
            () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'File download successfully at this location $tempPath'),
                    backgroundColor: Colors.green,
                  ),
                ));
      }
    } catch (e) {
      overlayEntry.remove();
      logger.e(e);
    }
  }
}
