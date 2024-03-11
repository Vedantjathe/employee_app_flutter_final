class ExpenseDataModel {
  String? lisResult;
  String? lisMessage;
  List<ExpenseItem>? expenseAmountList;

  ExpenseDataModel({this.lisResult, this.lisMessage, this.expenseAmountList});

  ExpenseDataModel.fromJson(Map<String, dynamic> json) {
    lisResult = json['lisResult'];
    lisMessage = json['lisMessage'];
    if (json['expenseAmountList'] != null) {
      expenseAmountList = <ExpenseItem>[];
      json['expenseAmountList'].forEach((v) {
        expenseAmountList!.add(new ExpenseItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lisResult'] = this.lisResult;
    data['lisMessage'] = this.lisMessage;
    if (this.expenseAmountList != null) {
      data['expenseAmountList'] =
          this.expenseAmountList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ExpenseItem {
  String? registeredDate;
  String? individualExpType;
  String? centerLocation;
  String? expenseAmount;

  ExpenseItem({
    this.registeredDate,
    this.individualExpType,
    this.centerLocation,
    this.expenseAmount,
  });

  ExpenseItem.fromJson(Map<String, dynamic> json) {
    registeredDate = json['registereddate'];
    individualExpType = json['individualexptype'];
    centerLocation = json['centerlocation'];
    expenseAmount = json['expenseamount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['registereddate'] = this.registeredDate;
    data['individualexptype'] = this.individualExpType;
    data['centerlocation'] = this.centerLocation;
    data['expenseamount'] = this.expenseAmount;
    return data;
  }
}
