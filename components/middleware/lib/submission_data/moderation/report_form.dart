enum ReportType {
  PROFILE,
  OUTFIT,
  COMMENT,
  OTHER,
}

String reportTypeToString(ReportType type){
  switch (type) {
    case ReportType.PROFILE:
      return 'Profile';
    case ReportType.OUTFIT:
      return 'Outfit';
    case ReportType.COMMENT:
      return 'Comment';
    case ReportType.OTHER:
      return 'Other';
    default:
      return 'Unkown';
  }
}

class ReportForm {

  ReportType type;
  String description;
  String reportedUserId;
  int reportedOutfitId;
  String reporterUserId;

  ReportForm({
    this.type = ReportType.PROFILE,
    this.description,
    this.reportedUserId,
    this.reportedOutfitId,
    this.reporterUserId,
  });

  bool get canBeSent => type!=null && reportedUserId != null && reporterUserId != null;

  Map<String, dynamic> toJson() => {
    'report_type' : reportTypeToString(type), 
    'report_description' : description, 
    'reported_user_id': reportedUserId,
    'reported_outfit_id' : reportedOutfitId,
    'reporter_user_id': reporterUserId,
  };
}