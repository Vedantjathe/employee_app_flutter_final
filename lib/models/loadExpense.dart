class LoadExpenseDetails {
  String? lisResult;
  String? lisMessage;
  List<LoadExpDetails>? loadExpDetails;

  LoadExpenseDetails({this.lisResult, this.lisMessage, this.loadExpDetails});

  LoadExpenseDetails.fromJson(Map<String, dynamic> json) {
    lisResult = json['lisResult'];
    lisMessage = json['lisMessage'];
    if (json['loadExp_Details'] != null) {
      loadExpDetails = <LoadExpDetails>[];
      json['loadExp_Details'].forEach((v) {
        loadExpDetails!.add(new LoadExpDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lisResult'] = this.lisResult;
    data['lisMessage'] = this.lisMessage;
    if (this.loadExpDetails != null) {
      data['loadExp_Details'] =
          this.loadExpDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LoadExpDetails {
  String? expItemType;
  String? expItemName;

  LoadExpDetails({this.expItemType, this.expItemName});

  LoadExpDetails.fromJson(Map<String, dynamic> json) {
    expItemType = json['expItemType'];
    expItemName = json['expItemName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['expItemType'] = this.expItemType;
    data['expItemName'] = this.expItemName;
    return data;
  }
}