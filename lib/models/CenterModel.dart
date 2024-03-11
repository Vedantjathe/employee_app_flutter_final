class CenterModel {
  String locationCode;
  String locationName;

  CenterModel({
    required this.locationCode,
    required this.locationName,
  });

  Map<String, dynamic> toMap() =>
      {"locationCode": this.locationCode, "locationName": this.locationName};

  factory CenterModel.fromJson(Map<String, dynamic> data) {
    final locationCode = data['locationCode'] as String;
    final locationName = data['locationName'] as String;

    return CenterModel(locationCode: locationCode, locationName: locationName);
  }
}
