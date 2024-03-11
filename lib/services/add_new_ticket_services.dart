import 'dart:convert';

import 'package:erp/logger.dart';
import 'package:erp/utils/StringConstants.dart';
import 'package:http/http.dart';

import '../models/CenterListModel.dart';
import '../models/IssueDepartmentModel.dart';
import '../models/IssueTypeListModel.dart';
import '../models/User.dart';
import '../utils/ConnectivityUtils.dart';

class AddService {
  final User user;

  const AddService(this.user);

  Future<List<CenterDetails>> getIssueCenterList() async {
    try {
      if (await ConnectivityUtils.hasConnection()) {
        if (user.usertype == "ZONALMANAGER") {
          logger.i('${StringConstants.BASE_URL}ticketMaster/IssueCenterLists');
          Response response = await post(
            Uri.parse(
                '${StringConstants.BASE_URL}ticketMaster/IssueCenterLists'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(
                {'authKey': StringConstants.AUTHKEY, 'UserId': user.id}),
          ).timeout(const Duration(seconds: 24));
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body.toString());
            if (data['lisResult'].toString() == 'True') {
              final registeredPatientDetails =
                  data['loadCenter_Details'] as List<dynamic>?;
              logger.i(registeredPatientDetails);
              List<CenterDetails> locationList =
                  registeredPatientDetails?.map((reviewData) {
                        return CenterDetails.fromJson(reviewData);
                      }).toList() ??
                      <CenterDetails>[];

              return locationList;
              //getAccountType();
            } else {
              throw Exception(data['lisMessage'].toString());
            }
          }
        }
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  Future<List<IssueDepartment>> getIssueDepartmentList() async {
    try {
      if (await ConnectivityUtils.hasConnection()) {
        if (user.usertype == "ZONALMANAGER") {
          logger.i(
              '${StringConstants.BASE_URL}ticketMaster/Issue_Departmentlists');
          Response response = await post(
            Uri.parse(
                '${StringConstants.BASE_URL}ticketMaster/Issue_Departmentlists'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              'authKey': StringConstants.AUTHKEY,
              'ownerId': user.locationID,
              'UserId': user.userid
            }),
          );
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body.toString());
            if (data['lisResult'].toString() == 'True') {
              final registeredPatientDetails =
                  data['load_ItemLists'] as List<dynamic>?;
              logger.i(registeredPatientDetails);
              List<IssueDepartment> locationList =
                  registeredPatientDetails?.map((reviewData) {
                        return IssueDepartment.fromJson(reviewData);
                      }).toList() ??
                      <IssueDepartment>[];

              return locationList;
              //getAccountType();
            } else {
              throw Exception(data['lisMessage'].toString());
            }
          }
        }
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  // Future<List<LoadDepartmentDetails>> getIssueDepartmentList() async {
  //   try {
  //     if (await ConnectivityUtils.hasConnection()) {
  //       if (user!.usertype == "ZONALMANAGER") {
  //         Response response = await post(
  //           Uri.parse(
  //               '${StringConstants.BASE_URL}ticketMaster/Issue_Departmentlist_UserWise'),
  //           headers: {"Content-Type": "application/json"},
  //           body: jsonEncode({
  //             'authKey': StringConstants.AUTHKEY,
  //             'ownerId': '100001',
  //             'UserId': 'E10001'
  //           }),
  //         ).timeout(const Duration(seconds: 24));
  //         if (response.statusCode == 200) {
  //           var data = jsonDecode(response.body.toString());
  //           if (data['lisResult'].toString() == 'True') {
  //             final registeredPatientDetailst =
  //                 data['loadDepartment_Details'] as List<dynamic>?;
  //             // if the reviews are not missing
  //
  //             var locationList = registeredPatientDetailst != null
  //                 // map each review to a Review object
  //                 ? registeredPatientDetailst
  //                     .map((reviewData) =>
  //                         LoadDepartmentDetails.fromJson(reviewData))
  //                     // map() returns an Iterable so we convert it to a List
  //                     .toList()
  //                 // use an empty list as fallback value
  //                 : <LoadDepartmentDetails>[];
  //
  //             var location = locationList[0];
  //
  //             //getAccountType();
  //           } else {
  //             final snackBar = SnackBar(
  //               content: Text(data['lisMessage'].toString()),
  //               action: SnackBarAction(
  //                 label: 'OK',
  //                 onPressed: () {
  //                   // Some code to undo the change.
  //                 },
  //               ),
  //             );
  //           }
  //         }
  //       } else {}
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<List<IssueTypeDetails>> getIssueTypeList(String department) async {
    try {
      if (await ConnectivityUtils.hasConnection()) {
        logger.i('${StringConstants.BASE_URL}ticketMaster/IssueType');
        Response response = await post(
          Uri.parse('${StringConstants.BASE_URL}ticketMaster/IssueType'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'authKey': StringConstants.AUTHKEY,
            'ownerId': user.locationID,
            'UserId': user.userid,
            'Department': department,
          }),
        ).timeout(const Duration(seconds: 24));
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body.toString());
          if (data['lisResult'].toString() == 'True') {
            final registeredPatientDetails =
                data['issueType_Details'] as List<dynamic>?;
            logger.i(registeredPatientDetails);
            List<IssueTypeDetails> locationList =
                registeredPatientDetails?.map((reviewData) {
                      return IssueTypeDetails.fromJson(reviewData);
                    }).toList() ??
                    <IssueTypeDetails>[];

            return locationList;
            //getAccountType();
          } else {
            throw Exception(data['lisMessage'].toString());
          }
        }
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  // Future getIssueTypeList() async {
  //   try {
  //     if (await ConnectivityUtils.hasConnection()) {
  //       if (user!.usertype == "ZONALMANAGER") {
  //         Response response = await post(
  //           Uri.parse(
  //               '${StringConstants.BASE_URL}ticketMaster/IssueType'),
  //           headers: {"Content-Type": "application/json"},
  //           body: jsonEncode({
  //             'authKey': StringConstants.AUTHKEY,
  //             'Department': 'IT SERVICES'
  //           }),
  //         ).timeout(const Duration(seconds: 24));
  //         if (response.statusCode == 200) {
  //           var data = jsonDecode(response.body.toString());
  //           if (data['lisResult'].toString() == 'True') {
  //             final registeredPatientDetailst =
  //                 data['issueType_Details'] as List<dynamic>?;
  //             // if the reviews are not missing
  //
  //             var locationList = registeredPatientDetailst != null
  //                 // map each review to a Review object
  //                 ? registeredPatientDetailst
  //                     .map(
  //                         (reviewData) => IssueTypeDetails.fromJson(reviewData))
  //                     // map() returns an Iterable so we convert it to a List
  //                     .toList()
  //                 // use an empty list as fallback value
  //                 : <IssueTypeDetails>[];
  //
  //             var location = locationList[0];
  //
  //             //getAccountType();
  //           } else {
  //             final snackBar = SnackBar(
  //               content: Text(data['lisMessage'].toString()),
  //               action: SnackBarAction(
  //                 label: 'OK',
  //                 onPressed: () {
  //                   // Some code to undo the change.
  //                 },
  //               ),
  //             );
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<Map<String, dynamic>> getUserDetailsForCreateTicket() async {
    try {
      if (await ConnectivityUtils.hasConnection()) {
        if (user.usertype == "ZONALMANAGER") {
          logger.i(
              '${StringConstants.BASE_URL}ticketMaster/GetUserDetailsOnNewTicket');
          Response response = await post(
            Uri.parse(
                '${StringConstants.BASE_URL}ticketMaster/GetUserDetailsOnNewTicket'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              'authKey': StringConstants.AUTHKEY,
              'UserId': user.userid,
            }),
          ).timeout(const Duration(seconds: 24));
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body.toString());
            if (data['lisResult'].toString() == 'True') {
              final showlist = data;
              return showlist;
              //getAccountType();
            } else {
              throw Exception(data['lisMessage'].toString());
            }
          }
        }
      }
    } catch (e) {
      rethrow;
    }
    return {};
  }

  // _getUserDetailsForCreateTicket() async {
  //   getUserDetailsMap = await client.getUserDetailsForCreateTicket();
  //   contactNoTFController.text = getUserDetailsMap['contactNumber'];
  // }
}
