class CreatedByDepartmentModel {
  String? lisResult;
  String? lisMessage;
  List<CreatedByList>? loadReAssignStaffists;

  CreatedByDepartmentModel(
      {this.lisResult, this.lisMessage, this.loadReAssignStaffists});

  CreatedByDepartmentModel.fromJson(Map<String, dynamic> json) {
    lisResult = json['lisResult'];
    lisMessage = json['lisMessage'];
    if (json['load_ReAssign_Staffists'] != null) {
      loadReAssignStaffists = <CreatedByList>[];
      json['load_ReAssign_Staffists'].forEach((v) {
        loadReAssignStaffists!.add(new CreatedByList.fromJson(v));
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

class CreatedByList {
  String? employeeId;
  String? employeeName;

  CreatedByList({this.employeeId, this.employeeName});

  CreatedByList.fromJson(Map<String, dynamic> json) {
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