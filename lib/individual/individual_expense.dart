// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:erp/custom_widgets/error_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../controller/dbProvider.dart';
import '../custom_widgets/loading_overlay.dart';
import '../custom_widgets/required_permission_layout.dart';
import '../db/UserDao.dart';
import '../logger.dart';
import '../models/CenterModel.dart';
import '../models/IndividualStaffExpenseModel.dart';
import '../models/User.dart';
import '../models/individualExpenseModel.dart';
import '../services/erp_services.dart';
import '../utils/ColorConstants.dart';
import '../utils/ConnectivityUtils.dart';
import '../utils/StringConstants.dart';
import '../utils/util_methods.dart';
import 'AddExpensePageIndividual.dart';
import 'ReviewDetailIndividual.dart';

class ExpensesPage2 extends StatefulWidget {
  const ExpensesPage2({super.key});

  @override
  State<ExpensesPage2> createState() => _ExpensesPage2State();
}

class _ExpensesPage2State extends State<ExpensesPage2> {
  late final UserDao userDao;
  User? user;
  late final Future<bool> pagePermissionFuture;

  String? ownerID;
  String? expenseCode;
  String? paidBy;
  String? expenseType;

  //List<LoadDailyExpenseDetail> expenseItemList = List.empty();

  List<String> accountItemList = ['All'];

  //List<LoadDailyExpenseDetail> expenseCardDetailsList = List.empty();

  List<ExpenseDetail> allExpenseCardDetails = List.empty(growable: true);

  /* List<CenterExpenseModel>? centerExpenseModelLists =
      List.empty(growable: true);*/

  //LoadDailyExpenseDetail? user;

  List<String> approveTypeList = List.empty();

  List labDetails = [];

  final _expenseStatusList = [
    "New",
    "Manager Approved",
    "Manager Rejected",
    "HO Approved",
    "HO Rejected"
  ];

  String? testTypeValue = "New";

  List<CenterModel> locationList = List.empty(growable: true);

  List<String> expenseTypeList = List.empty(growable: true);

  List<String> accountTypeList = List.empty(growable: true);

  String? accountTypeValue;
  String? expenseTypeValue;
  String expenseStatusValue = "New";

  List<ExpenseDetailsModel>? individualExpenseModelList =
      List.empty(growable: true);

  // String fromDate = new DateTime.now();
  // String toDate = new DateTime.now();

  String fromDate = "";
  String toDate = "";

  final TextEditingController ddSearchController = TextEditingController();

  late Future<List<ExpenseDetail>> cardExpenseFuture;

