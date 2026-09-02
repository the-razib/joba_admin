import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/disease_checkup/models/screener_admin_model.dart';
import 'package:joba_admin/core/repositories/screener_repository.dart';
import 'package:joba_admin/features/disease_checkup/controllers/admin_screener_controller.dart';
import 'package:joba_admin/features/disease_checkup/views/admin_screener_screen.dart';
import 'package:joba_admin/features/disease_checkup/views/widgets/question_editor_dialog.dart';
import 'package:joba_admin/features/disease_checkup/views/widgets/screener_editor_dialog.dart';

void main() {
  late AdminScreenerController controller;

  setUp(() async {
    Get.put<ScreenerRepository>(MockScreenerRepository());
    controller = Get.put(AdminScreenerController());
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });

  tearDown(Get.reset);

  testWidgets('disease checkup panes lay out cleanly on mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: AdminScreenerScreen())),
    );
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Active Tests'), findsOneWidget);
    expect(tester.takeException(), isNull);

    controller.mobileTab.value = 1;
    await tester.pump();
    expect(find.textContaining('Questionnaire'), findsOneWidget);
    expect(tester.takeException(), isNull);

    controller.mobileTab.value = 2;
    await tester.pump();
    expect(find.textContaining('Risk Gauge & Doctor Guidance'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('points dropdown opens cleanly on mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => QuestionEditorDialog.show(
                context,
                question: controller.screeners.first.questions.first,
                onSave: (question, isNew) async {},
              ),
              child: const Text('Edit question'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit question'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1 Point'));
    await tester.pumpAndSettle();

    expect(find.text('2 Points (Key Indicator)'), findsOneWidget);
    expect(find.text('3 Points (Critical Flag)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editing preserves hidden screener metadata', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final initial = controller.screeners.first.copyWith(
      accentColorHex: '#123456',
      displayOrder: 7,
    );
    ScreenerAdminModel? saved;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => ScreenerEditorDialog.show(
                context,
                screener: initial,
                onSave: (screener, isNew, {imageBytes, imageName}) async =>
                    saved = screener,
              ),
              child: const Text('Edit'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(saved?.accentColorHex, '#123456');
    expect(saved?.displayOrder, 7);
    expect(tester.takeException(), isNull);
  });
}
