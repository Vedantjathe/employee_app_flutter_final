import 'dart:async';
import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:erp/custom_widgets/loading_overlay.dart';
import 'package:erp/custom_widgets/required_permission_layout.dart';
import 'package:erp/logger.dart';
import 'package:erp/models/TicketDepartmentModel.dart';
import 'package:erp/services/erp_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../controller/dbProvider.dart';
import '../custom_widgets/error_page.dart';
import '../custom_widgets/ticket_card_widget.dart';
import '../db/UserDao.dart';
import '../models/AccountTypeModel.dart';
import '../models/CenterListModel.dart';
import '../models/CenterModel.dart';
import '../models/CreatedByModel.dart';
import '../models/EmployeeListModel.dart';
import '../models/IssueTypeModel.dart';
import '../models/TicketMasterDataModel.dart';
import '../models/User.dart';
import '../models/individualExpenseModel.dart';
import '../utils/ConnectivityUtils.dart';
import '../utils/StringConstants.dart';
import '../utils/util_methods.dart';
import 'AddNewTicketPage.dart';

class TicketPage extends StatefulWidget {
  final User user;
  const TicketPage({Key? key, required this.user}) : super(key: key);

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  CenterModel? location;
  List<CenterModel> locationList = List.empty(growable: true);
  // TextEditingController consignmentIDController = TextEditingController();
  TextEditingController centerController = TextEditingController();

  List<String> ticketStatusItems = [
    'ALL',
    'NEW',
    'Acknowleged',
    'In Process',
    'Hold',
    'Rejected',
    'Solved',
    'Closed'
  ];
  String? ticketStatusValue = "ALL";

  List<String> priorityStatusItems = [
    'ALL',
    'REGULAR',
    'MEDIUM',
    'HIGH',
  ];
  String priorityStatusValue = "ALL";

  List<String> centerList = ['ALL', 'DISPATCHED', 'RECEIVED'];
  String? centerValue;

  List<String> reAssignedStatusItems = ['-', 'OTHERS', 'ONLY ME']; //CHECK ERROR
  String reAssignedStatusValue = '-';

  // DateTime fromDate = DateTime.now();
  // DateTime toDate = DateTime.now();

  CenterDetails centerDetailsValue =
      CenterDetails(centerName: 'ALL', centerCode: '');

  late List<CenterDetails> centerLocationLists = [centerDetailsValue];

  LoadDepartmentDetails? statusValueDep;

  late List<LoadDepartmentDetails> departmentList = [];

  CreatedByList statusValueCreatedBy =
      CreatedByList(employeeId: '', employeeName: 'ALL');

  late List<CreatedByList> createdByList2 = [statusValueCreatedBy];

  IssueTypeDetails statusValueByTicketType =
      IssueTypeDetails(itemDescription: 'ALL', itemType: 'ALL');

  late List<IssueTypeDetails> ticketTypeList = [statusValueByTicketType];

  LoadReAssignStaffists statusValueByEmployeeList =
      LoadReAssignStaffists(employeeId: '', employeeName: 'ALL');

  late List<LoadReAssignStaffists> employeeListAcknowledgedBy = [
    statusValueByEmployeeList
  ];

  List<String> accountTypeList = List.empty(growable: true);

  List<ExpenseDetail>? cardExpenseItems = List.empty(growable: true);

  List<String> statusItemsNew2 = ['dfdfkng', 'rgdfpppe', 'gbgbb'];
  AccountItem? statusValueNew2;

//listviewapidata

  List<TicketMasterData> ticketPageList = List.empty();

  //usingthisone
  List<TicketMasterData> ticketCardItems = List.empty(growable: true);

  late final UserDao userDao;
  User? user;

  TicketMasterData? tikData;
  late final Future<bool> pagePermissionFuture;

  String fromDate = "";
  String toDate = "";

  Future<List<ExpenseDetail>>? futureLedgerCardData;
  late Future<List<TicketMasterData>> cardListFuture;

  List dataMap = [];

  @override
  void initState() {
    userDao = Provider.of<DBProvider>(context, listen: false).dao;
    user = widget.user;
    fromDate = DateFormat("dd MMM yyyy").format(DateTime.now());
    toDate = DateFormat("dd MMM yyyy").format(DateTime.now());
    pagePermissionFuture = userPagePermission();
    super.initState();
    cardListFuture = fetchTicketCardData();
    _getData();
  }

