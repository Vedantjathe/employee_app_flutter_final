
import 'package:floor/floor.dart';

@entity
class LoginResponse {
  @primaryKey
  int id =0;
  String? lisResult;
  String? lisMessage;
  String? userid;
  String? username;
  String? usertype;
  String? userDepartment;
  String? assignedRole;
  String? isUnBlockedForBilling;
  String? locationID;
  String? department;
  String? designation;

  LoginResponse(
      {this.lisResult,
        this.lisMessage,
        this.userid,
        this.username,
        this.usertype,
        this.userDepartment,
        this.assignedRole,
        this.isUnBlockedForBilling,
        this.locationID,
        this.department,
        this.designation});


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lisResult'] = this.lisResult;
    data['lisMessage'] = this.lisMessage;
    data['userid'] = this.userid;
    data['username'] = this.username;
    data['usertype'] = this.usertype;
    data['userDepartment'] = this.userDepartment;
    data['assignedRole'] = this.assignedRole;
    data['isUnBlockedForBilling'] = this.isUnBlockedForBilling;
    data['locationID'] = this.locationID;
    data['department'] = this.department;
    data['designation'] = this.designation;
    return data;
  }



  static dynamic getListMap(List<dynamic> items) {
    if (items == null) {
      return null;
    }
    List<Map<String, dynamic>> list = [];
    items.forEach((element) {
      list.add(element.toMap());
    });
    return list;
  }

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final lisResult = json['lisResult'] == null? "": json['lisResult'];
    final lisMessage = json['lisMessage'] == null? "": json['lisMessage'];
    final userid = json['userid'] == null? "": json['userid'];
    final username = json['username'] == null? "": json['username'];
    final  usertype = json['usertype'] == null? "": json['usertype'];
    final userDepartment = json['userDepartment'] == null? "": json['userDepartment'];
    final assignedRole = json['assignedRole'] == null? "": json['assignedRole'];
    final isUnBlockedForBilling = json['isUnBlockedForBilling'] == null? "": json['isUnBlockedForBilling'];
    final locationID = json['locationID'] == null? "": json['locationID'];
    final department = json['department'] == null? "": json['department'];
    final designation = json['designation'] == null? "": json['designation'];

    return LoginResponse(
      lisResult : lisResult,
      lisMessage : lisMessage,
      userid : userid,
      username :username,
      usertype :usertype,
      userDepartment :userDepartment,
      assignedRole :assignedRole,
      isUnBlockedForBilling :isUnBlockedForBilling,
      locationID :locationID,
      department :department,
      designation :designation,
    );
  }


}

