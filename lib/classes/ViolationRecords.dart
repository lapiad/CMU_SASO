class ViolationRecord {
  final String violationId;
  final String studentName;
  final String studentId;
  final String violation;
  final String department;
  final String role;
  final String reportedBy;
  final String dateTime;
  final String status;
  final String base64Imagestring;
  final String offenseLevel;
  String? remarks;

  var reportStatus;

  ViolationRecord({
    required this.violationId,
    required this.studentName,
    required this.studentId,
    required this.violation,
    required this.department,
    required this.role,
    required this.reportedBy,
    required this.dateTime,
    required this.status,
    required this.base64Imagestring,
    required this.offenseLevel,
    this.remarks,

  });

  factory ViolationRecord.fromJson(Map<String, dynamic> json) {
    return ViolationRecord(
      violationId: json['id'] ?? '', // ✅ IMPORTANT
      studentName: json['student_name'] ?? '',
      studentId: json['student_id'] ?? '',
      role: json['role'] ?? '',
      violation: json['violation'] ?? '',
      department: json['department'] ?? '',
      reportedBy: json['reported_by'] ?? '',
      dateTime: json['date_time'] ?? '',
      status: json['status'] ?? '',
      base64Imagestring: json['photo_evidence'] ?? '',
      offenseLevel: json['offense_level'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }


  Null get photoEvidence => null;
}
