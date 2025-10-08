class ViolationRecord {
  late final String studentName;
  late final String studentId;
  final String department;
  late final String violation;
  late final String status;
  final String reportedBy;
  final String dateTime;

  ViolationRecord({
    required this.studentName,
    required this.studentId,
    required this.department,
    required this.violation,
    required this.status,
    required this.reportedBy,
    required this.dateTime,
  });

  set actionStatus(String actionStatus) {}
}
