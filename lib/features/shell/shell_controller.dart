import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/shell/nav_items.dart';

class ShellController extends GetxController {
  final index = 0.obs;
  final sidebarCollapsed = false.obs;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  NavId get current => navItems[index.value].id;

  String get currentLabel => navItems[index.value].label;

  void select(NavId id) {
    final i = navItems.indexWhere((n) => n.id == id);
    if (i >= 0) index.value = i;
    if (scaffoldKey.currentState?.isDrawerOpen == true) {
      scaffoldKey.currentState?.closeDrawer();
    }
  }

  void toggleSidebar() => sidebarCollapsed.value = !sidebarCollapsed.value;
}
