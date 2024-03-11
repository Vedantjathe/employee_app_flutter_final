class IssueTypeList {
  String? lisResult;
  String? lisMessage;
  List<IssueTypeDetails>? issueTypeDetails;

  IssueTypeList({this.lisResult, this.lisMessage, this.issueTypeDetails});

  IssueTypeList.fromJson(Map<String, dynamic> json) {
    lisResult = json['lisResult'];
    lisMessage = json['lisMessage'];
    if (json['issueType_Details'] != null) {
      issueTypeDetails = <IssueTypeDetails>[];
      json['issueType_Details'].forEach((v) {
        issueTypeDetails!.add(new IssueTypeDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lisResult'] = this.lisResult;
    data['lisMessage'] = this.lisMessage;
    if (this.issueTypeDetails != null) {
      data['issueType_Details'] =
          this.issueTypeDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class IssueTypeDetails {
  String? itemDescription;
  String? itemType;

  IssueTypeDetails({this.itemDescription, this.itemType});

  IssueTypeDetails.fromJson(Map<String, dynamic> json) {
    itemDescription = json['item_Description'];
    itemType = json['item_Type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['item_Description'] = this.itemDescription;
    data['item_Type'] = this.itemType;
    return data;
  }
}
