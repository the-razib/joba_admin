import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';

/// Opens a right-side detail panel on desktop/tablet and a full-screen
/// page on mobile.
Future<void> showDetailPanel(
  BuildContext context, {
  required String title,
  required Widget child,
  List<Widget>? actions,
  Widget? footer,
  double width = 460,
}) {
  return Navigator.of(context).push(
    _DetailPanelRoute(
      title: title,
      actions: actions,
      footer: footer,
      width: width,
      child: child,
    ),
  );
}

class _DetailPanelRoute extends PopupRoute<void> {
  _DetailPanelRoute({
    required this.title,
    required this.child,
    this.actions,
    this.footer,
    required this.width,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? footer;
  final double width;

  @override
  Color? get barrierColor => Colors.black.withValues(alpha: 0.35);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Close panel';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 260);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final full = Responsive.isMobile(context);
    return Align(
      alignment: Alignment.centerRight,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: Material(
          color: context.palette.card,
          child: SizedBox(
            width: full ? double.infinity : width,
            height: double.infinity,
            child: _PanelContent(
              title: title,
              actions: actions,
              footer: footer,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelContent extends StatelessWidget {
  const _PanelContent({
    required this.title,
    required this.child,
    this.actions,
    this.footer,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: palette.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ...?actions,
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(child: child),
          if (footer != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: palette.border)),
              ),
              child: footer,
            ),
        ],
      ),
    );
  }
}
