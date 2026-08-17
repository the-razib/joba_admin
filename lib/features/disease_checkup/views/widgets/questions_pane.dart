import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/screener_admin_model.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/widgets/confirm_dialog.dart';
import 'package:joba_admin/features/disease_checkup/controllers/admin_screener_controller.dart';
import 'package:joba_admin/features/disease_checkup/views/widgets/question_editor_dialog.dart';

class QuestionsPane extends GetView<AdminScreenerController> {
  const QuestionsPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.selectedScreener.value;
      if (s == null) {
        return const Center(
          child: Text('Select a screener to manage questions'),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 520;
                  final title = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.checklist_rtl_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${s.nameEn} Questionnaire',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${s.questions.length} questions • ${s.activeQuestionsCount} active • Max points: ${s.totalPoints}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  );
                  final addButton = ElevatedButton.icon(
                    onPressed: () {
                      QuestionEditorDialog.show(
                        context,
                        onSave: (question, isNew) =>
                            controller.addQuestion(s.id, question),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Question'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        title,
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: addButton,
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: title),
                      const SizedBox(width: 16),
                      addButton,
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),

            // Reorderable Question List
            Expanded(
              child: s.questions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.quiz_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No questions in this screener yet',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Click "+ Add Question" to add symptom evaluation criteria.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: s.questions.length,
                        onReorder: (oldIndex, newIndex) {
                          controller.reorderQuestions(s.id, oldIndex, newIndex);
                        },
                        itemBuilder: (ctx, index) {
                          final q = s.questions[index];
                          return _QuestionCard(
                            key: ValueKey(q.id),
                            question: q,
                            screenerId: s.id,
                            index: index + 1,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}

class _QuestionCard extends GetView<AdminScreenerController> {
  final ScreenerQuestionAdmin question;
  final String screenerId;
  final int index;

  const _QuestionCard({
    super.key,
    required this.question,
    required this.screenerId,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: question.isActive,
          activeTrackColor: AppColors.primary,
          onChanged: (val) =>
              controller.toggleQuestionActive(screenerId, question.id, val),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          tooltip: 'Edit Question',
          onPressed: () {
            QuestionEditorDialog.show(
              context,
              question: question,
              onSave: (updated, isNew) =>
                  controller.updateQuestion(screenerId, updated),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
          tooltip: 'Delete Question',
          onPressed: () async {
            final confirmed = await showConfirmDialog(
              context,
              title: 'Delete Question',
              message: 'Are you sure you want to delete question #$index?',
              confirmLabel: 'Delete',
              danger: true,
            );
            if (confirmed) {
              await controller.deleteQuestion(screenerId, question.id);
            }
          },
        ),
      ],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: question.isActive
              ? Colors.grey.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;
          final content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2, right: 10),
                child: Icon(Icons.drag_indicator, size: 20, color: Colors.grey),
              ),
              Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.only(right: 12, top: 1),
                decoration: BoxDecoration(
                  color: question.isActive
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: question.isActive
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildQuestionContent()),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                content,
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              const SizedBox(width: 8),
              actions,
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuestionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.questionBn,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: question.isActive ? null : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          question.questionEn,
          style: TextStyle(
            fontSize: 12.5,
            color: question.isActive
                ? Colors.grey.shade600
                : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${question.points} ${question.points == 1 ? 'Point' : 'Points'}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
            if (!question.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Disabled',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
