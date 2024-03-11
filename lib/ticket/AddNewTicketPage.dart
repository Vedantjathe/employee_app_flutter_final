import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:erp/constants/constants.dart';
import 'package:erp/custom_widgets/custom_button.dart';
import 'package:erp/custom_widgets/loading_overlay.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controller/dbProvider.dart';
import '../db/UserDao.dart';
import '../models/CenterListModel.dart';
import '../models/EmployeeListModel.dart';
import '../models/IssueDepartmentModel.dart';
import '../models/IssueTypeListModel.dart';
import '../models/LabList.dart';
import '../models/User.dart';
import '../models/cardExpenseItems.dart';
import '../services/add_new_ticket_services.dart';
import '../services/api_multipart_request.dart';
import '../utils/StringConstants.dart';
import '../utils/dialog_util.dart';

final formatter = DateFormat.yMd();

class AddNewTicketPage extends StatefulWidget {
  const AddNewTicketPage({super.key, required User user});

  @override
  State<AddNewTicketPage> createState() => _AddNewTicketPageState();
}

class _AddNewTicketPageState extends State<AddNewTicketPage> {
  final OverlayEntry overlayEntry =
      OverlayEntry(builder: (context) => LoadingOverlay());

  File? expenseFile;
  List<Location> locations2 = List.empty();

  File? uploadDoc;

  CenterDetails? centerStatusValue;

  IssueDepartment? loadDepStatusValue;

  IssueTypeDetails? issueType;
  String? centerValue;

  List<String> testTypeItems = [
    'New',
    'Approved',
    'Rejected',
    'HO Approved',
    'HO Rejected'
  ];
  String? testTypeValue;

  String? errorTicketDescription;

  DateTime? fromDate;

  final TextEditingController ddSearchController = TextEditingController();

  late final UserDao userDao;

  late User user;

  TextEditingController designationTFController = TextEditingController(),
      usernameTFController = TextEditingController(),
      contactNoTFController = TextEditingController(),
      fromTFController = TextEditingController();

  String? ticketCategory,
      priority,
      patientName,
      prnNo,
      ticketDescription,
      actionTaken,
      isApprovalNeeded;
  List<String> ticketList = ['Issue', 'Requirement', 'Complaint', 'Other'],
      priorityList = ['Regular', 'Medium', 'High'],
      actionTakenList = [
        'Immediate Action',
        'Root Cause Analysis',
        'Corrective Action',
        'Preventive Action'
      ];

  List<CenterDetails> issueCenterList = [];

  List<IssueDepartment> issueDepartmentList = [];

  List<IssueTypeDetails> issueTypeList = [];

  // List<dynamic> getUserDetailsList = [];

  LoadReAssignStaffists? statusValueByEmployeeList;

  late List<LoadReAssignStaffists> employeeListAcknowledgedBy = [];

  Map<String, dynamic> getUserDetailsMap = {};

  late AddService client;

  late AddService departmentSelectedValue;

