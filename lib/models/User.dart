import 'package:floor/floor.dart';

@entity
class User {
  @primaryKey
  int id = 0;
  String username,
      usertype,
      assignedRole,
      userid,
      userDepartment,
      isUnBlockedForBilling,
      locationID,
      department,
      designation;

  User(
      {required this.username,
      required this.usertype,
      required this.assignedRole,
      required this.userid,
      required this.userDepartment,
      required this.isUnBlockedForBilling,
      required this.locationID,
      required this.department,
      required this.designation});

  Map<String, dynamic> toMap() => {
        "username": this.username,
        "usertype": this.usertype,
        "assignedRole": this.assignedRole,
        "userid": this.userid,
        "userDepartment": this.userDepartment,
        "isUnBlockedForBilling": this.isUnBlockedForBilling,
        "locationID": this.locationID,
        "department": this.department,
        "designation": this.designation
      };

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

  factory User.fromJson(Map<String, dynamic> data) {
    final username = data['username'] == null ? "" : data['username'] as String;
    final usertype = data['usertype'] == null ? "" : data['usertype'] as String;
    final assignedRole =
        data['assignedRole'] == null ? "" : data['assignedRole'] as String;
    final userid = data['userid'] == null ? "" : data['userid'] as String;
    final userDepartment =
        data['userDepartment'] == null ? "" : data['userDepartment'] as String;
    final isUnBlockedForBilling = data['isUnBlockedForBilling'] == null
        ? ""
        : data['isUnBlockedForBilling'] as String;
    final locationID =
        data['locationID'] == null ? "" : data['locationID'] as String;
    final department =
        data['department'] == null ? "" : data['department'] as String;
    final designation =
        data['designation'] == null ? "" : data['designation'] as String;

    return User(
        username: username,
        usertype: usertype,
        assignedRole: assignedRole,
        userid: userid,
        userDepartment: userDepartment,
        isUnBlockedForBilling: isUnBlockedForBilling,
        locationID: locationID,
        department: department,
        designation: designation);
  }
}
