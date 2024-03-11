class TicketDetailsResponse {
  String? lisResult;
  String? lisMessage;
  String? issuereportedby;
  String? contactName;
  String? raisedPersonContactNo;
  String? ticketStatus;
  String? modeOfContact;
  String? department;
  String? ticketType;
  String? centerCode;
  String? patientName;
  String? ticketDescription;
  String? patientRegDate;
  String? patientPRNO;
  String? acknowledgedOn;
  String? acknowledgedBy;
  String? inProgressedOn;
  String? inProgressedBy;
  String? completedOn;
  String? completedBy;
  String? solvedOn;
  String? solvedBy;
  String? createdBy;
  String? rejectedReason;
  String? acknowledge;
  bool? btnSubmit;
  bool? btnUpdate;
  bool? btnupload;
  bool? btnReassign;
  bool? btnHold;
  bool? btnReject;
  bool? btnResume;
  bool? btnACK;
  bool? btnUpdateProgress;
  bool? btnCompleted;
  bool? btnSolved;
  bool? divComments;
  bool? divUploadFiles;
  bool? divAck;
  bool? divCompleted;
  bool? divSolved;
  bool? divProgress;
  bool? divAssign;
  bool? divReject;
  List<TicketCommentLists>? ticketCommentLists;
  List<TicketAttachmentLists>? ticketAttachmentLists;
  String? priority;
  String? ticketActionTaken;
  String? isApprovalNeeded;

  TicketDetailsResponse({
    this.lisResult,
    this.lisMessage,
    this.issuereportedby,
    this.contactName,
    this.raisedPersonContactNo,
    this.ticketStatus,
    this.modeOfContact,
    this.department,
    this.ticketType,
    this.centerCode,
    this.patientName,
    this.ticketDescription,
    this.patientRegDate,
    this.patientPRNO,
    this.acknowledgedOn,
    this.acknowledgedBy,
    this.inProgressedOn,
    this.inProgressedBy,
    this.completedOn,
    this.completedBy,
    this.solvedOn,
    this.solvedBy,
    this.createdBy,
    this.rejectedReason,
    this.acknowledge,
    this.btnSubmit,
    this.btnUpdate,
    this.btnupload,
    this.btnReassign,
    this.btnHold,
    this.btnReject,
    this.btnResume,
    this.btnACK,
    this.btnUpdateProgress,
    this.btnCompleted,
    this.btnSolved,
    this.divComments,
    this.divUploadFiles,
    this.divAck,
    this.divCompleted,
    this.divSolved,
    this.divProgress,
    this.divAssign,
    this.divReject,
    this.ticketCommentLists = const [],
    this.ticketAttachmentLists = const [],
    this.priority,
    this.ticketActionTaken,
    this.isApprovalNeeded,
  });

  TicketDetailsResponse.fromJson(Map<String, dynamic> json) {
    lisResult = json['lisResult'];
    lisMessage = json['lisMessage'];
    issuereportedby = json['issuereportedby'];
    contactName = json['contactName'];
    raisedPersonContactNo = json['raisedPersonContactNo'];
    ticketStatus = json['ticketStatus'];
    modeOfContact = json['modeOfContact'];
    department = json['department'];
    ticketType = json['ticketType'];
    centerCode = json['centerCode'];
    patientName = json['patientName'];
    ticketDescription = json['ticketDescription'];
    patientRegDate = json['patientRegDate'];
    patientPRNO = json['patientPRNO'];
    acknowledgedOn = json['acknowledgedOn'];
    acknowledgedBy = json['acknowledgedBy'];
    inProgressedOn = json['inProgressed_On'];
    inProgressedBy = json['inProgressed_By'];
    completedOn = json['completedOn'];
    completedBy = json['completedBy'];
    solvedOn = json['solvedOn'];
    solvedBy = json['solvedBy'];
    createdBy = json['createdBy'];
    rejectedReason = json['rejected_Reason'];
    acknowledge = json['acknowledge'];
    btnSubmit = json['btnSubmit'];
    btnUpdate = json['btnUpdate'];
    btnupload = json['btnupload'];
    btnReassign = json['btnReassign'];
    btnHold = json['btnHold'];
    btnReject = json['btnReject'];
    btnResume = json['btnResume'];
    btnACK = json['btnACK'];
    btnUpdateProgress = json['btnUpdateProgress'];
    btnCompleted = json['btnCompleted'];
    btnSolved = json['btnSolved'];
    divComments = json['div_Comments'];
    divUploadFiles = json['divUploadFiles'];
    divAck = json['div_Ack'];
    divCompleted = json['div_Completed'];
    divSolved = json['div_Solved'];
    divProgress = json['div_Progress'];
    divAssign = json['div_Assign'];
    divReject = json['div_Reject'];
    if (json['ticket_Comment_Lists'] != null) {
      ticketCommentLists = <TicketCommentLists>[];
      json['ticket_Comment_Lists'].forEach((v) {
        ticketCommentLists!.add(TicketCommentLists.fromJson(v));
      });
    }
    if (json['ticket_Attachment_Lists'] != null) {
      ticketAttachmentLists = <TicketAttachmentLists>[];
      json['ticket_Attachment_Lists'].forEach((v) {
        ticketAttachmentLists!.add(TicketAttachmentLists.fromJson(v));
      });
    }
    priority = json['priority'];
    ticketActionTaken = json['ticketActionTaken'];
    isApprovalNeeded = json['isApprovalNeeded'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lisResult'] = lisResult;
    data['lisMessage'] = lisMessage;
    data['issuereportedby'] = issuereportedby;
    data['contactName'] = contactName;
    data['raisedPersonContactNo'] = raisedPersonContactNo;
    data['ticketStatus'] = ticketStatus;
    data['modeOfContact'] = modeOfContact;
    data['department'] = department;
    data['ticketType'] = ticketType;
    data['centerCode'] = centerCode;
    data['patientName'] = patientName;
    data['ticketDescription'] = ticketDescription;
    data['patientRegDate'] = patientRegDate;
    data['patientPRNO'] = patientPRNO;
    data['acknowledgedOn'] = acknowledgedOn;
    data['acknowledgedBy'] = acknowledgedBy;
    data['inProgressed_On'] = inProgressedOn;
    data['inProgressed_By'] = inProgressedBy;
    data['completedOn'] = completedOn;
    data['completedBy'] = completedBy;
    data['solvedOn'] = solvedOn;
    data['solvedBy'] = solvedBy;
    data['createdBy'] = createdBy;
    data['rejected_Reason'] = rejectedReason;
    data['acknowledge'] = acknowledge;
    data['btnSubmit'] = btnSubmit;
    data['btnUpdate'] = btnUpdate;
    data['btnupload'] = btnupload;
    data['btnReassign'] = btnReassign;
    data['btnHold'] = btnHold;
    data['btnReject'] = btnReject;
    data['btnResume'] = btnResume;
    data['btnACK'] = btnACK;
    data['btnUpdateProgress'] = btnUpdateProgress;
    data['btnCompleted'] = btnCompleted;
    data['btnSolved'] = btnSolved;
    data['div_Comments'] = divComments;
    data['divUploadFiles'] = divUploadFiles;
    data['div_Ack'] = divAck;
    data['div_Completed'] = divCompleted;
    data['div_Solved'] = divSolved;
    data['div_Progress'] = divProgress;
    data['div_Assign'] = divAssign;
    data['div_Reject'] = divReject;
    if (ticketCommentLists != null) {
      data['ticket_Comment_Lists'] =
          ticketCommentLists!.map((v) => v.toJson()).toList();
    }
    if (ticketAttachmentLists != null) {
      data['ticket_Attachment_Lists'] =
          ticketAttachmentLists!.map((v) => v.toJson()).toList();
    }
    data["priority"] = priority;
    data["ticketActionTaken"] = ticketActionTaken;
    data["isApprovalNeeded"] = isApprovalNeeded;
    return data;
  }
}

class TicketCommentLists {
  String? commentedBy;
  String? commentedOn;
  String? ticketComments;

  TicketCommentLists({this.commentedBy, this.commentedOn, this.ticketComments});

  TicketCommentLists.fromJson(Map<String, dynamic> json) {
    commentedBy = json['commentedBy'];
    commentedOn = json['commentedOn'];
    ticketComments = json['ticketComments'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['commentedBy'] = commentedBy;
    data['commentedOn'] = commentedOn;
    data['ticketComments'] = ticketComments;
    return data;
  }
}

class TicketAttachmentLists {
  String? fileName;
  String? uploadedOn;
  String? uploadedBy;
  String? ticketFileID;
  String? fileFullPathUrl;

  TicketAttachmentLists(
      {this.fileName,
      this.uploadedOn,
      this.uploadedBy,
      this.ticketFileID,
      this.fileFullPathUrl});

  TicketAttachmentLists.fromJson(Map<String, dynamic> json) {
    fileName = json['fileName'];
    uploadedOn = json['uploadedOn'];
    uploadedBy = json['uploadedBy'];
    ticketFileID = json['ticketFileID'];
    fileFullPathUrl = json['fileFullPathUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fileName'] = fileName;
    data['uploadedOn'] = uploadedOn;
    data['uploadedBy'] = uploadedBy;
    data['ticketFileID'] = ticketFileID;
    data['fileFullPathUrl'] = fileFullPathUrl;
    return data;
  }
}

class ReassignEmployeeModel {
  String? employeeId;
  String? employeeName;

  ReassignEmployeeModel({this.employeeId, this.employeeName});

  factory ReassignEmployeeModel.fromJson(Map<String, dynamic> json) {
    return ReassignEmployeeModel(
      employeeId: json['employeeId'] as String?,
      employeeName: json['employeeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
    };
  }
}

class DepartmentModel {
  String? departmentId;
  String? departmentName;
  String? issueType;
  String? issueDescription;
  String? iSEmployeeDepartment;

  DepartmentModel({
    this.departmentId,
    this.departmentName,
    this.issueType,
    this.issueDescription,
    this.iSEmployeeDepartment,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      departmentId: json['departmentId'] as String?,
      departmentName: json['departmentName'] as String?,
      issueType: json['item_Type'] as String?,
      issueDescription: json['item_Description'] as String?,
      iSEmployeeDepartment: json['iS_EmployeeDepartment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departmentId': departmentId,
      'departmentName': departmentName,
      'item_Type': issueType,
      'item_Description': issueDescription,
      'iS_EmployeeDepartment': iSEmployeeDepartment,
    };
  }
}
