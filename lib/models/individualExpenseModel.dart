class LoadIndividualExpensesDetail {
  String lisResult;
  List<ExpenseDetail> loadIndividualExpensesDetails;

  LoadIndividualExpensesDetail({
    required this.lisResult,
    required this.loadIndividualExpensesDetails,
  });

  factory LoadIndividualExpensesDetail.fromJson(Map<String, dynamic> json) =>
      LoadIndividualExpensesDetail(
        lisResult: json["lisResult"].toString(),
        loadIndividualExpensesDetails: List<ExpenseDetail>.from(
          json["loadIndividualExpenses_Details"]
              .map((x) => ExpenseDetail.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "lisResult": lisResult,
        "loadIndividualExpenses_Details": List<dynamic>.from(
            loadIndividualExpensesDetails.map((x) => x.toJson())),
      };
}

class ExpenseDetail {
  /*String expenseCode;
  String ownerId;
  String expenseDate;
  String firstName;
  String accountTypeCode;
  String expenseDescription;
  String expenseType;
  String expenseStatus;
  double expenseAmount;
  String recordId;
  String accountDescription;
  String centerLocation;
  String partnerName;
  String expenseBookingDate;*/
  String recordId;
  String expenseCode;
  String ownerId;
  String expenseDate;
  String partnerName;
  String firstName;
  String expenseStatus;
  String accountTypeCode;
  String accountDescription;
  String expenseDescription;
  String expenseAmount;
  String expenseType;
  String centerLocation;
  String employeeCMP_ID;
  String expenseBookingDate;
  String managerApproved_RejectedBy;
  String managerApproved_RejectedOn;
  String hoApproved_RejectedBy;
  String hoApproved_RejectedOn;

  ExpenseDetail({
    required this.recordId,
    required this.expenseCode,
    required this.ownerId,
    required this.expenseDate,
    required this.partnerName,
    required this.firstName,
    required this.expenseStatus,
    required this.accountTypeCode,
    required this.accountDescription,
    required this.expenseDescription,
    required this.expenseAmount,
    required this.expenseType,
    required this.centerLocation,
    required this.employeeCMP_ID,
    required this.expenseBookingDate,
    required this.managerApproved_RejectedBy,
    required this.managerApproved_RejectedOn,
    required this.hoApproved_RejectedBy,
    required this.hoApproved_RejectedOn,
  });

  factory ExpenseDetail.fromJson(Map<String, dynamic> json) => ExpenseDetail(
        /*expenseCode: json["expenseCode"].toString(),
        ownerId: json["ownerId"].toString(),
        expenseDate: json["expenseDate"].toString(),
        firstName: json["firstName"].toString(),
        accountTypeCode: json["accountTypeCode"].toString(),
        expenseDescription: json["expenseDescription"].toString(),
        expenseType: json["expenseType"].toString(),
        expenseStatus: json["expenseStatus"].toString(),
        expenseAmount: double.parse(json["expenseAmount"].toString()),
        recordId: json["recordId"].toString(),
        accountDescription: json["accountDescription"].toString(),
        centerLocation: json["centerLocation"].toString(),
        partnerName: json["partnerName"].toString(),
        expenseBookingDate: json["expenseBookingDate"].toString(),*/

        recordId: json["recordId"].toString(),
        expenseCode: json["expenseCode"].toString(),
        ownerId: json["ownerId"].toString(),
        expenseDate: json["expenseDate"].toString(),
        partnerName: json["partnerName"].toString(),
        firstName: json["firstName"].toString(),
        expenseStatus: json["expenseStatus"].toString(),
        accountTypeCode: json["accountTypeCode"].toString(),
        accountDescription: json["accountDescription"].toString(),
        expenseDescription: json["expenseDescription"].toString(),
        expenseAmount: json["expenseAmount"].toString(),
        expenseType: json["expenseType"].toString(),
        centerLocation: json["centerLocation"].toString(),
        employeeCMP_ID: json["employeeCMP_ID"].toString(),
        expenseBookingDate: json["expenseBookingDate"].toString(),
        managerApproved_RejectedBy:
            json["managerApproved_RejectedBy"].toString(),
        managerApproved_RejectedOn:
            json["managerApproved_RejectedOn"].toString(),
        hoApproved_RejectedBy: json["hoApproved_RejectedBy"].toString(),
        hoApproved_RejectedOn: json["hoApproved_RejectedOn"].toString(),
      );

  Map<String, dynamic> toJson() => {
        /*"expenseCode": expenseCode,
        "ownerId": ownerId,
        "expenseDate": expenseDate,
        "firstName": firstName,
        "accountTypeCode": accountTypeCode,
        "expenseDescription": expenseDescription,
        "expenseType": expenseType,
        "expenseStatus": expenseStatus,
        "expenseAmount": expenseAmount,
        "recordId": recordId,
        "accountDescription": accountDescription,
        "centerLocation": centerLocation,
        "partnerName": partnerName,
        "expenseBookingDate": expenseBookingDate,*/

        "recordId": recordId,
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
        "employeeCMP_ID": employeeCMP_ID,
        "expenseBookingDate": expenseBookingDate,
        "managerApproved_RejectedBy": managerApproved_RejectedBy,
        "managerApproved_RejectedOn": managerApproved_RejectedOn,
        "hoApproved_RejectedBy": hoApproved_RejectedBy,
        "hoApproved_RejectedOn": hoApproved_RejectedOn,
      };
}
