class EmployeeListModel {
  String? lisResult;
  String? lisMessage;
  List<LoadReAssignStaffists>? loadReAssignStaffists;

  EmployeeListModel(
      {this.lisResult, this.lisMessage, this.loadReAssignStaffists});

  EmployeeListModel.fromJson(Map<String, dynamic> json) {
    lisResult = json['lisResult'];
    lisMessage = json['lisMessage'];
    if (json['load_ReAssign_Staffists'] != null) {
      loadReAssignStaffists = <LoadReAssignStaffists>[];
      json['load_ReAssign_Staffists'].forEach((v) {
        loadReAssignStaffists!.add(new LoadReAssignStaffists.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lisResult'] = this.lisResult;
    data['lisMessage'] = this.lisMessage;
    if (this.loadReAssignStaffists != null) {
      data['load_ReAssign_Staffists'] =
          this.loadReAssignStaffists!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LoadReAssignStaffists {
  String? employeeId;
  String? employeeName;

  LoadReAssignStaffists({this.employeeId, this.employeeName});

  LoadReAssignStaffists.fromJson(Map<String, dynamic> json) {
    employeeId = json['employeeId'];
    employeeName = json['employeeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['employeeId'] = this.employeeId;
    data['employeeName'] = this.employeeName;
    return data;
  }
}