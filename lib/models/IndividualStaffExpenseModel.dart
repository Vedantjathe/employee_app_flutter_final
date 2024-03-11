class ExpenseDetailsModel {
  String lisResult;
  String expenseCode;
  String createdOn;
  String expenseDate;
  String staffName;
  String accountTypeCode;
  String expenseDescription;
  double expenseAmount;
  String expenseStatus;
  String ownerId;
  String recordId;
  String preparedBy;
  String preparedOn;
  String accountDescription;
  String paymentMode;
  String onlineEXPFilePath;
  String rejectReason;
  String expenseType;
  String centerLocation;
  String kilometer;
  String kmAmount;
  String travellingFrom;
  String travellingTo;
  String noOfPeople;
  String travellingKM;
  String expenseBookingDate;
  String travel_ID;

  ExpenseDetailsModel({
    required this.lisResult,
    required this.expenseCode,
    required this.createdOn,
    required this.expenseDate,
    required this.staffName,
    required this.accountTypeCode,
    required this.expenseDescription,
    required this.expenseAmount,
    required this.expenseStatus,
    required this.ownerId,
    required this.recordId,
    required this.preparedBy,
    required this.preparedOn,
    required this.accountDescription,
    required this.paymentMode,
    required this.onlineEXPFilePath,
    required this.rejectReason,
    required this.expenseType,
    required this.centerLocation,
    required this.kilometer,
    required this.kmAmount,
    required this.travellingFrom,
    required this.travellingTo,
    required this.noOfPeople,
    required this.travellingKM,
    required this.expenseBookingDate,
    required this.travel_ID,
  });

  factory ExpenseDetailsModel.fromJson(Map<String, dynamic> data) {
    return ExpenseDetailsModel(
      lisResult: data['lisResult'] as String,
      expenseCode: data['expenseCode'] as String,
      createdOn: data['createdOn'] as String,
      expenseDate: data['expenseDate'] as String,
      staffName: data['staffName'] as String,
      accountTypeCode: data['accountTypeCode'] as String,
      expenseDescription: data['expenseDescription'] as String,
      expenseAmount: double.parse(data['expenseAmount']),
      expenseStatus: data['expenseStatus'] as String,
      ownerId: data['ownerId'] as String,
      recordId: data['recordId'] as String,
      preparedBy: data['preparedBy'] as String,
      preparedOn: data['preparedOn'] as String,
      accountDescription: data['accountDescription'] as String,
      paymentMode: data['paymentMode'] as String,
      onlineEXPFilePath: data['onlineEXPFilePath'] as String,
      rejectReason: data['rejectReason'] as String,
      expenseType: data['expenseType'] as String,
      centerLocation: data['centerLocation'] as String,
      kilometer: data['kilometer'] as String,
      kmAmount: data['kmAmount'] as String,
      travellingFrom: data['travellingFrom'] as String,
      travellingTo: data['travellingTo'] as String,
      noOfPeople: data['noOfPeople'] as String,
      travellingKM: data['travellingKM'] as String,
      expenseBookingDate: data['expenseBookingDate'] as String,
      travel_ID: data['travel_ID'] as String,
    );
  }
}
