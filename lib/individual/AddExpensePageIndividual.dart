import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:erp/models/IndividualCenterModel.dart';
import 'package:erp/models/User.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../constants/constants.dart';
import '../custom_widgets/loading_overlay.dart';
import '../db/ErpDatabase.dart';
import '../db/UserDao.dart';
import '../utils/ConnectivityUtils.dart';
import '../utils/StringConstants.dart';
import '../utils/dialog_util.dart';

final formatter = DateFormat.yMd();

class AddExpenseCenterPage extends StatefulWidget {
  const AddExpenseCenterPage({super.key});

  @override
  State<AddExpenseCenterPage> createState() => _AddExpenseCenterPageState();
}

class _AddExpenseCenterPageState extends State<AddExpenseCenterPage> {
  List<IndividualCenterModel> individualCenterModelList = [];
  List<String> accountItemList = List.empty(growable: true);
  List<String> accountDescItemList = List.empty(growable: true);
  IndividualCenterModel? individualCenterModelValue;
  String? expenseStatusValue = "New";
  String? accountTypeValue;
  List<String> expenseStatus = ['New'];
  final TextEditingController ddSearchController = TextEditingController();
  TextEditingController narrationController = TextEditingController();
  TextEditingController expenseAmountController = TextEditingController();
  TextEditingController noOfPersonController = TextEditingController();
  TextEditingController travelFromController = TextEditingController();
  TextEditingController travelToController = TextEditingController();
  TextEditingController travelDistanceController = TextEditingController();

  List<String> kilometerList = ['30 Km', 'Above 30 Km'];
  String? accountDescriptionValue;
  String? kilometerValue;

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  ErpDatabase? krsnaaDatabase;
  UserDao? userDao;
  User? user;
  final OverlayEntry overlayEntry =
      OverlayEntry(builder: (context) => LoadingOverlay());

  String? errorTextNarration;
  String? errorTextAmount;
  String? errorTextNoOFPerson;
  String? errorTextTravelFrom;
  String? errorTextTravelTo;
  String? errorTextTravelDistance;
  bool expenseAmountEnable = true;
  bool _errorCenter = false;
  bool _errorAccountType = false;
  bool _errorAccountDescription = false;
  bool _errorKilometer = false;
  bool _errorExpenseFile = false;

  File? expenseFile;

  builder() async {
    krsnaaDatabase =
        await $FloorErpDatabase.databaseBuilder(StringConstants.DBNAME).build();
    setState(() {
      //  selectedDate = DateFormat('dd MMM yyyy', 'en_US').format(DateTime.now());
      userDao = krsnaaDatabase!.personDao;
      userDao!.findAllPersons().then((value) => {fetchLocations(value[0])});
    });
  }

