
class LedgerPageDataModel {
  String? lisResult;
  String? lisMessage;
  List<LoadLedgerList>? loadLedgerList;

  LedgerPageDataModel({this.lisResult, this.lisMessage, this.loadLedgerList});

  LedgerPageDataModel.fromJson(Map<String, dynamic> json) {
    lisResult = json['lisResult'];
    lisMessage = json['lisMessage'];
    if (json['loadLedgerList'] != null) {
      loadLedgerList = <LoadLedgerList>[];
      json['loadLedgerList'].forEach((v) {
        loadLedgerList!.add(new LoadLedgerList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lisResult'] = this.lisResult;
    data['lisMessage'] = this.lisMessage;
    if (this.loadLedgerList != null) {
      data['loadLedgerList'] =
          this.loadLedgerList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LoadLedgerList {
  String? accountCode;
  String? staffName;
  String? staffCode;
  String? openingBalance;
  String? advanceAmount;
  String? expenseAmount;
  String? creditAmount;
  String? debitAmount;
  String? closingBalance;

  LoadLedgerList(
      {this.accountCode,
        this.staffName,
        this.staffCode,
        this.openingBalance,
        this.advanceAmount,
        this.expenseAmount,
        this.creditAmount,
        this.debitAmount,
        this.closingBalance});

  LoadLedgerList.fromJson(Map<String, dynamic> json) {
    accountCode = json['accountCode'];
    staffName = json['staffName'];
    staffCode = json['staffCode'];
    openingBalance = json['openingBalance'];
    advanceAmount = json['advanceAmount'];
    expenseAmount = json['expenseAmount'];
    creditAmount = json['creditAmount'];
    debitAmount = json['debitAmount'];
    closingBalance = json['closingBalance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accountCode'] = this.accountCode;
    data['staffName'] = this.staffName;
    data['staffCode'] = this.staffCode;
    data['openingBalance'] = this.openingBalance;
    data['advanceAmount'] = this.advanceAmount;
    data['expenseAmount'] = this.expenseAmount;
    data['creditAmount'] = this.creditAmount;
    data['debitAmount'] = this.debitAmount;
    data['closingBalance'] = this.closingBalance;
    return data;
  }
}