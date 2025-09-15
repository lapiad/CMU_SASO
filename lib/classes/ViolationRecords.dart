class ViolationRecord {
  final String studentName;
  final String studentId;
  final String violation;
  final String status;
  final String reportStatus;
  final String reportedBy;
  final String dateTime;

  ViolationRecord({
    required this.studentName,
    required this.studentId,
    required this.violation,
    required this.status,
    required this.reportStatus,
    required this.reportedBy,
    required this.dateTime,
  });
}
