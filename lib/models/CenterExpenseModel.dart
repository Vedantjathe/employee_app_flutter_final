class CenterExpenseModel {
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
  double expenseAmount;
  String expenseType;

  CenterExpenseModel({
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

  Map<String, dynamic> toMap() => {
        "recordId": this.recordId,
        "expenseCode": this.expenseCode,
        "ownerId": this.ownerId,
        "expenseDate": this.expenseDate,
        "partnerName": this.partnerName,
        "firstName": this.firstName,
        "expenseStatus": this.expenseStatus,
        "accountTypeCode": this.accountTypeCode,
        "accountDescription": this.accountDescription,
        "expenseDescription": this.expenseDescription,
        "expenseAmount": this.expenseAmount,
        "expenseType": this.expenseType
      };

  factory CenterExpenseModel.fromJson(Map<String, dynamic> data) {
    final recordId = data['recordId'] as String;
    final expenseCode = data['expenseCode'] as String;
    final ownerId = data['ownerId'] as String;
    final expenseDate = data['expenseDate'] as String;
    final partnerName = data['partnerName'] as String;
    final firstName = data['firstName'] as String;
    final expenseStatus = data['expenseStatus'] as String;
    final accountTypeCode = data['accountTypeCode'] as String;
    final accountDescription = data['accountDescription'] as String;
    final expenseDescription = data['expenseDescription'] as String;
    final expenseAmount = data['expenseAmount'] as double;
    final expenseType = data['expenseType'] as String;

    return CenterExpenseModel(
        recordId: recordId,
        expenseCode: expenseCode,
        ownerId: ownerId,
        expenseDate: expenseDate,
        partnerName: partnerName,
        firstName: firstName,
        expenseStatus: expenseStatus,
        accountTypeCode: accountTypeCode,
        accountDescription: accountDescription,
        expenseDescription: expenseDescription,
        expenseAmount: expenseAmount,
        expenseType: expenseType);
  }
}
