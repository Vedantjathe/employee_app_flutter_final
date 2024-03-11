
class LoadDashboard {
  final String lisResult;
  final String lisMessage;
  final List<LoadDashboardDetails> loadDashboardDetails;

  LoadDashboard({
    required this.lisResult,
    required this.lisMessage,
    required this.loadDashboardDetails,
  });

  factory LoadDashboard.fromJson(Map<String, dynamic> json) {
    var detailsList = json['loadDashboard_Details'] as List;
    List<LoadDashboardDetails> details = detailsList
        .map((detail) => LoadDashboardDetails.fromJson(detail))
        .toList();

    return LoadDashboard(
      lisResult: json['lisResult'] ?? '',
      lisMessage: json['lisMessage'] ?? '',
      loadDashboardDetails: details,
    );
  }
}

class LoadDashboardDetails {
  final String totPathoPatient;
  final String totRadioPatient;
  final String totPathoTestCount;
  final String totRadioTestCount;
  final String totPathoBillAmount;
  final String totRadioBillAmount;
  final String totPathoAveragePrice;
  final String totRadioAveragePrice;
  final String totPendingCollectionPatho;
  final String totPendingForAccessionPatho;
  final String totPendingEntryPatho;
  final String totPendingAuthorizePatho;
  final String totPendingApprovePatho;
  final String totPendingRadioConfirmation;

  LoadDashboardDetails({
    required this.totPathoPatient,
    required this.totRadioPatient,
    required this.totPathoTestCount,
    required this.totRadioTestCount,
    required this.totPathoBillAmount,
    required this.totRadioBillAmount,
    required this.totPathoAveragePrice,
    required this.totRadioAveragePrice,
    required this.totPendingCollectionPatho,
    required this.totPendingForAccessionPatho,
    required this.totPendingEntryPatho,
    required this.totPendingAuthorizePatho,
    required this.totPendingApprovePatho,
    required this.totPendingRadioConfirmation,
  });

  factory LoadDashboardDetails.fromJson(Map<String, dynamic> json) {
    return LoadDashboardDetails(
      totPathoPatient: json['tot_Patho_Patient'] ?? '',
      totRadioPatient: json['tot_Radio_Patient'] ?? '',
      totPathoTestCount: json['tot_Patho_TestCount'] ?? '',
      totRadioTestCount: json['tot_Radio_TestCount'] ?? '',
      totPathoBillAmount: json['tot_Patho_BillAmount'] ?? '',
      totRadioBillAmount: json['tot_Radio_BillAmount'] ?? '',
      totPathoAveragePrice: json['tot_Patho_AveragePrice'] ?? '',
      totRadioAveragePrice: json['tot_Radio_AveragePrice'] ?? '',
      totPendingCollectionPatho: json['totPendingCollection_Patho'] ?? '',
      totPendingForAccessionPatho: json['totPendingForAccession_Patho'] ?? '',
      totPendingEntryPatho: json['totPendingEntry_Patho'] ?? '',
      totPendingAuthorizePatho: json['totPendingAuthorize_Patho'] ?? '',
      totPendingApprovePatho: json['totPendingApprove_Patho'] ?? '',
      totPendingRadioConfirmation: json['totPendingRadio_Confirmation'] ?? '',
    );
  }
}




















