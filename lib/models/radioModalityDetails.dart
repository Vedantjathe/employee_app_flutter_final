class ModalityDetails {
  final String modality;
  final String patientCount;
  final String testCount;
  final String billAmount;

  ModalityDetails({
    required this.modality,
    required this.patientCount,
    required this.testCount,
    required this.billAmount,
  });

  factory ModalityDetails.fromJson(Map<String, dynamic> json) {
    return ModalityDetails(
      modality: json['modality'],
      patientCount: json['patient_Count'],
      testCount: json['test_Count'],
      billAmount: json['billAmount'],
    );
  }
}

class ResponseData {
  final String lisResult;
  final String lisMessage;
  final List<ModalityDetails> modalityDetails;

  ResponseData({
    required this.lisResult,
    required this.lisMessage,
    required this.modalityDetails,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    var detailsList = json['load_Radio_Modality_Details'] as List;
    List<ModalityDetails> details = detailsList.map((e) => ModalityDetails.fromJson(e)).toList();

    return ResponseData(
      lisResult: json['lisResult'],
      lisMessage: json['lisMessage'],
      modalityDetails: details,
    );
  }
}
