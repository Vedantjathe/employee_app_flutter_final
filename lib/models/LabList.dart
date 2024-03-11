class Location {
  final String locationCode;
  final String locationName;

  Location({required this.locationCode, required this.locationName});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      locationCode: json['locationCode'],
      locationName: json['locationName'],
    );
  }
}