  final TextEditingController ddSearchController = TextEditingController();

  @override
  void dispose() {
    ddSearchController.dispose();
    super.dispose();
  }

// List<TicketMasterData> ticketItems = [];

  List<TicketMasterData> ticketItems = List.empty(growable: true);
  List<TicketMasterData> searchTicketItems = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    var _mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Image.asset(
              'assets/excel.png',
              height: 32,
              fit: BoxFit.fitHeight,
            ),
            onPressed: () async {
              if (dataMap.isEmpty) {
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
              for (var jsonObject in dataMap) {
                Map<String, dynamic> dataTwo =
                    Map<String, dynamic>.from(jsonObject);

                dataTwo.update(
                    "commentdate",
                    (value) => DateFormat("dd-MM-yyyy HH:mm:ss").format(
                        DateFormat("M/d/yyyy h:mm:ss a")
                            .parse(dataTwo["commentdate"].toString())));
                labDetailsS.add(dataTwo);
              }

              bool result =
                  await exportExcel(labDetailsS, 'TicketMaster.xlsx', null);
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
        ],
        toolbarHeight: _mediaQuery.size.height * 0.08,
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          "TICKET",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: 'Segoe',
            fontWeight: FontWeight.normal,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            // borderRadius: BorderRadius.only(
            //   bottomLeft: Radius.circular(25),
            //   bottomRight: Radius.circular(25),
            // ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xff3A9FBE),
                Color(0xff17E1DA),
              ],
              // colors: <Color> [Color.fromARGB(100, 58, 169, 190),
              //   Color.fromARGB(100, 23, 225,218),
              // ],
            ),
          ),
        ),
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

              return FutureBuilder(
                  future: cardListFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const LoadingOverlay();
                    }
                    if (snapshot.hasError) {
                      // snapshot.error.
                      logger.e(snapshot.error);
                      return const Center(child: Text('Error'));
                    }

                    if (snapshot.hasData) {
                      ticketCardItems = snapshot.data ?? [];
                    }
                    return Padding(
                      padding: const EdgeInsets.all(4),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Search Ticket',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      // controller: consignmentIDController,
                                      decoration: kTFFDecoration.copyWith(
                                        hintText: 'Search Ticket',
                                      ),
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          searchTicketItems = ticketItems;
                                        } else {
                                          searchTicketItems = ticketItems
                                              .where((it) => (it.TicketID.toLowerCase().contains(
                                                      value.toLowerCase()) ||
                                                  it.Location_Name.toLowerCase()
                                                      .contains(value
                                                          .toLowerCase()) ||
                                                  it.TicketType.toLowerCase()
                                                      .contains(value
                                                          .toLowerCase()) ||
                                                  it.TicketStatus.toLowerCase()
                                                      .contains(value
                                                          .toLowerCase()) ||
                                                  it.CreatedBy.toLowerCase().contains(
                                                      value.toLowerCase()) ||
                                                  it.RaisedPersonContactNo.toLowerCase()
                                                      .contains(value.toLowerCase())))
                                              .toList();
                                        }
                                        setState(() {
                                          searchTicketItems;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'From Date',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
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
                                              cardListFuture =
                                                  fetchTicketCardData();
                                            });
                                            //Dialogs.showLoadingDialog(context);
                                            //getRevenue();
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                fromDate,
                                                style: const TextStyle(
                                                    color: Colors.black54,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontFamily: 'Segoe',
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              const SizedBox(width: 10),
                                              Image.asset(
                                                  "assets/ic_calender.png",
                                                  color:
                                                      const Color(0XFF5D5D5D),
                                                  width: 16,
                                                  height: 16),
                                            ],
                                          )),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Department',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton2<
                                          LoadDepartmentDetails>(
                                        isExpanded: true,
                                        hint: const Text("Select Center"),
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            overflow: TextOverflow.ellipsis,
                                            fontFamily: 'Segoe',
                                            fontWeight: FontWeight.normal),
                                        onChanged: (value) {
                                          {
                                            setState(() {
                                              statusValueDep = value!;
                                              cardListFuture =
                                                  fetchTicketCardData();
                                            });
                                          }
                                        },
                                        value: statusValueDep,
                                        items: departmentList.map<
                                                DropdownMenuItem<
                                                    LoadDepartmentDetails>>(
                                            (LoadDepartmentDetails value) {
                                          return DropdownMenuItem<
                                              LoadDepartmentDetails>(
                                            value: value,
                                            child: Text(
                                                value.departmentName!.isEmpty
                                                    ? 'ALL'
                                                    : value.departmentName!),
                                          );
                                        }).toList(),

                                        buttonStyleData: ButtonStyleData(
                                          padding:
                                              const EdgeInsets.only(right: 16),
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: const Color(0XFFF9F9F9),
                                            border: Border.all(
                                                width: 1.3,
                                                color: const Color(0XFFBEDCF0)),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                          ),
                                        ),
                                        iconStyleData: IconStyleData(
                                          icon: Image.asset(
                                              "assets/dropdown.png",
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
                                        menuItemStyleData:
                                            const MenuItemStyleData(
                                          height: 40,
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
                                              decoration:
                                                  kTFFDecoration.copyWith(
                                                hintText:
                                                    'Search for Department...',
                                                hintStyle: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                    fontFamily: 'Segoe',
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ),
                                          ),
                                          searchMatchFn: (item, searchValue) {
                                            return item.value!.departmentName!
                                                    .toLowerCase()
                                                    .contains(searchValue
                                                        .toLowerCase()) ||
                                                item.value!.departmentId!
                                                    .toLowerCase()
                                                    .contains(searchValue
                                                        .toLowerCase());
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
                                )),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Center',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton2<CenterDetails>(
                                        isExpanded: true,
                                        hint: const Text("Select Center"),
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            overflow: TextOverflow.ellipsis,
                                            fontFamily: 'Segoe',
                                            fontWeight: FontWeight.normal),
                                        onChanged: (value) {
                                          setState(() {
                                            centerDetailsValue = value!;
                                            cardListFuture =
                                                fetchTicketCardData();
                                          });
                                        },
                                        value: centerDetailsValue,
                                        items: centerLocationLists.map<
                                                DropdownMenuItem<
                                                    CenterDetails>>(
                                            (CenterDetails value) {
                                          return DropdownMenuItem<
                                              CenterDetails>(
                                            value: value,
                                            child: Text(value.centerName),
                                          );
                                        }).toList(),

                                        buttonStyleData: ButtonStyleData(
                                          padding:
                                              const EdgeInsets.only(right: 16),
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: const Color(0XFFF9F9F9),
                                            border: Border.all(
                                                width: 1.3,
                                                color: const Color(0XFFBEDCF0)),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                          ),
                                        ),
                                        iconStyleData: IconStyleData(
                                          icon: Image.asset(
                                              "assets/dropdown.png",
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
                                        menuItemStyleData:
                                            const MenuItemStyleData(
                                          height: 40,
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
                                              decoration:
                                                  kTFFDecoration.copyWith(
                                                hintText: 'Search Center...',
                                                hintStyle: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                    fontFamily: 'Segoe',
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ),
                                          ),
                                          searchMatchFn: (item, searchValue) {
                                            return item.value!.centerName
                                                    .toLowerCase()
                                                    .contains(searchValue
                                                        .toLowerCase()) ||
                                                item.value!.centerCode
                                                    .toLowerCase()
                                                    .contains(searchValue
                                                        .toLowerCase());
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
                                    const SizedBox(height: 8),
                                    const Text(
                                      'To Date',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
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
                                              cardListFuture =
                                                  fetchTicketCardData();
                                            });
                                            // Dialogs.showLoadingDialog(context);
                                            //getRevenue();
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                toDate,
                                                style: const TextStyle(
                                                    color: Colors.black54,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontFamily: 'Segoe',
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              const SizedBox(width: 10),
                                              Image.asset(
                                                  "assets/ic_calender.png",
                                                  color:
                                                      const Color(0XFF5D5D5D),
                                                  width: 16,
                                                  height: 16),
                                            ],
                                          )),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Created By',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton2<CreatedByList>(
                                        isExpanded: true,
                                        hint: const Text("Select Center"),
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            overflow: TextOverflow.ellipsis,
                                            fontFamily: 'Segoe',
                                            fontWeight: FontWeight.normal),
                                        onChanged: (value) {
                                          setState(() {
                                            statusValueCreatedBy = value!;
                                            cardListFuture =
                                                fetchTicketCardData();
                                          });
                                        },
                                        value: statusValueCreatedBy,
                                        items: createdByList2.map<
                                                DropdownMenuItem<
                                                    CreatedByList>>(
                                            (CreatedByList value) {
                                          return DropdownMenuItem<
                                              CreatedByList>(
                                            value: value,
                                            child: Text(
                                                value.employeeName.toString()),
                                          );
                                        }).toList(),

                                        buttonStyleData: ButtonStyleData(
                                          padding:
                                              const EdgeInsets.only(right: 16),
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: const Color(0XFFF9F9F9),
                                            border: Border.all(
                                                width: 1.3,
                                                color: const Color(0XFFBEDCF0)),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                          ),
                                        ),
                                        iconStyleData: IconStyleData(
                                          icon: Image.asset(
                                              "assets/dropdown.png",
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
                                        menuItemStyleData:
                                            const MenuItemStyleData(
                                          height: 40,
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
                                              decoration:
                                                  kTFFDecoration.copyWith(
                                                hintText:
                                                    'Search Created By...',
                                                hintStyle: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                    fontFamily: 'Segoe',
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ),
                                          ),
                                          searchMatchFn: (item, searchValue) {
                                            return item.value!.employeeName!
                                                    .toLowerCase()
                                                    .contains(searchValue
                                                        .toLowerCase()) ||
                                                item.value!.employeeId!
                                                    .toLowerCase()
                                                    .contains(searchValue
                                                        .toLowerCase());
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
                                )),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ticket Status',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0XFFF9F9F9),
                                          border: Border.all(
                                              width: 1.3,
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
                                                width: 10,
                                                height: 10),
                                            iconSize: 24,
                                            elevation: 16,
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16,
                                                fontFamily: 'Segoe',
                                                fontWeight: FontWeight.normal),
                                            onChanged: (value) {
                                              setState(() {
                                                ticketStatusValue = value!;
                                                cardListFuture =
                                                    fetchTicketCardData();
                                              });
                                            },
                                            value: ticketStatusValue,
                                            hint: const Text("Select"),
                                            items: ticketStatusItems
                                                .map(
                                                    (value) => DropdownMenuItem(
                                                        value: value,
                                                        child: Text(
                                                          value,
                                                          maxLines: 5,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        )))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ticket Type',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      DropdownButtonHideUnderline(
                                        child:
                                            DropdownButton2<IssueTypeDetails>(
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
                                              statusValueByTicketType = value!;
                                            })
                                          },
                                          value: statusValueByTicketType,
                                          items: ticketTypeList.map<
                                                  DropdownMenuItem<
                                                      IssueTypeDetails>>(
                                              (IssueTypeDetails value) {
                                            return DropdownMenuItem<
                                                IssueTypeDetails>(
                                              value: value,
                                              child: Text(value.itemDescription
                                                  .toString()),
                                            );
                                          }).toList(),

                                          buttonStyleData: ButtonStyleData(
                                            padding: const EdgeInsets.only(
                                                right: 16),
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: const Color(0XFFF9F9F9),
                                              border: Border.all(
                                                  width: 1.3,
                                                  color:
                                                      const Color(0XFFBEDCF0)),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                            ),
                                          ),
                                          iconStyleData: IconStyleData(
                                            icon: Image.asset(
                                                "assets/dropdown.png",
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
                                                  color:
                                                      const Color(0xFFC0C0C0)),
                                              borderRadius: BorderRadius.circular(
                                                  10), //border raiuds of dropdown button
                                            ),
                                          ),
                                          menuItemStyleData:
                                              const MenuItemStyleData(
                                            height: 40,
                                          ),
                                          dropdownSearchData:
                                              DropdownSearchData(
                                            searchController:
                                                ddSearchController,
                                            searchInnerWidgetHeight: 50,
                                            searchInnerWidget: Container(
                                              height: 40,
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
                                                decoration:
                                                    kTFFDecoration.copyWith(
                                                  hintText:
                                                      'Search Created By...',
                                                  hintStyle: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 14,
                                                      fontFamily: 'Segoe',
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ),
                                            ),
                                            searchMatchFn: (item, searchValue) {
                                              return item
                                                      .value!.itemDescription!
                                                      .toLowerCase()
                                                      .contains(searchValue
                                                          .toLowerCase()) ||
                                                  item.value!.itemType!
                                                      .toLowerCase()
                                                      .contains(searchValue
                                                          .toLowerCase());
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
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Re Assigned',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0XFFF9F9F9),
                                          border: Border.all(
                                              width: 1.3,
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
                                                width: 10,
                                                height: 10),
                                            iconSize: 24,
                                            elevation: 16,
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16,
                                                fontFamily: 'Segoe',
                                                fontWeight: FontWeight.normal),
                                            onChanged: (value) {
                                              setState(() {
                                                reAssignedStatusValue = value!;
                                                cardListFuture =
                                                    fetchTicketCardData();
                                              });
                                            },
                                            value: reAssignedStatusValue,
                                            hint: const Text("Select"),
                                            items: reAssignedStatusItems
                                                .map(
                                                    (value) => DropdownMenuItem(
                                                        value: value,
                                                        child: Text(
                                                          value,
                                                          maxLines: 5,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        )))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Priority',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0XFFF9F9F9),
                                          border: Border.all(
                                              width: 1.3,
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
                                                width: 10,
                                                height: 10),
                                            iconSize: 24,
                                            elevation: 16,
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16,
                                                fontFamily: 'Segoe',
                                                fontWeight: FontWeight.normal),
                                            onChanged: (value) {
                                              setState(() {
                                                priorityStatusValue = value!;
                                                cardListFuture =
                                                    fetchTicketCardData();
                                              });
                                            },
                                            value: priorityStatusValue,
                                            hint: const Text("Select"),
                                            items: priorityStatusItems
                                                .map(
                                                    (value) => DropdownMenuItem(
                                                        value: value,
                                                        child: Text(
                                                          value,
                                                          maxLines: 5,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        )))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Acknowledged By',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton2<
                                            LoadReAssignStaffists>(
                                          isExpanded: true,
                                          hint: const Text("Select Center"),
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: 'Segoe',
                                              fontWeight: FontWeight.normal),
                                          onChanged: (value) {
                                            setState(() {
                                              statusValueByEmployeeList =
                                                  value!;
                                              cardListFuture =
                                                  fetchTicketCardData();
                                            });
                                          },
                                          value: statusValueByEmployeeList,
                                          items: employeeListAcknowledgedBy.map<
                                                  DropdownMenuItem<
                                                      LoadReAssignStaffists>>(
                                              (LoadReAssignStaffists value) {
                                            return DropdownMenuItem<
                                                LoadReAssignStaffists>(
                                              value: value,
                                              child: Text(value.employeeName
                                                  .toString()),
                                            );
                                          }).toList(),

                                          buttonStyleData: ButtonStyleData(
                                            padding: const EdgeInsets.only(
                                                right: 16),
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: const Color(0XFFF9F9F9),
                                              border: Border.all(
                                                  width: 1.3,
                                                  color:
                                                      const Color(0XFFBEDCF0)),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                            ),
                                          ),
                                          iconStyleData: IconStyleData(
                                            icon: Image.asset(
                                                "assets/dropdown.png",
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
                                                  color:
                                                      const Color(0xFFC0C0C0)),
                                              borderRadius: BorderRadius.circular(
                                                  10), //border raiuds of dropdown button
                                            ),
                                          ),
                                          menuItemStyleData:
                                              const MenuItemStyleData(
                                            height: 40,
                                          ),
                                          dropdownSearchData:
                                              DropdownSearchData(
                                            searchController:
                                                ddSearchController,
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
                                                decoration:
                                                    kTFFDecoration.copyWith(
                                                  hintText:
                                                      'Search Acknowledged By...',
                                                  hintStyle: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 14,
                                                      fontFamily: 'Segoe',
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ),
                                            ),
                                            searchMatchFn: (item, searchValue) {
                                              return item.value!.employeeName!
                                                      .toLowerCase()
                                                      .contains(searchValue
                                                          .toLowerCase()) ||
                                                  item.value!.employeeId!
                                                      .toLowerCase()
                                                      .contains(searchValue
                                                          .toLowerCase());
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            FutureBuilder<List<TicketMasterData>>(
                                future: cardListFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState !=
                                      ConnectionState.done) {
                                    return const LoadingOverlay(
                                        showBackrop: false);
                                  }
                                  if (snapshot.hasData) {
                                    return ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: searchTicketItems.length,
                                      itemBuilder: (context, index) {
                                        TicketMasterData tmData =
                                            searchTicketItems[index];
                                        return TicketCardWidget(tmData);
                                      },
                                    );
                                  }
                                  return const SizedBox();
                                }),
                          ],
                        ),
                      ),
                    );
                  });
            }
            return const LoadingOverlay();
          }),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 50),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [
                Color(0xff3A9FBE),
                Color(0xff17E1DA),
              ],
            ),
          ),
          height: 40,
          width: 160,
          child: FloatingActionButton(
            onPressed: () async {
              user = (await userDao.findAllPersons()).first;
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddNewTicketPage(
                          user: user!,
                        )),
              ).then(
                (value) => setState(() {
                  if (value) {
                    cardListFuture = fetchTicketCardData();
                  }
                }),
              );
            },
            backgroundColor: Colors.transparent,
            child: const Center(
                child: Text(
              "ADD NEW TICKET",
              style: TextStyle(
                color: Colors.white,
              ),
            )),
          ),
        ),
      ),
    );
  }

  Future<void> fetchCenterListLocations() async {
    try {
      logger.i("Check: fetchCenterListLocations()");
      final response = await http.post(
          Uri.parse('${StringConstants.BASE_URL}ticketMaster/IssueCenterLists'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {'authKey': StringConstants.AUTHKEY, 'userId': user?.userid}));

      final responseDataLocation = json.decode(response.body);
      if (response.statusCode == 200) {
        final lisResultLocation = responseDataLocation['lisResult'].toString();
        if (lisResultLocation == 'True') {
          final responseDataLocation = json.decode(response.body);
          final List<dynamic> locationData =
              responseDataLocation['loadCenter_Details'];
          centerLocationLists.addAll(locationData.map((data) {
            return CenterDetails.fromJson(data);
          }));
          centerLocationLists
              .sort((a, b) => a.centerName.compareTo(b.centerName));
          setState(() {
            centerLocationLists;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Issue Center List Not Fetched'),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchTicketDepartment() async {
    try {
      logger.i("Check: fetchTicketDepartment()");
      final response = await http.post(
          Uri.parse(
              '${StringConstants.BASE_URL}ticketMaster/Issue_Departmentlist_UserWise'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'authKey': StringConstants.AUTHKEY,
            'ownerId': user?.locationID,
            'UserId': user?.userid
          }));

      final responseDataLocation = json.decode(response.body);
      // logger.i(responseDataLocation);
      final lisResultLocation = responseDataLocation['lisResult'].toString();
      // logger.i(lisResultLocation);
      // final username = responseDataLocation['username'].toString();
      if (response.statusCode == 200) {
        // logger.i(responseDataLocation);
        // logger.i(lisResultLocation);
        // logger.i(departmentList);

        if (lisResultLocation == 'True') {
          final responseDataLocation = json.decode(response.body);
          final List<dynamic> locationData =
              responseDataLocation['loadDepartment_Details'];

          setState(() {
            departmentList.addAll(locationData.map((data) {
              return LoadDepartmentDetails.fromJson(data);
            }));
            statusValueDep = departmentList.singleWhere(
                (element) => element.departmentId?.isEmpty ?? false);
            // locations = responseDataLocation ;
          });
        } else {
          // Authentication failed
          logger.i('Login failed');
          // You can display an error message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Department Not Fetched'),
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

  Future<void> fetchCreatedBy() async {
    try {
      logger.i("Check: fetchCreatedBy()");
      final response = await http.post(
          Uri.parse('${StringConstants.BASE_URL}ticketMaster/EmployeeList'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {'authKey': StringConstants.AUTHKEY, 'UserId': user?.userid}));

      final responseDataLocation = json.decode(response.body);
      // logger.i(responseDataLocation);
      final lisResultLocation = responseDataLocation['lisResult'].toString();
      // logger.i(lisResultLocation);
      // final username = responseDataLocation['username'].toString();
      if (response.statusCode == 200) {
        // logger.i(responseDataLocation);
        // logger.i(lisResultLocation);
        // logger.i(createdByList2);

        if (lisResultLocation == 'True') {
          final responseDataLocation = json.decode(response.body);
          final List<dynamic> locationData =
              responseDataLocation['load_ReAssign_Staffists'];

          setState(() {
            createdByList2.addAll(locationData.map((data) {
              return CreatedByList.fromJson(data);
            }));
            // locations = responseDataLocation ;
          });
        } else {
          // Authentication failed
          logger.i('Login failed');
          // You can display an error message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ReAssign Staff list not fetched'),
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

  Future<void> fetchTicketType() async {
    try {
      logger.i("Check: fetchTicketType()");
      final response = await http.post(
          Uri.parse('${StringConstants.BASE_URL}ticketMaster/IssueType'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'authKey': StringConstants.AUTHKEY,
            'Department': user?.department
          }));
      final responseDataLocation = json.decode(response.body);
      final lisResultLocation = responseDataLocation['lisResult'].toString();
      if (response.statusCode == 200) {
        if (lisResultLocation == 'True') {
          final responseDataLocation = json.decode(response.body);
          final List<dynamic> locationData =
              responseDataLocation['issueType_Details'];

          setState(() {
            ticketTypeList.addAll(locationData.map((data) {
              return IssueTypeDetails.fromJson(data);
            }));
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Issue Type Not fetched'),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchAcknowledgedByList() async {
    try {
      logger.i("Check: fetchAcknowledgedByList()");
      final response = await http.post(
          Uri.parse('${StringConstants.BASE_URL}ticketMaster/EmployeeList'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {'authKey': StringConstants.AUTHKEY, 'userId': user?.userid}));

      if (response.statusCode == 200) {
        final responseDataLocation = json.decode(response.body);
        if (responseDataLocation['lisResult'].toString() == 'True') {
          final responseDataLocation = json.decode(response.body);
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
              content: Text('ReAssign Staff lists Not fetched'),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> userPagePermission() async {
    logger.i("Check: userPagePermission()");
    user = (await userDao.findAllPersons()).firstOrNull;
    ERPServices client = ERPServices();
    bool pagePermission = await client.getPagePermission(
        userId: user!.userid,
        pageName: 'Centre_TicketMasterSearch',
        locationId: user!.locationID);
    if (pagePermission) {
      getFilterData();
    }
    return pagePermission;
  }

  Future getFilterData() async {
    try {
      logger.i("Check: getFilterData()");
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
              setState(() {
                locationList = registeredPatientDetailst != null
                    ? registeredPatientDetailst
                        .map((reviewData) => CenterModel.fromJson(reviewData))
                        .toList()
                    : <CenterModel>[];

                location = locationList[0];
              });
              getAccountType();
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
          location =
              CenterModel(locationCode: user!.locationID, locationName: "");
          getAccountType();
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
        content: const Text('Please try later for fetch zonal manager'),
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
      if (!mounted) return;
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

  Future getAccountType() async {
    try {
      logger.i("Check: getAccountType()");
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
            setState(() {
              for (var details in accountTypeListData) {
                accountTypeList.add(details["accountType"]);
              }
            });
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

  Future<List<TicketMasterData>> fetchTicketCardData() async {
    logger.i("Check: fetchTicketCardData()");
    final url = Uri.parse(
        '${StringConstants.BASE_URL}ticketMaster/Get_TicketMastersData');
    user = (await userDao.findAllPersons()).firstOrNull;

    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'AckBy': statusValueByEmployeeList.employeeId,
          'authKey': StringConstants.AUTHKEY,
          'CreatedBy': statusValueCreatedBy.employeeId,
          'FromDate': DateFormat("yyyy-MM-dd")
              .format(DateFormat("dd MMM yyyy").parse(fromDate)),
          'OwnerId': centerDetailsValue.centerCode,
          'Priority_Ticket':
              priorityStatusValue == 'ALL' ? '' : priorityStatusValue,
          'ReAssignedTo': reAssignedStatusValue,
          'TicketDepartment': statusValueDep?.departmentId,
          'TicketStatus': ticketStatusValue == 'ALL' ? '' : ticketStatusValue,
          'Tickettype': statusValueByTicketType.itemDescription == 'ALL'
              ? ''
              : statusValueByTicketType.itemDescription,
          'ToDate': DateFormat("yyyy-MM-dd")
              .format(DateFormat("dd MMM yyyy").parse(toDate)),
          'UserID': user?.userid,
        }));
    List? ticketDetailst =
        json.decode((response.body.toString()))['ticketMastersDatas'];
    dataMap = ticketDetailst ?? [];
    final userList6 = ticketDetailst != null
        ? ticketDetailst
            .map((reviewData) => TicketMasterData.fromJson(reviewData))
            .toList()
        : <TicketMasterData>[];

    ticketItems = userList6;
    searchTicketItems = ticketItems;
    return ticketItems;
  }

  _getData() async {
    await userPagePermission();
    fetchCenterListLocations();
    fetchTicketDepartment();
    fetchCreatedBy();
    fetchTicketType();
    fetchAcknowledgedByList();
  }
}
