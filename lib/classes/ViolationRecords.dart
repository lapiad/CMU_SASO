class ViolationRecord {
  final int violationId;
  final String studentName;
  final String studentId;
  final String department;
  final String violation;
  final String status;
  final String reportedBy;
  final String dateTime;
  final String base64Imagestring;
  final String offenseLevel;

  ViolationRecord({
    required this.violationId,
    required this.studentName,
    required this.studentId,
    required this.department,
    required this.violation,
    required this.status,
    required this.reportedBy,
    required this.dateTime,
    required this.base64Imagestring,
    required this.offenseLevel,
  });

  factory ViolationRecord.fromJson(Map<String, dynamic> json) {
    return ViolationRecord(
      violationId: json['violation_id'] ?? json['id'] ?? 0,
      studentName: json['student_name'] ?? '',
      studentId: json['student_id'] ?? '',
      department: json['department'] ?? '',
      violation: json['violation'] ?? '',
      status: json['status'] ?? '',
      reportedBy: json['reported_by'] ?? '',
      dateTime: json['date_time'] ?? '',
      base64Imagestring: json['photo_evidence'] ?? '',
      offenseLevel: json['offense_level'] ?? '',
    );
  }
}
