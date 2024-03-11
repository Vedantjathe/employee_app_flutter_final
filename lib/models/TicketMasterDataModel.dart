import 'dart:convert';

TicketMasterDataList welcomeFromJson(String str) =>
    TicketMasterDataList.fromJson(json.decode(str));

String welcomeToJson(TicketMasterDataList data) => json.encode(data.toJson());

class TicketMasterDataList {
  String lisResult;
  String lisMessage;
  List<TicketMasterData> ticketMastersDatas;

  TicketMasterDataList({
    required this.lisResult,
    required this.lisMessage,
    required this.ticketMastersDatas,
  });

  factory TicketMasterDataList.fromJson(Map<String, dynamic> json) =>
      TicketMasterDataList(
        lisResult: json["lisResult"],
        lisMessage: json["lisMessage"],
        ticketMastersDatas: List<TicketMasterData>.from(
            json["ticketMastersDatas"]
                .map((x) => TicketMasterData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "lisResult": lisResult,
        "lisMessage": lisMessage,
        "ticketMastersDatas":
            List<dynamic>.from(ticketMastersDatas.map((x) => x.toJson())),
      };
}

class TicketMasterData {
  String Targeted_Time;
  String is_AboveTat;
  String TicketID;
  String TicketRecordID;
  String OwnerID;
  String RaisedBy;
  String RaisedPersonContactNo;
  String TicketType;
  String Priority_Ticket;
  String TicketDescription;
  String TicketStatus;
  String CreatedOn;
  String CreatedBy;
  String ModeOfContact;
  String IssueReportedBy;
  String ContactName;
  String PatientName;
  String ReportedTo;
  String ActionTaken;
  String DetailsReceived;
  String TicketRemarks;
  String TicketCompletedOn;
  String Commentdate;
  String PatientRegDate;
  String PatientPRNO;
  String Department;
  String AcknowledgedOn;
  String AcknowledgedBy;
  String InProgressed_On;
  String InProgressed_By;
  String CompletedOn;
  String CompletedBy;
  String SolvedOn;
  String SolvedBy;
  String Reassigned_On;
  String Reassigned_By;
  String Reassigned_To;
  String Reassigned_To_ID;
  String ApproverName;
  String Is_Approved;
  String ApprovalOn;
  String Location_Name;
  String Pending_NewComment;
  String TAT;
  /*String ticketRecordID;
  String ticketID;
  String locationName;
  String ticketType;
  String ticketStatus;
  String createdBy;
  String createdOn;
  String raisedPersonContactNo;
  String department;
  String acknowledgedBy;
  String acknowledgedOn;
  String reassignedBy;
  String reassignedTo;
  String inProgressedBy;
  String inProgressedOn;
  String solvedBy;
  String solvedOn;
  String completedBy;
  String completedOn;
  String tat;
  String pendingNewComment;
  String priorityTicket;
  String isAboveTat;
  String isApproved;
  String approverName;
  String approvalOn;*/

  TicketMasterData({
    required this.Targeted_Time,
    required this.is_AboveTat,
    required this.TicketID,
    required this.TicketRecordID,
    required this.OwnerID,
    required this.RaisedBy,
    required this.RaisedPersonContactNo,
    required this.TicketType,
    required this.Priority_Ticket,
    required this.TicketDescription,
    required this.TicketStatus,
    required this.CreatedOn,
    required this.CreatedBy,
    required this.ModeOfContact,
    required this.IssueReportedBy,
    required this.ContactName,
    required this.PatientName,
    required this.ReportedTo,
    required this.ActionTaken,
    required this.DetailsReceived,
    required this.TicketRemarks,
    required this.TicketCompletedOn,
    required this.Commentdate,
    required this.PatientRegDate,
    required this.PatientPRNO,
    required this.Department,
    required this.AcknowledgedOn,
    required this.AcknowledgedBy,
    required this.InProgressed_On,
    required this.InProgressed_By,
    required this.CompletedOn,
    required this.CompletedBy,
    required this.SolvedOn,
    required this.SolvedBy,
    required this.Reassigned_On,
    required this.Reassigned_By,
    required this.Reassigned_To,
    required this.Reassigned_To_ID,
    required this.ApproverName,
    required this.Is_Approved,
    required this.ApprovalOn,
    required this.Location_Name,
    required this.Pending_NewComment,
    required this.TAT,

    /*required this.ticketRecordID,
    required this.ticketID,
    required this.locationName,
    required this.ticketType,
    required this.ticketStatus,
    required this.createdBy,
    required this.createdOn,
    required this.raisedPersonContactNo,
    required this.department,
    required this.acknowledgedBy,
    required this.acknowledgedOn,
    required this.reassignedBy,
    required this.reassignedTo,
    required this.inProgressedBy,
    required this.inProgressedOn,
    required this.solvedBy,
    required this.solvedOn,
    required this.completedBy,
    required this.completedOn,
    required this.tat,
    required this.pendingNewComment,
    required this.priorityTicket,
    required this.isAboveTat,
    required this.isApproved,
    required this.approverName,
    required this.approvalOn,*/
  });
/*{targeted_Time: , is_AboveTat: NO, ticketID: T47776, ticketRecordID: 47776,
ownerID: 108523, raisedBy: E16875, raisedPersonContactNo: 7038794310,
ticketType: CT MACHINE BREAKDOWN, priority_Ticket: Medium,
ticketDescription: lllfdsdf, ticketStatus: New, createdOn: Feb 28 2024  4:56PM,
createdBy: KOMAL SADAVARTE, modeOfContact: , issueReportedBy: CENTER MANAGER,
contactName: KOMAL SADAVARTE ( KRSNAA HEAD OFFICE ), patientName: ,
reportedTo: , actionTaken: , detailsReceived: , ticketRemarks: ,
ticketCompletedOn: , commentdate: 2/28/2024 4:56:05 PM,
patientRegDate: , patientPRNO: , department: BIOMEDICAL,
acknowledgedOn: , acknowledgedBy: , inProgressed_On: ,
inProgressed_By: , completedOn: , completedBy: , solvedOn: , solvedBy: , reassigned_On: , reassigned_By: , reassigned_To: , reassigned_To_ID: , approverName: , is_Approved: False, approvalOn: , location_Name: PB MOHALI, pending_NewComment: 0, tat: }*/
  factory TicketMasterData.fromJson(Map<String, dynamic> json) =>
      TicketMasterData(
        Targeted_Time: json["targeted_Time"].toString(),
        is_AboveTat: json["is_AboveTat"].toString(),
        TicketID: json["ticketID"].toString(),
        TicketRecordID: json["ticketRecordID"].toString(),
        OwnerID: json["ownerID"].toString(),
        RaisedBy: json["raisedBy"].toString(),
        RaisedPersonContactNo: json["raisedPersonContactNo"].toString(),
        TicketType: json["ticketType"].toString(),
        Priority_Ticket: json["priority_Ticket"].toString(),
        TicketDescription: json["ticketDescription"].toString(),
        TicketStatus: json["ticketStatus"].toString(),
        CreatedOn: json["createdOn"].toString(),
        CreatedBy: json["createdBy"].toString(),
        ModeOfContact: json["modeOfContact"].toString(),
        IssueReportedBy: json["issueReportedBy"].toString(),
        ContactName: json["contactName"].toString(),
        PatientName: json["patientName"].toString(),
        ReportedTo: json["reportedTo"].toString(),
        ActionTaken: json["actionTaken"].toString(),
        DetailsReceived: json["detailsReceived"].toString(),
        TicketRemarks: json["ticketRemarks"].toString(),
        TicketCompletedOn: json["ticketCompletedOn"].toString(),
        Commentdate: json["commentdate"].toString(),
        PatientRegDate: json["patientRegDate"].toString(),
        PatientPRNO: json["patientPRNO"].toString(),
        Department: json["department"].toString(),
        AcknowledgedOn: json["acknowledgedOn"].toString(),
        AcknowledgedBy: json["acknowledgedBy"].toString(),
        InProgressed_On: json["inProgressed_On"].toString(),
        InProgressed_By: json["inProgressed_By"].toString(),
        CompletedOn: json["completedOn"].toString(),
        CompletedBy: json["completedBy"].toString(),
        SolvedOn: json["solvedOn"].toString(),
        SolvedBy: json["solvedBy"].toString(),
        Reassigned_On: json["reassigned_On"].toString(),
        Reassigned_By: json["reassigned_By"].toString(),
        Reassigned_To: json["reassigned_To"].toString(),
        Reassigned_To_ID: json["reassigned_To_ID"].toString(),
        ApproverName: json["approverName"].toString(),
        Is_Approved: json["is_Approved"].toString(),
        ApprovalOn: json["approvalOn"].toString(),
        Location_Name: json["location_Name"].toString(),
        Pending_NewComment: json["pending_NewComment"].toString(),
        TAT: json["tat"].toString(),
/*completedBy: ,
solvedOn: , solvedBy: , reassigned_On: ,
reassigned_By: , reassigned_To: , reassigned_To_ID: ,
approverName: , is_Approved: False, approvalOn: ,
 location_Name: PB MOHALI, pending_NewComment: 0, tat: }*/
        /*ticketRecordID: json["ticketRecordID"].toString(),
        ticketID: json["ticketID"].toString(),
        locationName: json["location_Name"].toString(),
        ticketType: json["ticketType"].toString(),
        ticketStatus: json["ticketStatus"].toString(),
        createdBy: json["createdBy"].toString(),
        createdOn: json["createdOn"].toString(),
        raisedPersonContactNo: json["raisedPersonContactNo"].toString(),
        department: json["department"].toString(),
        acknowledgedBy: json["acknowledgedBy"].toString(),
        acknowledgedOn: json["acknowledgedOn"].toString(),
        reassignedBy: json["reassigned_By"].toString(),
        reassignedTo: json["reassigned_To"].toString(),
        inProgressedBy: json["inProgressed_By"].toString(),
        inProgressedOn: json["inProgressed_On"].toString(),
        solvedBy: json["solvedBy"].toString(),
        solvedOn: json["solvedOn"].toString(),
        completedBy: json["completedBy"].toString(),
        completedOn: json["completedOn"].toString(),
        tat: json["tat"].toString(),
        pendingNewComment: json["pendingNewComment"].toString(),
        priorityTicket: json["priority_Ticket"].toString(),
        isAboveTat: json["is_AboveTat"].toString(),
        isApproved: json["is_Approved"].toString(),
        approverName: json["approverName"].toString(),
        approvalOn: json["approvalOn"].toString(),*/
      );

  Map<String, dynamic> toJson() => {
        "Targeted_Time": Targeted_Time,
        "is_AboveTat": is_AboveTat,
        "TicketID": TicketID,
        "TicketRecordID": TicketRecordID,
        "OwnerID": OwnerID,
        "RaisedBy": RaisedBy,
        "RaisedPersonContactNo": RaisedPersonContactNo,
        "TicketType": TicketType,
        "Priority_Ticket": Priority_Ticket,
        "TicketDescription": TicketDescription,
        "TicketStatus": TicketStatus,
        "CreatedOn": CreatedOn,
        "CreatedBy": CreatedBy,
        "ModeOfContact": ModeOfContact,
        "IssueReportedBy": IssueReportedBy,
        "ContactName": ContactName,
        "PatientName": PatientName,
        "ReportedTo": ReportedTo,
        "ActionTaken": ActionTaken,
        "DetailsReceived": DetailsReceived,
        "TicketRemarks": TicketRemarks,
        "TicketCompletedOn": TicketCompletedOn,
        "Commentdate": Commentdate,
        "PatientRegDate": PatientRegDate,
        "PatientPRNO": PatientPRNO,
        "Department": Department,
        "AcknowledgedOn": AcknowledgedOn,
        "AcknowledgedBy": AcknowledgedBy,
        "InProgressed_On": InProgressed_On,
        "InProgressed_By": InProgressed_By,
        "CompletedOn": CompletedOn,
        "CompletedBy": CompletedBy,
        "SolvedOn": SolvedOn,
        "SolvedBy": SolvedBy,
        "Reassigned_On": Reassigned_On,
        "Reassigned_By": Reassigned_By,
        "Reassigned_To": Reassigned_To,
        "Reassigned_To_ID": Reassigned_To_ID,
        "ApproverName": ApproverName,
        "Is_Approved": Is_Approved,
        "ApprovalOn": ApprovalOn,
        "Location_Name": Location_Name,
        "Pending_NewComment": Pending_NewComment,
        "TAT": TAT,

        /*"ticketRecordID": ticketRecordID,
        "ticketID": ticketID,
        "location_Name": locationName,
        "ticketType": ticketType,
        "ticketStatus": ticketStatus,
        "createdBy": createdBy,
        "createdOn": createdOn,
        "raisedPersonContactNo": raisedPersonContactNo,
        "department": department,
        "acknowledgedBy": acknowledgedBy,
        "acknowledgedOn": acknowledgedOn,
        "reassigned_By": reassignedBy,
        "reassigned_To": reassignedTo,
        "inProgressed_By": inProgressedBy,
        "inProgressed_On": inProgressedOn,
        "solvedBy": solvedBy,
        "solvedOn": solvedOn,
        "completedBy": completedBy,
        "completedOn": completedOn,
        "tat": tat,
        "pendingNewComment": pendingNewComment,
        "priority_Ticket": priorityTicket,
        "is_AboveTat": isAboveTat,
        "is_Approved": isApproved,
        "approverName": approverName,
        "approvalOn": approvalOn,*/
      };
}
