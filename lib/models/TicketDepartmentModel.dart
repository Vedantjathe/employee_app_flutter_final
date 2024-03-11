class TicketDepartmentModel {
  String? lisResult;
  String? lisMessage;
  List<LoadDepartmentDetails>? loadDepartmentDetails;

  TicketDepartmentModel(
      {this.lisResult, this.lisMessage, this.loadDepartmentDetails});

  TicketDepartmentModel.fromJson(Map<String, dynamic> json) {
    lisResult = json['lisResult'];
    lisMessage = json['lisMessage'];
    if (json['loadDepartment_Details'] != null) {
      loadDepartmentDetails = <LoadDepartmentDetails>[];
      json['loadDepartment_Details'].forEach((v) {
        loadDepartmentDetails!.add(new LoadDepartmentDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lisResult'] = this.lisResult;
    data['lisMessage'] = this.lisMessage;
    if (this.loadDepartmentDetails != null) {
      data['loadDepartment_Details'] =
          this.loadDepartmentDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LoadDepartmentDetails {
  String? departmentId;
  String? departmentName;
  String? iSEmployeeDepartment;

  LoadDepartmentDetails(
      {this.departmentId, this.departmentName, this.iSEmployeeDepartment});

  LoadDepartmentDetails.fromJson(Map<String, dynamic> json) {
    departmentId = json['departmentId'];
    departmentName = json['departmentName'];
    iSEmployeeDepartment = json['iS_EmployeeDepartment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['departmentId'] = this.departmentId;
    data['departmentName'] = this.departmentName;
    data['iS_EmployeeDepartment'] = this.iSEmployeeDepartment;
    return data;
  }
}