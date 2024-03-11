import 'dart:async';
import 'dart:convert';

import 'package:erp/custom_widgets/custom_button.dart';
import 'package:erp/individual_expense_approval/EditExpensePage.dart';
import 'package:erp/logger.dart';
import 'package:erp/utils/ColorConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controller/dbProvider.dart';
import '../custom_widgets/error_page.dart';
import '../custom_widgets/loading_overlay.dart';
import '../custom_widgets/required_permission_layout.dart';
import '../db/UserDao.dart';
import '../models/CreatedByModel.dart';
import '../models/IndividualStaffExpenseModel.dart';
import '../models/User.dart';
import '../models/travell_expense_response.dart';
import '../services/erp_services.dart';
import '../utils/ConnectivityUtils.dart';
import '../utils/StringConstants.dart';
import '../utils/util_methods.dart';

class IndividualExpenseApproval extends StatefulWidget {
  const IndividualExpenseApproval({super.key});

  @override
  State<IndividualExpenseApproval> createState() =>
      _IndividualExpenseApprovalState();
}

class _IndividualExpenseApprovalState extends State<IndividualExpenseApproval> {
  List<String> accountItemList = ['All'];
  CreatedByList? employeeValue;
  List<CreatedByList> employeeList = [
    CreatedByList(employeeName: 'ALL', employeeId: '')
  ];
  List<String> testTypeItems = [
    'New',
    'Manager Approved',
    'Manager Rejected',
    'HO Approved',
    'HO Rejected'
  ];
  String accountTypeValue = 'All';
  String expenseStatusValue = "New";

  List<ExpenseDetailsModel>? individualExpenseModelList =
      List.empty(growable: true);

  String fromDate = "";
  String toDate = "";

  late final UserDao userDao;
  User? user;
  late final Future<bool> pagePermissionFuture;

  List<IndividualExpensesApprovalDetail> cardExpenseSearchItems = [];

  late Future<List<IndividualExpensesApprovalDetail>> cardExpenseFuture;

