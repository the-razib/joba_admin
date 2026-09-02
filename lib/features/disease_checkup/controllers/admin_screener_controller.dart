import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/features/disease_checkup/models/screener_admin_model.dart';
import 'package:joba_admin/core/repositories/screener_repository.dart';

class AdminScreenerController extends GetxController {
  final ScreenerRepository _repository = Get.find<ScreenerRepository>();

  final RxBool loading = false.obs;
  final RxList<ScreenerAdminModel> screeners = <ScreenerAdminModel>[].obs;
  final RxString selectedScreenerId = ''.obs;

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
        if (selectedScreenerId.value.isEmpty ||
            !screeners.any((s) => s.id == selectedScreenerId.value)) {
          selectedScreenerId.value = screeners.first.id;
        }
      } else {
        selectedScreenerId.value = '';
      }
    } catch (e) {
      AppToast.error('Error', 'Failed to load screeners: $e');
    } finally {
      loading.value = false;
    }
  }

  ScreenerAdminModel? get selectedScreener {
    if (screeners.isEmpty) return null;
    return screeners
            .firstWhereOrNull((s) => s.id == selectedScreenerId.value) ??
        screeners.first;
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
    if (totalCompletionsCount == 0) return 'None yet';
    final sorted = List<ScreenerAdminModel>.from(screeners)
      ..sort((a, b) => b.totalCompletions.compareTo(a.totalCompletions));
    return sorted.first.nameEn;
  }

  // --- Screener Actions ---
  void selectScreener(ScreenerAdminModel screener) {
    selectedScreenerId.value = screener.id;
  }

  Future<void> saveScreener(
    ScreenerAdminModel screener, {
    required bool isNew,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      if (isNew) {
        final created = await _repository.createScreener(
          screener,
          imageBytes: imageBytes,
          imageName: imageName,
        );
        screeners.add(created);
        selectedScreenerId.value = created.id;
        AppToast.success('Success', 'Created screener "${screener.nameEn}"');
      } else {
        final updated = await _repository.updateScreener(
          screener,
          imageBytes: imageBytes,
          imageName: imageName,
        );
        final idx = screeners.indexWhere((s) => s.id == screener.id);
        if (idx != -1) {
          screeners[idx] = updated;
        }
        selectedScreenerId.value = updated.id;
        AppToast.success('Success', 'Updated screener "${screener.nameEn}"');
      }
    } catch (e) {
      AppToast.error('Error', 'Failed to save screener: $e');
    }
  }

  Future<void> deleteScreener(String id) async {
    try {
      final success = await _repository.deleteScreener(id);
      if (success) {
        screeners.removeWhere((s) => s.id == id);
        if (selectedScreenerId.value == id) {
          selectedScreenerId.value =
              screeners.isNotEmpty ? screeners.first.id : '';
        }
        AppToast.success('Success', 'Screener deleted successfully.');
      }
    } catch (e) {
      AppToast.error('Error', 'Failed to delete screener: $e');
    }
  }

  Future<void> toggleScreenerActive(String id, bool enabled) async {
    try {
      final success = await _repository.toggleScreenerActive(id, enabled);
      if (success) {
        final idx = screeners.indexWhere((s) => s.id == id);
        if (idx != -1) {
          screeners[idx] = screeners[idx].copyWith(enabled: enabled);
          screeners.refresh();
          AppToast.success(
            'Success',
            'Screener "${screeners[idx].nameEn}" ${enabled ? "activated" : "deactivated"}.',
          );
        }
      }
    } catch (e) {
      AppToast.error('Error', 'Failed to update active status: $e');
    }
  }

  Future<void> reorderScreeners(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = screeners.removeAt(oldIndex);
    screeners.insert(newIndex, item);

    // Re-index display orders 1..N
    for (int i = 0; i < screeners.length; i++) {
      screeners[i] = screeners[i].copyWith(displayOrder: i + 1);
    }
    screeners.refresh();

    try {
      await _repository.updateScreenersOrder(screeners);
      AppToast.success('Order Saved', 'Category serial updated successfully.');
    } catch (e) {
      AppToast.error('Error', 'Failed to save category order: $e');
    }
  }

  // --- Question Actions ---
  void addQuestion(String screenerId, ScreenerQuestionAdmin question) {
    final idx = screeners.indexWhere((s) => s.id == screenerId);
    if (idx == -1) return;

    final current = screeners[idx];
    final updatedQuestions = List<ScreenerQuestionAdmin>.from(current.questions)
      ..add(question.copyWith(order: current.questions.length + 1));

    final updatedScreener = current.copyWith(questions: updatedQuestions);
    saveScreener(updatedScreener, isNew: false);
  }

  void updateQuestion(String screenerId, ScreenerQuestionAdmin question) {
    final idx = screeners.indexWhere((s) => s.id == screenerId);
    if (idx == -1) return;

    final current = screeners[idx];
    final qIdx = current.questions.indexWhere((q) => q.id == question.id);
    if (qIdx != -1) {
      final updatedQuestions =
          List<ScreenerQuestionAdmin>.from(current.questions);
      updatedQuestions[qIdx] = question;
      final updatedScreener = current.copyWith(questions: updatedQuestions);
      saveScreener(updatedScreener, isNew: false);
    }
  }

  Future<void> deleteQuestion(String screenerId, String questionId) async {
    final idx = screeners.indexWhere((s) => s.id == screenerId);
    if (idx == -1) return;

    final current = screeners[idx];
    final updatedQuestions = List<ScreenerQuestionAdmin>.from(current.questions)
      ..removeWhere((q) => q.id == questionId);

    // Re-index orders
    for (var i = 0; i < updatedQuestions.length; i++) {
      updatedQuestions[i] = updatedQuestions[i].copyWith(order: i + 1);
    }

    final updatedScreener = current.copyWith(questions: updatedQuestions);
    await saveScreener(updatedScreener, isNew: false);
  }

  void reorderQuestions(String screenerId, int oldIndex, int newIndex) {
    final idx = screeners.indexWhere((s) => s.id == screenerId);
    if (idx == -1) return;

    final current = screeners[idx];
    final updated = List<ScreenerQuestionAdmin>.from(current.questions);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);

    // Re-index
    for (var i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(order: i + 1);
    }

    final updatedScreener = current.copyWith(questions: updated);
    saveScreener(updatedScreener, isNew: false);
  }

  void toggleQuestionActive(
    String screenerId,
    String questionId,
    bool isActive,
  ) {
    final idx = screeners.indexWhere((s) => s.id == screenerId);
    if (idx == -1) return;

    final current = screeners[idx];
    final qIdx = current.questions.indexWhere((q) => q.id == questionId);
    if (qIdx != -1) {
      final updated = List<ScreenerQuestionAdmin>.from(current.questions);
      updated[qIdx] = updated[qIdx].copyWith(isActive: isActive);
      final updatedScreener = current.copyWith(questions: updated);
      saveScreener(updatedScreener, isNew: false);
    }
  }

  // --- Risk Tier Actions ---
  void updateRiskTier(String screenerId, RiskTierAdminConfig tier) {
    final idx = screeners.indexWhere((s) => s.id == screenerId);
    if (idx == -1) return;

    final current = screeners[idx];
    final updatedTiers = List<RiskTierAdminConfig>.from(current.riskTiers);
    final tIdx = updatedTiers.indexWhere((t) => t.key == tier.key);
    if (tIdx != -1) {
      updatedTiers[tIdx] = tier;
    } else {
      updatedTiers.add(tier);
    }

    final updatedScreener = current.copyWith(riskTiers: updatedTiers);
    saveScreener(updatedScreener, isNew: false);
  }
}
