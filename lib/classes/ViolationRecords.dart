class ViolationRecord {
  late final String studentName;
  late final String studentId;
  final String department;
  late final String violation;
  late final String status;
  final String reportedBy;
  final String dateTime;
  final String base64Imagestring;
  final String offenseLevel;

  ViolationRecord({
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

  set actionStatus(String actionStatus) {}
}