  @override
  void initState() {
    super.initState();
    //fetchProducts();

    //fetchExpenseItems();
    // fetchAccountType();
    // fetchCardData();
    builder();
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
              "ADD EXPENSE",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Segoe',
                  fontWeight: FontWeight.normal),
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xff3A9FBE),
                Color(0xff17E1DA),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 1),
              child: const Text(
                "Center Location*",
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontFamily: 'Segoe',
                    fontWeight: FontWeight.normal),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 1, 10, 2),
                    child: DropdownButtonHideUnderline(
                      child: SizedBox(
                        height: 48,
                        child: DropdownButton2<IndividualCenterModel>(
                          isExpanded: true,
                          hint: const Text("Select Center"),
                          style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                              fontFamily: 'Segoe',
                              fontWeight: FontWeight.normal),
                          onChanged: (value) => {
                            setState(() {
                              /*userDao!
                                    .findAllPersons()
                                    .then((value) => {getRevenue()});*/
                              _errorCenter = false;
                              individualCenterModelValue = value!;
                              // Dialogs.showLoadingDialog(context);
                              //fetchCardData();
                            }),
                          },
                          value: individualCenterModelValue,
                          items: individualCenterModelList
                              .map<DropdownMenuItem<IndividualCenterModel>>(
                                  (IndividualCenterModel value) {
                            return DropdownMenuItem<IndividualCenterModel>(
                              value: value,
                              child: Text(value.centreName!),
                            );
                          }).toList(),

                          buttonStyleData: ButtonStyleData(
                            padding: const EdgeInsets.only(right: 16),
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0XFFF9F9F9),
                              border: Border.all(
                                  width: 1.3, color: const Color(0XFFBEDCF0)),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
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
                              border:
                                  Border.all(color: const Color(0xFFC0C0C0)),
                              borderRadius: BorderRadius.circular(
                                  10), //border raiuds of dropdown button
                            ),
                          ),
                          dropdownSearchData: DropdownSearchData(
                            searchController: ddSearchController,
                            searchInnerWidgetHeight: 40,
                            searchInnerWidget: Container(
                              height: 60,
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
                              return item.value!.centreName!
                                      .toLowerCase()
                                      .contains(searchValue.toLowerCase()) ||
                                  item.value!.centreCode!
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
                  ),
                ),
              ],
            ),
            Visibility(
              visible: _errorCenter,
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 5, 5),
                alignment: Alignment.topLeft,
                child: const Text(
                  "Select Center",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontFamily: 'Segoe',
                      fontWeight: FontWeight.normal),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 1),
                    child: const Text(
                      "Expense Booking Date*",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 1),
                    child: const Text(
                      "Expense Date*",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        /*DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: fromDate,
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2150),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            fromDate = pickedDate;
                          });
                        }*/
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0XFFF9F9F9),
                            border: Border.all(
                                width: 1, color: const Color(0XFFBEDCF0)),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 14, 15, 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/ic_calender.png",
                                  width: 21,
                                  height: 21,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  DateFormat("dd MMM yyyy").format(fromDate),
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18,
                                      fontFamily: 'Segoe',
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: toDate,
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            toDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0XFFF9F9F9),
                            border: Border.all(
                                width: 1, color: const Color(0XFFBEDCF0)),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 14, 15, 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/ic_calender.png",
                                  width: 21,
                                  height: 21,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  DateFormat("dd MMM yyyy").format(toDate),
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18,
                                      fontFamily: 'Segoe',
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 1),
                    child: const Text(
                      "Account Type*",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 1),
                    child: const Text(
                      "Account Description*",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2, left: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0XFFF9F9F9),
                        border: Border.all(
                            width: 1, color: const Color(0XFFBEDCF0)),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                          onChanged: (value) => {
                            setState(() {
                              //statusValue = value.;
                              accountTypeValue = value!;
                              expenseAmountEnable = true;
                              expenseAmountController.text = "";
                              noOfPersonController.text = "";
                              travelFromController.text = "";
                              travelToController.text = "";
                              travelDistanceController.text = "";
                              _errorAccountType = false;
                              kilometerValue = null;
                              narrationController.text = "";

                              getAccountDescription();
                            })
                          },
                          value: accountTypeValue,
                          hint: const Text("Account Type"),
                          items: accountItemList
                              .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    maxLines: 5,
                                    style: const TextStyle(fontSize: 14),
                                  )))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2, right: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0XFFF9F9F9),
                        border: Border.all(
                            width: 1, color: const Color(0XFFBEDCF0)),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                          onChanged: (value) => {
                            setState(() {
                              //statusValue = value.;
                              _errorAccountDescription = false;
                              accountDescriptionValue = value;
                              expenseAmountController.text = "";
                              travelFromController.text = "";
                              travelToController.text = "";
                              travelDistanceController.text = "";
                              noOfPersonController.text = "";
                              kilometerValue = null;
                              narrationController.text = "";

                              if (accountDescriptionValue ==
                                      "OWN VEHICLE ( BIKE )" ||
                                  accountDescriptionValue ==
                                      "OWN VEHICLE ( CAR )") {
                                expenseAmountEnable = false;
                              } else {
                                expenseAmountEnable = true;
                              }
                            })
                          },
                          value: accountDescriptionValue,
                          hint: const Text("Account Description"),
                          items: accountDescItemList
                              .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    maxLines: 5,
                                    style: const TextStyle(fontSize: 14),
                                  )))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: _errorAccountType,
                  child: Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                      alignment: Alignment.topLeft,
                      child: const Text(
                        "Select Account Type",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontFamily: 'Segoe',
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _errorAccountDescription,
                  child: Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      alignment: Alignment.topRight,
                      child: const Text(
                        "Select Account Description",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontFamily: 'Segoe',
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: accountTypeValue == "DAILY ALLOWANCE" ? true : false,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 1),
                    child: const Text(
                      "Kilometer*",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 12, right: 12, top: 2),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0XFFF9F9F9),
                              border: Border.all(
                                  width: 1, color: const Color(0XFFBEDCF0)),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                onChanged: (value) => {
                                  setState(() {
                                    //statusValue = value.;
                                    kilometerValue = value;
                                    _errorKilometer = false;
                                    if (value == "30 Km") {
                                      expenseAmountController.text = "250 Rs.";
                                    } else {
                                      expenseAmountController.text = "400 Rs.";
                                    }
                                    expenseAmountEnable = false;
                                  })
                                },
                                value: kilometerValue,
                                hint: const Text("Select Kilometer"),
                                items: kilometerList
                                    .map((value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(
                                          value,
                                          maxLines: 1,
                                          style: const TextStyle(fontSize: 14),
                                        )))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: _errorKilometer,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      alignment: Alignment.topLeft,
                      child: const Text(
                        "Select Kilometer",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontFamily: 'Segoe',
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: accountTypeValue == "HOTEL" ? true : false,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 1),
                    child: const Text(
                      "No of person*",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12),
                          child: Focus(
                            onFocusChange: ((value) {
                              /*if (!value) {
                          checkMobileValidation();
                        } else {
                          checkNameValidation();
                          checkUserNameValidation();
                        }*/
                            }),
                            child: TextField(
                                //F9F9F9
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                controller: noOfPersonController,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                maxLength: 10,
                                decoration: InputDecoration(
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
                                  contentPadding: const EdgeInsets.fromLTRB(
                                      20.0, 13, 20, 13),
                                  errorText: errorTextNoOFPerson,
                                  counterText: "",
                                  errorStyle: TextStyle(height: 0),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Color(0XFFBEDCF0)),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Color(0XFFBEDCF0)),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Color(0XFFBEDCF0)),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      errorTextNoOFPerson = null;
                                    });
                                  } else {
                                    setState(() {
                                      errorTextNoOFPerson =
                                          "Enter no of person";
                                    });
                                  }
                                },
                                style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                    fontFamily: 'Segoe',
                                    fontWeight: FontWeight.normal)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Visibility(
              visible: accountTypeValue == "TRAVELLING" ? true : false,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 1),
                    child: const Text(
                      "Travel From*",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12),
                          child: Focus(
                            onFocusChange: ((value) {
                              /*if (!value) {
                          checkMobileValidation();
                        } else {
                          checkNameValidation();
                          checkUserNameValidation();
                        }*/
                            }),
                            child: TextField(
                                //F9F9F9
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.text,
                                maxLength: 20,
                                controller: travelFromController,
                                decoration: InputDecoration(
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
                                  contentPadding: const EdgeInsets.fromLTRB(
                                      20.0, 13, 20, 13),
                                  errorText: errorTextTravelFrom,
                                  counterText: "",
                                  errorStyle: TextStyle(height: 0),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Color(0XFFBEDCF0)),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Color(0XFFBEDCF0)),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Color(0XFFBEDCF0)),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      errorTextTravelFrom = null;
                                    });
                                  } else {
                                    setState(() {
                                      errorTextTravelFrom = "Enter travel from";
                                    });
                                  }
                                },
                                style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                    fontFamily: 'Segoe',
                                    fontWeight: FontWeight.normal)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 1),
                    child: const Text(
                      "Travel To*",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12),
                          child: Focus(
                            onFocusChange: ((value) {
                              /*if (!value) {
                          checkMobileValidation();
                        } else {
                          checkNameValidation();
                          checkUserNameValidation();
                        }*/
                            }),
                            child: TextField(
                                //F9F9F9
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.text,
                                maxLength: 20,
                                controller: travelToController,
                                decoration: InputDecoration(
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
                                  contentPadding: const EdgeInsets.fromLTRB(
                                      20.0, 13, 20, 13),
                                  errorText: errorTextTravelTo,
                                  counterText: "",
                                  errorStyle: TextStyle(height: 0),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Color(0XFFBEDCF0)),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Color(0XFFBEDCF0)),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Color(0XFFBEDCF0)),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      errorTextTravelTo = null;
                                    });
                                  } else {
                                    setState(() {
                                      errorTextTravelTo = "Enter travel to";
                                    });
                                  }
                                },
                                style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                    fontFamily: 'Segoe',
                                    fontWeight: FontWeight.normal)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Visibility(
                      visible: (accountDescriptionValue != "AIR TRAVEL" &&
                          accountDescriptionValue !=
                              "RENTED VEHICLE / PUBLIC TRANSPORT / TRAIN"),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 1),
                            child: const Text(
                              "Travel Distance In KM*",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontFamily: 'Segoe',
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 12),
                                  child: Focus(
                                    onFocusChange: ((value) {
                                      /*if (!value) {
                          checkMobileValidation();
                        } else {
                          checkNameValidation();
                          checkUserNameValidation();
                        }*/
                                    }),
                                    child: TextField(
                                        //F9F9F9
                                        onTapOutside: (event) {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        controller: travelDistanceController,
                                        textInputAction: TextInputAction.next,
                                        maxLength: 20,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color(0XFFF9F9F9),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                                color: Color(0XFFBEDCF0)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                                color: Color(0XFFBEDCF0)),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  20.0, 13, 20, 13),
                                          errorText: errorTextTravelDistance,
                                          counterText: "",
                                          errorStyle: TextStyle(height: 0),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                                color: Color(0XFFBEDCF0)),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                                color: Color(0XFFBEDCF0)),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                                color: Color(0XFFBEDCF0)),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (value.isNotEmpty) {
                                            setState(() {
                                              errorTextTravelDistance = null;
                                            });
                                          } else {
                                            setState(() {
                                              errorTextTravelDistance =
                                                  "Enter Distance";
                                            });
                                          }
                                          if (accountDescriptionValue ==
                                              "OWN VEHICLE ( BIKE )") {
                                            expenseAmountController.text = value
                                                    .trim()
                                                    .isEmpty
                                                ? ""
                                                : (double.parse(
                                                            value.toString()) *
                                                        3.5)
                                                    .toString();
                                          } else if (accountDescriptionValue ==
                                              "OWN VEHICLE ( CAR )") {
                                            expenseAmountController.text = value
                                                    .trim()
                                                    .isEmpty
                                                ? ""
                                                : (double.parse(
                                                            value.toString()) *
                                                        10)
                                                    .toString();
                                          }
                                        },
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16,
                                            overflow: TextOverflow.ellipsis,
                                            fontFamily: 'Segoe',
                                            fontWeight: FontWeight.normal)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 1),
                    child: const Text(
                      "Expense Amount*",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 1),
                    child: const Text(
                      "Expense Status*",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 2),
                    child: Focus(
                      onFocusChange: ((value) {
                        /*if (!value) {
                          checkMobileValidation();
                        } else {
                          checkNameValidation();
                          checkUserNameValidation();
                        }*/
                      }),
                      child: TextField(
                          //F9F9F9
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: expenseAmountController,
                          maxLength: 10,
                          enabled: expenseAmountEnable,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0XFFF9F9F9),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(color: Color(0XFFBEDCF0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(color: Color(0XFFBEDCF0)),
                            ),
                            contentPadding:
                                const EdgeInsets.fromLTRB(20.0, 13, 20, 13),
                            errorText: errorTextAmount,
                            counterText: "",
                            errorStyle: TextStyle(height: 0),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(color: Color(0XFFBEDCF0)),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(color: Color(0XFFBEDCF0)),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(color: Color(0XFFBEDCF0)),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                errorTextAmount = null;
                              });
                            } else {
                              setState(() {
                                errorTextAmount = "Enter Amount";
                              });
                            }
                          },
                          style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                              fontFamily: 'Segoe',
                              fontWeight: FontWeight.normal)),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, left: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0XFFF9F9F9),
                        border: Border.all(
                            width: 1, color: const Color(0XFFBEDCF0)),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                          onChanged: (value) => {
                            setState(() {
                              //statusValue = value.;
                              expenseStatusValue = value!;
                            })
                          },
                          value: expenseStatusValue,
                          hint: const Text("Expense Status"),
                          items: expenseStatus
                              .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    maxLines: 5,
                                    style: const TextStyle(fontSize: 14),
                                  )))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 1),
              child: const Text(
                "Narration*",
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontFamily: 'Segoe',
                    fontWeight: FontWeight.normal),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Focus(
                      onFocusChange: ((value) {
                        /*if (!value) {
                          checkAddress();
                        } else {
                          checkNameValidation();
                          checkUserNameValidation();
                          checkMobileValidation();
                          checkEmailValidation();
                          checkCity();
                        }*/
                      }),
                      child: TextField(
                          //F9F9F9
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          maxLength: 200,
                          controller: narrationController,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                errorTextNarration = null;
                              });
                            } else {
                              setState(() {
                                errorTextNarration = "Enter Narration";
                              });
                            }
                          },
                          minLines: 4,
                          maxLines: 6,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0XFFF9F9F9),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(color: Color(0XFFBEDCF0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(color: Color(0XFFBEDCF0)),
                            ),
                            contentPadding:
                                const EdgeInsets.fromLTRB(20.0, 13, 20, 13),
                            errorText: errorTextNarration,
                            counterText: "",
                            errorStyle: TextStyle(height: 0),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(color: Color(0XFFBEDCF0)),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(color: Color(0XFFBEDCF0)),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(color: Color(0XFFBEDCF0)),
                            ),
                          ),
                          style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontFamily: 'Segoe',
                              fontWeight: FontWeight.normal)),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 1),
                  child: Text(
                    expenseFile?.path.split('/').last ?? '',
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontFamily: 'Segoe',
                        fontWeight: FontWeight.normal),
                  ),
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(80, 6, 80, 6),
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
                              uploadFileDialog(
                                context,
                                cameraCallback: () {
                                  Navigator.pop(context);
                                  _getFromCamera();
                                },
                                storageCallBack: () async {
                                  Navigator.pop(context);
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles();
                                  if (result != null) {
                                    expenseFile =
                                        File(result.files.single.path!);
                                    setState(() {});
                                  } else {}
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              disabledForegroundColor:
                                  Colors.transparent.withOpacity(0.38),
                              disabledBackgroundColor:
                                  Colors.transparent.withOpacity(0.12),
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text(
                              "Upload File",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: _errorExpenseFile,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                    alignment: Alignment.center,
                    child: const Text(
                      "Select Expense File",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(80, 6, 80, 6),
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
                              if (individualCenterModelValue == null) {
                                setState(() {
                                  _errorCenter = true;
                                });
                                return;
                              }

                              if (accountTypeValue == null) {
                                setState(() {
                                  _errorAccountType = true;
                                });
                                return;
                              }

                              if (accountDescriptionValue == null) {
                                setState(() {
                                  _errorAccountDescription = true;
                                });
                                return;
                              }

                              switch (accountTypeValue) {
                                case 'HOTEL':
                                  {
                                    if (noOfPersonController.text
                                        .trim()
                                        .isNotEmpty) {
                                      errorTextNoOFPerson = null;
                                      if (expenseAmountController.text
                                          .trim()
                                          .isNotEmpty) {
                                        if (narrationController.text
                                            .trim()
                                            .isNotEmpty) {
                                          errorTextNarration = null;
                                          saveExpense();
                                        } else {
                                          errorTextNarration =
                                              "Enter Narration";
                                        }
                                      } else {
                                        errorTextAmount = "Enter Amount";
                                      }
                                    } else {
                                      errorTextNoOFPerson =
                                          "Enter No of Person";
                                    }
                                  }
                                  break;
                                case 'DAILY ALLOWANCE':
                                  {
                                    if (kilometerValue != null) {
                                      if (expenseAmountController.text
                                          .trim()
                                          .isNotEmpty) {
                                        if (narrationController.text
                                            .trim()
                                            .isNotEmpty) {
                                          errorTextNarration = null;
                                          saveExpense();
                                        } else {
                                          errorTextNarration =
                                              "Enter Narration";
                                        }
                                      } else {
                                        errorTextAmount = "Enter Amount";
                                      }
                                    } else {
                                      _errorKilometer = true;
                                    }
                                  }
                                  break;
                                case 'TRAVELLING':
                                  {
                                    if (travelFromController.text
                                        .trim()
                                        .isNotEmpty) {
                                      errorTextTravelFrom = null;
                                      if (travelToController.text
                                          .trim()
                                          .isNotEmpty) {
                                        errorTextTravelTo = null;
                                        if (travelDistanceController.text
                                            .trim()
                                            .isNotEmpty) {
                                          errorTextTravelDistance = null;
                                          if (expenseAmountController.text
                                              .trim()
                                              .isNotEmpty) {
                                            if (narrationController.text
                                                .trim()
                                                .isNotEmpty) {
                                              errorTextNarration = null;
                                              saveExpense();
                                            } else {
                                              errorTextNarration =
                                                  "Enter Narration";
                                            }
                                          } else {
                                            errorTextAmount = "Enter Amount";
                                          }
                                        } else {
                                          if (accountDescriptionValue ==
                                                  "AIR TRAVEL" ||
                                              accountDescriptionValue ==
                                                  "RENTED VEHICLE / PUBLIC TRANSPORT / TRAIN") {
                                            errorTextTravelDistance = null;
                                            if (expenseAmountController.text
                                                .trim()
                                                .isNotEmpty) {
                                              if (narrationController.text
                                                  .trim()
                                                  .isNotEmpty) {
                                                errorTextNarration = null;
                                                saveExpense();
                                              } else {
                                                errorTextNarration =
                                                    "Enter Narration";
                                              }
                                            } else {
                                              errorTextAmount = "Enter Amount";
                                            }
                                          } else {
                                            errorTextTravelDistance =
                                                "Enter Travel Distance";
                                          }
                                        }
                                      } else {
                                        errorTextTravelTo = "Enter Travel to";
                                      }
                                    } else {
                                      errorTextTravelFrom = "Enter Travel From";
                                    }
                                  }
                                  break;
                                default:
                                  {
                                    if (expenseAmountController.text
                                        .trim()
                                        .isNotEmpty) {
                                      if (narrationController.text
                                          .trim()
                                          .isNotEmpty) {
                                        errorTextNarration = null;
                                        saveExpense();
                                      } else {
                                        errorTextNarration = "Enter Narration";
                                      }
                                    } else {
                                      errorTextAmount = "Enter Amount";
                                    }
                                  }
                                  break;
                              }
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              disabledForegroundColor:
                                  Colors.transparent.withOpacity(0.38),
                              disabledBackgroundColor:
                                  Colors.transparent.withOpacity(0.12),
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text(
                              "Save",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchLocations(User value) async {
    try {
      user = value;
      Dialogs.showLoadingDialog(context);
      final response = await http.post(
          Uri.parse('${StringConstants.VBASE_URL}Krasna/GetCentreListTwo'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'authKey': StringConstants.AUTHKEY,
          }));

      if (response.statusCode == 200) {
        final responseDataLocation = json.decode(response.body);
        final List<dynamic> locationData = responseDataLocation['Center'];

        if (locationData != null) {
          setState(() {
            var model = IndividualCenterModel(
                centreName: "New Project",
                centreCode: "NewProject",
                status: "Active");
            individualCenterModelList.add(model);
            individualCenterModelList.addAll(locationData.map((data) {
              return IndividualCenterModel.fromJson(data);
            }).where((item) => item.status == "ACTIVE"));
          });
          /*individualCenterModelList.sort(
              (a, b) => (a.centreName ?? '').compareTo((b.centreName ?? '')));*/
          fetchAccountType();
        } else {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Center Not Found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something Wrong At Server End. Please try Later'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Contact KDL Admin'),
          backgroundColor: Colors.red,
        ),
      );
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
          setState(() {
            for (var item in accountListData) {
              accountItemList.add(item['Item_Type']);
            }
          });
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account Type Not Found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something Wrong At Server End. Please try Later'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Contact KDL Admin'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> getAccountDescription() async {
    try {
      Dialogs.showLoadingDialog(context);
      final response = await http.post(
          Uri.parse('${StringConstants.VBASE_URL}Krasna/GetAccountDesc'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "Accounttype": accountTypeValue,
          }));
      if (response.statusCode == 200) {
        final responseOfAccountItems = json.decode(response.body);
        if (responseOfAccountItems != null) {
          final List<dynamic> accountListData =
              responseOfAccountItems['AccountDescription'];
          setState(() {
            accountDescriptionValue = null;
            accountDescItemList.clear();
            for (var item in accountListData) {
              accountDescItemList.add(item['Item_Description']);
            }
          });
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account Type Not Found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something Wrong At Server End. Please try Later'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Contact KDL Admin'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      expenseFile = File(pickedFile.path);
      List<String> filePathList = (expenseFile!.path).split('/');
      String fileName = filePathList.last;
      fileName = 'my_photo.${fileName.split('.').last}';
      filePathList.last = fileName;

      expenseFile = await expenseFile!.rename(filePathList.join('/'));

      setState(() {});
    }
  }

  Future<void> saveExpense() async {
    if (expenseFile != null) {
      setState(() {
        _errorExpenseFile = false;
      });
      if (await ConnectivityUtils.hasConnection()) {
        try {
          Dialogs.showLoadingDialog(context);
          var request = http.MultipartRequest(
              'POST',
              Uri.parse(
                  '${StringConstants.BASE_URL}TravelExpenseRequest/AddInd_StaffExpense'));

          /*print("" +
              "ExpenseDate:${DateFormat("dd MMM yyyy").format(toDate)}" +
              "StaffName:${user!.userid}" +
              "AccountTypeCode:$accountTypeValue" +
              "ExpenseDescription:${narrationController.text.trim()}" +
              "ExpenseAmount:${expenseAmountController.text.trim()}" +
              "ExpenseStatus:$expenseStatusValue" +
              "ownerId:${user!.locationID}" +
              "UpdatedBy:${user!.userid}" +
              "AccountDescription:$accountDescriptionValue" +
              "centerLocation:${individualCenterModelValue!.centrecode!}" +
              "ExpenseBookingDate:${DateFormat("dd MMM yyyy").format(fromDate)}" +
              "Kilometer:${kilometerValue == null ? "" : kilometerValue!.trim()}" +
              "KmAmount:" +
              "travelID:" +
              "fromLocation:${travelFromController.text.trim()}" +
              "toLocation:${travelToController.text.trim()}" +
              "fromtokm:${travelDistanceController.text.trim()}" +
              "NoOfPeople:${noOfPersonController.text.trim()}");*/

          request.fields['ExpenseDate'] =
              DateFormat("dd MMM yyyy").format(toDate);
          request.fields['StaffName'] = user!.userid;
          request.fields['authKey'] = StringConstants.AUTHKEY;
          request.fields['AccountTypeCode'] = accountTypeValue!;
          request.fields['ExpenseDescription'] =
              narrationController.text.trim();
          request.fields['ExpenseAmount'] =
              expenseAmountController.text.trim().replaceAll("Rs.", "");
          request.fields['ExpenseStatus'] = expenseStatusValue!;
          request.fields['ownerId'] = user!.locationID;
          request.fields['UpdatedBy'] = user!.userid;
          request.fields['AccountDescription'] = accountDescriptionValue!;
          request.fields['centerLocation'] =
              individualCenterModelValue!.centreCode!;
          request.fields['ExpenseBookingDate'] =
              DateFormat("dd MMM yyyy").format(fromDate);
          request.fields['Kilometer'] =
              kilometerValue == null ? "" : kilometerValue!.trim();
          request.fields['KmAmount'] = "";
          request.fields['travelID'] = "";
          request.fields['fromLocation'] = travelFromController.text.trim();
          request.fields['toLocation'] = travelToController.text.trim();
          request.fields['fromtokm'] = travelDistanceController.text.trim();
          request.fields['NoOfPeople'] = noOfPersonController.text.trim();
          request.files.add(
              await http.MultipartFile.fromPath("file", expenseFile!.path));
          var response =
              await request.send().timeout(const Duration(seconds: 24));
          var responsed = await http.Response.fromStream(response);
          final responseData = json.decode(responsed.body);
          Navigator.of(context).pop();
          if (response.statusCode == 200) {
            if (responseData["lisResult"] == "True") {
              Fluttertoast.showToast(
                  msg: "Expenses Added Successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0);

              Navigator.of(context).pop(true);
            } else {
              final snackBar = SnackBar(
                content: Text(responseData["lisMessage"]),
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
      }
    } else {
      setState(() {
        _errorExpenseFile = true;
      });
    }
  }
}
