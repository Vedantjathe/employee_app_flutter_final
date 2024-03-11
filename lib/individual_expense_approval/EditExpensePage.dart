import 'dart:async' show Future, TimeoutException;
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../custom_widgets/loading_overlay.dart';
import '../db/ErpDatabase.dart';
import '../db/UserDao.dart';
import '../logger.dart';
import '../models/IndividualCenterModel.dart';
import '../models/User.dart';
import '../utils/ConnectivityUtils.dart';
import '../utils/StringConstants.dart';
import '../utils/dialog_util.dart';
import '../utils/util_methods.dart';

class EditExpensePage extends StatefulWidget {
  final String? expenseCode;
  const EditExpensePage(this.expenseCode, {super.key});

  @override
  State<EditExpensePage> createState() =>
      _EditExpensePageState(this.expenseCode);
}

class _EditExpensePageState extends State<EditExpensePage> {
  final String? expenseCode;

  String? imageUrl;

  _EditExpensePageState(this.expenseCode);

  List<IndividualCenterModel> individualCenterModelList =
      List.empty(growable: true);
  List<String> accountItemList = List.empty(growable: true);
  List<String> accountDescItemList = List.empty(growable: true);
  IndividualCenterModel? individualCenterModelValue;
  String? expenseStatusValue;
  String? accountTypeValue;
  List<String> expenseStatus = List.empty(growable: true);
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
  var expFilePath = "";
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
              "EDIT EXPENSE",
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
                              individualCenterModelValue = value;
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
                            height: 48,
                            padding: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: const Color(0XFFF9F9F9),
                              border: Border.all(
                                  width: 1, color: const Color(0XFFBEDCF0)),
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
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownSearchData: DropdownSearchData(
                            searchController: ddSearchController,
                            searchInnerWidgetHeight: 50,
                            searchInnerWidget: Container(
                              height: 50,
                              padding: const EdgeInsets.all(8),
                              child: TextFormField(
                                expands: true,
                                maxLines: null,
                                controller: ddSearchController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  hintText: 'Search center',
                                  hintStyle: const TextStyle(fontSize: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
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
                        /*DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: toDate,
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2150),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            toDate = pickedDate;
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
                              accountTypeValue = value!;
                              expenseAmountEnable = true;
                              /*expenseAmountController.text = "";
                              noOfPersonController.text = "";
                              travelFromController.text = "";
                              travelToController.text = "";
                              travelDistanceController.text = "";*/
                              _errorAccountType = false;
                              kilometerValue = null;
                              //narrationController.text = "";

                              // getAccountDescription();
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
                              _errorAccountDescription = false;
                              accountDescriptionValue = value;
                              /*expenseAmountController.text = "";
                              travelFromController.text = "";
                              travelToController.text = "";
                              travelDistanceController.text = "";
                              noOfPersonController.text = "";
                              kilometerValue = null;
                              narrationController.text = "";*/

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
                                    /*if (value == "30 Km") {
                                      expenseAmountController.text = "250 Rs.";
                                    } else {
                                      expenseAmountController.text = "400 Rs.";
                                    }
                                    expenseAmountEnable = false;*/
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
                      "Travel From",
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
                                enabled: false,
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
                      "Travel To",
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
                                enabled: false,
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
                              "Travel Distance In KM",
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
                                        enabled: false,
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
                                          errorText: errorTextNoOFPerson,
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
                            errorText: errorTextNoOFPerson,
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
                          enabled: false,
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
                            errorText: errorTextNoOFPerson,
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
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 1),
                  child: Text(
                    expenseFile == null ? "" : expenseFile!.absolute.path,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontFamily: 'Segoe',
                        fontWeight: FontWeight.normal),
                  ),
                ),
                Visibility(
                    visible: false,
                    child: Expanded(
                      child: Image.network(
                        imageUrl ?? "",
                        height: 200,
                        width: 200,
                      ),
                    )),
                const SizedBox(
                  height: 8,
                ),
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  runSpacing: 16,
                  children: [
                    SizedBox(width: 2),
                    Visibility(
                      visible: expenseStatus.isNotEmpty &&
                          expenseStatus.first.toLowerCase() == 'new',
                      child: Padding(
                        padding: const EdgeInsets.all(2),
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
                                if (individualCenterModelValue != null) {
                                  if (accountTypeValue != null) {
                                    if (accountDescriptionValue != null) {
                                      if (accountTypeValue == "HOTEL") {
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
                                              updateExpenseData();
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
                                      } else if (accountTypeValue ==
                                          "DAILY ALLOWANCE") {
                                        if (kilometerValue != null) {
                                          if (expenseAmountController.text
                                              .trim()
                                              .isNotEmpty) {
                                            if (narrationController.text
                                                .trim()
                                                .isNotEmpty) {
                                              errorTextNarration = null;
                                              updateExpenseData();
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
                                      } else if (accountTypeValue ==
                                          "TRAVELLING") {
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
                                                  updateExpenseData();
                                                } else {
                                                  errorTextNarration =
                                                      "Enter Narration";
                                                }
                                              } else {
                                                errorTextAmount =
                                                    "Enter Amount";
                                              }
                                            } else {
                                              errorTextTravelDistance =
                                                  "Enter Travel Distance";
                                            }
                                          } else {
                                            errorTextTravelTo =
                                                "Enter Travel to";
                                          }
                                        } else {
                                          errorTextTravelFrom =
                                              "Enter Travel From";
                                        }
                                      } else {
                                        if (expenseAmountController.text
                                            .trim()
                                            .isNotEmpty) {
                                          if (narrationController.text
                                              .trim()
                                              .isNotEmpty) {
                                            errorTextNarration = null;
                                            updateExpenseData();
                                          } else {
                                            errorTextNarration =
                                                "Enter Narration";
                                          }
                                        } else {
                                          errorTextAmount = "Enter Amount";
                                        }
                                      }
                                    } else {
                                      _errorAccountDescription = true;
                                    }
                                  } else {
                                    _errorAccountType = true;
                                  }
                                } else {
                                  _errorCenter = true;
                                }
                              });
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
                              "Update",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2),
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
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2),
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
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2),
                  ],
                ),
                SizedBox(height: 24)
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

            individualCenterModelList.addAll(locationData
                .map((data) {
                  return IndividualCenterModel.fromJson(data);
                })
                .where((item) => item.status == "ACTIVE")
                .toList());

            /*individualCenterModelList = locationData
                .map((data) {
                  return IndividualCenterModel.fromJson(data);
                })
                .where((item) => item.status == "ACTIVE")
                .toList();*/
          });

          getReviewDetailsData();
          //fetchAccountType();
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
          setState(() {
            for (var item in accountListData) {
              accountItemList.add(item['Item_Type']);
            }
          });

          //Navigator.of(context).pop();
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
          Uri.parse(
              'http://android.krsnaadiagnostics.com/Krasna/GetAccountDesc'),
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
          Navigator.of(context).pop();
          setState(() {
            expenseAmountController.text = responseData['expenseAmount'];
            fromDate =
                DateFormat("dd/MMM/yyyy").parse(responseData['expenseDate']);

            toDate = DateFormat("M/d/yyyy")
                .parse(responseData['createdOn'].toString().split(" ")[0]);

            accountItemList.add(responseData['accountTypeCode']);
            accountTypeValue = responseData['accountTypeCode'];

            accountDescItemList.add(responseData['accountDescription']);
            accountDescriptionValue = responseData['accountDescription'];

            expenseStatus.add(responseData['expenseStatus']);
            expenseStatusValue = responseData['expenseStatus'];

            narrationController.text = responseData['expenseDescription'];

            for (var d in individualCenterModelList) {
              if (d.centreCode == responseData['centerLocation']) {
                individualCenterModelValue = d;
              }
            }

            if (accountTypeValue == "DAILY ALLOWANCE") {
              if (kilometerList.contains(responseData['kilometer']))
                kilometerValue = responseData['kilometer'];
            }

            if (accountTypeValue == "HOTEL") {
              noOfPersonController.text = responseData['noOfPeople'];
            }

            if (accountTypeValue == "TRAVELLING") {
              travelFromController.text = responseData['travellingFrom'];
              travelToController.text = responseData['travellingTo'];
              travelDistanceController.text = responseData['travellingKM'];
            }

            //responseData['onlineEXPFilePath'].toString().replaceAll(from, replace)

            imageUrl = responseData['onlineEXPFilePath'].replaceAll(
                "http://ilis.krsnaadiagnostics.com/",
                StringConstants.IMAGE_BASE_URL);
            expFilePath = imageUrl!;
            expenseAmountEnable = true;
          });
        } else {
          // Authentication failed
          //logger.i('Login failed');
          // You can display an error message to the user
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Non-200 status code, handle accordingly
        // logger.i('HTTP Error: ${response.statusCode}');
        // You can display an error message to the user
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle exceptions, e.g., network issues
      //logger.i('Exception occurred: $e');
      // You can display an error message to the user
      //Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateExpenseData() async {
    if (await ConnectivityUtils.hasConnection()) {
      try {
        Dialogs.showLoadingDialog(context);
        final response = await http.post(
            Uri.parse(
                '${StringConstants.BASE_URL}TravelExpenseRequest/UpdateInd_StaffExpense'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              'authKey': StringConstants.AUTHKEY,
              'expenseCode': expenseCode,
              'userId': user!.userid,
              'ExpenseAmount': expenseAmountController.text.toString().trim(),
              'CeneterId': individualCenterModelValue!.centreCode,
            }));

        final responseData = json.decode(response.body);

        final lisResult = responseData['lisResult'].toString();

        if (response.statusCode == 200) {
          if (lisResult == 'True') {
            Navigator.of(context).pop();
            Fluttertoast.showToast(
                msg: "Expense Data Update Successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
            Navigator.of(context).pop(true);
          } else {
            // Authentication failed
            //logger.i('Login failed');
            // You can display an error message to the user
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Non-200 status code, handle accordingly
          // logger.i('HTTP Error: ${response.statusCode}');
          // You can display an error message to the user
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Handle exceptions, e.g., network issues
        //logger.i('Exception occurred: $e');
        // You can display an error message to the user
        //Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please Check Internet Connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void showPreviewDialog() async {
    OverlayEntry overlayEntry =
        OverlayEntry(builder: (_) => const LoadingOverlay());
    try {
      Navigator.of(context).overlay?.insert(overlayEntry);
      File file = await loadPdfFromNetwork(expFilePath);
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
          "${StringConstants.BASE_URL.split("api/")[0]}${expFilePath.split("in/")[1]}",
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
      overlayEntry.remove();

      logger.e(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
