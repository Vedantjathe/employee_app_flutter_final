class IndividualExpensesApprovalDetail {
  String? recordId;
  String? employeeCMP_ID;
  String? user_Code;
  String? employeeId;
  String? expenseCode;
  String? ownerId;
  String? expenseDate;
  String? partnerName;
  String? firstName;
  String? expenseStatus;
  String? accountTypeCode;
  String? accountDescription;
  String? expenseDescription;
  String? expenseAmount;
  String? expenseType;
  String? centerLocation;
  String? managerApproved_RejectedBy;
  String? managerApproved_RejectedOn;
  String? hoApproved_RejectedBy;
  String? hoApproved_RejectedOn;

  /*String? expenseCode;
  String? ownerId;
  String? expenseDate;
  String? staffName;
  String? accountTypeCode;
  String? expenseDescription;
  String? expenseType;
  String? expenseStatus;
  String? expenseAmount;
  String? recordId;
  String? managerApprovedRejectedBy;
  String? managerApprovedRejectedOn;
  String? hoApprovedRejectedBy;
  String? hoApprovedRejectedOn;
  String? accountDescription;
  String? centerLocation;
  String? partnerName;*/

  IndividualExpensesApprovalDetail({
    this.recordId,
    this.employeeCMP_ID,
    this.user_Code,
    this.employeeId,
    this.expenseCode,
    this.ownerId,
    this.expenseDate,
    this.partnerName,
    this.firstName,
    this.expenseStatus,
    this.accountTypeCode,
    this.accountDescription,
    this.expenseDescription,
    this.expenseAmount,
    this.expenseType,
    this.centerLocation,
    this.managerApproved_RejectedBy,
    this.managerApproved_RejectedOn,
    this.hoApproved_RejectedBy,
    this.hoApproved_RejectedOn,

    /*this.expenseCode,
    this.ownerId,
    this.expenseDate,
    this.staffName,
    this.accountTypeCode,
    this.expenseDescription,
    this.expenseType,
    this.expenseStatus,
    this.expenseAmount,
    this.recordId,
    this.managerApprovedRejectedBy,
    this.managerApprovedRejectedOn,
    this.hoApprovedRejectedBy,
    this.hoApprovedRejectedOn,
    this.accountDescription,
    this.centerLocation,
    this.partnerName,*/
  });

  factory IndividualExpensesApprovalDetail.fromJson(
          Map<String, dynamic> json) =>
      IndividualExpensesApprovalDetail(
        recordId: json["recordId"],
        employeeCMP_ID: json["employeeCMP_ID"],
        user_Code: json["user_Code"],
        employeeId: json["employeeId"],
        expenseCode: json["expenseCode"],
        ownerId: json["ownerId"],
        expenseDate: json["expenseDate"],
        partnerName: json["partnerName"],
        firstName: json["firstName"],
        expenseStatus: json["expenseStatus"],
        accountTypeCode: json["accountTypeCode"],
        accountDescription: json["accountDescription"],
        expenseDescription: json["expenseDescription"],
        expenseAmount: json["expenseAmount"],
        expenseType: json["expenseType"],
        centerLocation: json["centerLocation"],
        managerApproved_RejectedBy: json["managerApproved_RejectedBy"],
        managerApproved_RejectedOn: json["managerApproved_RejectedOn"],
        hoApproved_RejectedBy: json["hoApproved_RejectedBy"],
        hoApproved_RejectedOn: json["hoApproved_RejectedOn"],

        /*expenseCode: json["expenseCode"],
        ownerId: json["ownerId"],
        expenseDate: json["expenseDate"],
        staffName: json["staffName"],
        accountTypeCode: json["accountTypeCode"],
        expenseDescription: json["expenseDescription"],
        expenseType: json["expenseType"],
        expenseStatus: json["expenseStatus"],
        expenseAmount: json["expenseAmount"],
        recordId: json["recordId"],
        managerApprovedRejectedBy: json["managerApproved_RejectedBy"],
        managerApprovedRejectedOn: json["managerApproved_RejectedOn"],
        hoApprovedRejectedBy: json["hoApproved_RejectedBy"],
        hoApprovedRejectedOn: json["hoApproved_RejectedOn"],
        accountDescription: json["accountDescription"],
        centerLocation: json["centerLocation"],
        partnerName: json["partnerName"],*/
      );

  Map<String, dynamic> toJson() => {
        "recordId": recordId,
        "employeeCMP_ID": employeeCMP_ID,
        "user_Code": user_Code,
        "employeeId": employeeId,
        "expenseCode": expenseCode,
        "ownerId": ownerId,
        "expenseDate": expenseDate,
        "partnerName": partnerName,
        "firstName": firstName,
        "expenseStatus": expenseStatus,
        "accountTypeCode": accountTypeCode,
        "accountDescription": accountDescription,
        "expenseDescription": expenseDescription,
        "expenseAmount": expenseAmount,
        "expenseType": expenseType,
        "centerLocation": centerLocation,
        "managerApproved_RejectedBy": managerApproved_RejectedBy,
        "managerApproved_RejectedOn": managerApproved_RejectedOn,
        "hoApproved_RejectedBy": hoApproved_RejectedBy,
        "hoApproved_RejectedOn": hoApproved_RejectedOn,

        /*"expenseCode": expenseCode,
        "ownerId": ownerId,
        "expenseDate": expenseDate,
        "staffName": staffName,
        "accountTypeCode": accountTypeCode,
        "expenseDescription": expenseDescription,
        "expenseType": expenseType,
        "expenseStatus": expenseStatus,
        "expenseAmount": expenseAmount,
        "recordId": recordId,
        "managerApproved_RejectedBy": managerApprovedRejectedBy,
        "managerApproved_RejectedOn": managerApprovedRejectedOn,
        "hoApproved_RejectedBy": hoApprovedRejectedBy,
        "hoApproved_RejectedOn": hoApprovedRejectedOn,
        "accountDescription": accountDescription,
        "centerLocation": centerLocation,
        "partnerName": partnerName,*/
      };
}
