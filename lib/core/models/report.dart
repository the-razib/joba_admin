enum ReportType { bug, prediction, content, feature, payment, other }

enum ReportStatus { pending, inProgress, resolved }

enum ReportPriority { low, medium, high }

/// Mirrors submissions from the app's Report Problem screen.
class Report {
  const Report({
    required this.id,
    required this.type,
    required this.subject,
    required this.description,
    required this.userName,
    required this.userEmail,
    required this.status,
    required this.priority,
    required this.date,
    this.deviceModel,
    this.os,
  });

  final String id;
  final ReportType type;
  final String subject;
  final String description;
  final String userName;
  final String userEmail;
  final ReportStatus status;
  final ReportPriority priority;
  final DateTime date;
  final String? deviceModel;
  final String? os;

  Report copyWith({ReportStatus? status, ReportPriority? priority}) => Report(
        id: id,
        type: type,
        subject: subject,
        description: description,
        userName: userName,
        userEmail: userEmail,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        date: date,
        deviceModel: deviceModel,
        os: os,
      );
}
