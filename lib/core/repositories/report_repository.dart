import 'package:joba_admin/core/models/report.dart';

/// Phase 1: mock seed. Phase 3: `FirebaseReportRepository` reads `reports`,
/// written by the app's Report Problem screen.
abstract class ReportRepository {
  Future<List<Report>> seedReports();
}

class MockReportRepository implements ReportRepository {
  @override
  Future<List<Report>> seedReports() async {
    final now = DateTime.now();
    DateTime d(int days, [int hour = 10]) =>
        now.subtract(Duration(days: days)).copyWith(hour: hour);
    return [
      Report(id: 'RP-001', type: ReportType.prediction, subject: 'Prediction is wrong', description: 'My period prediction is always late by 5-7 days. I have regular cycles but the app shows wrong dates every time. Please fix this.', userName: 'Farhana Akter', userEmail: 'farhana@gmail.com', status: ReportStatus.pending, priority: ReportPriority.high, date: d(1, 10), deviceModel: 'Samsung Galaxy A52', os: 'Android 13'),
      Report(id: 'RP-002', type: ReportType.bug, subject: 'App crashes on home screen', description: 'The app crashes whenever I open the calendar view after logging a day.', userName: 'Meherun Nisa', userEmail: 'meherun@gmail.com', status: ReportStatus.inProgress, priority: ReportPriority.high, date: d(1, 9), deviceModel: 'Xiaomi Redmi 10', os: 'Android 12'),
      Report(id: 'RP-003', type: ReportType.content, subject: 'Wrong information in article', description: 'The information in the hygiene article is outdated compared to my doctor\'s advice.', userName: 'Nusrat Jahan', userEmail: 'nusrat@gmail.com', status: ReportStatus.pending, priority: ReportPriority.medium, date: d(2, 20), deviceModel: 'iPhone 12', os: 'iOS 17'),
      Report(id: 'RP-004', type: ReportType.feature, subject: 'New feature suggestion', description: 'Please add a dark mode feature to the app, it would help at night.', userName: 'Tania Ahmed', userEmail: 'tania@gmail.com', status: ReportStatus.inProgress, priority: ReportPriority.low, date: d(2, 19), deviceModel: 'OnePlus Nord', os: 'Android 14'),
      Report(id: 'RP-005', type: ReportType.bug, subject: 'Notification not working', description: 'I am not receiving reminders even after enabling notifications.', userName: 'Sadia Islam', userEmail: 'sadia@gmail.com', status: ReportStatus.resolved, priority: ReportPriority.high, date: d(3, 18), deviceModel: 'Samsung Galaxy S21', os: 'Android 13'),
      Report(id: 'RP-006', type: ReportType.payment, subject: 'Payment failed but amount deducted', description: 'Payment was failed but money is deducted from my bKash account.', userName: 'Riya Dey', userEmail: 'riya@gmail.com', status: ReportStatus.inProgress, priority: ReportPriority.high, date: d(4, 16), deviceModel: 'Realme 9', os: 'Android 12'),
    ];
  }
}
