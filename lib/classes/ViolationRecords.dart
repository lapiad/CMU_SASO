class ViolationRecord {
  late final String studentName;
  late final String studentId;
  late final String violation;
  late final String status;
  final String reportStatus;
  final String reportedBy;
  final String dateTime;
  final String department;

  ViolationRecord({
    required this.studentName,
    required this.studentId,
    required this.violation,
    required this.status,
    required this.reportStatus,
    required this.reportedBy,
    required this.dateTime,
    required this.department,
  });

  set actionStatus(String actionStatus) {}
}
