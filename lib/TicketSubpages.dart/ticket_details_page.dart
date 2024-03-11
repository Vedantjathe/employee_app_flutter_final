import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:erp/custom_widgets/loading_overlay.dart';
import 'package:erp/models/User.dart';
import 'package:erp/services/erp_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constants/enums.dart';
import '../controller/dbProvider.dart';
import '../custom_widgets/custom_button.dart';
import '../db/UserDao.dart';
import '../logger.dart';
import '../models/TicketMasterDataModel.dart';
import '../models/ticket_details_response.dart';
import '../services/api_multipart_request.dart';
import '../utils/StringConstants.dart';
import '../utils/dialog_util.dart';
import '../utils/util_methods.dart';

class TicketDetailsPage extends StatefulWidget {
  final TicketMasterData data;
  const TicketDetailsPage({super.key, required this.data});

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  late TicketMasterData tmData;

  String? reassignedTo = 'User';
  late final UserDao userDao;
  User? user;

  TicketDetailsResponse tdResponse = TicketDetailsResponse();
  late Future<bool> dataLoaded;

  bool multiBtn = false;

  OverlayEntry overlayEntry =
      OverlayEntry(builder: (_) => const LoadingOverlay());

  ERPServices client = ERPServices();

  TextEditingController rejectedReasonTFC = TextEditingController(),
      commentTFController = TextEditingController(),
      reEmpDDSearchController = TextEditingController(),
      deptDDSearchController = TextEditingController(),
      filePathTFC = TextEditingController();

  File? uploadDoc;

  late Future<List<ReassignEmployeeModel>> staffListFuture;
  ReassignEmployeeModel? reassignEmployee;

  late Future<List<DepartmentModel>> departmentListFuture;
  DepartmentModel? reassignDepartment;

  @override
  void initState() {
    userDao = Provider.of<DBProvider>(context, listen: false).dao;

    tmData = widget.data;
    super.initState();
    dataLoaded = _getData();
    staffListFuture = _getStaffList();
    departmentListFuture = _getDepartmentList();
  }

