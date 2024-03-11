class LoadCenterDetails {
  final String lisResult;
  final String lisMessage;
  final List<CenterDetails> loadCenterDetails;

  LoadCenterDetails({
    required this.lisResult,
    required this.lisMessage,
    required this.loadCenterDetails,
  });

  factory LoadCenterDetails.fromJson(Map<String, dynamic> json) {
    var centerList = json['loadCenter_Details'] as List;
    List<CenterDetails> centers =
        centerList.map((center) => CenterDetails.fromJson(center)).toList();

    return LoadCenterDetails(
      lisResult: json['lisResult'] ?? "",
      lisMessage: json['lisMessage'] ?? "",
      loadCenterDetails: centers,
    );
  }
}

class CenterDetails {
  final String centerName;
  final String centerCode;

  CenterDetails({
    required this.centerName,
    required this.centerCode,
  });

  factory CenterDetails.fromJson(Map<String, dynamic> json) {
    return CenterDetails(
      centerName: json['centerName'] ?? "",
      centerCode: json['centerCode'] ?? "",
    );
  }
}
