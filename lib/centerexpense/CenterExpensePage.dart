import 'dart:async';
import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:erp/models/CenterExpenseModel.dart';
import 'package:erp/utils/StringConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../controller/dbProvider.dart';
import '../custom_widgets/error_page.dart';
import '../custom_widgets/loading_overlay.dart';
import '../custom_widgets/required_permission_layout.dart';
import '../db/UserDao.dart';
import '../logger.dart';
import '../models/CenterModel.dart';
import '../models/User.dart';
import '../services/erp_services.dart';
import '../utils/ColorConstants.dart';
import '../utils/ConnectivityUtils.dart';
import '../utils/util_methods.dart';
import 'CenterExpenseDetailPage.dart';

class CenterExpensePage extends StatefulWidget {
  const CenterExpensePage({super.key});

  @override
  State<CenterExpensePage> createState() => _CenterExpensePageState();
}

class _CenterExpensePageState extends State<CenterExpensePage> {
  late final UserDao userDao;
  User? user;
  late final Future<bool> pagePermissionFuture;
  CenterModel? location;

  List<CenterModel> locationList = List.empty(growable: true);
  CenterModel? centerModelValue;

  final _expenseStatusList = [
    "New",
    "Approved",
    "Rejected",
    "HO Approved",
    "Ho Rejected"
  ];
  String expenseStatusValue = "New";

  List<String> accountTypeList = List.empty(growable: true);
  String? accountTypeValue;

  List<String> expenseTypeList = List.empty(growable: true);
  String? expenseTypeValue;

  final TextEditingController ddSearchController = TextEditingController();

  late Future<List<CenterExpenseModel>> revenueFuture;

  String fromDate = "";
  String toDate = "";

  String? staffName;

  List labDetails = [];