  late Future<bool> dataLoaded;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    dataLoaded = _getData();
    super.initState();
  }

  @override
  void dispose() {
    ddSearchController.dispose();
    super.dispose();
  }

  List<LoadDailyExpenseDetail> cardExpenseItems = [];

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CREATE NEW TICKET",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: 'Segoe',
            fontWeight: FontWeight.normal,
          ),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
        toolbarHeight: mediaQuery.size.height * 0.08,
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, false); // This will pop the current route
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: FutureBuilder<bool>(
            future: dataLoaded,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const LoadingOverlay(
                  showBackrop: false,
                );
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      DropdownButtonFormField2<CenterDetails>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          isDense: true,
                          fillColor: Color(0XFFF9F9F9),
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                          hintText: 'Search Center...',
                          hintStyle: TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1.3, color: Color(0XFFBEDCF0)),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1.3, color: Color(0XFFBEDCF0)),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1.3, color: Color(0XFFBEDCF0)),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1.3, color: Color(0XFFBEDCF0)),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1.3, color: Color(0XFFBEDCF0)),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1.3, color: Color(0XFFBEDCF0)),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        hint: const Text("Select Center"),
                        style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            fontFamily: 'Segoe',
                            fontWeight: FontWeight.normal),

                        onChanged: (value) => {
                          setState(() {
                            centerStatusValue = value!;
                            _formKey.currentState!.validate();
                          }),
                        },
                        value: centerStatusValue,
                        validator: (value) {
                          if (value == null) {
                            return '* Select Center';
                          }
                          return null;
                        },
                        items: issueCenterList
                            .map<DropdownMenuItem<CenterDetails>>(
                                (CenterDetails value) {
                          return DropdownMenuItem<CenterDetails>(
                            value: value,
                            child: Text(value.centerName),
                          );
                        }).toList(),

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
                            border: Border.all(color: Colors.grey),
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
                            height: 56,
                            padding: const EdgeInsets.all(8),
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
                            return item.value!.centerName
                                    .toLowerCase()
                                    .contains(searchValue.toLowerCase()) ||
                                item.value!.centerCode
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
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0XFFF9F9F9),
                          border: Border.all(
                              width: 1.3, color: const Color(0XFFBEDCF0)),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: TextField(
                          controller: designationTFController,
                          enabled: true,
                          readOnly: true,
                          style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontFamily: 'Segoe',
                              fontWeight: FontWeight.normal),
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0XFFF9F9F9),
                                border: Border.all(
                                    width: 1.3, color: const Color(0XFFBEDCF0)),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              // height: 50,
                              child: TextField(
                                controller: usernameTFController,
                                enabled: true,
                                readOnly: true,
                                style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontFamily: 'Segoe',
                                    fontWeight: FontWeight.normal),
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4)),
                              ),
                            ),
                          ),
                          const SizedBox(
                              width:
                                  10), // Adjust the spacing between text fields
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0XFFF9F9F9),
                                border: Border.all(
                                    width: 1.3, color: const Color(0XFFBEDCF0)),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: TextField(
                                controller: contactNoTFController,
                                enabled: true,
                                readOnly: true,
                                style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontFamily: 'Segoe',
                                    fontWeight: FontWeight.normal),
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
                                  counterText: "",
                                  errorStyle: const TextStyle(height: 0),
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
                                // decoration: InputDecoration(
                                //     border: InputBorder.none,
                                //     contentPadding: const EdgeInsets.symmetric(
                                //         horizontal: 8, vertical: 4)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField2<String>(
                              isExpanded: true,
                              decoration: const InputDecoration(
                                isDense: true,
                                fillColor: const Color(0XFFF9F9F9),
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                                hintText: 'Search Ticket Category...',
                                hintStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontFamily: 'Segoe',
                                    fontWeight: FontWeight.normal),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              hint: const Text("Ticket Category"),
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontFamily: 'Segoe',
                                  fontWeight: FontWeight.normal),
                              onChanged: (value) => {
                                setState(() {
                                  ticketCategory = value!;
                                  _formKey.currentState!.validate();
                                }),
                              },
                              value: ticketCategory,
                              validator: (value) {
                                if (value == null) {
                                  return '* Select Ticket Category';
                                }
                                return null;
                              },
                              items: ticketList.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              iconStyleData: IconStyleData(
                                icon: Image.asset("assets/dropdown.png",
                                    color: const Color(0XFF5D5D5D),
                                    width: 14,
                                    height: 14),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 350,
                                offset: const Offset(0, -4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  //background color of dropdown button//border of dropdown button
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(
                                      10), //border raiuds of dropdown button
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField2<IssueDepartment>(
                              decoration: const InputDecoration(
                                isDense: true,
                                fillColor: const Color(0XFFF9F9F9),
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                                hintText: 'Search Department...',
                                hintStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontFamily: 'Segoe',
                                    fontWeight: FontWeight.normal),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              isExpanded: true,
                              hint: const Text("Department"),
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontFamily: 'Segoe',
                                  fontWeight: FontWeight.normal),

                              onChanged: (value) {
                                setState(() {
                                  issueType = null;
                                  issueTypeList.clear();
                                  loadDepStatusValue = value!;
                                  _formKey.currentState!.validate();
                                });
                                _getIssueTypeList();
                              },
                              value: loadDepStatusValue,
                              validator: (value) {
                                if (value == null) {
                                  return '* Select Department';
                                }
                                return null;
                              },
                              items: issueDepartmentList
                                  .map<DropdownMenuItem<IssueDepartment>>(
                                      (IssueDepartment value) {
                                return DropdownMenuItem<IssueDepartment>(
                                  value: value,
                                  child: Text(value.item_Type!),
                                );
                              }).toList(),
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
                                  border: Border.all(color: Colors.grey),
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
                                  height: 56,
                                  padding: const EdgeInsets.all(8),
                                  child: TextFormField(
                                    expands: true,
                                    maxLines: null,
                                    controller: ddSearchController,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      fillColor: const Color(0XFFF9F9F9),
                                      filled: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      hintText: 'Search Department...',
                                      hintStyle: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                          fontFamily: 'Segoe',
                                          fontWeight: FontWeight.normal),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                searchMatchFn: (item, searchValue) {
                                  return item.value!.item_Type!
                                          .toLowerCase()
                                          .contains(
                                              searchValue.toLowerCase()) ||
                                      item.value!.item_Description!
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
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField2<IssueTypeDetails>(
                              decoration: const InputDecoration(
                                isDense: true,
                                fillColor: const Color(0XFFF9F9F9),
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                                hintText: 'Search Issue Type...',
                                hintStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontFamily: 'Segoe',
                                    fontWeight: FontWeight.normal),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              isExpanded: true,
                              hint: const Text("Issue Type"),
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontFamily: 'Segoe',
                                  fontWeight: FontWeight.normal),

                              onChanged: (value) => {
                                setState(() {
                                  issueType = value!;
                                  _formKey.currentState!.validate();
                                }),
                              },
                              value: issueType,
                              validator: (value) {
                                if (issueTypeList.isNotEmpty && value == null) {
                                  return '* Select Issue Tye';
                                }
                                return null;
                              },
                              items: issueTypeList
                                  .map<DropdownMenuItem<IssueTypeDetails>>(
                                      (IssueTypeDetails value) {
                                return DropdownMenuItem<IssueTypeDetails>(
                                  value: value,
                                  child: Text(value.itemDescription!),
                                );
                              }).toList(),
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
                                  border: Border.all(color: Colors.grey),
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
                                  height: 56,
                                  padding: const EdgeInsets.all(8),
                                  child: TextFormField(
                                    expands: true,
                                    maxLines: null,
                                    controller: ddSearchController,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      fillColor: const Color(0XFFF9F9F9),
                                      filled: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      hintText: 'Search Issue Type...',
                                      hintStyle: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                          fontFamily: 'Segoe',
                                          fontWeight: FontWeight.normal),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                searchMatchFn: (item, searchValue) {
                                  return item.value!.itemDescription!
                                          .toLowerCase()
                                          .contains(
                                              searchValue.toLowerCase()) ||
                                      item.value!.itemType!
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
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField2<String>(
                              decoration: const InputDecoration(
                                isDense: true,
                                fillColor: const Color(0XFFF9F9F9),
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                                hintText: 'Search Priority...',
                                hintStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontFamily: 'Segoe',
                                    fontWeight: FontWeight.normal),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              isExpanded: true,
                              hint: const Text("Priority"),
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontFamily: 'Segoe',
                                  fontWeight: FontWeight.normal),
                              onChanged: (value) => {
                                setState(() {
                                  priority = value!;
                                  _formKey.currentState!.validate();
                                }),
                              },
                              value: priority,
                              validator: (value) {
                                if (value == null) {
                                  return '* Select Priority';
                                }
                                return null;
                              },
                              items: priorityList.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              iconStyleData: IconStyleData(
                                icon: Image.asset("assets/dropdown.png",
                                    color: const Color(0XFF5D5D5D),
                                    width: 14,
                                    height: 14),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 350,
                                offset: const Offset(0, -4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  //background color of dropdown button//border of dropdown button
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(
                                      10), //border raiuds of dropdown button
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Visibility(
                        visible: issueType?.itemType == 'PATIENT',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              onSubmitted: (value) {
                                patientName = value;
                              },
                              onChanged: (value) {
                                patientName = value;
                              },
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontFamily: 'Segoe',
                                  fontWeight: FontWeight.normal),
                              decoration: InputDecoration(
                                  hintText: 'Enter Patient Name',
                                  hintStyle: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontFamily: 'Segoe',
                                      fontWeight: FontWeight.normal),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4)),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: fromTFController,
                                    enabled: true,
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        firstDate: DateTime(1950),
                                        lastDate: DateTime(2150),
                                      );

                                      if (pickedDate != null) {
                                        fromDate = pickedDate;
                                        fromTFController.text =
                                            '${fromDate?.day}/${fromDate?.month}/${fromDate?.year}';
                                      }
                                    },
                                    style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                        fontFamily: 'Segoe',
                                        fontWeight: FontWeight.normal),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                      hintText: 'Patient Reg Date',
                                      hintStyle: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                          fontFamily: 'Segoe',
                                          fontWeight: FontWeight.normal),
                                      suffix: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6),
                                        child: SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: Image.asset(
                                            "assets/ic_calender.png",
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    onSubmitted: (value) {
                                      prnNo = value;
                                    },
                                    onChanged: (value) {
                                      prnNo = value;
                                    },
                                    style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                        fontFamily: 'Segoe',
                                        fontWeight: FontWeight.normal),
                                    decoration: InputDecoration(
                                        hintText: 'Patient PRN No.',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.grey),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        onChanged: (value) {
                          ticketDescription = value;
                          _formKey.currentState!.validate();
                        },
                        minLines: 3,
                        maxLines: 3,
                        style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            fontFamily: 'Segoe',
                            fontWeight: FontWeight.normal),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '* Enter Ticket Description';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Ticket Description',
                          filled: true,
                          fillColor: const Color(0XFFF9F9F9),
                          errorText: errorTicketDescription,
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
                          counterText: "",
                          errorStyle: const TextStyle(height: 0),
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
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField2<String>(
                              decoration: const InputDecoration(
                                isDense: true,
                                fillColor: const Color(0XFFF9F9F9),
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                                hintText: 'Search Ticket Status...',
                                hintStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontFamily: 'Segoe',
                                    fontWeight: FontWeight.normal),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              isExpanded: true,
                              hint: const Text("Ticket Status"),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'Segoe',
                                  fontWeight: FontWeight.normal),
                              onChanged: null,
                              value: 'New',
                              items: [
                                'New'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              iconStyleData: IconStyleData(
                                icon: Image.asset("assets/dropdown.png",
                                    color: const Color(0XFF5D5D5D),
                                    width: 14,
                                    height: 14),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 350,
                                offset: const Offset(0, -4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  //background color of dropdown button//border of dropdown button
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(
                                      10), //border raiuds of dropdown button
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField2<String>(
                              decoration: const InputDecoration(
                                isDense: true,
                                fillColor: const Color(0XFFF9F9F9),
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                                hintText: 'Search Action Taken...',
                                hintStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontFamily: 'Segoe',
                                    fontWeight: FontWeight.normal),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              isExpanded: true,
                              hint: const Text("Action Taken"),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'Segoe',
                                  fontWeight: FontWeight.normal),

                              onChanged: (value) => {
                                setState(() {
                                  actionTaken = value!;
                                  _formKey.currentState!.validate();
                                }),
                              },
                              value: actionTaken,
                              validator: (value) {
                                if (value == null) {
                                  return '* Select Action Taken';
                                }
                                return null;
                              },
                              items: actionTakenList
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
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
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(
                                      10), //border raiuds of dropdown button
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                              ),
                              //This to clear the search value when you close the menu
                              onMenuStateChange: (isOpen) {
                                if (!isOpen) {
                                  ddSearchController.clear();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField2<String>(
                              decoration: const InputDecoration(
                                isDense: true,
                                fillColor: const Color(0XFFF9F9F9),
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                                hintStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontFamily: 'Segoe',
                                    fontWeight: FontWeight.normal),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1.3, color: Color(0XFFBEDCF0)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              isExpanded: true,
                              hint: const Text("Is Approval Needed?"),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'Segoe',
                                  fontWeight: FontWeight.normal),
                              onChanged: (value) => {
                                setState(() {
                                  isApprovalNeeded = value!;
                                  statusValueByEmployeeList = null;
                                  employeeListAcknowledgedBy.clear();
                                  _formKey.currentState!.validate();
                                  if (value == "Yes") _getEmployeeList();
                                }),
                              },
                              value: isApprovalNeeded,
                              validator: (value) {
                                if (value == null) {
                                  return '* Select approval needed';
                                }
                                return null;
                              },
                              items: [
                                'Yes',
                                'No'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              iconStyleData: IconStyleData(
                                icon: Image.asset("assets/dropdown.png",
                                    color: const Color(0XFF5D5D5D),
                                    width: 14,
                                    height: 14),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 350,
                                offset: const Offset(0, -4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  //background color of dropdown button//border of dropdown button
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(
                                      10), //border raiuds of dropdown button
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Visibility(
                              visible:
                                  isApprovalNeeded?.contains('Yes') ?? false,
                              child: DropdownButtonFormField2<
                                  LoadReAssignStaffists>(
                                decoration: const InputDecoration(
                                  isDense: true,
                                  fillColor: const Color(0XFFF9F9F9),
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 12,
                                  ),
                                  hintText: 'Search Employee...',
                                  hintStyle: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontFamily: 'Segoe',
                                      fontWeight: FontWeight.normal),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1.3, color: Color(0XFFBEDCF0)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1.3, color: Color(0XFFBEDCF0)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1.3, color: Color(0XFFBEDCF0)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1.3, color: Color(0XFFBEDCF0)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1.3, color: Color(0XFFBEDCF0)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1.3, color: Color(0XFFBEDCF0)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                isExpanded: true,
                                hint: const Text("Select Employee"),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Segoe',
                                    fontWeight: FontWeight.normal),

                                onChanged: (value) => {
                                  setState(() {
                                    statusValueByEmployeeList = value!;
                                  }),
                                },
                                value: statusValueByEmployeeList,
                                validator: (value) {
                                  if (isApprovalNeeded == 'Yes' &&
                                      value == null) {
                                    return '* Select an employee';
                                  }
                                  return null;
                                },
                                items: employeeListAcknowledgedBy.map<
                                        DropdownMenuItem<
                                            LoadReAssignStaffists>>(
                                    (LoadReAssignStaffists value) {
                                  return DropdownMenuItem<
                                      LoadReAssignStaffists>(
                                    value: value,
                                    child: Text(value.employeeName.toString()),
                                  );
                                }).toList(),
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
                                    border: Border.all(color: Colors.grey),
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
                                    height: 56,
                                    padding: const EdgeInsets.all(8),
                                    child: TextFormField(
                                      expands: true,
                                      maxLines: null,
                                      controller: ddSearchController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        fillColor: const Color(0XFFF9F9F9),
                                        filled: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        hintText: 'Search Employee...',
                                        hintStyle: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                            fontFamily: 'Segoe',
                                            fontWeight: FontWeight.normal),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  searchMatchFn: (item, searchValue) {
                                    return item.value!.employeeName!
                                            .toLowerCase()
                                            .contains(
                                                searchValue.toLowerCase()) ||
                                        item.value!.employeeName!
                                            .toLowerCase()
                                            .contains(
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
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
                                      uploadDoc =
                                          File(result.files.single.path!);
                                      setState(() {
                                        uploadDoc;
                                      });
                                    }
                                  },
                                );
                              },
                              child: Container(
                                // width: 150,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    colors: [
                                      // Color(0xff676C6EFF),
                                      // Color(0xff676C6EFF),
                                      Colors.grey,
                                      Colors.grey
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Upload Document",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: GradientButton(
                              onPressed: () {
                                _formKey.currentState!.validate();
                                addTicket();
                              },
                              label: 'Submit Ticket',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        uploadDoc?.path.split('/').last ?? '',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Future<bool> _getData() async {
    await _getUser();
    await _getCenters();
    await _getIssueDepartmentList();
    await _getUserDetailsForCreateTicket();

    return true;
  }

  Future<bool> _getEmployeeList() async {
    await fetchAcknowledgedByList();
    return true;
  }

  _getUser() async {
    userDao = Provider.of<DBProvider>(context, listen: false).dao;
    user = (await userDao.findAllPersons()).first;

    designationTFController.text = user.designation;

    usernameTFController.text = user.username ?? '';

    // usernameTFController.text = getUserDetailsMap['contactNumber'] ?? '';

    client = AddService(user);
  }

  _getCenters() async {
    if (user.usertype == "ZONALMANAGER" || user.usertype == "HEADOFFICE") {
      // issueCenterList.add(CenterDetails(centerName: 'All', centerCode: ''));
      issueCenterList.addAll(await client.getIssueCenterList());
    } else {
      issueCenterList.add(CenterDetails(
          centerName: user.username.split("(")[1].replaceFirst(")", "").trim(),
          centerCode: user.locationID));
      centerStatusValue = issueCenterList[0];
    }
    issueCenterList.sort((a, b) => a.centerName.compareTo(b.centerName));
  }

  _getIssueDepartmentList() async {
    issueDepartmentList = await client.getIssueDepartmentList();
    /*if (issueDepartmentList.first.departmentName == '') {
      issueDepartmentList.first.departmentName = 'All';
    }
    loadDepStatusValue = issueDepartmentList[0];*/
  }

  _getIssueTypeList() async {
    try {
      issueTypeList =
          await client.getIssueTypeList(loadDepStatusValue?.item_Type ?? '');
      setState(() {
        issueTypeList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "No Issue Tye found for ${loadDepStatusValue?.item_Description}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  _getUserDetailsForCreateTicket() async {
    getUserDetailsMap = await client.getUserDetailsForCreateTicket();
    contactNoTFController.text = getUserDetailsMap['contactNumber'];
  }

  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      uploadDoc = File(pickedFile.path);
      List<String> filePathList = (uploadDoc!.path).split('/');
      String fileName = filePathList.last;
      fileName = 'my_photo.${fileName.split('.').last}';
      filePathList.last = fileName;

      uploadDoc = await uploadDoc!.rename(filePathList.join('/'));
      setState(() {
        uploadDoc;
      });
    }
  }

  //commentedAddTicket
  addTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      String path = 'ticketMaster/addTicket';

      Map<String, String> filePathMap = {};
      if (uploadDoc != null) {
        filePathMap['file'] = uploadDoc!.path;
      }

      ApiMultipartRequest multipartClient = ApiMultipartRequest();

      Navigator.of(context).overlay?.insert(overlayEntry);

      Response<Map<String, dynamic>?> response =
          await multipartClient.sendRequest(
        path,
        filePathMap: filePathMap,
        fieldValueMap: {
          'authKey': StringConstants.AUTHKEY,
          'OwnerId': centerStatusValue?.centerCode ?? '',
          'Center': centerStatusValue?.centerCode ?? '',
          'IssueReportedBy': user.designation ?? '',
          'Name': user.username ?? '',
          'ContactNo': getUserDetailsMap['contactNumber'] ?? '',
          'Category': ticketCategory ?? '',
          'Department': loadDepStatusValue?.item_Type ?? '',
          'IssueType': issueType?.itemDescription ?? '',
          'PatientName': patientName ?? '',
          'PatientRegDate': fromDate?.toString() ?? '',
          'PatientPRNNo': prnNo ?? '',
          'TicketDescriptions': ticketDescription ?? '',
          'userId': user.userid ?? '',
          'PriorityTicket': priority ?? '',
          'IsApprovalNeeded': (isApprovalNeeded ?? '') == "Yes" ? "1" : "0",
          'ApproverId': statusValueByEmployeeList?.employeeId ?? '' ?? "",
        },
      );

      overlayEntry.remove();
      if (!mounted) return;

      if (response.data?['lisResult'] == "True") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket Added Successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data?['lisMessage'] ?? ''),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on DioException catch (e) {
      if (overlayEntry.mounted) overlayEntry.remove();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? ''),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (overlayEntry.mounted) overlayEntry.remove();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchAcknowledgedByList() async {
    try {
      Navigator.of(context).overlay?.insert(overlayEntry);
      final response = await http.post(
          Uri.parse('${StringConstants.BASE_URL}ticketMaster/EmployeeList'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {'authKey': StringConstants.AUTHKEY, 'userId': user.userid}));
      if (response.statusCode == 200) {
        final responseDataLocation = json.decode(response.body);
        final lisResultLocation = responseDataLocation['lisResult'].toString();
        if (lisResultLocation == 'True') {
          final List<dynamic> locationData =
              responseDataLocation['load_ReAssign_Staffists'];
          setState(() {
            employeeListAcknowledgedBy.addAll(locationData.map((data) {
              return LoadReAssignStaffists.fromJson(data);
            }));
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Employee List Not Available'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      overlayEntry.remove();
      if (!mounted) return;
    } catch (e) {
      if (overlayEntry.mounted) overlayEntry.remove();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Future<void> addTicket() async {
//   try {
//     String apiUrl =
//         'https://services.techjivaaindia.in/limsapi/ticketMaster/addTicket';
//
//     // Populate your form data
//     Map<String, String> formData = {
//       'authKey': StringConstants.AUTHKEY,
//       'OwnerId': centerStatusValue?.centerCode ?? '',
//       'Center': centerStatusValue?.centerCode ?? '',
//       'IssueReportedBy': user.designation ?? '',
//       'Name': user.username ?? '',
//       'ContactNo': getUserDetailsMap['contactNumber'] ?? '',
//       'Category': ticketCategory ?? '',
//       'Department': loadDepStatusValue?.departmentName ?? '',
//       'IssueType': issueType?.itemDescription ?? '',
//       'PatientName': patientName ?? '',
//       'PatientRegDate': fromDate.toString() ?? '',
//       'PatientPRNNo': prnNo ?? '',
//       'TicketDescriptions': ticketDescription ?? '',
//       'userId': user.userid ?? '',
//       'PriorityTicket': priority ?? '',
//       'IsApprovalNeeded': isApprovalNeeded ?? '',
//       'ApproverId': statusValueByEmployeeList.employeeId ?? '',
//     };
//
//     // Create a MultipartRequest
//     var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
//
//     // Add form data to the request
//     formData.forEach((key, value) {
//       request.fields[key] = value;
//     });
//
//     // Add file to the request if applicable
//     if (uploadDoc != null) {
//       request.files
//           .add(await http.MultipartFile.fromPath('file', uploadDoc!.path));
//     }
//
//     // Send the request
//     var response = await request.send();
//
//     // Decode and print the response
//     String responseBody = await response.stream.bytesToString();
//     print(responseBody);
//
//     // Handle response as needed
//     if (response.statusCode == 200) {
//       // Successful response, handle accordingly
//     } else {
//       // Handle error response
//       print('Error: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error: $e');
//     // Handle general error
//   }
// }
}
