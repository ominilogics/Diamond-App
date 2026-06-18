import 'package:flutter/material.dart';

class AppHelpers {
  AppHelpers._(); // Prevent instantiation

  /// Dismisses the keyboard and removes focus from any active FocusNode globally.
  static void dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
