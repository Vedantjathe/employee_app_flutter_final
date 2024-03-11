class getUserDetailOnNewTicket {
  String? lisResult;
  String? lisMessage;
  String? employeeName;
  String? designation;
  String? contactNumber;

  getUserDetailOnNewTicket(
      {this.lisResult,
      this.lisMessage,
      this.employeeName,
      this.designation,
      this.contactNumber});

  getUserDetailOnNewTicket.fromJson(Map<String, dynamic> json) {
    lisResult = json['lisResult'];
    lisMessage = json['lisMessage'];
    employeeName = json['employeeName'];
    designation = json['designation'];
    contactNumber = json['contactNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lisResult'] = this.lisResult;
    data['lisMessage'] = this.lisMessage;
    data['employeeName'] = this.employeeName;
    data['designation'] = this.designation;
    data['contactNumber'] = this.contactNumber;
    return data;
  }
}