  List labDetails = [];
  OverlayEntry overlayEntry =
      OverlayEntry(builder: (_) => const LoadingOverlay());
  @override
  void initState() {
    fromDate = DateFormat("dd MMM yyyy").format(DateTime.now());
    toDate = DateFormat("dd MMM yyyy").format(DateTime.now());
    userDao = Provider.of<DBProvider>(context, listen: false).dao;
    employeeValue = employeeList.first;
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
            dataTwo.remove("ownerId");
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
              return FutureBuilder<List<IndividualExpensesApprovalDetail>>(
                  future: cardExpenseFuture,
                  builder: (context, snapshot) {
                    List<IndividualExpensesApprovalDetail> cardExpenseItems =
                        [];

                    if (snapshot.hasError) {
                      // snapshot.error.
                      return const Text('Error');
                    }
                    if (snapshot.hasData) {
                      cardExpenseItems = snapshot.data ?? [];
                    }

                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
                          child: Column(
                            children: [
                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10),
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]'))
                                ],
                                onChanged: (value) {
                                  cardExpenseSearchItems = cardExpenseItems
                                      .where(
                                        (element) => (element.firstName
                                                .toString()
                                                .toLowerCase()
                                                .contains(value) ||
                                            element.expenseAmount!
                                                .contains(value) ||
                                            element.expenseCode
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                                    value.toLowerCase()) ||
                                            element.expenseDate
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                                    value.toLowerCase()) ||
                                            element.firstName
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                                    value.toLowerCase()) ||
                                            element.accountTypeCode
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                                    value.toLowerCase()) ||
                                            element.expenseDescription
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                                    value.toLowerCase()) ||
                                            element.expenseType
                                                .toString()
                                                .toLowerCase()
                                                .contains(value.toLowerCase()) ||
                                            element.expenseStatus.toString().toLowerCase().contains(value.toLowerCase()) ||
                                            element.expenseAmount.toString().toLowerCase().contains(value.toLowerCase()) ||
                                            element.recordId.toString().toLowerCase().contains(value.toLowerCase()) ||
                                            element.managerApproved_RejectedBy.toString().toLowerCase().contains(value.toLowerCase()) ||
                                            element.managerApproved_RejectedOn.toString().toLowerCase().contains(value.toLowerCase()) ||
                                            element.hoApproved_RejectedBy.toString().toLowerCase().contains(value.toLowerCase()) ||
                                            element.hoApproved_RejectedOn.toString().toLowerCase().contains(value.toLowerCase()) ||
                                            element.accountDescription.toString().toLowerCase().contains(value.toLowerCase())),
                                      )
                                      .toList();
                                  setState(() {
                                    cardExpenseItems;
                                  });
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.grey,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0XFFF9F9F9),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Color(0XFFBEDCF0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Color(0XFFBEDCF0)),
                                  ),
                                  hintText: 'Search Expense',
                                  contentPadding:
                                      const EdgeInsetsDirectional.only(
                                          start: 10.0),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 12, 0, 12),
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
                                              locale:
                                                  DateTimePickerLocale.en_us,
                                              looping: false,
                                            );
                                            setState(() {
                                              fromDate = DateFormat(
                                                      'dd MMM yyyy', 'en_US')
                                                  .format(datePicked!);

                                              cardExpenseFuture =
                                                  fetchCardData();
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Text(
                                                fromDate,
                                                style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 16,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontFamily: 'Segoe',
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              const Spacer(),
                                              Image.asset(
                                                  "assets/ic_calender.png",
                                                  color:
                                                      const Color(0XFF5D5D5D),
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
                                              locale:
                                                  DateTimePickerLocale.en_us,
                                              looping: false,
                                            );
                                            setState(() {
                                              toDate = DateFormat(
                                                      'dd MMM yyyy', 'en_US')
                                                  .format(datePicked!);
                                            });

                                            cardExpenseFuture = fetchCardData();
                                          },
                                          child: Row(
                                            children: [
                                              Text(
                                                toDate,
                                                style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 16,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontFamily: 'Segoe',
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              const Spacer(),
                                              Image.asset(
                                                  "assets/ic_calender.png",
                                                  color:
                                                      const Color(0XFF5D5D5D),
                                                  width: 15,
                                                  height: 15),
                                              const SizedBox(width: 10)
                                            ],
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 2),
                                  Expanded(
                                      child: Text(
                                    'Status',
                                    style: TextStyle(fontSize: 16),
                                  )),
                                  SizedBox(width: 10),
                                  // Expanded(
                                  //     child: Text(
                                  //   'Account Type',
                                  //   style: TextStyle(fontSize: 16),
                                  // )),
                                  Expanded(
                                      child: Text(
                                    'Employee Name',
                                    style: TextStyle(fontSize: 16),
                                  )),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0XFFF9F9F9),
                                        border: Border.all(
                                            width: 1,
                                            color: const Color(0XFFBEDCF0)),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 0),
                                        child: DropdownButton(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          underline: const SizedBox.shrink(),
                                          isExpanded: true,
                                          icon: Image.asset(
                                              "assets/dropdown.png",
                                              color: const Color(0XFF5D5D5D),
                                              width: 14,
                                              height: 14),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: 'Segoe',
                                              fontWeight: FontWeight.normal),
                                          onChanged: (value) => {
                                            setState(() {
                                              expenseStatusValue = value ?? "";

                                              cardExpenseFuture =
                                                  fetchCardData();
                                            })
                                          },
                                          value: expenseStatusValue,
                                          hint: const Text("New"),
                                          items: testTypeItems
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
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0XFFF9F9F9),
                                        border: Border.all(
                                            width: 1,
                                            color: const Color(0XFFBEDCF0)),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 0),
                                        child: DropdownButton(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          underline: const SizedBox.shrink(),
                                          isExpanded: true,
                                          icon: Image.asset(
                                              "assets/dropdown.png",
                                              color: const Color(0XFF5D5D5D),
                                              width: 14,
                                              height: 14),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: 'Segoe',
                                              fontWeight: FontWeight.normal),
                                          onChanged: (value) => {
                                            setState(() {
                                              employeeValue = value!;

                                              cardExpenseFuture =
                                                  fetchCardData();
                                            })
                                          },
                                          value: employeeValue,
                                          hint: const Text("Employee Name"),
                                          items: employeeList
                                              .map((value) => DropdownMenuItem(
                                                  value: value,
                                                  child: Text(
                                                    value.employeeName ?? '',
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
                              const SizedBox(height: 10),
                              Flexible(
                                  flex: 8,
                                  child: cardExpenseItems.isNotEmpty == true
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          itemCount:
                                              cardExpenseSearchItems.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              margin: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: const Color(0XFFF9F9F9),
                                                border: Border.all(
                                                    width: 1.3,
                                                    color: const Color(
                                                        0XFFBEDCF0)),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                              ),
                                              child: Column(
                                                children: [
                                                  IntrinsicHeight(
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    10,
                                                                    15,
                                                                    0,
                                                                    10),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                  'Paid By',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal),
                                                                  softWrap:
                                                                      true,
                                                                ),
                                                                const SizedBox(
                                                                  height: 4,
                                                                ),
                                                                Text(
                                                                  cardExpenseSearchItems[
                                                                              index]
                                                                          .firstName ??
                                                                      '',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Color(
                                                                        0xff156397),
                                                                  ),
                                                                  softWrap:
                                                                      true,
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                const Text(
                                                                  'Account Type',
                                                                  // overflow: TextOverflow.ellipsis,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal),
                                                                  softWrap:
                                                                      true,
                                                                ),
                                                                const SizedBox(
                                                                  height: 4,
                                                                ),
                                                                Text(
                                                                  cardExpenseSearchItems[
                                                                              index]
                                                                          .accountTypeCode ??
                                                                      '',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Color(
                                                                        0xff156397),
                                                                  ),
                                                                  softWrap:
                                                                      true,
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                const Text(
                                                                  'Reason',
                                                                  // overflow: TextOverflow.ellipsis,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal),
                                                                  softWrap:
                                                                      true,
                                                                ),
                                                                Text(
                                                                  cardExpenseSearchItems[
                                                                              index]
                                                                          .expenseDescription ??
                                                                      '',
                                                                  // overflow: TextOverflow.ellipsis,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Color(
                                                                        0xff156397),
                                                                  ),
                                                                  softWrap:
                                                                      true,
                                                                ),
                                                                const SizedBox(
                                                                  height: 6,
                                                                ),
                                                                const Row(
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              'Manager Name',
                                                                              textAlign: TextAlign.left,
                                                                              style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.normal),
                                                                              softWrap: true,
                                                                            )
                                                                          ],
                                                                        )),
                                                                    Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Text(
                                                                              'HO',
                                                                              textAlign: TextAlign.left,
                                                                              style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.normal),
                                                                              softWrap: true,
                                                                            )
                                                                          ],
                                                                        )),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              "${cardExpenseSearchItems[index].managerApproved_RejectedBy ?? ''}\n${cardExpenseSearchItems[index].managerApproved_RejectedOn}",
                                                                              // overflow: TextOverflow.ellipsis,
                                                                              textAlign: TextAlign.left,
                                                                              style: const TextStyle(
                                                                                fontSize: 13,
                                                                                color: Color(0xff156397),
                                                                              ),
                                                                              softWrap: true,
                                                                            ),
                                                                          ],
                                                                        )),
                                                                    Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Text(
                                                                              "${cardExpenseSearchItems[index].hoApproved_RejectedBy ?? ''}\n"
                                                                              "${cardExpenseSearchItems[index].hoApproved_RejectedOn ?? ""}",
                                                                              textAlign: TextAlign.center,
                                                                              style: const TextStyle(
                                                                                fontSize: 13,
                                                                                color: Color(0xff156397),
                                                                              ),
                                                                              softWrap: true,
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xEAEAEAFF),
                                                              border: Border.all(
                                                                  color: const Color(
                                                                      0xEAEAEAFF)),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10), //border raiuds of dropdown button
                                                            ),
                                                            margin:
                                                                const EdgeInsets
                                                                    .fromLTRB(4,
                                                                    20, 4, 20),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              // Use a Column to stack text vertically
                                                              children: [
                                                                const SizedBox(
                                                                    height: 8),
                                                                Image.asset(
                                                                    cardExpenseSearchItems[index].expenseStatus ==
                                                                            null
                                                                        ? "assets/waiting_ic.png"
                                                                        : cardExpenseSearchItems[index].expenseStatus!.contains("New")
                                                                            ? "assets/waiting_ic.png"
                                                                            : cardExpenseSearchItems[index].expenseStatus!.contains("Approved")
                                                                                ? "assets/approval_ic.png"
                                                                                : "assets/rejected_ic.png",
                                                                    width: 20,
                                                                    height: 20),
                                                                const SizedBox(
                                                                  height: 6,
                                                                ),
                                                                Text(
                                                                  cardExpenseSearchItems[
                                                                              index]
                                                                          .expenseStatus ??
                                                                      '',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Color(
                                                                        0xff156397),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                const Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              40,
                                                                          right:
                                                                              40),
                                                                  child:
                                                                      Divider(
                                                                    color: Colors
                                                                        .black,
                                                                    // You can set the color of the line
                                                                    thickness:
                                                                        1, // You can adjust the thickness of the line
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                const Text(
                                                                  'Expense Date',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  cardExpenseSearchItems[
                                                                          index]
                                                                      .expenseDate
                                                                      .toString(),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Color(
                                                                        0xff156397),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                const Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              40,
                                                                          right:
                                                                              40),
                                                                  child:
                                                                      Divider(
                                                                    color: Colors
                                                                        .black,
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
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '\u20B9 ${cardExpenseSearchItems[index].expenseAmount.toString()}',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: Color(
                                                                        0xff156397),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                const Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              40,
                                                                          right:
                                                                              40),
                                                                  child:
                                                                      Divider(
                                                                    color: Colors
                                                                        .black,
                                                                    // You can set the color of the line
                                                                    thickness:
                                                                        1, // You can adjust the thickness of the line
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    bool?
                                                                        result =
                                                                        await Navigator
                                                                            .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              EditExpensePage(
                                                                                cardExpenseItems[index].expenseCode,
                                                                              )),
                                                                    );
                                                                    if (result ??
                                                                        false) {
                                                                      setState(
                                                                          () {
                                                                        cardExpenseFuture =
                                                                            fetchCardData();
                                                                      });
                                                                    }
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Review Detail',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Color(
                                                                          0xff156397),
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
                                                  IntrinsicHeight(
                                                    child: Visibility(
                                                      visible:
                                                          cardExpenseSearchItems[
                                                                      index]
                                                                  .expenseStatus ==
                                                              "New",
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      0,
                                                                      0,
                                                                      2,
                                                                      0),
                                                              child:
                                                                  GradientButton(
                                                                      width:
                                                                          170,
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          approveRejectExpense(
                                                                              "Approve",
                                                                              cardExpenseSearchItems[index].expenseCode!,
                                                                              cardExpenseSearchItems[index].ownerId!);
                                                                        });
                                                                      },
                                                                      label:
                                                                          'Approve'),
                                                            ),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      2,
                                                                      0,
                                                                      0,
                                                                      0),
                                                              child:
                                                                  GradientButton(
                                                                      width:
                                                                          170,
                                                                      onPressed:
                                                                          () {
                                                                        approveRejectExpense(
                                                                            "Reject",
                                                                            cardExpenseSearchItems[index].expenseCode!,
                                                                            cardExpenseSearchItems[index].ownerId!);
                                                                      },
                                                                      label:
                                                                          'Reject'),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          alignment: Alignment.center,
                                          child:
                                              const Text("Record Not Found"))),
                            ],
                          ),
                        ),
                        Visibility(
                          child: const LoadingOverlay(),
                          visible:
                              snapshot.connectionState != ConnectionState.done,
                        )
                      ],
                    );
                  });
            }
            return const LoadingOverlay();
          }),
    );
  }

  Future<List<IndividualExpensesApprovalDetail>> fetchCardData() async {
    List<IndividualExpensesApprovalDetail> cardExpenseItems = [];
    try {
      if (await ConnectivityUtils.hasConnection()) {
        http.Response response = await http
            .post(
              Uri.parse(
                  '${StringConstants.BASE_URL}TravelExpenseRequest/Get_Indiv_StaffExpenses_Approval'),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                'ExpenseType': "",
                'EmployeeCode': employeeValue!.employeeId ?? '',
                'authKey': StringConstants.AUTHKEY,
                'ExpenseStatus': expenseStatusValue,
                'fromDate': DateFormat("yyyy-MM-dd")
                    .format(DateFormat("dd MMM yyyy").parse(fromDate)),
                'ownwerId': user!.locationID,
                'staffCode': user!.userid,
                'toDate': DateFormat("yyyy-MM-dd")
                    .format(DateFormat("dd MMM yyyy").parse(toDate)),
              }),
            )
            .timeout(const Duration(seconds: 24));

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body.toString());
          if (data['lisResult'].toString() == 'True') {
            setState(() {
              labDetails = data["loadIndividualExpenses_Approval_Details"]
                  as List<dynamic>;
              cardExpenseItems = labDetails != null
                  // map each review to a Review object
                  ? labDetails
                      .map((reviewData) =>
                          IndividualExpensesApprovalDetail.fromJson(reviewData))
                      // map() returns an Iterable so we convert it to a List
                      .toList()
                  // use an empty list as fallback value
                  : [];
              cardExpenseSearchItems = cardExpenseItems;
            });
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

            if (!mounted) return [];
            ScaffoldMessenger.of(context).showSnackBar(snackBar);

            setState(() {
              cardExpenseSearchItems.clear();
              labDetails.clear();
            });
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
        if (!mounted) return [];
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        setState(() {
          cardExpenseSearchItems.clear();
          labDetails.clear();
        });
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
      return cardExpenseItems;
    } catch (e) {
      logger.i(e.toString());

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
      setState(() {
        cardExpenseSearchItems.clear();
        labDetails.clear();
      });
    }
    return [];
  }

  Future<bool> userPagePermission() async {
    user ??= (await userDao.findAllPersons()).firstOrNull;
    ERPServices client = ERPServices();
    bool pagePermission = await client.getPagePermission(
        userId: user!.userid,
        pageName: 'IndivalExpensesManagerApproval',
        locationId: user!.locationID);
    if (pagePermission) {
      // await fetchAccountType();
      await fetchEmployeeName();
      cardExpenseFuture = fetchCardData();
    }
    return pagePermission;
  }

  Future<void> fetchAccountType() async {
    try {
      final response = await http.post(
          Uri.parse(
              'http://android.krsnaadiagnostics.com/Krasna/GetAccountType'),
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
          if (!mounted) return;

          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account Type Not Found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something Wrong At Server End. Please try Later'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Contact KDL Admin'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchEmployeeName() async {
    try {
      final response = await http.post(
          Uri.parse(
              '${StringConstants.BASE_URL}TravelExpenseRequest/LIS_GetEmployeeDetails'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "authKey": StringConstants.AUTHKEY,
            "EmpId": user!.userid,
          }));
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody != null) {
          if (responseBody['lisResult'] == "True") {
            final List<dynamic> accountListData =
                responseBody['handoverEmployees'];

            for (var item in accountListData) {
              employeeList.add(CreatedByList.fromJson(item));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Employee List Not Found.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // if (!mounted) return;

          //Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Employee List Not Found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // if (!mounted) return;
        // Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something Wrong At Server End. Please try Later'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      //if (!mounted) return;
      //Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Contact KDL Admin'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> approveRejectExpense(
    String status,
    String expenseCode,
    String ownerId,
  ) async {
    Navigator.of(context).overlay?.insert(overlayEntry);
    try {
      final response = await http.post(
          Uri.parse(status == "Approve"
              ? '${StringConstants.BASE_URL}TravelExpenseRequest/Indiv_StaffExpensesManagerApproval_ByCode'
              : '${StringConstants.BASE_URL}TravelExpenseRequest/Indiv_StaffExpensesManagerRejected_ByCode'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "authKey": StringConstants.AUTHKEY,
            "ExpenseCode": expenseCode,
            "Approver_UserCode": user!.userid,
            "ownerId": ownerId,
          }));
      if (response.statusCode == 200) {
        overlayEntry.remove();
        final responseOfAccountItems = json.decode(response.body);
        if (responseOfAccountItems['lisResult'] == "True") {
          Fluttertoast.showToast(
              msg: responseOfAccountItems['lisMessage'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
          cardExpenseFuture = fetchCardData();
        } else {
          //if (!mounted) return;
          //Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseOfAccountItems['lisMessage']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        //if (!mounted) return;
        //Navigator.of(context).pop();
        overlayEntry.remove();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something Wrong At Server End. Please try Later'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // if (!mounted) return;
      //Navigator.of(context).pop();
      overlayEntry.remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Contact KDL Admin'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
