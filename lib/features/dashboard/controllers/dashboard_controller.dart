import 'package:get/get.dart';
import 'package:joba_admin/features/users/models/app_user.dart';
import 'package:joba_admin/features/articles/models/article.dart';
import 'package:joba_admin/features/reports/models/report.dart';
import 'package:joba_admin/core/repositories/article_repository.dart';
import 'package:joba_admin/core/repositories/report_repository.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';
import 'package:joba_admin/core/utils/format.dart';

class DashboardController extends GetxController {
  final UserRepository usersRepo = Get.find();
  final ArticleRepository articlesRepo = Get.find();
  final ReportRepository reportsRepo = Get.find();

  final loading = true.obs;
  final users = <AppUser>[].obs;
  final articles = <Article>[].obs;
  final reports = <Report>[].obs;
  final range = 'Last 7 Days'.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    final results = await Future.wait([
      usersRepo.seedUsers(),
      articlesRepo.seedArticles(),
      reportsRepo.seedReports(),
    ]);
    users.assignAll(results[0] as List<AppUser>);
    articles.assignAll(results[1] as List<Article>);
    reports.assignAll(results[2] as List<Report>);
    loading.value = false;
  }

  void setRange(String r) => range.value = r;

  List<double> get activityValues => switch (range.value) {
    'Last 7 Days' => const [
      2500,
      3550,
      3050,
      3900,
      3150,
      3100,
      2550,
      3000,
      3600,
    ],
    'Last 30 Days' => const [
      2100,
      2400,
      2300,
      2800,
      2600,
      3000,
      2900,
      3300,
      3100,
      3500,
      3300,
      3700,
      3400,
      3900,
    ],
    _ => const [1800, 2200, 2600, 2400, 2900, 3200, 3000, 3600, 3400, 4000],
  };

  List<String> get activityLabels {
    final now = DateTime.now();
    final count = activityValues.length;
    final step = range.value == 'Last 7 Days'
        ? 1
        : range.value == 'Last 30 Days'
        ? 2
        : 7;
    return [
      for (var i = 0; i < count; i++)
        _fmtLabel(now.subtract(Duration(days: (count - 1 - i) * step))),
    ];
  }

  String _fmtLabel(DateTime d) =>
      '${d.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]}';

  final countrySlices = const [
    ('Bangladesh', 78.4),
    ('India', 10.7),
    ('Pakistan', 4.3),
    ('Indonesia', 2.8),
    ('Others', 3.8),
  ];

  List<AppUser> get recentUsers => users.take(4).toList();

  List<Article> get popularArticles {
    final list = articles.toList()..sort((a, b) => b.views.compareTo(a.views));
    return list.take(3).toList();
  }

  List<Report> get recentReports => reports.take(4).toList();

  String compact(int v) => compactNumber(v);
}
