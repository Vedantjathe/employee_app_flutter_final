class AccountDetails {
  final String lisResult;
  final String lisMessage;
  final List<AccountItem> loadAccountDetails;

  AccountDetails({
    required this.lisResult,
    required this.lisMessage,
    required this.loadAccountDetails,
  });

  factory AccountDetails.fromJson(Map<String, dynamic> json) {
    List<dynamic> loadAccountDetailsJson = json['loadAccount_Details'];
    List<AccountItem> loadAccountDetails = loadAccountDetailsJson
        .map((itemJson) => AccountItem.fromJson(itemJson))
        .toList();

    return AccountDetails(
      lisResult: json['lisResult'],
      lisMessage: json['lisMessage'],
      loadAccountDetails: loadAccountDetails,
    );
  }
}

class AccountItem {
  final String accountType;
  final String accountName;

  AccountItem({required this.accountType, required this.accountName});

  factory AccountItem.fromJson(Map<String, dynamic> json) {
    return AccountItem(
      accountType: json['accountType'],
      accountName: json['accountName'],
    );
  }
}
