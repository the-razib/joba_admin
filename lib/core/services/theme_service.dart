import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeService extends GetxService {
  final mode = ThemeMode.light.obs;

  bool get isDark => mode.value == ThemeMode.dark;

  void toggle() {
    mode.value = isDark ? ThemeMode.light : ThemeMode.dark;
  }
}
