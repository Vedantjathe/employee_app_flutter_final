class IndividualCenterModel {
  String? centreCode;
  String? centreName;
  String? status;

  IndividualCenterModel({this.centreCode, this.centreName, this.status});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['centrecode'] = this.centreCode;
    data['centrename'] = this.centreName;
    data['status'] = this.status;
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

  factory IndividualCenterModel.fromJson(Map<String, dynamic> json) {
    final centrecode = json['centrecode'] == null ? "" : json['centrecode'];
    final centrename = json['centrename'] == null ? "" : json['centrename'];
    final status = json['status'] == null ? "" : json['status'];

    return IndividualCenterModel(
        centreCode: centrecode, centreName: centrename, status: status);
  }
}
