import 'package:dio/dio.dart';
import 'package:erp/constants/enums.dart';
import 'package:erp/logger.dart';

import '../models/ticket_details_response.dart';
import '../utils/StringConstants.dart';

class ERPServices {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 24),
      contentType: "application/json",
    ),
  );

  Future<TicketDetailsResponse> getTicketDetails(
      {required String userId,
      required String userRoleId,
      required String ticketRecordID}) async {
    try {
      Response response = await _dio.post(
          '${StringConstants.BASE_URL}ticketMaster/Get_Ticket_Details',
          data: {
            "authKey": StringConstants.AUTHKEY,
            "UserID": userId,
            "User_Role_ID": userRoleId,
            "TicketRecordID": ticketRecordID,
          });
      logger.i('${StringConstants.BASE_URL}ticketMaster/Get_Ticket_Details');
      logger.i(response.data.toString());

      TicketDetailsResponse data =
          TicketDetailsResponse.fromJson(response.data);
      return data;
    } catch (e) {
      logger.e('ticketMaster/Get_Ticket_Details', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateTicketStatus({
    required String userId,
    required TicketStatus status,
    required String ticketRecordID,
    required String rejectMark,
    String? reassignId,
  }) async {
    String path = '';
    Map<String, dynamic> body = {
      "authKey": StringConstants.AUTHKEY,
      "ownerId": "",
      "UserID": userId,
      "Department": "",
      "TicketRecordID": ticketRecordID,
    };

    try {
      switch (status) {
        case TicketStatus.ack:
          path = "Update_TicketACK";
          break;
        case TicketStatus.progress:
          path = "Update_TicketProgress";
          break;
        case TicketStatus.solved:
          path = "Update_TicketSolved";
          break;
        case TicketStatus.reject:
          path = "Update_Ticket_Reject";
          body["ReAssignedTo"] = "";
          body["RejectionRemarks"] = rejectMark;
          break;
        case TicketStatus.hold:
          path = "Update_TicketHold";
          break;
        case TicketStatus.resume:
          path = "Update_TicketResumed";
          break;
        case TicketStatus.reAssign:
          path = "Update_Ticket_ReAssign";
          body["ReAssignedTo"] = reassignId;
          body["RejectionRemarks"] = "";
          body["TicketDepartment"] = "";
          break;
        case TicketStatus.complete:
          path = "Update_TicketComplete";
          break;
      }

      Response response = await _dio.post(
        '${StringConstants.BASE_URL}ticketMaster/$path',
        data: body,
      );
      logger.i('${StringConstants.BASE_URL}ticketMaster/$path');

      logger.i(response.data);
      return response.data;
    } catch (e) {
      logger.e('ticketMaster/$path', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addTicketComment(
      {required String userId,
      required String userRoleId,
      required String ticketRecordID,
      required String comment}) async {
    try {
      Response response = await _dio
          .post('${StringConstants.BASE_URL}ticketMaster/AddComments', data: {
        "authKey": StringConstants.AUTHKEY,
        "UserID": userId,
        "User_Role_ID": userRoleId,
        "TicketRecordID": ticketRecordID,
        "Comment": comment,
      });
      logger.i('${StringConstants.BASE_URL}ticketMaster/AddComments');
      logger.i(response.data);
      return response.data;
    } catch (e) {
      logger.e('ticketMaster/AddComments', error: e);
      rethrow;
    }
  }

  Future<List<ReassignEmployeeModel>> getReassignStaffList({
    required String userId,
    required String ticketDepartment,
  }) async {
    try {
      Response response = await _dio.post(
        '${StringConstants.BASE_URL}ticketMaster/GetIssue_ReAssign_Stafflists',
        data: {
          "authKey": StringConstants.AUTHKEY,
          "ownerId": "",
          "UserID": userId,
          "Department": "",
          "TicketRecordID": "",
          "ReAssignedTo": "",
          "RejectionRemarks": "",
          "TicketDepartment": ticketDepartment,
        },
      );
      logger.i(
          '${StringConstants.BASE_URL}ticketMaster/GetIssue_ReAssign_Stafflists');
      logger.i(response.data);
      List<ReassignEmployeeModel> dataList = [];
      if ((response.data as Map).containsKey('load_ReAssign_Staffists')) {
        dataList = (response.data['load_ReAssign_Staffists'] as List).map((e) {
          return ReassignEmployeeModel.fromJson(e);
        }).toList();
      }
      return dataList;
    } catch (e) {
      logger.e('ticketMaster/GetIssue_ReAssign_Stafflists', error: e);
      rethrow;
    }
  }

  Future<List<DepartmentModel>> getTicketDepartmentList() async {
    try {
      Response response = await _dio.post(
        '${StringConstants.BASE_URL}ticketMaster/Issue_Departmentlists',
        data: {
          "authKey": StringConstants.AUTHKEY,
          "ownerId": "",
          "UserID": "",
          "Department": "",
        },
      );
      logger.i('${StringConstants.BASE_URL}ticketMaster/Issue_Departmentlists');
      logger.i(response.data);
      List<DepartmentModel> dataList = [];
      if ((response.data as Map).containsKey('load_ItemLists')) {
        dataList = (response.data['load_ItemLists'] as List).map((e) {
          return DepartmentModel.fromJson(e);
        }).toList();
      }
      return dataList;
    } catch (e) {
      logger.e('ticketMaster/Issue_Departmentlists', error: e);
      rethrow;
    }
  }

  Future<bool> getPagePermission({
    required String userId,
    required String pageName,
    required String locationId,
  }) async {
    try {
      Response response = await _dio.post(
        '${StringConstants.BASE_URL}LIS_UserPermission_API/User_PagePermission',
        data: {
          'authKey': StringConstants.AUTHKEY,
          'userId': userId,
          'pageName': pageName,
          'LocationID': locationId,
        },
      );
      var data = response.data;
      // logger.i(data);
      if (data['lisResult'].toString() == 'True') {
        if (data['visibility'].toString() == 'YES') {
          return true;
        }
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
}
