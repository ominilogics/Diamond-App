import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../routing/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomSnackbar {
  static OverlayEntry? _currentOverlayEntry;

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, isSuccess: true, icon: Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, isSuccess: false, icon: Icons.error_outline);
  }

  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.info_outline,
  }) {
    final isSuccess = icon == Icons.check_circle_outline || icon == Icons.check;
    _show(context, message, isSuccess: isSuccess, icon: icon);
  }

  static void _show(
    BuildContext context,
    String message, {
    required bool isSuccess,
    required IconData icon,
  }) {
    _dismissCurrent();

    final overlayState = Overlay.maybeOf(context) ??
        Overlay.maybeOf(AppRouter.rootNavigatorKey.currentContext!);

    if (overlayState == null) return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return _CustomToastWidget(
          message: message,
          isSuccess: isSuccess,
          icon: icon,
          onDismissed: () {
            if (_currentOverlayEntry == entry) {
              entry.remove();
              _currentOverlayEntry = null;
            }
          },
        );
      },
    );

    _currentOverlayEntry = entry;
    overlayState.insert(entry);
  }

  static void _dismissCurrent() {
    if (_currentOverlayEntry != null) {
      try {
        _currentOverlayEntry!.remove();
      } catch (_) {}
      _currentOverlayEntry = null;
    }
  }
}

class _CustomToastWidget extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final IconData icon;
  final VoidCallback onDismissed;

  const _CustomToastWidget({
    required this.message,
    required this.isSuccess,
    required this.icon,
    required this.onDismissed,
  });

  @override
  State<_CustomToastWidget> createState() => _CustomToastWidgetState();
}

class _CustomToastWidgetState extends State<_CustomToastWidget>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _exitController;

  late Animation<double> _slideInY;
  late Animation<double> _slideOutX;
  late Animation<double> _entryFade;
  late Animation<double> _exitFade;

  bool _isDismissing = false;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    // Entry slide down from top: -120.h -> 0.0
    _slideInY = Tween<double>(
      begin: -1.2,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));

    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    // Exit slide to the right: 0.0 -> +1.2 (off screen right)
    _slideOutX = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInCubic,
    ));

    _exitFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeIn,
    ));

    _entryController.forward();

    // Auto-dismiss after 3.5 seconds
    _autoDismissTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        _dismissWithSlideRight();
      }
    });
  }

  void _dismissWithSlideRight() {
    if (_isDismissing) return;
    _isDismissing = true;
    _autoDismissTimer?.cancel();

    _exitController.forward().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _entryController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top + 12.h;

    final gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primaryButtonGradientStart,
        AppColors.primaryButtonGradientEnd,
      ],
    );

    Widget iconWidget;
    if (widget.isSuccess) {
      iconWidget = Icon(widget.icon, color: const Color(0xFF10B981), size: 22.sp);
    } else {
      iconWidget = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => gradient.createShader(bounds),
        child: Icon(widget.icon, size: 22.sp),
      );
    }

    return Positioned(
      top: topPadding,
      left: 20.w,
      right: 20.w,
      child: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: Listenable.merge([_entryController, _exitController]),
          builder: (context, child) {
            final screenWidth = mediaQuery.size.width;

            final translateX = _isDismissing ? _slideOutX.value * screenWidth : 0.0;
            final translateY = _isDismissing ? 0.0 : _slideInY.value * 100.h;
            final opacity = _isDismissing ? _exitFade.value : _entryFade.value;

            return Transform.translate(
              offset: Offset(translateX, translateY),
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Dismissible(
                  key: ValueKey('${widget.message}_${widget.hashCode}'),
                  direction: DismissDirection.horizontal,
                  onDismissed: (_) {
                    _autoDismissTimer?.cancel();
                    widget.onDismissed();
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.98),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: widget.isSuccess
                              ? const Color(0xFF10B981).withValues(alpha: 0.6)
                              : AppColors.primaryButtonGradientStart.withValues(alpha: 0.6),
                          width: 1.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          iconWidget,
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              widget.message,
                              style: AppTextStyles.roboto500Medium14(
                                fontSize: 13.5.sp,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _dismissWithSlideRight,
                              customBorder: const CircleBorder(),
                              splashColor: Colors.black.withValues(alpha: 0.08),
                              highlightColor: Colors.black.withValues(alpha: 0.04),
                              child: SizedBox(
                                width: 36.w,
                                height: 36.w,
                                child: Center(
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 20.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
