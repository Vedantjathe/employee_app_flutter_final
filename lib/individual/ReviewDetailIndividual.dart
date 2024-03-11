import 'dart:convert' show json, jsonEncode;
import 'dart:io';

import 'package:erp/logger.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../custom_widgets/loading_overlay.dart';
import '../utils/StringConstants.dart';
import '../utils/util_methods.dart';

class ReviewDetailsPage extends StatefulWidget {
  final String? expenseCode;
  const ReviewDetailsPage(this.expenseCode, {super.key});
  // const ReviewDetailsPage(this.expenseCode, {super.key});

  @override
  State<ReviewDetailsPage> createState() =>
      _ReviewDetailsPageState(this.expenseCode);
}

class _ReviewDetailsPageState extends State<ReviewDetailsPage> {
  final String? expenseCode;

  var expFilePath = "";

  _ReviewDetailsPageState(this.expenseCode);

  void showPreviewDialog() async {
    OverlayEntry overlayEntry =
        OverlayEntry(builder: (_) => const LoadingOverlay());
    try {
      Navigator.of(context).overlay?.insert(overlayEntry);
      File file = await loadPdfFromNetwork(
          "${StringConstants.BASE_URL.split("api/")[0]}${expFilePath.split("com/")[1]}");
      overlayEntry.remove();
      final result = await OpenFilex.open(file.path);
      logger.i(result.message);
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

  void showDownloadDialog() async {
    OverlayEntry overlayEntry =
        OverlayEntry(builder: (_) => const LoadingOverlay());
    try {
      Navigator.of(context).overlay?.insert(overlayEntry);
      String result = await downloadFile(
          "${StringConstants.BASE_URL.split("api/")[0]}${expFilePath.split("com/")[1]}",
          expFilePath.split('/').last);
      overlayEntry.remove();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (overlayEntry.mounted) overlayEntry.remove();

      logger.e(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  var travellingKM = "";

  var travellingFrom = "";

  var travellingTo = "";

  var expenseAmount = "";

  var expenseBookingDate = "";
  var centerLocationName = "";

  var expenseDateToDisplay = "";

  var accountType = "";

  var accountDescription = "";

  var expenseStatus = "";

  var expenseDescription = "";

  var paymentMode = "";

  var travelDistance = "";
  var noOfPeople = "";

  DateTime? expenseDate2;

  @override
  void initState() {
    super.initState();
    getReviewDetailsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: const Center(
            child: Padding(
          padding: EdgeInsets.only(right: 40),
          child: Text(
            "Review Expense",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Segoe',
                fontWeight: FontWeight.normal),
          ),
        )),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: const Color(0XFFF9F9F9),
                  border: Border.all(width: 1, color: const Color(0XFFBEDCF0)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: const Color(0XFFBEDCF0),
                    ),
                    Expanded(
                      child: Column(
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
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color(0XFFF9F9F9),
                  border: Border.all(width: 1, color: const Color(0XFFBEDCF0)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Expense Booking Date  :",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          expenseBookingDate.split('T')[0],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Centre Location  :",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: Text(
                            centerLocationName,
                            maxLines: 4,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        const Text(
                          "Account type  :",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Flexible(
                          child: Text(
                            accountType,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        const Text(
                          "Account Description : ",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Flexible(
                          child: Text(
                            accountDescription,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Visibility(
                      visible: accountType == "DAILY ALLOWANCE",
                      child: Row(
                        children: [
                          const Text(
                            "Kilometer  :",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            travelDistance,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: accountType == "HOTEL",
                      child: Row(
                        children: [
                          const Text(
                            "No. Of Person  :",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            noOfPeople,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: accountType == "TRAVELLING",
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 4, 4),
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color(0XFFF9F9F9),
                    border:
                        Border.all(width: 1, color: const Color(0XFFBEDCF0)),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Travel From:",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            travellingFrom,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Travel To :",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            travellingTo,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Distance in Km:",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            travellingKM,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      /*const SizedBox(
                          height: 8,
                        ),
                        const Row(
                          children: [
                            Text(
                              "Kilometer:",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "30 KM",
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),*/
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 4, 4),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color(0XFFF9F9F9),
                  border: Border.all(width: 1, color: const Color(0XFFBEDCF0)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Status:",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          expenseStatus,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Expense Description :",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Text(
                            expenseDescription,
                            maxLines: 4,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Visibility(
                      visible: false,
                      child: Row(
                        children: [
                          const Text(
                            "Payment Mode:",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            paymentMode,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    /*const SizedBox(
                          height: 8,
                        ),
                        const Row(
                          children: [
                            Text(
                              "Kilometer:",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "30 KM",
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),*/
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color(0XFFF9F9F9),
                  border: Border.all(width: 1, color: const Color(0XFFBEDCF0)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Attachment",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
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
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            // width: 150,
                            // height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff3A9FBE),
                                  Color(0xff17E1DA),
                                ],
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: showPreviewDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                disabledForegroundColor:
                                    Colors.transparent.withOpacity(0.38),
                                disabledBackgroundColor:
                                    Colors.transparent.withOpacity(0.12),
                                shadowColor: Colors.transparent,
                              ),
                              child: const Text(
                                "Preview",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            // width: 150,
                            // height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff3A9FBE),
                                  Color(0xff17E1DA),
                                ],
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: showDownloadDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                disabledForegroundColor:
                                    Colors.transparent.withOpacity(0.38),
                                disabledBackgroundColor:
                                    Colors.transparent.withOpacity(0.12),
                                shadowColor: Colors.transparent,
                              ),
                              child: const Text(
                                "Download",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getReviewDetailsData() async {
    try {
      final response = await http.post(
          Uri.parse(
              '${StringConstants.BASE_URL}TravelExpenseRequest/Get_Indiv_StaffExpenses_ByCode'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'authKey': StringConstants.AUTHKEY,
            'ExpenseCode': expenseCode
          }));

      final responseData = json.decode(response.body);

      final lisResult = responseData['lisResult'].toString();

      if (response.statusCode == 200) {
        if (lisResult == 'True') {
          setState(() {
            expenseAmount = "\u{20B9}${responseData['expenseAmount']}";

            expenseDateToDisplay = "${responseData['expenseDate']}";

            expenseBookingDate = DateFormat("dd-MMM-yyyy").format(
                DateFormat("M/d/yyyy")
                    .parse(responseData['createdOn'].toString().split(" ")[0]));

            accountType = "${responseData['accountTypeCode']}";

            centerLocationName =
                "${responseData['centerLocation'] == 'NewProject' ? "New Project" : responseData['centerLocationName']}";

            accountDescription = "${responseData['accountDescription']}";

            expenseStatus = "${responseData['expenseStatus']}";

            expenseDescription = "${responseData['expenseDescription']}";

            paymentMode = "${responseData['paymentMode']}";

            travellingKM = "${responseData['travellingKM']}";
            travellingFrom = "${responseData['travellingFrom']}";
            travellingTo = "${responseData['travellingTo']}";
            noOfPeople = "${responseData['noOfPeople']}";
            travelDistance = "${responseData['kilometer']}";
            expFilePath = "${responseData['onlineEXPFilePath']}";
          });
        } else {
          // Authentication failed
          logger.i('Login failed');
          // You can display an error message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Non-200 status code, handle accordingly
        logger.i('HTTP Error: ${response.statusCode}');
        // You can display an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle exceptions, e.g., network issues
      logger.i('Exception occurred: $e');
      // You can display an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

//
// Future fetchCardData() async {
//   try {
//     // Dialogs.showLoadingDialog(context);
//     if (await ConnectivityUtils.hasConnection()) {
//       var accountTypeData="";
//       if(statusValueNew2!=null){
//         accountTypeData=statusValueNew2!.accountType;
//       }
//
//       Response response = await post(
//         Uri.parse('${StringConstants.BASE_URL}TravelExpenseRequest/Get_Indiv_StaffExpenses'),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           'ExpenseType':" ",
//           'AccountType':accountTypeData??"",
//           'authKey':StringConstants.AUTHKEY,
//           'ExpenseStatus':testTypeValue ?? "",
//           'fromDate':DateFormat("yyyy-MM-dd")
//               .format(DateFormat("dd MMM yyyy").parse(fromDate)),
//           'ownerId':location!.locationCode.toString(),
//           'staffCode':user!.userid,
//           'toDate':DateFormat("yyyy-MM-dd")
//               .format(DateFormat("dd MMM yyyy").parse(toDate)),
//         }),
//       ).timeout(const Duration(seconds: 24));
//
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body.toString());
//         if (data['lisResult'].toString() == 'True') {
//           setState(() {
//             var labDetails =
//             data["loadIndividualExpenses_Details"] as List<dynamic>?;
//             cardExpenseItems = labDetails != null
//             // map each review to a Review object
//                 ? labDetails
//                 .map((reviewData) =>
//                 ExpenseDetail.fromJson(reviewData))
//             // map() returns an Iterable so we convert it to a List
//                 .toList()
//             // use an empty list as fallback value
//                 : <ExpenseDetail>[];
//           });
//         } else {
//           final snackBar = SnackBar(
//             content: Text(data['lisMessage'].toString()),
//             action: SnackBarAction(
//               label: 'OK',
//               onPressed: () {
//                 // Some code to undo the change.
//               },
//             ),
//           );
//
//           ScaffoldMessenger.of(context).showSnackBar(snackBar);
//         }
//       } else {
//         // Navigator.of(context).pop();
//         final snackBar = SnackBar(
//           content: const Text('Please check internet connection'),
//           action: SnackBarAction(
//             label: 'OK',
//             onPressed: () {
//               // Some code to undo the change.
//             },
//           ),
//         );
//       }
//     } else {
//       //Navigator.of(context).pop();
//       final snackBar = SnackBar(
//         content: const Text('Please check internet connection'),
//         action: SnackBarAction(
//           label: 'OK',
//           onPressed: () {
//             // Some code to undo the change.
//           },
//         ),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     }
//   } on TimeoutException catch (e) {
//     final snackBar = SnackBar(
//       content: const Text('Please try later'),
//       action: SnackBarAction(
//         label: 'OK',
//         onPressed: () {
//           // Some code to undo the change.
//         },
//       ),
//     );
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   } catch (e) {
//     //logger.i(e.toString());
//     //Navigator.of(context).pop();
//     final snackBar = SnackBar(
//       content: const Text('Please Contact KDL Admin'),
//       action: SnackBarAction(
//         label: 'OK',
//         onPressed: () {
//           // Some code to undo the change.
//         },
//       ),
//     );
//
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   } finally {
//     Navigator.of(context).pop();
//   }
// }
