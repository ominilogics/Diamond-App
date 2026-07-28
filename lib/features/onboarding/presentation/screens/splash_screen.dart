import 'dart:math' as math;
import 'package:daimond/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/routing/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ─── Single controller driving the smooth 3.6-second sequence ───────────
  late final AnimationController _controller;

  // ─── Cards (Left-to-Right Slide & Opacity) ───────────────────────────────
  late final Animation<Offset> _backCardSlideAnim;
  late final Animation<Offset> _frontCardSlideAnim;
  late final Animation<double> _cardOpacityAnim;
  late final Animation<double> _cardScaleAnim;

  // ─── R letter ────────────────────────────────────────────────────────────
  late final Animation<double> _letterOpacityAnim;
  late final Animation<double> _letterScaleAnim;

  // ─── Custom Underline Loading Line (Appears LAST under R) ────────────────
  late final Animation<double> _underlineWidthAnim;

  @override
  void initState() {
    super.initState();

    // Force light icons on the status bar during splash
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    // ── 1. Cards Entrance (Hardware-accelerated slide from left) ────────────
    _backCardSlideAnim =
        Tween<Offset>(begin: const Offset(-1.4, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.22, curve: Curves.easeOutCubic),
          ),
        );

    _frontCardSlideAnim =
        Tween<Offset>(begin: const Offset(-1.6, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.03, 0.28, curve: Curves.easeOutCubic),
          ),
        );

    _cardOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.20, curve: Curves.easeOut),
      ),
    );

    _cardScaleAnim = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    // ── 2. R Letter Entrance (Spring pop & fade) ────────────────────────────
    _letterOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.40, curve: Curves.easeOut),
      ),
    );

    _letterScaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.42, curve: Curves.easeOutBack),
      ),
    );

    // ── 3. Custom Underline Loading Line (Static 2.0-second loading duration) ──
    // Runs from 1300ms to 3300ms = EXACTLY 2000ms (2.0 seconds)
    _underlineWidthAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3611, 0.9167, curve: Curves.easeInOutCubic),
      ),
    );

    // Start animation and trigger navigation upon completion (no fade-out)
    _controller.forward().whenComplete(_navigateNext);
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;

    if (kIsWeb) {
      context.go(AppRoute.adminDashboard.path);
      return;
    }

    if (session != null) {
      context.go(AppRoute.main.path);
    } else {
      if (AppRouter.hasSeenOnboarding) {
        context.go(AppRoute.login.path);
      } else {
        context.go(AppRoute.onboarding.path);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF12E56),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                // Gradient applied from Right to Left
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                stops: [0.069, 0.7396, 0.931],
                colors: [
                  Color(0xFFFD7A73),
                  Color(0xFFF12E56),
                  Color(0xFFF12E56),
                ],
              ),
            ),


            child: SafeArea(child: Center(child: _buildCentreComposition())),
          );
        },
      ),
    );

  }

  /// Centred composition: Back card → Front card (with Drop Shadow) → R letter → Custom Underline Loading Line
  Widget _buildCentreComposition() {
    return Transform.scale(
      scale: _cardScaleAnim.value,
      child: SizedBox(
        width: 131.03,
        height: 168.26,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Back card (Sliding from Left) ───────────────────────
            Positioned(
              left: 7.4,
              top: 0,
              width: 123.63,
              height: 157.09,
              child: SlideTransition(
                position: _backCardSlideAnim,
                child: Opacity(
                  opacity: _cardOpacityAnim.value,
                  child: SvgPicture.asset(
                    'assets/icons/back_card.svg',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),

            // ── Front card (Staggered Slide from Left + Drop Shadow) ───
            Positioned(
              left: 0,
              top: 17.42,
              width: 109.32,
              height: 150.84,
              child: SlideTransition(
                position: _frontCardSlideAnim,
                child: Opacity(
                  opacity: _cardOpacityAnim.value,
                  child: Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x4D6C0117), // box-shadow: -15.45px 25.72px 28.28px 0px #6C01174D
                          offset: Offset(-15.45, 25.72),
                          blurRadius: 28.28,
                          spreadRadius: 0.0,
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/front_card.svg',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),

            // ── R letter (Pop & Scale entrance) ─────────────────────
            Positioned(
              left: 26.51,
              top: 47.83,
              width: 55.79,
              height: 60.53,
              child: Opacity(
                opacity: _letterOpacityAnim.value,
                child: Transform.scale(
                  scale: _letterScaleAnim.value,
                  child: Image.asset(
                    'assets/icons/R_letter.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),

            // ── Custom Underline Loading Line (Rotated under R matching R width) ───
            Positioned(
              left: 29.51,
              top: 127.36,
              width: 55.79,
              height: 7.0,
              child: Transform.rotate(
                angle: -5 * math.pi / 180,
                child: CustomPaint(
                  painter: _UnderlineLoadingPainter(
                    progress: _underlineWidthAnim.value,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter rendering a loading line directly under the R letter
class _UnderlineLoadingPainter extends CustomPainter {
  final double progress;

  _UnderlineLoadingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Underline track and progress appear ONLY when loading actually starts
    if (progress <= 0) return;

    final double lineHeight = size.height; // 7.0px

    // 1. White track background so gradient fill contrasts sharply
    final RRect trackRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, lineHeight),
      Radius.circular(lineHeight / 2),
    );
    final Paint trackPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(trackRRect, trackPaint);

    // 2. Active loading line filled with CSS 270.59deg gradient
    final double progressWidth = size.width * progress.clamp(0.0, 1.0);
    final Rect progressRect = Rect.fromLTWH(0, 0, progressWidth, lineHeight);
    final RRect progressRRect = RRect.fromRectAndRadius(
      progressRect,
      Radius.circular(lineHeight / 2),
    );

    final Paint progressPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        stops: [0.0038, 0.6151, 0.9962],
        colors: [Color(0xFFFB6A79), Color(0xFFFB3D5F), Color(0xFFFB3D5F)],
      ).createShader(progressRect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(progressRRect, progressPaint);
  }


  @override
  bool shouldRepaint(covariant _UnderlineLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
