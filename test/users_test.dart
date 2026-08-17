import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/pagination_bar.dart';
import 'package:joba_admin/features/users/controllers/users_controller.dart';
import 'package:joba_admin/features/users/views/users_screen.dart';

void main() {
  Future<void> pumpBar(
    WidgetTester tester, {
    required int page,
    required int totalItems,
    int pageSize = 10,
    Size size = const Size(1440, 900),
    ValueChanged<int>? onPageChanged,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          // A Column mirrors how the table hosts the bar: full width available,
          // which is what used to make the chips stretch.
          body: Column(
            children: [
              PaginationBar(
                page: page,
                totalItems: totalItems,
                pageSize: pageSize,
                onPageChanged: onPageChanged ?? (_) {},
                onPageSizeChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> pumpUsers(
    WidgetTester tester, {
    Size size = const Size(1440, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Get.put<UserRepository>(MockUserRepository());
    Get.put(UsersController());
    addTearDown(Get.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: UsersScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('PaginationBar', () {
    testWidgets('highlights the current page exactly once', (tester) async {
      await pumpBar(tester, page: 1, totalItems: 12);

      // Regression: an unconditional active chip used to render on top of the
      // page loop, painting two green "1" bars.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sizes chips to their label instead of the full row', (
      tester,
    ) async {
      await pumpBar(tester, page: 1, totalItems: 12);

      final chip = find.ancestor(
        of: find.text('1'),
        matching: find.byType(InkWell),
      );
      final width = tester.getSize(chip.first).width;
      expect(width, lessThan(60));
    });

    testWidgets('windows the page list around the current page', (
      tester,
    ) async {
      await pumpBar(tester, page: 7, totalItems: 120);

      for (final label in ['1', '6', '7', '8', '12']) {
        expect(
          find.text(label),
          findsOneWidget,
          reason: 'expected chip $label',
        );
      }
      // The old windowing always emitted 1-5, so the current page had no chip.
      expect(find.text('3'), findsNothing);
      expect(find.text('…'), findsNWidgets(2));
    });

    testWidgets('shows a compact indicator instead of chips on mobile', (
      tester,
    ) async {
      await pumpBar(
        tester,
        page: 2,
        totalItems: 120,
        size: const Size(390, 844),
      );

      expect(find.text('Page 2 of 12'), findsOneWidget);
      expect(find.text('12'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('arrows step the page and clamp at the first page', (
      tester,
    ) async {
      final taps = <int>[];
      await pumpBar(tester, page: 1, totalItems: 120, onPageChanged: taps.add);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();
      expect(taps, isEmpty, reason: 'previous is disabled on page 1');

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      expect(taps, [2]);
    });
  });

  group('UsersScreen', () {
    testWidgets('renders no page header and no mock action buttons', (
      tester,
    ) async {
      await pumpUsers(tester);

      expect(find.text('Users'), findsNothing);
      expect(find.text('Manage and monitor your app users'), findsNothing);
      expect(find.text('Export CSV'), findsNothing);
      expect(find.text('Import Users'), findsNothing);
      expect(find.text('Add User'), findsNothing);
    });

    testWidgets('has no row selection checkbox', (tester) async {
      await pumpUsers(tester);

      expect(find.byType(Checkbox), findsNothing);
    });

    testWidgets('shows the email inside the user cell, not its own column', (
      tester,
    ) async {
      await pumpUsers(tester);

      expect(find.text('Email'), findsNothing);
      expect(find.textContaining('@'), findsWidgets);
    });

    testWidgets('keeps status and plan pills content-sized so they do not '
        'collide', (tester) async {
      await pumpUsers(tester);

      final pills = find.byType(PillBadge);
      expect(pills, findsWidgets);
      for (var i = 0; i < tester.widgetList(pills).length; i++) {
        expect(tester.getSize(pills.at(i)).width, lessThanOrEqualTo(130));
      }
    });

    testWidgets('renders without overflow across breakpoints', (tester) async {
      for (final size in const [
        Size(1440, 1400),
        Size(834, 1400),
        Size(390, 1400),
      ]) {
        await pumpUsers(tester, size: size);
        expect(
          tester.takeException(),
          isNull,
          reason: 'overflow at ${size.width}px',
        );
        Get.reset();
      }
    });
  });
}
