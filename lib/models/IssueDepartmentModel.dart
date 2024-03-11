class IssueDepartmentList {
  String? lisResult;
  String? lisMessage;
  List<LoadDepartmentDetails>? loadDepartmentDetails;
  List<IssueDepartment>? load_ItemLists;

  IssueDepartmentList(
      {this.lisResult,
      this.lisMessage,
      this.loadDepartmentDetails,
      this.load_ItemLists});

  IssueDepartmentList.fromJson(Map<String, dynamic> json) {
    lisResult = json['lisResult'];
    lisMessage = json['lisMessage'];
    if (json['loadDepartment_Details'] != null) {
      loadDepartmentDetails = <LoadDepartmentDetails>[];
      json['loadDepartment_Details'].forEach((v) {
        loadDepartmentDetails!.add(new LoadDepartmentDetails.fromJson(v));
      });
    }
    if (json["load_ItemLists"] != null) {
      load_ItemLists = <IssueDepartment>[];
      json['load_ItemLists'].forEach((v) {
        load_ItemLists!.add(new IssueDepartment.fromJson(v));
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
    if (this.load_ItemLists != null) {
      data['load_ItemLists'] =
          this.load_ItemLists!.map((v) => v.toJson()).toList();
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

class IssueDepartment {
  String? item_Type;
  String? item_Description;

  IssueDepartment({this.item_Type, this.item_Description});

  IssueDepartment.fromJson(Map<String, dynamic> json) {
    item_Type = json['item_Type'];
    item_Description = json['item_Description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['item_Type'] = this.item_Type;
    data['item_Description'] = this.item_Description;
    return data;
  }
}
