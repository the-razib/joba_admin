import 'package:joba_admin/features/reports/models/report.dart';

/// Phase 1: mock seed. Phase 3: `FirebaseReportRepository` reads `reports`,
/// written by the app's Report Problem screen.
abstract class ReportRepository {
  Future<List<Report>> seedReports();
  Future<List<Report>> fetchReports({int limit = 50});
  Future<void> updateReportStatus(String id, ReportStatus status);
  Future<void> updateReportPriority(String id, ReportPriority priority);
  Future<void> markAsRead(String id);
  Future<void> deleteReport(String id);
}

class MockReportRepository implements ReportRepository {
  final List<Report> _reports = [
    Report(
      id: 'RP-001',
      type: ReportType.prediction,
      subject: 'Prediction is wrong',
      description: 'My period prediction is always late by 5-7 days.',
      userName: 'Farhana Akter',
      userEmail: 'farhana@gmail.com',
      status: ReportStatus.pending,
      priority: ReportPriority.high,
      date: DateTime.now().subtract(const Duration(days: 1)),
      deviceModel: 'Samsung Galaxy A52',
      os: 'Android 13',
      isRead: false,
    ),
    Report(
      id: 'RP-002',
      type: ReportType.bug,
      subject: 'App crashes on home screen',
      description: 'The app crashes whenever I open the calendar view.',
      userName: 'Meherun Nisa',
      userEmail: 'meherun@gmail.com',
      status: ReportStatus.inProgress,
      priority: ReportPriority.high,
      date: DateTime.now().subtract(const Duration(days: 1)),
      deviceModel: 'Xiaomi Redmi 10',
      os: 'Android 12',
      isRead: true,
    ),
    Report(
      id: 'RP-003',
      type: ReportType.content,
      subject: 'Wrong information in article',
      description: 'The information in the hygiene article is outdated.',
      userName: 'Nusrat Jahan',
      userEmail: 'nusrat@gmail.com',
      status: ReportStatus.pending,
      priority: ReportPriority.medium,
      date: DateTime.now().subtract(const Duration(days: 2)),
      deviceModel: 'iPhone 12',
      os: 'iOS 17',
      isRead: false,
    ),
    Report(
      id: 'RP-004',
      type: ReportType.feature,
      subject: 'New feature suggestion',
      description: 'Please add a dark mode feature to the app.',
      userName: 'Tania Ahmed',
      userEmail: 'tania@gmail.com',
      status: ReportStatus.inProgress,
      priority: ReportPriority.low,
      date: DateTime.now().subtract(const Duration(days: 2)),
      deviceModel: 'OnePlus Nord',
      os: 'Android 14',
      isRead: true,
    ),
    Report(
      id: 'RP-005',
      type: ReportType.bug,
      subject: 'Notification not working',
      description: 'I am not receiving reminders even after enabling.',
      userName: 'Sadia Islam',
      userEmail: 'sadia@gmail.com',
      status: ReportStatus.resolved,
      priority: ReportPriority.high,
      date: DateTime.now().subtract(const Duration(days: 3)),
      deviceModel: 'Samsung Galaxy S21',
      os: 'Android 13',
      isRead: true,
    ),
    Report(
      id: 'RP-006',
      type: ReportType.other,
      subject: 'Payment failed but amount deducted',
      description: 'Payment was failed but money is deducted.',
      userName: 'Riya Dey',
      userEmail: 'riya@gmail.com',
      status: ReportStatus.inProgress,
      priority: ReportPriority.high,
      date: DateTime.now().subtract(const Duration(days: 4)),
      deviceModel: 'Realme 9',
      os: 'Android 12',
      isRead: true,
    ),
  ];

  @override
  Future<List<Report>> seedReports() async => _reports;

  @override
  Future<List<Report>> fetchReports({int limit = 50}) async => _reports;

  @override
  Future<void> updateReportStatus(String id, ReportStatus status) async {
    final idx = _reports.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _reports[idx] = _reports[idx].copyWith(status: status);
    }
  }

  @override
  Future<void> updateReportPriority(String id, ReportPriority priority) async {
    final idx = _reports.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _reports[idx] = _reports[idx].copyWith(priority: priority);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    final idx = _reports.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _reports[idx] = _reports[idx].copyWith(isRead: true);
    }
  }

  @override
  Future<void> deleteReport(String id) async {
    _reports.removeWhere((r) => r.id == id);
  }
}
