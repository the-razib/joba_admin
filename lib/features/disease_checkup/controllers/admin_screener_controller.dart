import 'package:get/get.dart';
import 'package:joba_admin/core/models/screener_admin_model.dart';
import 'package:joba_admin/core/repositories/screener_repository.dart';

class AdminScreenerController extends GetxController {
  final ScreenerRepository _repository = Get.find<ScreenerRepository>();

  final RxBool loading = false.obs;
  final RxList<ScreenerAdminModel> screeners = <ScreenerAdminModel>[].obs;
  final Rxn<ScreenerAdminModel> selectedScreener = Rxn<ScreenerAdminModel>();

  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs; // 'all', 'active', 'inactive'
  final RxInt activeTab = 0.obs; // 0: Questions, 1: Risk Tiers & Guidance
  final RxInt mobileTab =
      0.obs; // 0: Screeners List, 1: Questions, 2: Risk Guidance

  @override
  void onInit() {
    super.onInit();
    loadScreeners();
  }

  Future<void> loadScreeners() async {
    loading.value = true;
    try {
      final list = await _repository.getScreeners();
      screeners.assignAll(list);
      if (screeners.isNotEmpty) {
        if (selectedScreener.value == null) {
          selectedScreener.value = screeners.first;
        } else {
          final updated = screeners.firstWhereOrNull(
            (s) => s.id == selectedScreener.value!.id,
          );
          selectedScreener.value = updated ?? screeners.first;
        }
      } else {
        selectedScreener.value = null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load screeners: $e');
    } finally {
      loading.value = false;
    }
  }

  List<ScreenerAdminModel> get filteredScreeners {
    return screeners.where((s) {
      // Filter by status
      if (statusFilter.value == 'active' && !s.enabled) return false;
      if (statusFilter.value == 'inactive' && s.enabled) return false;

      // Filter by search query
      final q = searchQuery.value.trim().toLowerCase();
      if (q.isEmpty) return true;

      return s.nameBn.toLowerCase().contains(q) ||
          s.nameEn.toLowerCase().contains(q) ||
          s.source.toLowerCase().contains(q);
    }).toList();
  }

  // --- KPI Stats ---
  int get totalScreenersCount => screeners.length;

  int get activeScreenersCount => screeners.where((s) => s.enabled).length;

  int get totalQuestionsCount =>
      screeners.fold(0, (sum, s) => sum + s.questions.length);

  int get totalCompletionsCount =>
      screeners.fold(0, (sum, s) => sum + s.totalCompletions);

  String get mostPopularScreener {
    if (screeners.isEmpty) return 'N/A';
    final sorted = List<ScreenerAdminModel>.from(screeners)
      ..sort((a, b) => b.totalCompletions.compareTo(a.totalCompletions));
    return sorted.first.nameEn;
  }

  // --- Screener Actions ---
  void selectScreener(ScreenerAdminModel screener) {
    selectedScreener.value = screener;
  }

  Future<void> saveScreener(
    ScreenerAdminModel screener, {
    required bool isNew,
  }) async {
    try {
      if (isNew) {
        final created = await _repository.createScreener(screener);
        screeners.add(created);
        selectedScreener.value = created;
        Get.snackbar('Success', 'Created screener "${screener.nameEn}"');
      } else {
        final updated = await _repository.updateScreener(screener);
        final idx = screeners.indexWhere((s) => s.id == screener.id);
        if (idx != -1) {
          screeners[idx] = updated;
        }
        selectedScreener.value = updated;
        Get.snackbar('Success', 'Updated screener "${screener.nameEn}"');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save screener: $e');
    }
  }

  Future<void> deleteScreener(String id) async {
    try {
      final success = await _repository.deleteScreener(id);
      if (success) {
        screeners.removeWhere((s) => s.id == id);
        selectedScreener.value = screeners.isNotEmpty ? screeners.first : null;
        Get.snackbar('Deleted', 'Screener has been deleted.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete screener: $e');
    }
  }

  Future<void> toggleScreenerActive(String id, bool enabled) async {
    try {
      final success = await _repository.toggleScreenerActive(id, enabled);
      if (success) {
        final idx = screeners.indexWhere((s) => s.id == id);
        if (idx != -1) {
          screeners[idx] = screeners[idx].copyWith(enabled: enabled);
          if (selectedScreener.value?.id == id) {
            selectedScreener.value = screeners[idx];
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle screener status: $e');
    }
  }

  // --- Question Actions ---
  Future<void> addQuestion(
    String screenerId,
    ScreenerQuestionAdmin question,
  ) async {
    final current = screeners.firstWhereOrNull((s) => s.id == screenerId);
    if (current == null) return;

    final updatedQuestions = List<ScreenerQuestionAdmin>.from(current.questions)
      ..add(question.copyWith(order: current.questions.length + 1));

    final updated = current.copyWith(questions: updatedQuestions);
    await saveScreener(updated, isNew: false);
  }

  Future<void> updateQuestion(
    String screenerId,
    ScreenerQuestionAdmin question,
  ) async {
    final current = screeners.firstWhereOrNull((s) => s.id == screenerId);
    if (current == null) return;

    final updatedQuestions = current.questions.map((q) {
      return q.id == question.id ? question : q;
    }).toList();

    final updated = current.copyWith(questions: updatedQuestions);
    await saveScreener(updated, isNew: false);
  }

  Future<void> deleteQuestion(String screenerId, String questionId) async {
    final current = screeners.firstWhereOrNull((s) => s.id == screenerId);
    if (current == null) return;

    final updatedQuestions = current.questions
        .where((q) => q.id != questionId)
        .toList();

    // Re-index orders
    for (int i = 0; i < updatedQuestions.length; i++) {
      updatedQuestions[i] = updatedQuestions[i].copyWith(order: i + 1);
    }

    final updated = current.copyWith(questions: updatedQuestions);
    await saveScreener(updated, isNew: false);
  }

  Future<void> toggleQuestionActive(
    String screenerId,
    String questionId,
    bool isActive,
  ) async {
    final current = screeners.firstWhereOrNull((s) => s.id == screenerId);
    if (current == null) return;

    final updatedQuestions = current.questions.map((q) {
      return q.id == questionId ? q.copyWith(isActive: isActive) : q;
    }).toList();

    final updated = current.copyWith(questions: updatedQuestions);
    await saveScreener(updated, isNew: false);
  }

  Future<void> reorderQuestions(
    String screenerId,
    int oldIndex,
    int newIndex,
  ) async {
    final current = screeners.firstWhereOrNull((s) => s.id == screenerId);
    if (current == null) return;

    final list = List<ScreenerQuestionAdmin>.from(current.questions);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    // Re-assign orders
    final reindexed = <ScreenerQuestionAdmin>[];
    for (int i = 0; i < list.length; i++) {
      reindexed.add(list[i].copyWith(order: i + 1));
    }

    final updated = current.copyWith(questions: reindexed);
    await saveScreener(updated, isNew: false);
  }

  // --- Risk Tier Actions ---
  Future<void> updateRiskTier(
    String screenerId,
    RiskTierAdminConfig updatedTier,
  ) async {
    final current = screeners.firstWhereOrNull((s) => s.id == screenerId);
    if (current == null) return;

    final updatedTiers = current.riskTiers.map((t) {
      return t.key == updatedTier.key ? updatedTier : t;
    }).toList();

    final updated = current.copyWith(riskTiers: updatedTiers);
    await saveScreener(updated, isNew: false);
  }
}
