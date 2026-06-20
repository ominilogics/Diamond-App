import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/app_helpers.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBodyBehindAppBar;
  final bool useSafeArea;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = true, // Set to true if appbar is transparent
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    // The Container fills the screen with the gradient
    Widget content = GestureDetector(
      onTap: AppHelpers.dismissKeyboard,
      behavior:
          HitTestBehavior.opaque, // Ensures taps on empty space are registered
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.globalBackgroundGradient,
        ),
        child: useSafeArea ? SafeArea(child: body) : body,
      ),
    );

    return Scaffold(
      // We set scaffold background to transparent so the container shows through
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: true, // Useful if you have a transparent bottom nav bar
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: content,
    );
  }
}
