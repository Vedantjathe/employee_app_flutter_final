import 'dart:async';
import 'dart:convert';

import 'package:erp/controller/dbProvider.dart';
import 'package:erp/custom_widgets/error_page.dart';
import 'package:erp/custom_widgets/loading_overlay.dart';
import 'package:erp/custom_widgets/required_permission_layout.dart';
import 'package:erp/individual/view_details_page.dart';
import 'package:erp/logger.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../db/UserDao.dart';
import '../models/LedgerPagedataModel.dart';
import '../models/User.dart';
import '../models/ViewDetails2Model.dart';
import '../services/erp_services.dart';
import '../utils/ColorConstants.dart';
import '../utils/StringConstants.dart';
import '../utils/util_methods.dart';

final formatter = DateFormat.yMd();

class LedgerPage extends StatefulWidget {
  const LedgerPage({super.key});

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  final OverlayEntry overlayEntry =
      OverlayEntry(builder: (context) => const LoadingOverlay());

  List<LoadLedgerList> cardLedgerItemsList = List.empty();

  List<String> yearList = [];

  List<String> monthList = [];

  late User loginUser;

  late final UserDao userDao;
  User? user;
  late final Future<bool> pagePermissionFuture;

  void generateYearList() {
    int currentYear = DateTime.now().year;

    for (int year = 2016; year <= currentYear; year++) {
      yearList.add(year.toString());
    }
  }

  void generateMonthsList() {
    for (int month = 1; month <= 12; month++) {
      String monthName = DateFormat('MMMM').format(DateTime(2022, month));
      monthList.add(monthName);
    }
  }

  String? yearValue;

  String? monthValue;

  late Future<List<LoadLedgerList>> futureLedgerCardData;
  TextEditingController searchController = TextEditingController();
  String searchText = '';

  List dataMapLedger = [];

  @override
  void initState() {
    //fetchProducts();
    userDao = Provider.of<DBProvider>(context, listen: false).dao;
    pagePermissionFuture = userPagePermission();
    generateYearList();
    generateMonthsList();
    // getDashboradData();
    //getRadioModalityDetails();
    //fetchLocations();

    yearValue = DateTime.now().year.toString();
    monthValue = monthList[DateTime.now().month - 1];
    // fetchExpenseDetails();
    super.initState();
    //fetchViewDetails2Data();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   foregroundColor: Colors.white,
      //   actions: <Widget>[
      //     IconButton(
      //       icon: Image.asset(
      //         'assets/excel.png',
      //         height: 32,
      //         fit: BoxFit.fitHeight,
      //       ),
      //       onPressed: () async {
      //         if (dataMapLedger.isEmpty) {
      //           Future.delayed(
      //               const Duration(seconds: 0),
      //               () => ScaffoldMessenger.of(context).showSnackBar(
      //                     const SnackBar(
      //                       content: Text('No Records Found'),
      //                       backgroundColor: Colors.red,
      //                     ),
      //                   ));
      //           return;
      //         }
      //         bool result = await exportExcel(dataMapLedger, 'LedgerPage.xlsx');
      //         if (result) {
      //           Future.delayed(
      //               const Duration(seconds: 0),
      //               () => ScaffoldMessenger.of(context).showSnackBar(
      //                     const SnackBar(
      //                       content: Text('Excel File Downloaded Successfully'),
      //                       backgroundColor: Colors.green,
      //                     ),
      //                   ));
      //         } else {
      //           Future.delayed(
      //               const Duration(seconds: 0),
      //               () => ScaffoldMessenger.of(context).showSnackBar(
      //                     const SnackBar(
      //                       content: Text('Error Downloading File'),
      //                       backgroundColor: Colors.red,
      //                     ),
      //                   ));
      //         }
      //       },
      //     ),
      //   ],
      //   toolbarHeight: _mediaQuery.size.height * 0.08,
      //   backgroundColor: Colors.white,
      //   elevation: 0.0,
      //   centerTitle: true,
      //   title: const Text(
      //     "TICKET",
      //     style: TextStyle(
      //       fontSize: 21,
      //       color: Colors.white,
      //       fontFamily: 'Segoe',
      //       fontWeight: FontWeight.normal,
      //     ),
      //   ),
      //   flexibleSpace: Container(
      //     decoration: const BoxDecoration(
      //       // borderRadius: BorderRadius.only(
      //       //   bottomLeft: Radius.circular(25),
      //       //   bottomRight: Radius.circular(25),
      //       // ),
      //       gradient: LinearGradient(
      //         begin: Alignment.topCenter,
      //         end: Alignment.bottomCenter,
      //         colors: <Color>[
      //           Color(0xff3A9FBE),
      //           Color(0xff17E1DA),
      //         ],
      //         // colors: <Color> [Color.fromARGB(100, 58, 169, 190),
      //         //   Color.fromARGB(100, 23, 225,218),
      //         // ],
      //       ),
      //     ),
      //   ),
      // ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorConstants.purpul500Color,
        child: Image.asset(
          'assets/excel.png',
          height: 32,
          fit: BoxFit.fitHeight,
        ),
        onPressed: () async {
          if (dataMapLedger.isEmpty) {
            Future.delayed(
                const Duration(seconds: 0),
                () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No Records Found'),
                        backgroundColor: Colors.red,
                      ),
                    ));
            return;
          }

