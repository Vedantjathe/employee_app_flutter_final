import 'dart:async';
import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:erp/utils/ColorConstants.dart';
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
import '../utils/ConnectivityUtils.dart';

enum SelectedButton { all, radiology, pathology }

SelectedButton selectedButton =
    SelectedButton.all; // Initialize with the default button.

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late final UserDao userDao;
  User? user;
  late final Future<bool> pagePermissionFuture;
  CenterModel? location;

  //var genderItems = ["0%", "5%", "10%", "15%", "20%"];

  // String toDate = "";
  //String fromDate = "";

  String totPathoPatient = "0";
  String totRadioPatient = "0.00";
  String totPathoTestCount = "0";
  String totRadioTestCount = "0.0";
  String totPathoBillAmount = "0.0";
  String totRadioBillAmount = "0.00";
  String totPathoAveragePrice = "0.0";
  String totRadioAveragePrice = "0.00";
  String totPendingCollectionPatho = "0";
  String totPendingForAccessionPatho = "0";
  String totPendingEntryPatho = "0";
  String totPendingAuthorizePatho = "0";
  String totPendingApprovePatho = "0";
  String totPendingRadioConfirmation = "0";

  /*{tot_Patho_Patient: 0, tot_Radio_Patient: 820, tot_Patho_TestCount: 0, tot_Radio_TestCount: 820,
  tot_Patho_BillAmount: 0.00, tot_Radio_BillAmount: 874661.20, tot_Patho_AveragePrice: 0.00,
  tot_Radio_AveragePrice: 1066.66, totPendingCollection_Patho: 0,
  totPendingForAccession_Patho: 0, totPendingEntry_Patho: 0, totPendingAuthorize_Patho: 0,
  totPendingApprove_Patho: 0, totPendingRadio_Confirmation: 0}*/

  var modality = "0";
  var modalityCT = "0";
  var patientCountCT = "0";
  var testCountCT = "0";
  var billAmountCT = "0.0";

  var averagePriceCT = "0.0";

  var modalityMRI = "0";
  var patientCountMRI = "0";
  var testCountMRI = "0";
  var billAmountMRI = "0.0";

  var modalityUSG = "0";
  var patientCountUSG = "0";
  var testCountUSG = "0";
  var billAmountUSG = "0.0";

  var modalityXRAY = "0";
  var patientCountXRAY = "0";
  var testCountXRAY = "0";
  var billAmountXRAY = "0.0";
  List<CenterModel> locationList = List.empty(growable: true);
  CenterModel? statusValue;

  String fromDate = "";
  String toDate = "";

  late Future<bool> revenueFuture;

  @override
  void initState() {
    userDao = Provider.of<DBProvider>(context, listen: false).dao;
    fromDate = DateFormat("dd MMM yyyy").format(DateTime.now());
    toDate = DateFormat("dd MMM yyyy").format(DateTime.now());
    pagePermissionFuture = userPagePermission();
    super.initState();
    userPagePermission();
  }

  final TextEditingController ddSearchController = TextEditingController();

  @override
  void dispose() {
    ddSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              return FutureBuilder<bool>(
                  future: revenueFuture,
                  builder: (context, snapshot) {
                    // if (snapshot.connectionState != ConnectionState.done) {
                    //   return const LoadingOverlay();
                    // }
                    if (snapshot.hasError) {
                      // snapshot.error.
                      return const Text('Error');
                    }
                    return Stack(
                      children: [
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 56,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedButton = SelectedButton.all;
                                          });
                                        },
                                        child: Text(
                                          "All",
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: selectedButton ==
                                                      SelectedButton.all
                                                  ? const Color(0xff3A9FBE)
                                                  : Colors.black,
                                              fontSize: 18,
                                              fontFamily: 'Segoe',
                                              fontWeight: selectedButton ==
                                                      SelectedButton.all
                                                  ? FontWeight.bold
                                                  : FontWeight.normal),
                                        ),
                                      ),
                                      VerticalDivider(
                                        color: ColorConstants.purpul700Color,
                                        width: 2,
                                        indent: 4,
                                        endIndent: 4,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedButton =
                                                SelectedButton.radiology;
                                          });
                                        },
                                        child: Text(
                                          "RADIOLOGY",
                                          textAlign: TextAlign.right,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: selectedButton ==
                                                      SelectedButton.radiology
                                                  ? const Color(0xff3A9FBE)
                                                  : Colors.black,
                                              fontSize: 18,
                                              fontFamily: 'Segoe',
                                              fontWeight: selectedButton ==
                                                      SelectedButton.radiology
                                                  ? FontWeight.bold
                                                  : FontWeight.normal),
                                        ),
                                      ),
                                      const VerticalDivider(
                                        color: ColorConstants.purpul700Color,
                                        width: 2,
                                        indent: 4,
                                        endIndent: 4,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedButton =
                                                SelectedButton.pathology;
                                          });
                                        },
                                        child: Center(
                                          child: Text(
                                            "PATHOLOGY",
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: selectedButton ==
                                                        SelectedButton.pathology
                                                    ? const Color(0xff3A9FBE)
                                                    : Colors.black,
                                                fontSize: 18,
                                                fontFamily: 'Segoe',
                                                fontWeight: selectedButton ==
                                                        SelectedButton.pathology
                                                    ? FontWeight.bold
                                                    : FontWeight.normal),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
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
                                        padding:
                                            const EdgeInsets.only(right: 16),
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
                                      menuItemStyleData:
                                          const MenuItemStyleData(
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
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          ),
                                        ),
                                        searchMatchFn: (item, searchValue) {
                                          return item.value!.locationName
                                                  .toLowerCase()
                                                  .contains(searchValue
                                                      .toLowerCase()) ||
                                              item.value!.locationCode
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
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            10, 5, 5, 5),
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
                                                firstDate: DateTime(2000),
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
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            5, 5, 10, 5),
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
                                    ),
                                  ],
                                ),
                                Visibility(
                                    visible:
                                        selectedButton == SelectedButton.all,
                                    child: Column(
                                      children: [
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text(
                                                  "RADIOLOGY",
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                      fontFamily: 'Segoe',
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text(
                                                  "PATHOLOGY",
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                      fontFamily: 'Segoe',
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0XFFF9F9F9),
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
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "Total Revenue",
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        "₹ $totRadioBillAmount",
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .linecolor,
                                                            fontSize: 21,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "Total Patient",
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        totRadioPatient,
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .linecolor,
                                                            fontSize: 18,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "Average Price",
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        "₹ $totRadioAveragePrice",
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .linecolor,
                                                            fontSize: 18,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0XFFF9F9F9),
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
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "Total Revenue",
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        "₹ $totPathoBillAmount",
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .linecolor,
                                                            fontSize: 21,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "Total Patient",
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        totPathoPatient,
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .linecolor,
                                                            fontSize: 18,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "Average Price",
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        "₹ $totPathoAveragePrice",
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .linecolor,
                                                            fontSize: 18,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.all(8),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0XFFF9F9F9),
                                                  border: Border.all(
                                                      width: 1.3,
                                                      color: const Color(
                                                          0XFFBEDCF0)),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "CT",
                                                        textAlign:
                                                            TextAlign.left,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        patientCountCT,
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .linecolor,
                                                            fontSize: 21,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.all(8),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0XFFF9F9F9),
                                                  border: Border.all(
                                                      width: 1.3,
                                                      color: const Color(
                                                          0XFFBEDCF0)),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "Total Test",
                                                        textAlign:
                                                            TextAlign.left,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        totPathoTestCount,
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .linecolor,
                                                            fontSize: 21,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.all(8),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0XFFF9F9F9),
                                                  border: Border.all(
                                                      width: 1.3,
                                                      color: const Color(
                                                          0XFFBEDCF0)),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "MRI",
                                                        textAlign:
                                                            TextAlign.left,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        patientCountMRI,
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .linecolor,
                                                            fontSize: 21,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.all(8),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0XFFF9F9F9),
                                                  border: Border.all(
                                                      width: 1.3,
                                                      color: const Color(
                                                          0XFFBEDCF0)),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "Pending\nCollection",
                                                        textAlign:
                                                            TextAlign.left,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        totPendingCollectionPatho,
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .linecolor,
                                                            fontSize: 21,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.all(8),
                                                // Corrected margin value
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0XFFF9F9F9),
                                                  border: Border.all(
                                                      width: 1.3,
                                                      color: const Color(
                                                          0XFFBEDCF0)),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "USG",
                                                        textAlign:
                                                            TextAlign.left,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                          fontFamily: 'Segoe',
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        patientCountUSG,
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                          color: ColorConstants
                                                              .linecolor,
                                                          fontSize: 21,
                                                          fontFamily: 'Segoe',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.all(8),
                                                // Corrected margin value
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0XFFF9F9F9),
                                                  border: Border.all(
                                                      width: 1.3,
                                                      color: const Color(
                                                          0XFFBEDCF0)),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "Pending\nAccession",
                                                        textAlign:
                                                            TextAlign.left,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                          fontFamily: 'Segoe',
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        totPendingForAccessionPatho,
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                          color: ColorConstants
                                                              .linecolor,
                                                          fontSize: 21,
                                                          fontFamily: 'Segoe',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.all(8),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0XFFF9F9F9),
                                                  border: Border.all(
                                                      width: 1.3,
                                                      color: const Color(
                                                          0XFFBEDCF0)),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "X-RAY",
                                                        textAlign:
                                                            TextAlign.left,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        patientCountXRAY,
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .linecolor,
                                                            fontSize: 21,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.all(8),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0XFFF9F9F9),
                                                  border: Border.all(
                                                      width: 1.3,
                                                      color: const Color(
                                                          0XFFBEDCF0)),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "Pending\nResult Entry",
                                                        textAlign:
                                                            TextAlign.left,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        totPendingEntryPatho,
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .linecolor,
                                                            fontSize: 21,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.all(8),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0XFFF9F9F9),
                                                  border: Border.all(
                                                      width: 1.3,
                                                      color: const Color(
                                                          0XFFBEDCF0)),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "Radiology\nConfirmation",
                                                        textAlign:
                                                            TextAlign.left,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        totPendingRadioConfirmation,
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .linecolor,
                                                            fontSize: 21,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.all(8),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0XFFF9F9F9),
                                                  border: Border.all(
                                                      width: 1.3,
                                                      color: const Color(
                                                          0XFFBEDCF0)),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Text(
                                                        "Pending Result\nApproval",
                                                        textAlign:
                                                            TextAlign.left,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        totPendingApprovePatho,
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .linecolor,
                                                            fontSize: 21,
                                                            fontFamily: 'Segoe',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                Visibility(
                                    visible: selectedButton ==
                                        SelectedButton.radiology,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0XFFF9F9F9),
                                            border: Border.all(
                                                width: 1.3,
                                                color: const Color(0XFFBEDCF0)),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                          ),
                                          child: Column(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text(
                                                  "Total Revenue",
                                                  textAlign: TextAlign.right,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                      fontFamily: 'Segoe',
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Text(
                                                  "₹ $totRadioBillAmount",
                                                  textAlign: TextAlign.right,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                      color: ColorConstants
                                                          .linecolor,
                                                      fontSize: 26,
                                                      fontFamily: 'Segoe',
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Column(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Average Price",
                                                          textAlign:
                                                              TextAlign.right,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          "₹ $totRadioAveragePrice",
                                                          textAlign:
                                                              TextAlign.right,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                                  Expanded(
                                                      child: Column(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Average Test",
                                                          textAlign:
                                                              TextAlign.right,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          totRadioPatient
                                                                      .isEmpty ==
                                                                  true
                                                              ? "0"
                                                              : totRadioTestCount
                                                                          .isEmpty ==
                                                                      true
                                                                  ? "0"
                                                                  : double.parse(
                                                                              totRadioPatient) ==
                                                                          0
                                                                      ? "0"
                                                                      : (double.parse(totRadioTestCount) /
                                                                              double.parse(totRadioPatient))
                                                                          .toStringAsFixed(2),
                                                          textAlign:
                                                              TextAlign.right,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            "Modality wise",
                                            textAlign: TextAlign.right,
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 21,
                                                fontFamily: 'Segoe',
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Container(
                                              margin: const EdgeInsets.all(8),
                                              padding: const EdgeInsets.all(8),
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
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Text(
                                                      totRadioPatient,
                                                      textAlign:
                                                          TextAlign.right,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          color: ColorConstants
                                                              .linecolor,
                                                          fontSize: 26,
                                                          fontFamily: 'Segoe',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      "Total Patient",
                                                      textAlign:
                                                          TextAlign.right,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18,
                                                          fontFamily: 'Segoe',
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                            Expanded(
                                                child: Container(
                                              margin: const EdgeInsets.all(8),
                                              padding: const EdgeInsets.all(8),
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
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Text(
                                                      totRadioTestCount,
                                                      textAlign:
                                                          TextAlign.right,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          color: ColorConstants
                                                              .linecolor,
                                                          fontSize: 26,
                                                          fontFamily: 'Segoe',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      "Total Test",
                                                      textAlign:
                                                          TextAlign.right,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18,
                                                          fontFamily: 'Segoe',
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                          ],
                                        ),
                                        Container(
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0XFFF9F9F9),
                                            border: Border.all(
                                                width: 1.3,
                                                color: const Color(0XFFBEDCF0)),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                          ),
                                          child: Row(
                                            children: [
                                              const Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      "CT",
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  )),
                                              Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Revenue",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          "₹ $billAmountCT",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Average Price",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          patientCountCT
                                                                      .isEmpty ==
                                                                  true
                                                              ? "₹ 0.0"
                                                              : billAmountCT
                                                                      .isEmpty
                                                                  ? "₹ 0.0"
                                                                  : double.parse(
                                                                              patientCountCT) ==
                                                                          0
                                                                      ? "₹ 0.0"
                                                                      : "₹ ${(double.parse(billAmountCT) / double.parse(patientCountCT)).toStringAsFixed(2)}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Patient",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          patientCountCT,
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0XFFF9F9F9),
                                            border: Border.all(
                                                width: 1.3,
                                                color: const Color(0XFFBEDCF0)),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                          ),
                                          child: Row(
                                            children: [
                                              const Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      "MRI",
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  )),
                                              Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Revenue",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          "₹ $billAmountMRI",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Average Price",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          patientCountMRI
                                                                      .isEmpty ==
                                                                  true
                                                              ? "₹ 0.0"
                                                              : billAmountMRI
                                                                          .isEmpty ==
                                                                      true
                                                                  ? "₹ 0.0"
                                                                  : double.parse(
                                                                              patientCountMRI) ==
                                                                          0
                                                                      ? "₹ 0.0"
                                                                      : "₹ ${(double.parse(billAmountMRI) / double.parse(patientCountMRI)).toStringAsFixed(2)}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Patient",
                                                          textAlign:
                                                              TextAlign.right,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          patientCountMRI,
                                                          textAlign:
                                                              TextAlign.right,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0XFFF9F9F9),
                                            border: Border.all(
                                                width: 1.3,
                                                color: const Color(0XFFBEDCF0)),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                          ),
                                          child: Row(
                                            children: [
                                              const Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      "USG",
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  )),
                                              Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Revenue",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          "₹ $billAmountUSG",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Average Price",
                                                          textAlign:
                                                              TextAlign.right,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          patientCountUSG
                                                                      .isEmpty ==
                                                                  true
                                                              ? "₹ 0.0"
                                                              : billAmountUSG
                                                                          .isEmpty ==
                                                                      true
                                                                  ? "₹ 0.0"
                                                                  : double.parse(
                                                                              patientCountUSG) ==
                                                                          0
                                                                      ? "₹ 0.0"
                                                                      : "₹ ${(double.parse(billAmountUSG) / double.parse(patientCountUSG)).toStringAsFixed(2)}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Patient",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          patientCountUSG,
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0XFFF9F9F9),
                                            border: Border.all(
                                                width: 1.3,
                                                color: const Color(0XFFBEDCF0)),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                          ),
                                          child: Row(
                                            children: [
                                              const Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      "X-RAY",
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  )),
                                              Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Revenue",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          "₹ ${double.parse(billAmountXRAY)}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Average Price",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          patientCountXRAY
                                                                      .isEmpty ==
                                                                  true
                                                              ? "₹ 0.0"
                                                              : billAmountXRAY
                                                                          .isEmpty ==
                                                                      true
                                                                  ? "₹ 0.0"
                                                                  : double.parse(
                                                                              patientCountXRAY) ==
                                                                          0
                                                                      ? "₹ 0.0"
                                                                      : "₹ ${(double.parse(billAmountXRAY) / double.parse(patientCountXRAY)).toStringAsFixed(2)}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Patient",
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          patientCountXRAY,
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: const Color(0XFFF9F9F9),
                                            border: Border.all(
                                                width: 1.3,
                                                color: const Color(0XFFBEDCF0)),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              const Expanded(
                                                  child: Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text(
                                                  "Radiology Confirmation",
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                      fontFamily: 'Segoe',
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              )),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Text(
                                                    totPendingRadioConfirmation,
                                                    textAlign: TextAlign.right,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        color: ColorConstants
                                                            .linecolor,
                                                        fontSize: 16,
                                                        fontFamily: 'Segoe',
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                                Visibility(
                                    visible: selectedButton ==
                                        SelectedButton.pathology,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0XFFF9F9F9),
                                            border: Border.all(
                                                width: 1.3,
                                                color: const Color(0XFFBEDCF0)),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                          ),
                                          child: Column(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text(
                                                  "Total Revenue",
                                                  textAlign: TextAlign.right,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                      fontFamily: 'Segoe',
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Text(
                                                  "₹ $totPathoBillAmount",
                                                  textAlign: TextAlign.right,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                      color: ColorConstants
                                                          .linecolor,
                                                      fontSize: 26,
                                                      fontFamily: 'Segoe',
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Column(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Average Price",
                                                          textAlign:
                                                              TextAlign.right,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          totPathoBillAmount
                                                                      .isEmpty ==
                                                                  true
                                                              ? "₹ 0.0"
                                                              : totPathoPatient
                                                                          .isEmpty ==
                                                                      true
                                                                  ? "₹ 0.0"
                                                                  : double.parse(
                                                                              totPathoPatient) ==
                                                                          0
                                                                      ? "₹ 0.0"
                                                                      : "₹ ${(double.parse(totPathoBillAmount) / double.parse(totPathoPatient)).toStringAsFixed(2)}",
                                                          textAlign:
                                                              TextAlign.right,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                                  Expanded(
                                                      child: Column(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Text(
                                                          "Average Test",
                                                          textAlign:
                                                              TextAlign.right,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          totPathoTestCount
                                                                      .isEmpty ==
                                                                  true
                                                              ? "0"
                                                              : totPathoPatient
                                                                          .isEmpty ==
                                                                      true
                                                                  ? "0"
                                                                  : double.parse(
                                                                              totPathoPatient) ==
                                                                          0
                                                                      ? "0"
                                                                      : (double.parse(totPathoTestCount) /
                                                                              double.parse(totPathoPatient))
                                                                          .toStringAsFixed(2),
                                                          textAlign:
                                                              TextAlign.right,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .linecolor,
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Segoe',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Container(
                                              margin: const EdgeInsets.all(8),
                                              padding: const EdgeInsets.all(8),
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
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Text(
                                                      totPathoPatient,
                                                      textAlign:
                                                          TextAlign.right,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          color: ColorConstants
                                                              .linecolor,
                                                          fontSize: 26,
                                                          fontFamily: 'Segoe',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      "Total Patient",
                                                      textAlign:
                                                          TextAlign.right,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18,
                                                          fontFamily: 'Segoe',
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                            Expanded(
                                                child: Container(
                                              margin: const EdgeInsets.all(8),
                                              padding: const EdgeInsets.all(8),
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
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Text(
                                                      totPathoTestCount,
                                                      textAlign:
                                                          TextAlign.right,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          color: ColorConstants
                                                              .linecolor,
                                                          fontSize: 26,
                                                          fontFamily: 'Segoe',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      "Total Test",
                                                      textAlign:
                                                          TextAlign.right,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18,
                                                          fontFamily: 'Segoe',
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Container(
                                              margin: const EdgeInsets.all(8),
                                              padding: const EdgeInsets.all(8),
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
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      "Pending\nCollection",
                                                      textAlign: TextAlign.left,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Text(
                                                      totPendingCollectionPatho,
                                                      textAlign:
                                                          TextAlign.right,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          color: ColorConstants
                                                              .linecolor,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                            Expanded(
                                                child: Container(
                                              margin: const EdgeInsets.all(8),
                                              padding: const EdgeInsets.all(8),
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
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      "Pending\nAccession",
                                                      textAlign: TextAlign.left,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Text(
                                                      totPendingForAccessionPatho,
                                                      textAlign:
                                                          TextAlign.right,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          color: ColorConstants
                                                              .linecolor,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Container(
                                              margin: const EdgeInsets.all(8),
                                              padding: const EdgeInsets.all(8),
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
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      "Pending\nEntry",
                                                      textAlign: TextAlign.left,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Text(
                                                      totPendingEntryPatho,
                                                      textAlign:
                                                          TextAlign.right,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          color: ColorConstants
                                                              .linecolor,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                            Expanded(
                                                child: Container(
                                              margin: const EdgeInsets.all(8),
                                              padding: const EdgeInsets.all(8),
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
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      "Pending\nAuthorization",
                                                      textAlign: TextAlign.left,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Text(
                                                      totPendingAuthorizePatho,
                                                      textAlign:
                                                          TextAlign.right,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          color: ColorConstants
                                                              .linecolor,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Container(
                                              margin: const EdgeInsets.all(8),
                                              padding: const EdgeInsets.all(8),
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
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      "Pending For\nApprove",
                                                      textAlign: TextAlign.left,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Text(
                                                      totPendingApprovePatho,
                                                      textAlign:
                                                          TextAlign.right,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          color: ColorConstants
                                                              .linecolor,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                            Expanded(
                                                child: Container(
                                              margin: const EdgeInsets.all(8),
                                              padding: const EdgeInsets.all(8),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      "",
                                                      textAlign: TextAlign.left,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                      "",
                                                      textAlign:
                                                          TextAlign.right,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          color: ColorConstants
                                                              .linecolor,
                                                          fontSize: 16,
                                                          fontFamily: 'Segoe',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                          ],
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                            visible: snapshot.connectionState !=
                                ConnectionState.done,
                            child: const LoadingOverlay()),
                      ],
                    );
                  });
            }
            return const LoadingOverlay(
              showBackrop: true,
            );
          }),
    );
  }

  Future<bool> userPagePermission() async {
    user = (await userDao.findAllPersons()).firstOrNull;
    ERPServices client = ERPServices();
    bool pagePermission = await client.getPagePermission(
        userId: user!.userid,
        pageName: 'MyDashboard',
        locationId: user!.locationID);
    if (pagePermission) {
      await getFilterData();
      revenueFuture = getRevenue();
    }
    return pagePermission;
  }

  Future getFilterData() async {
    try {
      //
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

              locationList = registeredPatientDetailst != null
                  // map each review to a Review object
                  ? registeredPatientDetailst
                      .map((reviewData) => CenterModel.fromJson(reviewData))
                      // map() returns an Iterable so we convert it to a List
                      .toList()
                  // use an empty list as fallback value
                  : <CenterModel>[];

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
          //
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

  Future<bool> getRevenue() async {
    try {
      //
      if (await ConnectivityUtils.hasConnection()) {
        Response response = await post(
          Uri.parse('${StringConstants.BASE_URL}LIS_Dashboard/LoadDashboard'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'authKey': StringConstants.AUTHKEY,
            'userID': user!.userid,
            'fromDate': DateFormat("yyyy-MM-dd")
                .format(DateFormat("dd MMM yyyy").parse(fromDate)),
            'toDate': DateFormat("yyyy-MM-dd")
                .format(DateFormat("dd MMM yyyy").parse(toDate)),
            'DepartmentType': user!.department,
            'isUnBlockedForBilling': user!.isUnBlockedForBilling,
            'ownerId': location!.locationCode,
            'userType': user!.usertype
          }),
        ).timeout(const Duration(seconds: 24));

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body.toString());
          if (data['lisResult'].toString() == 'True') {
            var loadDashboardDetails = data["loadDashboard_Details"];

            totPathoPatient =
                loadDashboardDetails[0]['tot_Patho_Patient'].toString();
            totRadioPatient =
                loadDashboardDetails[0]['tot_Radio_Patient'].toString();
            totPathoTestCount =
                loadDashboardDetails[0]['tot_Patho_TestCount'].toString();

            totRadioTestCount =
                loadDashboardDetails[0]['tot_Radio_TestCount'].toString();

            totPathoBillAmount =
                loadDashboardDetails[0]['tot_Patho_BillAmount'].toString();

            totRadioBillAmount =
                loadDashboardDetails[0]['tot_Radio_BillAmount'].toString();

            totPathoAveragePrice =
                loadDashboardDetails[0]['tot_Patho_AveragePrice'].toString();

            totRadioAveragePrice =
                loadDashboardDetails[0]['tot_Radio_AveragePrice'].toString();

            totPendingCollectionPatho = loadDashboardDetails[0]
                    ['totPendingCollection_Patho']
                .toString();

            totPendingForAccessionPatho = loadDashboardDetails[0]
                    ['totPendingForAccession_Patho']
                .toString();

            totPendingEntryPatho =
                loadDashboardDetails[0]['totPendingEntry_Patho'].toString();

            totPendingAuthorizePatho =
                loadDashboardDetails[0]['totPendingAuthorize_Patho'].toString();

            totPendingApprovePatho =
                loadDashboardDetails[0]['totPendingApprove_Patho'].toString();
            totPendingRadioConfirmation = loadDashboardDetails[0]
                    ['totPendingRadio_Confirmation']
                .toString();

            Response responseRadioMod = await post(
              Uri.parse(
                  '${StringConstants.BASE_URL}LIS_Dashboard/Get_Radio_ModalityWiseDetails'),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                'authKey': StringConstants.AUTHKEY,
                'userID': user!.userid,
                'fromDate': DateFormat("yyyy-MM-dd")
                    .format(DateFormat("dd MMM yyyy").parse(fromDate)),
                'toDate': DateFormat("yyyy-MM-dd")
                    .format(DateFormat("dd MMM yyyy").parse(toDate)),
                'DepartmentType': user!.department,
                'isUnBlockedForBilling': user!.isUnBlockedForBilling,
                'ownerId': location!.locationCode,
                'userType': user!.usertype
              }),
            ).timeout(const Duration(seconds: 12));

            if (responseRadioMod.statusCode == 200) {
              var dataRadioMod = jsonDecode(responseRadioMod.body.toString());
              if (dataRadioMod['lisResult'].toString() == 'True') {
                var jsonString = dataRadioMod['load_Radio_Modality_Details'];
                logger.i(jsonString);
                List<Map<String, dynamic>> loadRadioModalityDetails =
                    List<Map<String, dynamic>>.from(jsonString.map((item) {
                  return Map<String, dynamic>.from(item);
                }));

                modalityCT = "0";
                patientCountCT = "0";
                testCountCT = "0";
                billAmountCT = "0.0";

                modalityMRI = "0";
                patientCountMRI = "0";
                testCountMRI = "0";
                billAmountMRI = "0.0";

                modalityUSG = "0";
                patientCountUSG = "0";
                testCountUSG = "0";
                billAmountUSG = "0.0";

                modalityXRAY = "0";
                patientCountXRAY = "0";
                testCountXRAY = "0";
                billAmountXRAY = "0.0";

                logger.i(loadRadioModalityDetails);
                for (var details in loadRadioModalityDetails) {
                  String modality = details["modality"] ?? "";
                  String patientCount = details["patient_Count"] ?? "";
                  String testCount = details["test_Count"] ?? "";
                  String billAmount = details["billAmount"] ?? "";

                  if (modality == "CT") {
                    modalityCT = modality;
                    patientCountCT = patientCount;
                    testCountCT = testCount;
                    billAmountCT = billAmount;
                  }

                  if (modality == "MRI") {
                    modalityMRI = modality;
                    patientCountMRI = patientCount;
                    testCountMRI = testCount;
                    billAmountMRI = billAmount;
                  }

                  if (modality == "USG") {
                    modalityUSG = modality;
                    patientCountUSG = patientCount;
                    testCountUSG = testCount;
                    billAmountUSG = billAmount;
                  }
                  if (modality == "2D ECHO") {
                    //modality_MRI = modality;
                    // patient_count_MRI = patientCount;
                    // test_Count_MRI = testCount;
                    //billAmount_MRI = billAmount;
                  } else {}

                  if (modality == "XRAY") {
                    modalityXRAY = modality;
                    patientCountXRAY = patientCount;
                    testCountXRAY = testCount;
                    billAmountXRAY = billAmount;
                  }
                }
              }
            }
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

            if (!mounted) return false;
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }
      } else {
        //
        final snackBar = SnackBar(
          content: const Text('Please check internet connection'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        if (!mounted) return false;
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
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      //logger.i(e.toString());
      //
      final snackBar = SnackBar(
        content: const Text('Please Contact KDL Admin'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );

      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return true;
  }
}