  List<ExpenseDetail> cardExpenseSearchItems = [];
  TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  void dispose() {
    ddSearchController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    userDao = Provider.of<DBProvider>(context, listen: false).dao;
    fromDate = DateFormat("dd MMM yyyy").format(DateTime.now());
    toDate = DateFormat("dd MMM yyyy").format(DateTime.now());
    accountTypeValue = accountItemList.first;
    pagePermissionFuture = userPagePermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorConstants.purpul500Color,
        child: Image.asset(
          'assets/excel.png',
          height: 32,
          fit: BoxFit.fitHeight,
        ),
        onPressed: () async {
          if (labDetails.isEmpty) {
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
          for (var jsonObject in labDetails) {
            Map<String, dynamic> dataTwo =
                Map<String, dynamic>.from(jsonObject);
            dataTwo.remove("recordId");
            dataTwo.remove("expenseCode");
            dataTwo.remove("ownerId"); //3/1/2024 12:00:00 AM
            dataTwo.update(
                "expenseBookingDate",
                (value) => DateFormat("dd-MM-yyyy").format(
                    DateFormat("MM/dd/yyyy").parse(dataTwo["expenseBookingDate"]
                        .toString()
                        .split(" ")[0])));
            labDetailsS.add(dataTwo);
          }

          bool result =
              await exportExcel(labDetailsS, 'Expenses Summary.xlsx', null);
          if (result) {
            Future.delayed(
                const Duration(seconds: 0),
                () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Excel File Downloaded Successfully'),
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
              return FutureBuilder<List<ExpenseDetail>>(
                  future: cardExpenseFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const LoadingOverlay();
                    }
                    if (snapshot.hasError) {
                      // snapshot.error.
                      return const Text('Error');
                    }
                    if (snapshot.hasData) {
                      List<ExpenseDetail> cardExpenseItems =
                          snapshot.data ?? [];
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 48,
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 0, 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0XFFF9F9F9),
                                      border: Border.all(
                                          width: 1,
                                          color: const Color(0XFFBEDCF0)),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    child: InkWell(
                                        onTap: () async {
                                          var datePicked = await DatePicker
                                              .showSimpleDatePicker(
                                            context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2010),
                                            lastDate: DateFormat(
                                                    'dd MMM yyyy', 'en_US')
                                                .parse(toDate),
                                            dateFormat: "dd-MMMM-yyyy",
                                            locale: DateTimePickerLocale.en_us,
                                            looping: false,
                                          );
                                          if (datePicked == null) {
                                            return;
                                          }

                                          setState(() {
                                            fromDate = DateFormat(
                                                    'dd MMM yyyy', 'en_US')
                                                .format(datePicked);

                                            cardExpenseFuture = fetchCardData();
                                          });
                                          //
                                          // cardExpenseFuture = fetchCardData();
                                          //getRevenue();
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              fromDate,
                                              style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontFamily: 'Segoe',
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                            const Spacer(),
                                            Image.asset(
                                                "assets/ic_calender.png",
                                                color: const Color(0XFF5D5D5D),
                                                width: 15,
                                                height: 15),
                                            const SizedBox(width: 10)
                                          ],
                                        )),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    height: 48,
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 10, 0, 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0XFFF9F9F9),
                                      border: Border.all(
                                          width: 1,
                                          color: const Color(0XFFBEDCF0)),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    child: InkWell(
                                        onTap: () async {
                                          var datePicked = await DatePicker
                                              .showSimpleDatePicker(
                                            context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateFormat(
                                                    'dd MMM yyyy', 'en_US')
                                                .parse(fromDate),
                                            lastDate: DateTime.now(),
                                            dateFormat: "dd-MMMM-yyyy",
                                            locale: DateTimePickerLocale.en_us,
                                            looping: false,
                                          );
                                          if (datePicked == null) {
                                            return;
                                          }

                                          setState(() {
                                            toDate = DateFormat(
                                                    'dd MMM yyyy', 'en_US')
                                                .format(datePicked);

                                            cardExpenseFuture = fetchCardData();
                                          });
                                          //
                                          // cardExpenseFuture = fetchCardData();
                                          // getRevenue();
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              toDate,
                                              style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontFamily: 'Segoe',
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                            const Spacer(),
                                            Image.asset(
                                                "assets/ic_calender.png",
                                                color: const Color(0XFF5D5D5D),
                                                width: 15,
                                                height: 15),
                                            const SizedBox(width: 10)
                                          ],
                                        )),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 8, 5, 5),
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    decoration: BoxDecoration(
                                      color: const Color(0XFFF9F9F9),
                                      border: Border.all(
                                          width: 1,
                                          color: const Color(0XFFBEDCF0)),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    child: DropdownButton<String>(
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
                                          color: Colors.black54,
                                          fontSize: 12,
                                          overflow: TextOverflow.ellipsis,
                                          fontFamily: 'Segoe',
                                          fontWeight: FontWeight.normal),
                                      onChanged: (value) => {
                                        setState(() {
                                          expenseStatusValue = value!;

                                          cardExpenseFuture = fetchCardData();
                                        }),
                                      },
                                      onTap: () {},
                                      hint: const Text("select Status"),
                                      value: expenseStatusValue,
                                      items: _expenseStatusList
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 8, 0, 5),
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    decoration: BoxDecoration(
                                      color: const Color(0XFFF9F9F9),
                                      border: Border.all(
                                          width: 1,
                                          color: const Color(0XFFBEDCF0)),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    child: DropdownButton<String>(
                                      underline: const SizedBox.shrink(),
                                      isExpanded: true,
                                      icon: Image.asset("assets/dropdown.png",
                                          color: const Color(0XFF5D5D5D),
                                          width: 14,
                                          height: 14),
                                      elevation: 16,
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          overflow: TextOverflow.ellipsis,
                                          fontFamily: 'Segoe',
                                          fontWeight: FontWeight.normal),
                                      onChanged: (value) => {
                                        setState(() {
                                          accountTypeValue = value;

                                          cardExpenseFuture = fetchCardData();
                                        }),
                                      },
                                      onTap: () {},
                                      hint: const Text("Account Type"),
                                      value: accountTypeValue,
                                      items: accountItemList
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
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
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
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
                                      onPressed: () {
                                        setState(() {
                                          cardExpenseFuture = fetchCardData();
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        disabledForegroundColor: Colors
                                            .transparent
                                            .withOpacity(0.38),
                                        disabledBackgroundColor: Colors
                                            .transparent
                                            .withOpacity(0.12),
                                        shadowColor: Colors.transparent,
                                      ),
                                      child: const Text(
                                        "Search",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
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
                                      onPressed: () async {
                                        bool? result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const AddExpenseCenterPage()),
                                        );
                                        if (result ?? false) {
                                          setState(() {
                                            cardExpenseFuture = fetchCardData();
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        disabledForegroundColor: Colors
                                            .transparent
                                            .withOpacity(0.38),
                                        disabledBackgroundColor: Colors
                                            .transparent
                                            .withOpacity(0.12),
                                        shadowColor: Colors.transparent,
                                      ),
                                      child: const Text(
                                        "Add Expense",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Flexible(
                              flex: 8,
                              child: cardExpenseItems.isEmpty
                                  ? const Center(
                                      child: Text("Record Not Found",
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 18,
                                              fontFamily: 'Segoe',
                                              fontWeight: FontWeight.normal)),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: cardExpenseItems.length,
                                      //itemCount: ViewDetails2LItems.length,
                                      itemBuilder: (context, index) {
                                        // String? dateprint =
                                        //     cardExpenseItems[index]
                                        //         .expenseDate
                                        //         .toString();
                                        ExpenseDetail ex =
                                            cardExpenseItems[index];
                                        return Visibility(
                                          visible: (ex.expenseCode
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(searchText) ||
                                              ex.expenseDate
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(searchText) ||
                                              ex.firstName
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(searchText) ||
                                              ex.accountTypeCode
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(searchText) ||
                                              ex.expenseDescription
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(searchText) ||
                                              ex.expenseAmount
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(searchText) ||
                                              ex.expenseBookingDate
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(searchText)),
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 8),
                                            decoration: BoxDecoration(
                                              color: const Color(0XFFF9F9F9),
                                              border: Border.all(
                                                  width: 1,
                                                  color:
                                                      const Color(0XFFBEDCF0)),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                            ),
                                            child: IntrinsicHeight(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  // First part of the card: Left Side
                                                  Expanded(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          10, 15, 0, 10),
                                                      child: Column(
                                                        // Use a Column to stack text vertically
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            'Paid By',
                                                            // overflow: TextOverflow.ellipsis,
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                            softWrap: true,
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            cardExpenseItems[
                                                                    index]
                                                                .firstName,
                                                            // overflow: TextOverflow.ellipsis,
                                                            textAlign:
                                                                TextAlign.left,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              color: Color(
                                                                  0xff156397),
                                                            ),
                                                            softWrap: true,
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          const Text(
                                                            'Account Type',
                                                            // overflow: TextOverflow.ellipsis,
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                            softWrap: true,
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            cardExpenseItems[
                                                                    index]
                                                                .accountTypeCode,
                                                            // overflow: TextOverflow.ellipsis,
                                                            textAlign:
                                                                TextAlign.left,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              color: Color(
                                                                  0xff156397),
                                                            ),
                                                            softWrap: true,
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          const Text(
                                                            'Reason',
                                                            // overflow: TextOverflow.ellipsis,
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                            softWrap: true,
                                                          ),
                                                          Text(
                                                            cardExpenseItems[
                                                                    index]
                                                                .expenseDescription,
                                                            // overflow: TextOverflow.ellipsis,
                                                            textAlign:
                                                                TextAlign.left,
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
                                                  ),
                                                  Expanded(
                                                    // flex: 1,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xEAEAEAFF),
                                                        //background color of dropdown button//border of dropdown button
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xEAEAEAFF)),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10), //border raiuds of dropdown button
                                                      ),
                                                      margin: const EdgeInsets
                                                          .fromLTRB(
                                                          4, 10, 8, 10),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        // Use a Column to stack text vertically
                                                        children: [
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            cardExpenseItems[
                                                                    index]
                                                                .expenseStatus,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                              color: Color(
                                                                  0xff156397),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          const Text(
                                                            'Expense Date',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                            // dateprint!.substring(0,dateprint.indexOf(' ')),
                                                            // dateprint != null ? dateprint.substring(0, dateprint.indexOf(' ')) : '',
                                                            cardExpenseItems[
                                                                    index]
                                                                .expenseDate
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                              color: Color(
                                                                  0xff156397),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 40,
                                                                    right: 40),
                                                            child: Divider(
                                                              color:
                                                                  Colors.black,
                                                              // You can set the color of the line
                                                              thickness:
                                                                  1, // You can adjust the thickness of the line
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          const Text(
                                                            'Amount',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          Text(
                                                            '\u{20B9}${cardExpenseItems[index].expenseAmount.toString()}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 25,
                                                              color: Color(
                                                                  0xff156397),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 40,
                                                                    right: 40),
                                                            child: Divider(
                                                              color:
                                                                  Colors.black,
                                                              // You can set the color of the line
                                                              thickness:
                                                                  1, // You can adjust the thickness of the line
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ReviewDetailsPage(
                                                                              cardExpenseItems[index].expenseCode,
                                                                            )),
                                                              );
                                                            },
                                                            child: const Text(
                                                              'Review Detail',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                color: Color(
                                                                    0xff156397),
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
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
                            ),
                          ],
                        ),
                      );
                    }
                    return const Text("No Data Found");
                  });
            }
            return const LoadingOverlay();
          }),
    );
  }

  Future<List<ExpenseDetail>> fetchCardData() async {
    List<ExpenseDetail> cardExpenseItems = [];
    try {
      if (await ConnectivityUtils.hasConnection()) {
        Response response = await post(
          Uri.parse(
              '${StringConstants.BASE_URL}TravelExpenseRequest/Get_Indiv_StaffExpenses'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'ExpenseType': " ",
            'AccountType':
                (accountTypeValue ?? '') == 'All' ? '' : accountTypeValue,
            'authKey': StringConstants.AUTHKEY,
            'ExpenseStatus': expenseStatusValue,
            'fromDate': DateFormat("yyyy-MM-dd")
                .format(DateFormat("dd MMM yyyy").parse(fromDate)),
            'ownerId': user!.locationID,
            'staffCode': user!.userid,
            'toDate': DateFormat("yyyy-MM-dd")
                .format(DateFormat("dd MMM yyyy").parse(toDate)),
          }),
        ).timeout(const Duration(seconds: 24));

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body.toString());
          if (data['lisResult'].toString() == 'True') {
            //Navigator.of(context).pop();

            labDetails =
                (data["loadIndividualExpenses_Details"] as List<dynamic>?)!;
            cardExpenseItems = labDetails != null
                // map each review to a Review object
                ? labDetails
                    .map((reviewData) => ExpenseDetail.fromJson(reviewData))
                    // map() returns an Iterable so we convert it to a List
                    .toList()
                // use an empty list as fallback value
                : <ExpenseDetail>[];
            allExpenseCardDetails = cardExpenseItems;
          } else {
            final snackBar = SnackBar(
              content: const Text("Record Not Found"),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {
                  // Some code to undo the change.
                },
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            try {
              allExpenseCardDetails.clear();
              labDetails.clear();
            } catch (e) {}
            setState(() {});
          }
        }
      } else {
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
        try {
          allExpenseCardDetails.clear();
          labDetails.clear();
        } catch (e) {}
        setState(() {});
      }
      return cardExpenseItems;
    } on TimeoutException catch (e) {
      logger.e('Timeout', error: e);

      final snackBar = SnackBar(
        content: const Text('Please try later'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      if (!mounted) return [];
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      try {
        allExpenseCardDetails.clear();
        labDetails.clear();
      } catch (e) {}
      setState(() {});
      return [];
    } catch (e) {
      final snackBar = SnackBar(
        content: const Text('Please Contact KDL Admin'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );

      if (!mounted) return [];
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      try {
        allExpenseCardDetails.clear();
        labDetails.clear();
      } catch (e) {}
      setState(() {});
      return [];
    }
  }

  Future<void> fetchAccountType() async {
    try {
      final response = await http.post(
          Uri.parse('${StringConstants.VBASE_URL}Krasna/GetAccountType'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "authKey": StringConstants.AUTHKEY,
          }));
      if (response.statusCode == 200) {
        final responseOfAccountItems = json.decode(response.body);
        if (responseOfAccountItems != null) {
          final List<dynamic> accountListData =
              responseOfAccountItems['AccountType'];
          for (var item in accountListData) {
            accountItemList.add(item['Item_Type']);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account Type Not Found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something Wrong At Server End. Please try Later'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Contact KDL Admin'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> userPagePermission() async {
    user ??= (await userDao.findAllPersons()).firstOrNull;
    ERPServices client = ERPServices();
    bool pagePermission = await client.getPagePermission(
        userId: user!.userid,
        pageName: 'IndivStaffExpenses',
        locationId: user!.locationID);
    if (pagePermission) {
      await fetchAccountType();
      cardExpenseFuture = fetchCardData();
    }
    return pagePermission;
  }
}