          List<dynamic> labDetailsS = [];
          for (var jsonObject in dataMapLedger) {
            Map<String, dynamic> dataTwo =
                Map<String, dynamic>.from(jsonObject);
            dataTwo.remove("staffCode");
            labDetailsS.add(dataTwo);
          }
          bool result = await exportExcel(
              labDetailsS, 'ExpensesLedger_$monthValue-$yearValue.xlsx', null);
          if (result) {
            Future.delayed(
                const Duration(seconds: 0),
                () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Excel File Downloaded in Employee Folder Successfully'),
                        backgroundColor: Colors.green,
                      ),
                    ));
          } else {
            Future.delayed(
                const Duration(seconds: 0),
                () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error Downloading File'),
                        backgroundColor: Colors.red,
                      ),
                    ));
          }
        },
      ),
      body: FutureBuilder<bool>(
          future: pagePermissionFuture,
          builder: (context, permissionSS) {
            if (permissionSS.hasError) {
              return const ErrorPage();
            }
            if (permissionSS.hasData) {
              if (!permissionSS.data!) {
                return const RequiredPermissionPage();
              }
              return FutureBuilder<List<LoadLedgerList>>(
                  future: futureLedgerCardData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const LoadingOverlay();
                    }
                    if (snapshot.hasError) {
                      // snapshot.error.
                      return const Text('Error');
                    }
                    if (snapshot.hasData) {
                      searchLedgerCardItems = snapshot.data ?? [];
                      return Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 8, 5, 5),
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    //background color of dropdown button//border of dropdown button
                                    border: Border.all(
                                        color: const Color(0xFFC0C0C0)),
                                    borderRadius: BorderRadius.circular(
                                        10), //border raiuds of dropdown button
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: DropdownButton(
                                      borderRadius: BorderRadius.circular(10),
                                      underline: const SizedBox.shrink(),
                                      isExpanded: true,
                                      icon: Image.asset("assets/dropdown.png",
                                          color: const Color(0XFF5D5D5D),
                                          width: 14,
                                          height: 14),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                          fontFamily: 'Segoe',
                                          fontWeight: FontWeight.normal),
                                      onChanged: (value) {
                                        setState(() {
                                          //statusValue = value.;
                                          yearValue = value;
                                          futureLedgerCardData =
                                              fetchLedgerCardData(
                                                  testType: yearValue,
                                                  month: (monthList.indexOf(
                                                              monthValue!) +
                                                          1)
                                                      .toString());
                                        });
                                      },
                                      value: yearValue,
                                      hint: const Text("New"),
                                      items: yearList
                                          .map((value) => DropdownMenuItem(
                                              value: value,
                                              child: Text(
                                                value,
                                                maxLines: 5,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              )))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              Expanded(
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(5, 8, 10, 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    //background color of dropdown button//border of dropdown button
                                    border: Border.all(
                                        color: const Color(0xFFC0C0C0)),
                                    borderRadius: BorderRadius.circular(
                                        10), //border raiuds of dropdown button
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: DropdownButton(
                                      borderRadius: BorderRadius.circular(10),
                                      underline: const SizedBox.shrink(),
                                      isExpanded: true,
                                      icon: Image.asset("assets/dropdown.png",
                                          color: const Color(0XFF5D5D5D),
                                          width: 14,
                                          height: 14),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                          fontFamily: 'Segoe',
                                          fontWeight: FontWeight.normal),
                                      onChanged: (value) {
                                        setState(() {
                                          //statusValue = value.;
                                          monthValue = value;
                                          futureLedgerCardData =
                                              fetchLedgerCardData(
                                                  testType: yearValue,
                                                  month: (monthList.indexOf(
                                                              monthValue!) +
                                                          1)
                                                      .toString());
                                        });
                                      },
                                      value: monthValue,
                                      hint: const Text("New"),
                                      items: monthList
                                          .map((value) => DropdownMenuItem(
                                              value: value,
                                              child: Text(
                                                value,
                                                maxLines: 5,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              )))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: searchController,
                              decoration: kTFFDecoration.copyWith(
                                hintText: 'Search',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchText = value;
                                });
                              },
                            ),
                          ),
                          Expanded(
                              child: Visibility(
                            visible: searchLedgerCardItems.isNotEmpty,
                            replacement: const Text('No Data Found'),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: searchLedgerCardItems.length,
                              itemBuilder: (context, index) {
                                LoadLedgerList it =
                                    searchLedgerCardItems[index];
                                // if (searchText.isEmpty) {
                                //   searchLedgerCardItems = ledgerCardItems;
                                // } else {
                                //   searchLedgerCardItems = ledgerCardItems
                                //       .where((it) => ((it.accountCode ?? '')
                                //               .toLowerCase()
                                //               .contains(searchText.toLowerCase()) ||
                                //           (it.staffName ?? '')
                                //               .toLowerCase()
                                //               .contains(searchText.toLowerCase()) ||
                                //           (it.staffCode ?? '')
                                //               .toLowerCase()
                                //               .contains(searchText.toLowerCase()) ||
                                //           (it.openingBalance ?? '')
                                //               .toLowerCase()
                                //               .contains(searchText.toLowerCase()) ||
                                //           (it.advanceAmount ?? '')
                                //               .toLowerCase()
                                //               .contains(searchText.toLowerCase()) ||
                                //           (it.expenseAmount ?? '')
                                //               .toLowerCase()
                                //               .contains(searchText.toLowerCase()) ||
                                //           (it.creditAmount ?? '')
                                //               .toLowerCase()
                                //               .contains(searchText.toLowerCase()) ||
                                //           (it.debitAmount ?? '')
                                //               .toLowerCase()
                                //               .contains(searchText.toLowerCase()) ||
                                //           (it.closingBalance ?? '')
                                //               .toLowerCase()
                                //               .contains(searchText.toLowerCase())))
                                //       .toList();
                                // }
                                // setState(() {
                                //   Future<List<LoadLedgerList>> as() async =>
                                //       searchLedgerCardItems;
                                //   futureLedgerCardData = as();
                                // });
                                return Visibility(
                                  visible: ((it.accountCode ?? '')
                                          .toLowerCase()
                                          .contains(searchText.toLowerCase()) ||
                                      (it.staffName ?? '')
                                          .toLowerCase()
                                          .contains(searchText.toLowerCase()) ||
                                      (it.staffCode ?? '')
                                          .toLowerCase()
                                          .contains(searchText.toLowerCase()) ||
                                      (it.openingBalance ?? '')
                                          .toLowerCase()
                                          .contains(searchText.toLowerCase()) ||
                                      (it.advanceAmount ?? '')
                                          .toLowerCase()
                                          .contains(searchText.toLowerCase()) ||
                                      (it.expenseAmount ?? '')
                                          .toLowerCase()
                                          .contains(searchText.toLowerCase()) ||
                                      (it.creditAmount ?? '')
                                          .toLowerCase()
                                          .contains(searchText.toLowerCase()) ||
                                      (it.debitAmount ?? '')
                                          .toLowerCase()
                                          .contains(searchText.toLowerCase()) ||
                                      (it.closingBalance ?? '')
                                          .toLowerCase()
                                          .contains(searchText.toLowerCase())),
                                  child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0XFFF9F9F9),
                                      border: Border.all(
                                          width: 1.3,
                                          color: const Color(0XFFBEDCF0)),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 15, 0, 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Account Code',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black),
                                                    softWrap: true,
                                                  ),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text(
                                                    searchLedgerCardItems[index]
                                                        .accountCode!,
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Color(0xff156397),
                                                    ),
                                                    softWrap: true,
                                                  ),
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                  const Text(
                                                    'Name',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                    softWrap: true,
                                                  ),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text(
                                                    searchLedgerCardItems[index]
                                                        .staffName!,
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Color(0xff156397),
                                                    ),
                                                    softWrap: true,
                                                  ),
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Opening\nBalance',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              softWrap: true,
                                                            ),
                                                            Text(
                                                              '\u{20B9}${searchLedgerCardItems[index].openingBalance!}'
                                                                  .trim(),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                                color: Color(
                                                                    0xff156397),
                                                              ),
                                                              softWrap: true,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Credit\nAmount',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              softWrap: true,
                                                            ),
                                                            Text(
                                                              '\u{20B9}${searchLedgerCardItems[index].creditAmount!}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                                color: Color(
                                                                    0xff156397),
                                                              ),
                                                              softWrap: true,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Closing\nBalance',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              softWrap: true,
                                                            ),
                                                            Text(
                                                              '\u{20B9}${searchLedgerCardItems[index].closingBalance!}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                                color: Color(
                                                                    0xff156397),
                                                              ),
                                                              softWrap: true,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Debit\nAmount',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              softWrap: true,
                                                            ),
                                                            Text(
                                                              '\u{20B9}${searchLedgerCardItems[index].debitAmount!}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                                color: Color(
                                                                    0xff156397),
                                                              ),
                                                              softWrap: true,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              color: const Color(0xEAEAEAFF),
                                              margin: const EdgeInsets.fromLTRB(
                                                  4, 12, 8, 12),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                // Use a Column to stack text vertically
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  const Text(
                                                    "Advance Amount",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    '\u{20B9}${searchLedgerCardItems[index].advanceAmount!}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xff156397),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  InkWell(
                                                    onTap: () async {},
                                                    child: const Text(
                                                      'View Detail',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xff156397),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 40, right: 40),
                                                    child: Divider(
                                                      color: Colors.black,
                                                      // You can set the color of the line
                                                      thickness:
                                                          1, // You can adjust the thickness of the line
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  const Text(
                                                    'Expense Amount',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    '\u{20B9}${searchLedgerCardItems[index].expenseAmount!}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xff156397),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      List<dynamic>
                                                          expenseItemList =
                                                          await fetchExpenseDetails(
                                                              searchLedgerCardItems[
                                                                      index]
                                                                  .accountCode!);
                                                      if ((expenseItemList[0]
                                                              as List)
                                                          .isNotEmpty) {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (_) =>
                                                                ViewDetailsPages(
                                                              staffCode:
                                                                  searchLedgerCardItems[
                                                                          index]
                                                                      .accountCode!,
                                                              staffName:
                                                                  searchLedgerCardItems[
                                                                          index]
                                                                      .staffName!,
                                                              fileName:
                                                                  '${searchLedgerCardItems[index].accountCode!}  IndivExpense_$monthValue - $yearValue.xlsx',
                                                              expenseItemList:
                                                                  expenseItemList[
                                                                      0],
                                                              jsonData:
                                                                  expenseItemList[
                                                                      1],
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                'No records found'),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: const Text(
                                                      'View Detail',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xff156397),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 40, right: 40),
                                                    child: Divider(
                                                      color: Colors.black,
                                                      // You can set the color of the line
                                                      thickness:
                                                          1, // You can adjust the thickness of the line
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )),
                        ],
                      );
                    }
                    return const Text("No Data Found");
                  });
            }
            return const LoadingOverlay();
          }),
    );
  }

  List<LoadLedgerList> searchLedgerCardItems = [];

  Future<List<LoadLedgerList>> fetchLedgerCardData(
      {String? testType, String? month}) async {
    // OverlayEntry overlayEntry = OverlayEntry(builder: (context)=> LoadingOverlay());
    // Navigator.of(context).overlay?.insert(overlayEntry);
    // overlayEntry.remove();
    final userDao = Provider.of<DBProvider>(context, listen: false).dao;
    loginUser = (await userDao.findAllPersons()).first;

    final url =
        Uri.parse('${StringConstants.BASE_URL}TravelExpenseRequest/GetLedger');

    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'authKey': StringConstants.AUTHKEY,
          'ownerId': loginUser.userid,
          'year': testType,
          'month': month,

          //(monthList.indexOf(month!) + 1).toString()
        }));

    // logger.i(response.body);
    // logger.i(response.statusCode);

    final ticketDetailst = json
        .decode((response.body.toString()))['loadLedgerList'] as List<dynamic>?;
    dataMapLedger = ticketDetailst ?? [];

    // if the reviews are not missing
    final userList6 = ticketDetailst != null
        // map each review to a Review object
        ? ticketDetailst
            .map((reviewData) => LoadLedgerList.fromJson(reviewData))
            // map() returns an Iterable so we convert it to a List
            .toList()
        // use an empty list as fallback value
        : <LoadLedgerList>[];

    // ledgerCardItems = userList6;
    // setState(() {
    //   logger.i(ledgerCardItems);
    //   logger.i(snapshot.data ?? []);
    // });
    return userList6;
  }

  Future<List<dynamic>> fetchExpenseDetails(String accountCode) async {
    List<ExpenseItem> expenseItemList = List.empty(growable: true);
    loginUser = (await userDao.findAllPersons()).firstOrNull!;
    final url = Uri.parse(
        '${StringConstants.BASE_URL}TravelExpenseRequest/GetExpenseAmountData');

    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'authKey': StringConstants.AUTHKEY,
          'ownerId': accountCode,
          'year': yearValue,
          'month': (monthList.indexOf(monthValue!) + 1).toString()
        }));

    logger.i(response.body);
    logger.i(response.statusCode);

    final ticketDetailst =
        json.decode((response.body.toString()))['expenseAmountList']
            as List<dynamic>?;

    // if the reviews are not missing
    final userList7 = ticketDetailst != null
        // map each review to a Review object
        ? ticketDetailst
            .map((reviewData) => ExpenseItem.fromJson(reviewData))
            // map() returns an Iterable so we convert it to a List
            .toList()
        // use an empty list as fallback value
        : <ExpenseItem>[];

    expenseItemList = userList7;
    logger.i(expenseItemList);
    return [expenseItemList, ticketDetailst];
  }

  _getAdvanceAmountDetails(String accountCode) async {
    List<ExpenseItem> expenseItemList = List.empty(growable: true);
    Navigator.of(context).overlay?.insert(overlayEntry);
    try {
      Response response = await post(
        Uri.parse(
            '${StringConstants.BASE_URL}TravelExpenseRequest/GetAdvanceAmountData'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'authKey': StringConstants.AUTHKEY,
          'ownerId': accountCode,
          'year': yearValue,
          'month': (monthList.indexOf(monthValue!) + 1).toString(),
        }),
      ).timeout(const Duration(seconds: 24));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        if (data['lisResult'].toString() == 'True') {
          var labDetails = data["expenseAmountList"] as List<dynamic>?;
          expenseItemList = labDetails != null
              // map each review to a Review object
              ? labDetails
                  .map((reviewData) => ExpenseItem.fromJson(reviewData))
                  // map() returns an Iterable so we convert it to a List
                  .toList()
              // use an empty list as fallback value
              : <ExpenseItem>[];
          setState(() {
            expenseItemList;
          });
        } else {
          final snackBar = SnackBar(
            content: Text(data['lisMessage'].toString()),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
      overlayEntry.remove();
    } catch (e) {
      overlayEntry.remove();
      logger.i('View Details api error: $e');
    }
  }

  // void _viewExpenseAmount() {
  //   showGeneralDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  //     barrierColor: Colors.black45,
  //     transitionDuration: const Duration(milliseconds: 200),
  //     pageBuilder: (BuildContext buildContext, Animation animation,
  //         Animation secondaryAnimation) {
  //       return Center(
  //         child: Container(
  //           width: MediaQuery.of(context).size.width - 10,
  //           height: MediaQuery.of(context).size.height - 80,
  //           color: Colors.white,
  //           child: SingleChildScrollView(
  //             child: Column(
  //               children: [
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: Container(
  //                         decoration: const BoxDecoration(
  //                           gradient: LinearGradient(
  //                             begin: Alignment.topCenter,
  //                             end: Alignment.bottomCenter,
  //                             colors: <Color>[
  //                               Color(0xff3A9FBE),
  //                               Color(0xff17E1DA),
  //                             ],
  //                           ),
  //                         ),
  //                         height: 80.0,
  //                         child: const Center(
  //                           child: Text(
  //                             'Expense Amount',
  //                             style: TextStyle(
  //                               fontSize: 25,
  //                               color: Colors.black,
  //                               decoration: TextDecoration.none,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(
  //                   height: 20,
  //                 ),
  //                 const Row(
  //                   children: [
  //                     Padding(
  //                       padding: EdgeInsets.all(8.0),
  //                       child: Column(
  //                         children: [
  //                           Text(
  //                             "Staff Code",
  //                             style: TextStyle(
  //                               fontSize: 20,
  //                               color: Colors.black,
  //                               decoration: TextDecoration.none,
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             height: 10,
  //                           ),
  //                           Text(
  //                             "E13555",
  //                             style: TextStyle(
  //                               fontSize: 20,
  //                               color: Colors.blue,
  //                               decoration: TextDecoration.none,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       width: 40,
  //                     ),
  //                     Padding(
  //                       padding: EdgeInsets.all(8.0),
  //                       child: Column(
  //                         children: [
  //                           Text(
  //                             "Name",
  //                             style: TextStyle(
  //                               fontSize: 20,
  //                               color: Colors.black,
  //                               decoration: TextDecoration.none,
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             height: 10,
  //                           ),
  //                           Text(
  //                             "John Doe",
  //                             // Placeholder name, replace with actual data
  //                             style: TextStyle(
  //                               fontSize: 20,
  //                               color: Colors.blue,
  //                               decoration: TextDecoration.none,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //
  //                 Column(
  //                   children: [
  //                     Container(
  //                       color: Colors.grey[200],
  //                       child: const Padding(
  //                         padding: EdgeInsets.all(8.0),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Expanded(
  //                               flex: 1,
  //                               child: Center(
  //                                 child: Text(
  //                                   "Registration\nDate",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                       fontSize: 12,
  //                                       color: Colors.black,
  //                                       decoration: TextDecoration.none),
  //                                 ),
  //                               ),
  //                             ),
  //                             Expanded(
  //                               flex: 1,
  //                               child: Center(
  //                                 child: Text(
  //                                   "Expense\nType",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                       fontSize: 12,
  //                                       color: Colors.black,
  //                                       decoration: TextDecoration.none),
  //                                 ),
  //                               ),
  //                             ),
  //                             Expanded(
  //                               flex: 1,
  //                               child: Center(
  //                                 child: Text(
  //                                   "Center\nLocation",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                       fontSize: 12,
  //                                       color: Colors.black,
  //                                       decoration: TextDecoration.none),
  //                                 ),
  //                               ),
  //                             ),
  //                             Expanded(
  //                               flex: 1,
  //                               child: Center(
  //                                 child: Text(
  //                                   "Expense\nAmount",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                       fontSize: 12,
  //                                       color: Colors.black,
  //                                       decoration: TextDecoration.none),
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     ListView.builder(
  //                       shrinkWrap: true,
  //                       itemCount: expenseItemList.length,
  //                       itemBuilder: (BuildContext context, int index) {
  //                         return Container(
  //                           //color: Colors.red,
  //                           padding: const EdgeInsets.fromLTRB(2, 8, 2, 8),
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               Expanded(
  //                                 flex: 1,
  //                                 child: Center(
  //                                   child: Text(
  //                                     expenseItemList[index]
  //                                         .registeredDate
  //                                         .toString(),
  //                                     textAlign: TextAlign.center,
  //                                     style: const TextStyle(
  //                                         fontSize: 14,
  //                                         color: Colors.blue,
  //                                         decoration: TextDecoration.none),
  //                                   ),
  //                                 ),
  //                               ),
  //                               Expanded(
  //                                 flex: 1,
  //                                 child: Center(
  //                                   child: Text(
  //                                     expenseItemList[index]
  //                                         .individualExpType
  //                                         .toString(),
  //                                     textAlign: TextAlign.center,
  //                                     style: const TextStyle(
  //                                         fontSize: 14,
  //                                         color: Colors.blue,
  //                                         decoration: TextDecoration.none),
  //                                   ),
  //                                 ),
  //                               ),
  //                               Expanded(
  //                                 flex: 1,
  //                                 child: Center(
  //                                   child: Text(
  //                                     expenseItemList[index]
  //                                         .centerLocation
  //                                         .toString(),
  //                                     textAlign: TextAlign.center,
  //                                     style: const TextStyle(
  //                                         fontSize: 14,
  //                                         color: Colors.blue,
  //                                         decoration: TextDecoration.none),
  //                                   ),
  //                                 ),
  //                               ),
  //                               Expanded(
  //                                 flex: 1,
  //                                 child: Center(
  //                                   child: Text(
  //                                     expenseItemList[index]
  //                                         .expenseAmount
  //                                         .toString(),
  //                                     textAlign: TextAlign.center,
  //                                     style: const TextStyle(
  //                                         fontSize: 14,
  //                                         color: Colors.blue,
  //                                         decoration: TextDecoration.none),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //
  //                 // recentlycommented listview
  //                 //                                                  ListView.builder(
  //                 //                                                    shrinkWrap: true,
  //                 //                                                    itemCount: ViewDetails2LItems.length,
  //                 //                                                    itemBuilder: (BuildContext context, int index) {
  //                 //                                                      final expenseData = ViewDetails2LItems[index];
  //                 //
  //                 //                                                      return Row(
  //                 //                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 //                                                        children: [
  //                 //                                                          Text(
  //                 //                                                            ViewDetails2LItems[index].registeredDate.toString(),
  //                 //                                                            style: TextStyle(fontSize: 10,decoration: TextDecoration.none,color: Colors.blue),
  //                 //                                                          ),
  //                 //                                                          Text(
  //                 //                                                            ViewDetails2LItems[index].expenseAmount.toString(),
  //                 //                                                            style: TextStyle(fontSize: 10,decoration: TextDecoration.none,color: Colors.blue),
  //                 //                                                          ),
  //                 //                                                          Text(
  //                 //                                                            ViewDetails2LItems[index].centerLocation.toString(),
  //                 //                                                            style: TextStyle(fontSize: 10,decoration: TextDecoration.none,color: Colors.blue),
  //                 //                                                          ),
  //                 //                                                          Text(
  //                 //                                                            ViewDetails2LItems[index].expenseAmount.toString(),
  //                 //                                                            style: TextStyle(fontSize: 10,decoration: TextDecoration.none,color: Colors.blue),
  //                 //                                                          ),
  //                 //                                                        ],
  //                 //                                                      );
  //                 //                                                    },
  //                 //                                                  ),
  //
  //                 // ListView.builder
  //                 // ListView.builder(
  //                 //   shrinkWrap: true,
  //                 //   itemCount: ViewDetails2LItems.length,
  //                 //   itemBuilder: (BuildContext context, int row) {
  //                 //     return Row(
  //                 //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 //       children: List.generate(4, (int col) {
  //                 //         return Container(
  //                 //           width: 75,
  //                 //           height: 50,
  //                 //           margin: EdgeInsets.all(8),
  //                 //           //color: Colors.blue,
  //                 //           child: Center(
  //                 //             child: Text(
  //                 //               'Item $row-$col',
  //                 //               style: TextStyle(
  //                 //                 color: Colors.black,
  //                 //                 fontSize: 15,
  //                 //                 decoration: TextDecoration.none,
  //                 //               ),
  //                 //             ),
  //                 //           ),
  //                 //         );
  //                 //       }),
  //                 //     );
  //                 //   },
  //                 // ),
  //
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Container(
  //                       margin: const EdgeInsets.only(right: 8.0),
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(12),
  //                         gradient: const LinearGradient(
  //                           colors: [
  //                             Color(0xff3A9FBE),
  //                             Color(0xff17E1DA),
  //                           ],
  //                         ),
  //                       ),
  //                       child: ElevatedButton(
  //                         onPressed: () {
  //                           Navigator.of(context).pop();
  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.transparent,
  //                           disabledForegroundColor:
  //                               Colors.transparent.withOpacity(0.38),
  //                           disabledBackgroundColor:
  //                               Colors.transparent.withOpacity(0.12),
  //                           shadowColor: Colors.transparent,
  //                         ),
  //                         child: const Text(
  //                           "Export",
  //                           style: TextStyle(color: Colors.white, fontSize: 18),
  //                         ),
  //                       ),
  //                     ),
  //                     Container(
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(12),
  //                         gradient: const LinearGradient(
  //                           colors: [
  //                             Color(0xff3A9FBE),
  //                             Color(0xff17E1DA),
  //                           ],
  //                         ),
  //                       ),
  //                       child: ElevatedButton(
  //                         onPressed: () {
  //                           Navigator.of(context).pop();
  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.transparent,
  //                           disabledForegroundColor:
  //                               Colors.transparent.withOpacity(0.38),
  //                           disabledBackgroundColor:
  //                               Colors.transparent.withOpacity(0.12),
  //                           shadowColor: Colors.transparent,
  //                         ),
  //                         child: const Text(
  //                           "Close",
  //                           style: TextStyle(color: Colors.white, fontSize: 18),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 // ElevatedButton(
  //                 //   onPressed: () {
  //                 //     Navigator.of(context).pop();
  //                 //   },
  //                 //   child: Text(
  //                 //     "Close",
  //                 //     style: TextStyle(
  //                 //         color: Colors.white),
  //                 //   ),
  //                 // ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<bool> userPagePermission() async {
    user ??= (await userDao.findAllPersons()).firstOrNull;
    ERPServices client = ERPServices();
    bool pagePermission = await client.getPagePermission(
        userId: user!.userid,
        pageName: 'IndividualStaffExpensesLedger',
        locationId: user!.locationID);
    if (pagePermission) {
      futureLedgerCardData = fetchLedgerCardData(
          testType: yearValue,
          month: (monthList.indexOf(monthValue!) + 1).toString());
    }
    return pagePermission;
  }
}