  @override
  void dispose() {
    rejectedReasonTFC.dispose();
    commentTFController.dispose();
    reEmpDDSearchController.dispose();
    deptDDSearchController.dispose();
    filePathTFC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: mediaQuery.size.height * 0.08,
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text(
          "TICKET DETAIL - ${tmData.TicketRecordID}",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: 'Segoe',
            fontWeight: FontWeight.normal,
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
      body: FutureBuilder(
          future: dataLoaded,
          builder: (context, snapshot) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _getDisplayWidget(
                                  label: 'Center', value: tmData.Location_Name),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _getRightDisplayWidget(
                                  label: 'Issue Reported By',
                                  value: tdResponse.issuereportedby ?? ''),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _getDisplayWidget(
                                  label: 'Name', value: tmData.CreatedBy),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _getRightDisplayWidget(
                                  label: 'Contact No.',
                                  value: tmData.RaisedPersonContactNo),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _getDisplayWidget(
                                  label: 'Category',
                                  value: tmData.Location_Name),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _getRightDisplayWidget(
                                  label: 'Department',
                                  value: tmData.Department),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _getDisplayWidget(
                                  label: 'Issue Type',
                                  value: tmData.TicketType),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _getRightDisplayWidget(
                                  label: 'Ticket Status',
                                  value: tmData.TicketStatus),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _getDisplayWidget(
                                  label: 'Priority',
                                  value: tmData.Priority_Ticket),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _getRightDisplayWidget(
                                  label: 'Is Approval Needed?',
                                  value: (tdResponse.isApprovalNeeded ?? '')
                                              .toLowerCase() ==
                                          'true'
                                      ? 'Yes'
                                      : 'No'),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: (tdResponse.isApprovalNeeded ?? '')
                              .toLowerCase()
                              .contains('true'),
                          child: _getDisplayWidget(
                              label: 'Approval Name',
                              value: tmData.ApproverName),
                        ),
                        _getDisplayWidget(
                            label: 'Ticket Description',
                            value: tdResponse.ticketDescription ?? ''),
                        Row(
                          children: [
                            Expanded(
                              child: Visibility(
                                visible: tdResponse.divAck ?? false,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Visibility(
                                      visible: tdResponse
                                              .acknowledgedBy?.isNotEmpty ??
                                          false,
                                      child: _getRichText(
                                          label: "Acknowledged By",
                                          value: tdResponse.acknowledgedBy
                                                  ?.split("Acknowledged By : ")
                                                  .lastOrNull ??
                                              ''),
                                    ),
                                    const SizedBox(height: 8),
                                    Visibility(
                                      visible: tdResponse
                                              .acknowledgedOn?.isNotEmpty ??
                                          false,
                                      child: _getRichText(
                                          label: "Acknowledged On",
                                          value: tdResponse.acknowledgedOn
                                                  ?.split('Acknowledged On : ')
                                                  .lastOrNull ??
                                              ''),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Visibility(
                                visible: tdResponse.divProgress ?? false,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Visibility(
                                      visible: tdResponse
                                              .inProgressedBy?.isNotEmpty ??
                                          false,
                                      child: _getRichText(
                                          label: "In Progress By",
                                          value: tdResponse.inProgressedBy
                                                  ?.split('InProgressed By : ')
                                                  .lastOrNull ??
                                              ''),
                                    ),
                                    const SizedBox(height: 8),
                                    Visibility(
                                      visible: tdResponse
                                              .inProgressedOn?.isNotEmpty ??
                                          false,
                                      child: _getRichText(
                                          label: "In Progress On",
                                          value: tdResponse.inProgressedOn
                                                  ?.split('InProgressed On : ')
                                                  .lastOrNull ??
                                              ''),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Visibility(
                                visible: tdResponse.divSolved ??
                                    false, // Set your visibility condition here
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Visibility(
                                      visible:
                                          tdResponse.solvedBy?.isNotEmpty ??
                                              false,
                                      child: _getRichText(
                                          label: "Solved By",
                                          value: tdResponse.solvedBy
                                                  ?.split('Solved By : ')
                                                  .lastOrNull ??
                                              ''),
                                    ),
                                    const SizedBox(height: 8),
                                    Visibility(
                                      visible:
                                          tdResponse.solvedOn?.isNotEmpty ??
                                              false,
                                      child: _getRichText(
                                          label: "Solved On",
                                          value: tdResponse.solvedOn
                                                  ?.split('Solved On : ')
                                                  .lastOrNull ??
                                              ''),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Visibility(
                                visible: tdResponse.divCompleted ??
                                    false, // Set your visibility condition here
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Visibility(
                                      visible:
                                          tdResponse.completedBy?.isNotEmpty ??
                                              false,
                                      child: _getRichText(
                                          label: "Completed By",
                                          value: tdResponse.completedBy
                                                  ?.split('Completed By : ')
                                                  .lastOrNull ??
                                              ''),
                                    ),
                                    Visibility(
                                      visible:
                                          tdResponse.completedOn?.isNotEmpty ??
                                              false,
                                      child: _getRichText(
                                          label: "Completed On",
                                          value: tdResponse.completedOn
                                                  ?.split('Completed On : ')
                                                  .lastOrNull ??
                                              ''),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 6.0),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex:
                                    (tdResponse.btnResume ?? false) && multiBtn
                                        ? 1
                                        : 0,
                                child: Visibility(
                                  visible: tdResponse.btnResume ?? false,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: GradientButton(
                                      onPressed: () {
                                        updateTicketStatus(TicketStatus.resume);
                                      },
                                      label: "Resume",
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: (tdResponse.btnUpdateProgress ?? false) &&
                                        (tdResponse.acknowledge
                                            .toString()
                                            .contains(user?.userid ?? '')) &&
                                        multiBtn
                                    ? 1
                                    : 0,
                                child: Visibility(
                                  visible:
                                      (tdResponse.btnUpdateProgress ?? false) &&
                                          (tdResponse.acknowledge
                                              .toString()
                                              .contains(user?.userid ?? '')),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: GradientButton(
                                      onPressed: () {
                                        updateTicketStatus(
                                            TicketStatus.progress);
                                      },
                                      label: "Update In-Progress Ticket",
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex:
                                    (tdResponse.btnSolved ?? false) && multiBtn
                                        ? 1
                                        : 0,
                                child: Visibility(
                                  visible: tdResponse.btnSolved ?? false,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: GradientButton(
                                      onPressed: () {
                                        updateTicketStatus(TicketStatus.solved);
                                      },
                                      label: "Solved the Ticket",
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: (tdResponse.btnCompleted ?? false) &&
                                        multiBtn
                                    ? 1
                                    : 0,
                                child: Visibility(
                                  visible: tdResponse.btnCompleted ?? false,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: GradientButton(
                                      onPressed: () {
                                        updateTicketStatus(
                                            TicketStatus.complete);
                                      },
                                      label: "Mark As Closed",
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: (tdResponse.btnACK ?? false) && multiBtn
                                    ? 1
                                    : 0,
                                child: Visibility(
                                  visible: tdResponse.btnACK ?? false,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0),
                                    child: GradientButton(
                                      onPressed: () {
                                        updateTicketStatus(TicketStatus.ack);
                                      },
                                      label: "Acknowledge Ticket",
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: (tdResponse.btnHold ?? false) && multiBtn
                                    ? 1
                                    : 0,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Visibility(
                                    visible: tdResponse.btnHold ?? false,
                                    child: GradientButton(
                                      gradient: const LinearGradient(colors: [
                                        Color(0xff45b6af),
                                        Color(0xff2cc7bd),
                                      ]),
                                      onPressed: () {
                                        updateTicketStatus(TicketStatus.hold);
                                      },
                                      label: "Hold",
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: tdResponse.divReject ??
                              false, // Set your visibility condition here
                          child: _buildTextFormField(
                              label: 'Reason for Rejection:',
                              hintText: 'REASON FOR REJECT',
                              controller: rejectedReasonTFC),
                        ),
                        Visibility(
                          visible: (tdResponse.divReject ?? false) &&
                              (tdResponse.btnReject ?? false),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: GradientButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  if (rejectedReasonTFC.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Please Add Reject Reason"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  updateTicketStatus(TicketStatus.reject);
                                },
                                label: "Reject Ticket",
                                gradient: const LinearGradient(colors: [
                                  Color(0xFFdfba49),
                                  Color(0xFFebbf38),
                                ]),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: tdResponse.divAssign ?? false,
                          child: Column(
                            children: [
                              const Center(
                                child: Text(
                                  'Reassign to',
                                  style: TextStyle(fontSize: 19),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        isExpanded: true,
                                        hint: const Text("Select User"),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            overflow: TextOverflow.ellipsis,
                                            fontFamily: 'Segoe',
                                            fontWeight: FontWeight.normal),
                                        onChanged: (value) => {
                                          setState(() {
                                            reassignedTo = value;
                                          }),
                                        },
                                        value: reassignedTo,
                                        items: ["User", "Department"]
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        buttonStyleData: ButtonStyleData(
                                          padding: const EdgeInsets.only(
                                              right: 16, top: 3.5, bottom: 3.5),
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
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Visibility(
                                      visible: reassignedTo == "User",
                                      replacement: _buildDepartmentDropdown(),
                                      child: _buildEmployeeDropdown(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              GradientButton(
                                  onPressed: () {
                                    updateTicketStatus(TicketStatus.reAssign);
                                  },
                                  label: 'Reassign')
                            ],
                          ),
                        ),
                        Visibility(
                          visible: tdResponse.ticketStatus
                                      .toString()
                                      .toLowerCase() !=
                                  'Closed' ||
                              (tdResponse.divComments ?? false),
                          child: Column(
                            children: [
                              _buildTextFormField(
                                  label: 'Comment',
                                  hintText: 'Add Comment',
                                  controller: commentTFController),
                              const SizedBox(height: 16),
                              Center(
                                  child: GradientButton(
                                      onPressed: () {
                                        addComment();
                                      },
                                      label: 'Save Comment')),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: tdResponse.ticketCommentLists!.isNotEmpty,
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8.0),
                            height: 40,
                            color: Colors.grey[600],
                            child: const Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "Commented By",
                                      style: TextStyle(
                                        fontFamily: 'PoppinsRegular',
                                        fontSize: 12.0,
                                        color:
                                            Colors.white, // Set your text color
                                      ),
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  thickness: 1,
                                  color: Colors.white,
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "Commented On",
                                      style: TextStyle(
                                        fontFamily: 'PoppinsRegular',
                                        fontSize: 12.0,
                                        color:
                                            Colors.white, // Set your text color
                                      ),
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  thickness: 1,
                                  color: Colors.white,
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "Comment",
                                      style: TextStyle(
                                        fontFamily: 'PoppinsRegular',
                                        fontSize: 12.0,
                                        color:
                                            Colors.white, // Set your text color
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: tdResponse.ticketCommentLists!
                              .isNotEmpty, // Set your visibility condition
                          child: ListView.builder(
                            itemCount: tdResponse.ticketCommentLists!.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              TicketCommentLists comment =
                                  tdResponse.ticketCommentLists![index];
                              return buildCommentCard(comment);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Visibility(
                          visible: tdResponse.btnupload ?? false,
                          child: Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child: TextFormField(
                                  controller: filePathTFC,
                                  onTap: () async {
                                    uploadFileDialog(
                                      context,
                                      cameraCallback: () {
                                        Navigator.pop(context);
                                        _getFromCamera();
                                      },
                                      storageCallBack: () async {
                                        Navigator.pop(context);
                                        FilePickerResult? result =
                                            await FilePicker.platform
                                                .pickFiles();
                                        if (result != null) {
                                          uploadDoc =
                                              File(result.files.single.path!);
                                          filePathTFC.text =
                                              uploadDoc?.path ?? '';
                                        }
                                      },
                                    );
                                  },
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 1.3, color: Color(0XFFBEDCF0)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    hintText: 'Choose File',
                                    contentPadding:
                                        const EdgeInsetsDirectional.only(
                                            start: 10.0),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Flexible(
                                  flex: 2,
                                  child: GradientButton(
                                      onPressed: () {
                                        uploadFileToServer();
                                      },
                                      label: 'Upload')),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Visibility(
                          visible: tdResponse.ticketAttachmentLists!.isNotEmpty,
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8.0),
                            // padding: const EdgeInsets.symmetric(vertical: 5.0),
                            height: 40,
                            color: Colors.grey[600],
                            child: const Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "File Name",
                                      style: TextStyle(
                                        fontFamily: 'PoppinsRegular',
                                        fontSize: 12.0,
                                        color:
                                            Colors.white, // Set your text color
                                      ),
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  thickness: 1,
                                  color: Colors.white,
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "Uploaded On",
                                      style: TextStyle(
                                        fontFamily: 'PoppinsRegular',
                                        fontSize: 12.0,
                                        color:
                                            Colors.white, // Set your text color
                                      ),
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  thickness: 1,
                                  color: Colors.white,
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "Uploaded by",
                                      style: TextStyle(
                                        fontFamily: 'PoppinsRegular',
                                        fontSize: 12.0,
                                        color:
                                            Colors.white, // Set your text color
                                      ),
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  thickness: 1,
                                  color: Colors.white,
                                ),
                                Expanded(
                                  child: SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: tdResponse.ticketAttachmentLists!
                              .isNotEmpty, // Set your visibility condition
                          child: ListView.builder(
                            itemCount: tdResponse.ticketAttachmentLists!.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              TicketAttachmentLists attachment =
                                  tdResponse.ticketAttachmentLists![index];
                              return buildAttachmentCard(attachment);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Visibility(
                    visible: snapshot.connectionState != ConnectionState.done,
                    child: const LoadingOverlay()),
              ],
            );
          }),
    );
  }

  FutureBuilder<List<ReassignEmployeeModel>> _buildEmployeeDropdown() {
    return FutureBuilder<List<ReassignEmployeeModel>>(
        future: staffListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error Loading List');
          }
          if (snapshot.hasData) {
            return DropdownButtonHideUnderline(
              child: DropdownButton2<ReassignEmployeeModel>(
                isExpanded: true,
                hint: const Text("Select User"),
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                    fontFamily: 'Segoe',
                    fontWeight: FontWeight.normal),
                onChanged: (value) => {
                  setState(() {
                    reassignEmployee = value;
                  }),
                },
                value: reassignEmployee,
                items: snapshot.data!
                    .map<DropdownMenuItem<ReassignEmployeeModel>>(
                        (ReassignEmployeeModel value) {
                  return DropdownMenuItem<ReassignEmployeeModel>(
                    value: value,
                    child: Text(value.employeeName ?? ''),
                  );
                }).toList(),
                buttonStyleData: ButtonStyleData(
                  padding:
                      const EdgeInsets.only(right: 16, top: 3.5, bottom: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0XFFF9F9F9),
                    border:
                        Border.all(width: 1.3, color: const Color(0XFFBEDCF0)),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                iconStyleData: IconStyleData(
                  icon: Image.asset("assets/dropdown.png",
                      color: const Color(0XFF5D5D5D), width: 14, height: 14),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 350,
                  offset: const Offset(0, -8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    //background color of dropdown button//border of dropdown button
                    border: Border.all(color: const Color(0xFFC0C0C0)),
                    borderRadius: BorderRadius.circular(
                        10), //border raiuds of dropdown button
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                ),
                dropdownSearchData: DropdownSearchData(
                  searchController: reEmpDDSearchController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Container(
                    height: 56,
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      expands: true,
                      maxLines: null,
                      controller: reEmpDDSearchController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: 'Search for an item',
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    return item.value!.employeeName!
                            .toLowerCase()
                            .contains(searchValue.toLowerCase()) ||
                        item.value!.employeeId!
                            .toLowerCase()
                            .contains(searchValue.toLowerCase());
                  },
                ),
                //This to clear the search value when you close the menu
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {
                    reEmpDDSearchController.clear();
                  }
                },
              ),
            );
          }
          return const Text('Loading...');
        });
  }

  FutureBuilder<List<DepartmentModel>> _buildDepartmentDropdown() {
    return FutureBuilder<List<DepartmentModel>>(
        future: departmentListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error Loading List');
          }
          if (snapshot.hasData) {
            return DropdownButtonHideUnderline(
              child: DropdownButton2<DepartmentModel>(
                isExpanded: true,
                hint: const Text("Select Department"),
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                    fontFamily: 'Segoe',
                    fontWeight: FontWeight.normal),
                onChanged: (value) => {
                  setState(() {
                    reassignDepartment = value;
                  }),
                },
                value: reassignDepartment,
                items: snapshot.data!.map<DropdownMenuItem<DepartmentModel>>(
                    (DepartmentModel value) {
                  return DropdownMenuItem<DepartmentModel>(
                    value: value,
                    child: Text(value.issueDescription ?? ''),
                  );
                }).toList(),
                buttonStyleData: ButtonStyleData(
                  padding:
                      const EdgeInsets.only(right: 16, top: 3.5, bottom: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0XFFF9F9F9),
                    border:
                        Border.all(width: 1.3, color: const Color(0XFFBEDCF0)),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                iconStyleData: IconStyleData(
                  icon: Image.asset("assets/dropdown.png",
                      color: const Color(0XFF5D5D5D), width: 14, height: 14),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 350,
                  offset: const Offset(0, -8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    //background color of dropdown button//border of dropdown button
                    border: Border.all(color: const Color(0xFFC0C0C0)),
                    borderRadius: BorderRadius.circular(
                        10), //border raiuds of dropdown button
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                ),
                dropdownSearchData: DropdownSearchData(
                  searchController: deptDDSearchController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Container(
                    height: 56,
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      expands: true,
                      maxLines: null,
                      controller: deptDDSearchController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: 'Search for an item',
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    return item.value!.issueDescription!
                            .toLowerCase()
                            .contains(searchValue.toLowerCase()) ||
                        item.value!.issueType!
                            .toLowerCase()
                            .contains(searchValue.toLowerCase());
                  },
                ),
                //This to clear the search value when you close the menu
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {
                    reEmpDDSearchController.clear();
                  }
                },
              ),
            );
          }
          return const Text('Loading...');
        });
  }

  Container buildCommentCard(TicketCommentLists comment) {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFF757575)),
          left: BorderSide(color: Color(0xFF757575)),
          bottom: BorderSide(color: Color(0xFF757575)),
        ),
      ),
      // color: Color(0xFF757575)
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                comment.commentedBy ?? '',
                style: TextStyle(
                  fontFamily: 'PoppinsRegular',
                  fontSize: 14.0,
                  color: Colors.grey[700], // Set your text color
                ),
              ),
            ),
          ),
          VerticalDivider(
            thickness: 1,
            color: Colors.grey[600],
          ),
          Expanded(
            child: Center(
              child: Text(
                comment.commentedOn ?? '',
                style: TextStyle(
                  fontFamily: 'PoppinsRegular',
                  fontSize: 14.0,
                  color: Colors.grey[700], // Set your text color
                ),
              ),
            ),
          ),
          VerticalDivider(
            thickness: 1,
            color: Colors.grey[600],
          ),
          Expanded(
            child: Center(
              child: Text(
                comment.ticketComments ?? '',
                maxLines: 2,
                style: TextStyle(
                  fontFamily: 'PoppinsRegular',
                  fontSize: 14.0,
                  color: Colors.grey[700], // Set your text color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column _buildTextFormField(
      {required String label,
      required String hintText,
      TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 5),
        TextFormField(
          maxLines: 3,
          minLines: 3,
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0XFFF9F9F9),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide:
                  const BorderSide(width: 1.3, color: Color(0XFFBEDCF0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide:
                  const BorderSide(width: 1.3, color: Color(0XFFBEDCF0)),
            ),
            contentPadding: const EdgeInsets.fromLTRB(20.0, 13, 20, 13),
            counterText: "",
            errorStyle: const TextStyle(height: 0),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide:
                  const BorderSide(width: 1.3, color: Color(0XFFBEDCF0)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide:
                  const BorderSide(width: 1.3, color: Color(0XFFBEDCF0)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide:
                  const BorderSide(width: 1.3, color: Color(0XFFBEDCF0)),
            ),
          ), /*InputDecoration(
            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 2, color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
            hintText: hintText,
            contentPadding: const EdgeInsetsDirectional.only(start: 10.0),
          ),*/
        ),
      ],
    );
  }

  Column _getDisplayWidget({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
          decoration: BoxDecoration(
            color: const Color(0XFFF9F9F9),
            border: Border.all(width: 1.3, color: const Color(0XFFBEDCF0)),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Text(
            value,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Column _getRightDisplayWidget(
      {required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
          decoration: BoxDecoration(
            color: const Color(0XFFF9F9F9),
            border: Border.all(width: 1.3, color: const Color(0XFFBEDCF0)),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Text(
            value,
            maxLines: 4,
            overflow: TextOverflow.clip,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  _getRichText({required String label, required String value}) {
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: "$label\n",
            style: const TextStyle(fontSize: 15, color: Colors.black),
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(fontSize: 15, color: Color(0xFF156397)),
              )
            ]));
  }

  Future<bool> _getData() async {
    user ??= (await userDao.findAllPersons()).firstOrNull;

    tdResponse = await client.getTicketDetails(
        userId: user!.userid,
        userRoleId: user!.assignedRole,
        ticketRecordID: tmData.TicketRecordID);
    if (tdResponse.rejectedReason?.isNotEmpty ?? false) {
      rejectedReasonTFC.text = tdResponse.rejectedReason!;
    }
    int btnCount = 0;
    if (tdResponse.btnHold ?? false) btnCount++;
    if (tdResponse.btnACK ?? false) btnCount++;
    if (tdResponse.btnCompleted ?? false) btnCount++;
    if (tdResponse.btnSolved ?? false) btnCount++;
    if (tdResponse.btnUpdateProgress ?? false) btnCount++;
    if (tdResponse.btnResume ?? false) btnCount++;

    if (btnCount > 1) {
      multiBtn = true;
    } else {
      multiBtn = false;
    }

    return true;
  }

  Future<List<ReassignEmployeeModel>> _getStaffList() async {
    user ??= (await userDao.findAllPersons()).firstOrNull;

    List<ReassignEmployeeModel> reassignEmpList =
        await client.getReassignStaffList(
      userId: user!.userid,
      ticketDepartment: tmData.Department,
    );

    return reassignEmpList;
  }

  Future<List<DepartmentModel>> _getDepartmentList() async {
    user ??= (await userDao.findAllPersons()).firstOrNull;

    List<DepartmentModel> departmentList =
        await client.getTicketDepartmentList();

    return departmentList;
  }

  Future<void> updateTicketStatus(TicketStatus status) async {
    try {
      Navigator.of(context).overlay?.insert(overlayEntry);
      Map<String, dynamic> ticketStatusResponse =
          await client.updateTicketStatus(
        userId: user!.userid,
        status: status,
        ticketRecordID: tmData.TicketRecordID,
        rejectMark: rejectedReasonTFC.text,
        reassignId: reassignedTo == 'User'
            ? reassignEmployee?.employeeId
            : reassignDepartment?.departmentId,
      );
      overlayEntry.remove();
      if (!mounted) return;

      if (ticketStatusResponse['lisResult'].toLowerCase() == "true") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ticketStatusResponse['lisMessage'] ?? ''),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          dataLoaded = _getData();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ticketStatusResponse['lisMessage'] ?? ''),
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

  addComment() async {
    if (commentTFController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Enter Comment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      Navigator.of(context).overlay?.insert(overlayEntry);
      FocusScope.of(context).unfocus();
      Map<String, dynamic> response = await client.addTicketComment(
        userId: user!.userid,
        userRoleId: user!.assignedRole,
        ticketRecordID: tmData.TicketRecordID,
        comment: commentTFController.text.trim(),
      );
      overlayEntry.remove();
      if (!mounted) return;
      if (response['lisResult'].toString().toLowerCase() == "true") {
        commentTFController.text = '';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment Saved Successfully'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          dataLoaded = _getData();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['lisMessage'] ?? ''),
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

      filePathTFC.text = uploadDoc!.path;
    }
  }

  uploadFileToServer() async {
    if (uploadDoc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      String path = 'ticketMaster/Ticket_UploadFile';

      Map<String, String> filePathMap = {'file': uploadDoc!.path};

      ApiMultipartRequest multipartClient = ApiMultipartRequest();

      Navigator.of(context).overlay?.insert(overlayEntry);

      Response<Map<String, dynamic>?> response =
          await multipartClient.sendRequest(
        path,
        filePathMap: filePathMap,
        fieldValueMap: {
          "authKey": StringConstants.AUTHKEY,
          "UserID": user?.userid ?? '',
          "TicketRecordID": tmData.TicketRecordID,
        },
      );

      overlayEntry.remove();
      if (!mounted) return;

      if (response.data?['lisResult'].toLowerCase() == "true") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File Upload Successfully'),
            backgroundColor: Colors.green,
          ),
        );
        filePathTFC.text = '';
        setState(() {
          dataLoaded = _getData();
        });
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

  Container buildAttachmentCard(TicketAttachmentLists attachment) {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFF757575)),
          left: BorderSide(color: Color(0xFF757575)),
          bottom: BorderSide(color: Color(0xFF757575)),
        ),
      ),
      // color: Color(0xFF757575)
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                attachment.fileName ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PoppinsRegular',
                  fontSize: 14.0,
                  color: Colors.grey[700], // Set your text color
                ),
              ),
            ),
          ),
          VerticalDivider(
            thickness: 1,
            color: Colors.grey[600],
          ),
          Expanded(
            child: Center(
              child: Text(
                attachment.uploadedOn ?? '',
                style: TextStyle(
                  fontFamily: 'PoppinsRegular',
                  fontSize: 14.0,
                  color: Colors.grey[700], // Set your text color
                ),
              ),
            ),
          ),
          VerticalDivider(
            thickness: 1,
            color: Colors.grey[600],
          ),
          Expanded(
            child: Center(
              child: Text(
                attachment.uploadedBy ?? '',
                maxLines: 2,
                style: TextStyle(
                  fontFamily: 'PoppinsRegular',
                  fontSize: 14.0,
                  color: Colors.grey[700], // Set your text color
                ),
              ),
            ),
          ),
          VerticalDivider(
            thickness: 1,
            color: Colors.grey[600],
          ),
          Expanded(
            child: Center(
              child: TextButton(
                onPressed: () {
                  downloadFile(attachment);
                },
                child: Text(
                  overflow: TextOverflow.visible,
                  'Download',
                  style: TextStyle(
                    fontFamily: 'PoppinsRegular',
                    fontSize: 11.0,
                    color: Colors.blue, // Set your text color
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // "${StringConstants.BASE_URL.split("api/")[0]}${attachment.fileFullPathUrl?.split(".com/")[1]}"
  downloadFile(TicketAttachmentLists selectedFile) async {
    OverlayEntry overlayEntry =
        OverlayEntry(builder: (context) => const LoadingOverlay());
    Navigator.of(context).overlay?.insert(overlayEntry);

    var url = Uri.parse(
        "${StringConstants.BASE_URL.split("api/")[0]}${selectedFile.fileFullPathUrl?.split(".com/")[1]}");

    try {
      final response = await http.get(
        url,
      );

      if (response.contentLength == 0) {
        overlayEntry.remove();
        Future.delayed(
            const Duration(seconds: 0),
            () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('File did not download .\nTry again later.'),
                    backgroundColor: Colors.red,
                  ),
                ));
        return;
      }
      String tempPath = await createFolder();
      if (tempPath == "") {
        overlayEntry.remove();
        Future.delayed(
            const Duration(seconds: 0),
            () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Storage permission needed to download file . Go to setting and turn on permission storage."),
                    backgroundColor: Colors.red,
                  ),
                ));
      } else {
        File file = File('$tempPath/${selectedFile.fileName}');
        int i = 1;
        while (file.existsSync()) {
          file = File(
              '$tempPath/${selectedFile.fileName!.split('.').first}($i).${selectedFile.fileName!.split('.').last}');
          i++;
        }
        await file.writeAsBytes(response.bodyBytes);
        // OpenFile.open(file.path);
        overlayEntry.remove();
        Future.delayed(
            const Duration(seconds: 0),
            () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'File download successfully at this location $tempPath'),
                    backgroundColor: Colors.green,
                  ),
                ));
      }
    } catch (e) {
      overlayEntry.remove();
      logger.e(e);
    }
  }
}
