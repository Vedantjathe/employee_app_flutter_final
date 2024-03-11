

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  String lisResult;
  String lisMessage;
  List<LoadDailyExpenseDetail> loadDailyExpenseDetails;

  Welcome({
    required this.lisResult,
    required this.lisMessage,
    required this.loadDailyExpenseDetails,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
    lisResult: json["lisResult"],
    lisMessage: json["lisMessage"],
    loadDailyExpenseDetails: List<LoadDailyExpenseDetail>.from(json["loadDailyExpense_Details"].map((x) => LoadDailyExpenseDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "lisResult": lisResult,
    "lisMessage": lisMessage,
    "loadDailyExpense_Details": List<dynamic>.from(loadDailyExpenseDetails.map((x) => x.toJson())),
  };
}

class LoadDailyExpenseDetail {
  String recordId;
  String expenseCode;
  String ownerId;
  DateTime expenseDate;
  String partnerName;
  String firstName;
  String expenseStatus;
  String accountTypeCode;
  String accountDescription;
  String expenseDescription;
  double expenseAmount;
  String expenseType;

  LoadDailyExpenseDetail({
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
  });

  factory LoadDailyExpenseDetail.fromJson(Map<String, dynamic> json) => LoadDailyExpenseDetail(
    recordId: json["recordId"].toString(),
    expenseCode: json["expenseCode"].toString(),
    ownerId: json["ownerId"].toString(),
    expenseDate: DateTime.parse(json["expenseDate"].toString()),
    partnerName: json["partnerName"].toString(),
    firstName: json["firstName"].toString(),
    expenseStatus: json["expenseStatus"].toString(),
    accountTypeCode: json["accountTypeCode"].toString(),
    accountDescription: json["accountDescription"].toString(),
    expenseDescription: json["expenseDescription"].toString(),
    expenseAmount: double.parse(json["expenseAmount"].toString()),
    expenseType: json["expenseType"].toString(),
  );




  Map<String, dynamic> toJson() => {
    "recordId": recordId,
    "expenseCode": expenseCode,
    "ownerId": ownerId,
    "expenseDate": expenseDate.toIso8601String(),
    "partnerName": partnerName,
    "firstName": firstName,
    "expenseStatus": expenseStatus,
    "accountTypeCode": accountTypeCode,
    "accountDescription": accountDescription,
    "expenseDescription": expenseDescription,
    "expenseAmount": expenseAmount,
    "expenseType": expenseType,
  };
}