  @override
  void initState() {
    userDao = Provider.of<DBProvider>(context, listen: false).dao;
    fromDate = DateFormat("dd MMM yyyy").format(DateTime.now());
    toDate = DateFormat("dd MMM yyyy").format(DateTime.now());
    pagePermissionFuture = userPagePermission();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                "expenseDate",
                (value) => DateFormat("dd-MMM-yyyy").format(
                    DateFormat("yyyy-MM-dd").parse(
                        dataTwo["expenseDate"].toString().split("T")[0])));
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
              return Flex(
                mainAxisSize: MainAxisSize.max,
                direction: Axis.vertical,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<CenterModel>(
                              isExpanded: true,

                              hint: const Text("Select Center"),
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                  fontFamily: 'Segoe',
                                  fontWeight: FontWeight.normal),
                              onChanged: (value) => {
                                setState(() {
                                  location = value;

                                  revenueFuture = getRevenue();
                                }),
                              },
                              value: location,
                              items: locationList
                                  .map<DropdownMenuItem<CenterModel>>(
                                      (CenterModel value) {
                                return DropdownMenuItem<CenterModel>(
                                  value: value,
                                  child: Text(value.locationName),
                                );
                              }).toList(),

                              buttonStyleData: ButtonStyleData(
                                padding: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0XFFF9F9F9),
                                  border: Border.all(
                                      width: 1.3,
                                      color: const Color(0XFFBEDCF0)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                              ),
                              iconStyleData: IconStyleData(
                                icon: Image.asset("assets/dropdown.png",
                                    color: const Color(0XFF5D5D5D),
                                    width: 14,
                                    height: 14),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 350,
                                offset: const Offset(0, -8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  //background color of dropdown button//border of dropdown button
                                  border: Border.all(
                                      color: const Color(0xFFC0C0C0)),
                                  borderRadius: BorderRadius.circular(
                                      10), //border raiuds of dropdown button
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                              ),
                              dropdownSearchData: DropdownSearchData(
                                searchController: ddSearchController,
                                searchInnerWidgetHeight: 50,
                                searchInnerWidget: Container(
                                  height: 50,
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 4,
                                    right: 8,
                                    left: 8,
                                  ),
                                  child: TextFormField(
                                    expands: true,
                                    maxLines: null,
                                    controller: ddSearchController,
                                    decoration: kTFFDecoration.copyWith(
                                      hintText: 'Search Center...',
                                      hintStyle: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                          fontFamily: 'Segoe',
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ),
                                searchMatchFn: (item, searchValue) {
                                  return item.value!.locationName
                                          .toLowerCase()
                                          .contains(
                                              searchValue.toLowerCase()) ||
                                      item.value!.locationCode
                                          .toLowerCase()
                                          .contains(searchValue.toLowerCase());
                                },
                              ),
                              //This to clear the search value when you close the menu
                              onMenuStateChange: (isOpen) {
                                if (!isOpen) {
                                  ddSearchController.clear();
                                }
                              },
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0XFFF9F9F9),
                                  border: Border.all(
                                      width: 1.3,
                                      color: const Color(0XFFBEDCF0)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: InkWell(
                                    onTap: () async {
                                      var datePicked =
                                          await DatePicker.showSimpleDatePicker(
                                        context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2010),
                                        lastDate:
                                            DateFormat('dd MMM yyyy', 'en_US')
                                                .parse(toDate),
                                        dateFormat: "dd-MMMM-yyyy",
                                        locale: DateTimePickerLocale.en_us,
                                        looping: false,
                                      );

                                      setState(() {
                                        fromDate =
                                            DateFormat('dd MMM yyyy', 'en_US')
                                                .format(datePicked!);
                                        revenueFuture = getRevenue();
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          fromDate,
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: 'Segoe',
                                              fontWeight: FontWeight.normal),
                                        ),
                                        const SizedBox(width: 10),
                                        Image.asset("assets/ic_calender.png",
                                            color: const Color(0XFF5D5D5D),
                                            width: 16,
                                            height: 16),
                                      ],
                                    )),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0XFFF9F9F9),
                                  border: Border.all(
                                      width: 1.3,
                                      color: const Color(0XFFBEDCF0)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: InkWell(
                                    onTap: () async {
                                      var datePicked =
                                          await DatePicker.showSimpleDatePicker(
                                        context,
                                        initialDate: DateTime.now(),
                                        firstDate:
                                            DateFormat('dd MMM yyyy', 'en_US')
                                                .parse(fromDate),
                                        lastDate: DateTime.now(),
                                        dateFormat: "dd-MMMM-yyyy",
                                        locale: DateTimePickerLocale.en_us,
                                        looping: false,
                                      );

                                      setState(() {
                                        toDate =
                                            DateFormat('dd MMM yyyy', 'en_US')
                                                .format(datePicked!);
                                        revenueFuture = getRevenue();
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          toDate,
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: 'Segoe',
                                              fontWeight: FontWeight.normal),
                                        ),
                                        const SizedBox(width: 10),
                                        Image.asset("assets/ic_calender.png",
                                            color: const Color(0XFF5D5D5D),
                                            width: 16,
                                            height: 16),
                                      ],
                                    )),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(10, 8, 5, 5),
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                decoration: BoxDecoration(
                                  color: const Color(0XFFF9F9F9),
                                  border: Border.all(
                                      width: 1.3,
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
                                      overflow: TextOverflow.ellipsis,
                                      fontFamily: 'Segoe',
                                      fontWeight: FontWeight.normal),
                                  onChanged: (value) => {
                                    setState(() {
                                      /*userDao!
                                      .findAllPersons()
                                      .then((value) => {getRevenue()});*/
                                      expenseStatusValue = value!;

                                      revenueFuture = getRevenue();
                                    }),
                                  },
                                  onTap: () {},
                                  hint: const Text("Select Status"),
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
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: const Text("Account Type"),
                                    style: const TextStyle(
                                        color: Colors.black54,
                                        overflow: TextOverflow.ellipsis,
                                        fontFamily: 'Segoe',
                                        fontWeight: FontWeight.normal),
                                    onChanged: (value) => {
                                      setState(() {
                                        accountTypeValue = value;

                                        revenueFuture = getRevenue();
                                      }),
                                    },
                                    value: accountTypeValue,
                                    items: accountTypeList
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child:
                                            Text(value.isEmpty ? 'ALL' : value),
                                      );
                                    }).toList(),

                                    buttonStyleData: ButtonStyleData(
                                      padding: const EdgeInsets.fromLTRB(
                                          8, 3, 16, 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0XFFF9F9F9),
                                        border: Border.all(
                                            width: 1.3,
                                            color: const Color(0XFFBEDCF0)),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                    ),
                                    iconStyleData: IconStyleData(
                                      icon: Image.asset("assets/dropdown.png",
                                          color: const Color(0XFF5D5D5D),
                                          width: 14,
                                          height: 14),
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 350,
                                      offset: const Offset(0, -8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFFFF),
                                        //background color of dropdown button//border of dropdown button
                                        border: Border.all(
                                            color: const Color(0xFFC0C0C0)),
                                        borderRadius: BorderRadius.circular(
                                            10), //border raiuds of dropdown button
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                    ),
                                    dropdownSearchData: DropdownSearchData(
                                      searchController: ddSearchController,
                                      searchInnerWidgetHeight: 50,
                                      searchInnerWidget: Container(
                                        height: 50,
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          bottom: 4,
                                          right: 8,
                                          left: 8,
                                        ),
                                        child: TextFormField(
                                          expands: true,
                                          maxLines: null,
                                          controller: ddSearchController,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            hintText: 'Search Account Type...',
                                            hintStyle:
                                                const TextStyle(fontSize: 12),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      searchMatchFn: (item, searchValue) {
                                        return item.value!
                                                .toLowerCase()
                                                .contains(searchValue
                                                    .toLowerCase()) ||
                                            item.value!.toLowerCase().contains(
                                                searchValue.toLowerCase());
                                      },
                                    ),
                                    //This to clear the search value when you close the menu
                                    onMenuStateChange: (isOpen) {
                                      if (!isOpen) {
                                        ddSearchController.clear();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 4, 5, 0),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: const Text("Expense Type"),
                                    style: const TextStyle(
                                        color: Colors.black54,
                                        overflow: TextOverflow.ellipsis,
                                        fontFamily: 'Segoe',
                                        fontWeight: FontWeight.normal),
                                    onChanged: (value) => {
                                      setState(() {
                                        expenseTypeValue = value!;

                                        revenueFuture = getRevenue();
                                      }),
                                    },
                                    value: expenseTypeValue,
                                    items: expenseTypeList
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),

                                    buttonStyleData: ButtonStyleData(
                                      padding: const EdgeInsets.fromLTRB(
                                          8, 4, 20, 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0XFFF9F9F9),
                                        border: Border.all(
                                            width: 1.3,
                                            color: const Color(0XFFBEDCF0)),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                    ),
                                    iconStyleData: IconStyleData(
                                      icon: Image.asset("assets/dropdown.png",
                                          color: const Color(0XFF5D5D5D),
                                          width: 14,
                                          height: 14),
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 350,
                                      offset: const Offset(0, -8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFFFF),
                                        //background color of dropdown button//border of dropdown button
                                        border: Border.all(
                                            color: const Color(0xFFC0C0C0)),
                                        borderRadius: BorderRadius.circular(
                                            10), //border raiuds of dropdown button
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                    ),
                                    dropdownSearchData: DropdownSearchData(
                                      searchController: ddSearchController,
                                      searchInnerWidgetHeight: 50,
                                      searchInnerWidget: Container(
                                        height: 50,
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          bottom: 4,
                                          right: 8,
                                          left: 8,
                                        ),
                                        child: TextFormField(
                                          expands: true,
                                          maxLines: null,
                                          controller: ddSearchController,
                                          decoration: kTFFDecoration.copyWith(
                                            hintText: 'Search Expense Type...',
                                            hintStyle: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14,
                                                fontFamily: 'Segoe',
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                      ),
                                      searchMatchFn: (item, searchValue) {
                                        return item.value!
                                                .toLowerCase()
                                                .contains(searchValue
                                                    .toLowerCase()) ||
                                            item.value!.toLowerCase().contains(
                                                searchValue.toLowerCase());
                                      },
                                    ),
                                    //This to clear the search value when you close the menu
                                    onMenuStateChange: (isOpen) {
                                      if (!isOpen) {
                                        ddSearchController.clear();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(5, 8, 10, 5),
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                decoration: BoxDecoration(
                                  color: const Color(0XFFF9F9F9),
                                  border: Border.all(
                                      width: 1.3,
                                      color: const Color(0XFFBEDCF0)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
                                  onChanged: (value) {
                                    staffName = value;
                                  },
                                  onSubmitted: (value) {
                                    setState(() {
                                      revenueFuture = getRevenue();
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Search by Staff Name',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Expanded(
                            child: FutureBuilder<List<CenterExpenseModel>>(
                                future: revenueFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState !=
                                      ConnectionState.done) {
                                    return const LoadingOverlay();
                                  }
                                  if (snapshot.hasError) {
                                    // snapshot.error.
                                    return const Text('Error');
                                  }
                                  if (snapshot.hasData) {
                                    List<CenterExpenseModel>
                                        centerExpenseModelLists =
                                        snapshot.data ?? [];
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: centerExpenseModelLists.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              10, 5, 10, 5),
                                          decoration: BoxDecoration(
                                            color: const Color(0XFFF9F9F9),
                                            border: Border.all(
                                                width: 1,
                                                color: const Color(0XFFBEDCF0)),
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
                                                  flex: 1,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        10, 15, 15, 10),
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
                                                            fontSize: 16,
                                                            color: Colors.black,
                                                          ),
                                                          softWrap: true,
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          centerExpenseModelLists[
                                                                  index]
                                                              .firstName,
                                                          // overflow: TextOverflow.ellipsis,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 17,
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
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black),
                                                          softWrap: true,
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          centerExpenseModelLists[
                                                                  index]
                                                              .accountTypeCode,
                                                          // overflow: TextOverflow.ellipsis,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 17,
                                                            color: Color(
                                                                0xff156397),
                                                          ),
                                                          softWrap: true,
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        const Text(
                                                          'Reason ',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black),
                                                          softWrap: true,
                                                        ),
                                                        Text(
                                                          centerExpenseModelLists[
                                                                  index]
                                                              .expenseDescription,
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
                                                          'Expense Type ',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.black,
                                                          ),
                                                          softWrap: true,
                                                        ),
                                                        Text(
                                                          centerExpenseModelLists[
                                                                  index]
                                                              .expenseType,
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
                                                  flex: 1,
                                                  child: Container(
                                                    color:
                                                        const Color(0xeaeaeaff),
                                                    margin: const EdgeInsets
                                                        .fromLTRB(8, 10, 8, 10),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize
                                                          .min, // Use a Column to stack text vertically
                                                      children: [
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          centerExpenseModelLists[
                                                                  index]
                                                              .expenseStatus,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            color: Color(
                                                                0xff156397),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 40,
                                                                  right: 40),
                                                          child: Divider(
                                                            color: Colors
                                                                .black, // You can set the color of the line
                                                            thickness:
                                                                1, // You can adjust the thickness of the line
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Text(
                                                          'Expense Date',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          DateFormat(
                                                                  'dd MMM yyyy',
                                                                  'en_US')
                                                              .format(DateFormat(
                                                                      'yyyy-MM-dd',
                                                                      'en_US')
                                                                  .parse(centerExpenseModelLists[
                                                                          index]
                                                                      .expenseDate
                                                                      .split(
                                                                          "T")[0])),
                                                          // DateTime.format(cardExpenseItems[index].expenseDate) ,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            color: Color(
                                                                0xff156397),
                                                          ),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 40,
                                                                  right: 40),
                                                          child: Divider(
                                                            color: Colors
                                                                .black, // You can set the color of the line
                                                            thickness:
                                                                1, // You can adjust the thickness of the line
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Text(
                                                          'Amount',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        Text(
                                                          "\u{20B9} ${centerExpenseModelLists[index].expenseAmount}",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 25,
                                                            color: Color(
                                                                0xff156397),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 40,
                                                                  right: 40),
                                                          child: Divider(
                                                            color: Colors
                                                                .black, // You can set the color of the line
                                                            thickness:
                                                                1, // You can adjust the thickness of the line
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => CenterExpenseDetailPage(
                                                                      centerExpenseModelLists[
                                                                              index]
                                                                          .ownerId,
                                                                      centerExpenseModelLists[
                                                                              index]
                                                                          .expenseCode,
                                                                      centerExpenseModelLists[
                                                                              index]
                                                                          .firstName,
                                                                      centerExpenseModelLists[
                                                                              index]
                                                                          .expenseType)),
                                                            );
                                                          },
                                                          child: const Text(
                                                            'Review Detail',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color: Color(
                                                                  0xff156397),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 30,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                  return const Text("No Data Found");
                                })),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const LoadingOverlay();
          }),
    );
  }

  Future<bool> userPagePermission() async {
    user ??= (await userDao.findAllPersons()).firstOrNull;
    ERPServices client = ERPServices();
    bool pagePermission = await client.getPagePermission(
        userId: user!.userid,
        pageName: 'StaffExpenses',
        locationId: user!.locationID);
    if (pagePermission) {
      await getFilterData();
      await getAccountType();
      await getExpenseType();
      revenueFuture = getRevenue();
    }
    return pagePermission;
  }

  Future getFilterData() async {
    try {
      if (await ConnectivityUtils.hasConnection()) {
        if (user!.usertype == "ZONALMANAGER") {
          Response response = await post(
            Uri.parse(
                '${StringConstants.BASE_URL}LIS_ERP_APP/LoadZonalManagerMappedCentres'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              'authKey': StringConstants.AUTHKEY,
              'ownerId': user!.locationID,
              'usertype': user!.usertype,
              'userid': user!.userid
            }),
          ).timeout(const Duration(seconds: 24));
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body.toString());
            if (data['lisResult'].toString() == 'True') {
              final registeredPatientDetailst =
                  data['loadZonalManager_Details'] as List<dynamic>?;
              // if the reviews are not missing
              locationList.clear();
              /*locationList
                  .add(CenterModel(locationCode: "All", locationName: "All"));*/
              locationList.addAll(registeredPatientDetailst != null
                  // map each review to a Review object
                  ? registeredPatientDetailst
                      .map((reviewData) => CenterModel.fromJson(reviewData))
                      // map() returns an Iterable so we convert it to a List
                      .toList()
                  // use an empty list as fallback value
                  : <CenterModel>[]);

              location = locationList[0];
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
        } else {
          //Navigator.of(context).pop();
          location =
              CenterModel(locationCode: user!.locationID, locationName: "");
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      //logger.i(e.toString());

      final snackBar = SnackBar(
        content: const Text('Please Contact KDL Admin'),
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

  Future getAccountType() async {
    try {
      if (await ConnectivityUtils.hasConnection()) {
        Response response = await post(
          Uri.parse('${StringConstants.BASE_URL}StaffExp/LoadAccountDetails'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'authKey': StringConstants.AUTHKEY,
            'ownerId': user!.locationID,
            'usertype': user!.usertype,
            'userid': user!.userid
          }),
        ).timeout(const Duration(seconds: 24));
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body.toString());
          if (data['lisResult'].toString() == 'True') {
            var jsonString = data['loadAccount_Details'];

            List<Map<String, dynamic>> accountTypeListData =
                List<Map<String, dynamic>>.from(jsonString.map((item) {
              return Map<String, dynamic>.from(item);
            }));
            //accountTypeList.add("All");
            for (var details in accountTypeListData) {
              accountTypeList.add(details["accountType"]);
            }
            accountTypeValue = accountTypeList.first;
          } else {
            if (context.mounted) {}
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      //logger.i(e.toString());

      final snackBar = SnackBar(
        content: const Text('Please Contact KDL Admin'),
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

  Future getExpenseType() async {
    try {
      if (await ConnectivityUtils.hasConnection()) {
        Response response = await post(
          Uri.parse('${StringConstants.BASE_URL}StaffExp/LoadExpDetails'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'authKey': StringConstants.AUTHKEY,
            'ownerId': user!.locationID,
            'usertype': user!.usertype,
            'userid': user!.userid
          }),
        ).timeout(const Duration(seconds: 24));
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body.toString());
          if (data['lisResult'].toString() == 'True') {
            var jsonString = data['loadExp_Details'];

            List<Map<String, dynamic>> expenseTypeListData =
                List<Map<String, dynamic>>.from(jsonString.map((item) {
              return Map<String, dynamic>.from(item);
            }));
            expenseTypeList.add("All");
            for (var details in expenseTypeListData) {
              expenseTypeList.add(details["expItemType"]);
            }
            expenseTypeValue = "All";
            revenueFuture = getRevenue();
          } else {
            if (context.mounted) {}
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      //logger.i(e.toString());

      final snackBar = SnackBar(
        content: const Text('Please Contact KDL Admin'),
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

  Future<List<CenterExpenseModel>> getRevenue() async {
    List<CenterExpenseModel> centerExpenseModelLists = [];
    try {
      // Dialogs.showLoadingDialog(context);
      if (await ConnectivityUtils.hasConnection()) {
        Response response = await post(
          Uri.parse('${StringConstants.BASE_URL}StaffExp/LoadDailyExpDetails'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'authKey': StringConstants.AUTHKEY,
            'accoutnTypeCode':
                (accountTypeValue == "All" ? "" : accountTypeValue) ?? "",
            'fromDate': DateFormat("yyyy-MM-dd")
                .format(DateFormat("dd MMM yyyy").parse(fromDate)),
            'toDate': DateFormat("yyyy-MM-dd")
                .format(DateFormat("dd MMM yyyy").parse(toDate)),
            'ExpenseCode':
                (expenseTypeValue == "All" ? "" : expenseTypeValue) ?? "",
            'ExpenseStatus': expenseStatusValue,
            'ExpenseType':
                (expenseTypeValue == "All" ? "" : expenseTypeValue) ?? "",
            'ownerId':
                location!.locationCode == "All" ? "" : location!.locationCode,
            'StaffName': staffName ?? ''
          }),
        ).timeout(const Duration(seconds: 24));

        if (response.statusCode == 200) {
          logger.i(response.body);
          var data = jsonDecode(response.body.toString());
          if (data['lisResult'].toString() == 'True') {
            labDetails = (data["loadDailyExpense_Details"] as List<dynamic>?)!;
            //labDetails = data["loadDailyExpense_Details"] as List<dynamic>?;
            centerExpenseModelLists = labDetails != null
                // map each review to a Review object
                ? labDetails
                    .map(
                        (reviewData) => CenterExpenseModel.fromJson(reviewData))
                    // map() returns an Iterable so we convert it to a List
                    .toList()
                // use an empty list as fallback value
                : <CenterExpenseModel>[];
            return centerExpenseModelLists;
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
            if (!mounted) return [];
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            try {
              labDetails.clear();
            } catch (e) {}
            setState(() {});
            return List.empty();
          }
        }
      } else {
        //Navigator.of(context).pop();
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
      }
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
        labDetails.clear();
      } catch (e) {}
      setState(() {});
      return [];
    } catch (e) {
      //logger.i(e.toString());
      //Navigator.of(context).pop();
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
        labDetails.clear();
      } catch (e) {}
      setState(() {});
      return [];
    }
    return centerExpenseModelLists;
  }
}
