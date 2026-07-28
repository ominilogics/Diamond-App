import 'dart:async';
import 'dart:math' as math;
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/primary_button.dart';

class PreviewCardScreen extends StatefulWidget {
  final String? message;
  final String? coverImageUrl;
  final String? frontMessage;

  const PreviewCardScreen({
    super.key,
    this.message,
    this.coverImageUrl,
    this.frontMessage,
  });

  @override
  State<PreviewCardScreen> createState() => _PreviewCardScreenState();
}

class _PreviewCardScreenState extends State<PreviewCardScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _flipController;
  late AnimationController _teaserController;

  late Animation<double> _flapRotation;
  late Animation<Offset> _cardTranslation;
  late Animation<double> _cardScale;
  late Animation<double> _cardHeight;
  late Animation<double> _cardTop;
  late Animation<double> _launchFlip;
  late Animation<double> _envelopeOpacity;

  late Animation<double> _tapFlipAnimation;
  late Animation<double> _teaserAnimation;

  Timer? _hintTimer;
  bool _isFlipped = false;
  bool _showFlipHint = false;


  @override
  void initState() {
    super.initState();

    developer.log(
      'PreviewCardScreen initState -> frontMessage: "${widget.frontMessage}", message: "${widget.message}", coverImageUrl: "${widget.coverImageUrl}"',
      name: 'PreviewCardScreen',
    );

    // Main envelope flap & card emergence controller (3600ms total duration)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    // Interactive card tap-to-flip controller
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Teaser tilt controller (15° Y-axis peek hint)
    _teaserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _teaserAnimation = Tween<double>(begin: 0.0, end: 0.26).animate(
      CurvedAnimation(parent: _teaserController, curve: Curves.easeInOutCubic),
    );

    _tapFlipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    // Trigger Teaser Tilt and show hint badge after 5s idle IF user hasn't flipped card yet
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _hintTimer?.cancel();
        _hintTimer = Timer(const Duration(seconds: 5), () {
          if (mounted && !_isFlipped) {
            setState(() {
              _showFlipHint = true;
            });
            _teaserController.forward().then((_) {
              if (mounted) {
                _teaserController.reverse();
              }
            });
          }
        });
      }
    });

    // Phase 1: 3D X-Axis Flap Flip (0° to 180° over 800ms)
    _flapRotation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.222, curve: Curves.easeInOutSine),
      ),
    );

    // Phase 1-2: Upward Card Growth / Peek (400ms-800ms) + 200ms Hold Pause (800ms-1000ms)
    // Card stays inside envelope during closed_top rotation (0ms-400ms), then grows 165.0.h -> 275.0.h (400ms-800ms) as animate_top opens!
    // Bottom (387.29.h) stays 100% anchored to envelope bottom throughout!
    _cardHeight = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(165.0),
        weight: 0.111, // 0ms - 400ms (closed_top rotates 0° -> 90°, card stays inside envelope)
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 165.0, end: 275.0).chain(
          CurveTween(curve: Curves.easeInOutSine),
        ),
        weight: 0.111, // 400ms - 800ms (Card grows upward right as animate_top comes!)
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(275.0),
        weight: 0.056, // 800ms - 1000ms (Exact 200ms / 0.2s hold pause!)
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 275.0, end: 295.0).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 0.662, // 1000ms - 3384ms (Launch out of envelope)
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(295.0),
        weight: 0.06, // 3384ms - 3600ms
      ),
    ]).animate(_controller);

    _cardTop = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(222.29),
        weight: 0.111, // 0ms - 400ms (closed_top rotates 0° -> 90°, card stays inside envelope)
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 222.29, end: 112.29).chain(
          CurveTween(curve: Curves.easeInOutSine),
        ),
        weight: 0.111, // 400ms - 800ms (Card top moves upward right as animate_top comes!)
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(112.29),
        weight: 0.056, // 800ms - 1000ms (Exact 200ms / 0.2s hold pause!)
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 112.29, end: 151.32).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 0.662, // 1000ms - 3384ms (Launch out of envelope)
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(151.32),
        weight: 0.06, // 3384ms - 3600ms
      ),
    ]).animate(_controller);

    // Phase 3 Launch Scaling (1000ms to 3384ms)
    _cardScale = Tween<double>(begin: 1.0, end: 1.62).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.278, 0.94, curve: Curves.easeOutCubic),
      ),
    );

    _cardTranslation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, -0.187),
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.278, 0.94, curve: Curves.easeOutCubic),
          ),
        );

    // Phase 3 Graceful Multi-Spin (1000ms to 3240ms)
    _launchFlip = Tween<double>(begin: 0.0, end: 10 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.278, 0.90, curve: Curves.easeOutQuart),
      ),
    );

    // Phase 3 Fast Fade Out Envelope Assets (1000ms to 1300ms = 300ms fast fade out as spin starts!)
    _envelopeOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.278, 0.361, curve: Curves.easeOut),
      ),
    );






    // Start animation smoothly after screen entrance
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _controller.dispose();
    _flipController.dispose();
    _teaserController.dispose();
    super.dispose();
  }

  void _toggleCardFlip() {
    if (_flipController.isAnimating) return;
    _hintTimer?.cancel();
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
      _showFlipHint = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    final effectiveCoverUrl = widget.coverImageUrl;
    final effectiveBackMsg =
        (widget.message != null && widget.message!.trim().isNotEmpty)
        ? widget.message!.trim()
        : "Wishing you joy, health, and happiness!";

    developer.log(
      'PreviewCardScreen build -> FRONT: "${widget.frontMessage}", BACK: "$effectiveBackMsg"',
      name: 'PreviewCardScreen',
    );

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            const AppBar2(title: 'Preview Card'),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: 390.w,
                      height: 530.h,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _controller,
                          _flipController,
                          _teaserController,
                        ]),
                        builder: (context, child) {
                          final flapRad = _flapRotation.value;
                          final envOpacity = _envelopeOpacity.value;

                          // Seamless 3D Flap Cross-fade & Rotation Math
                          double closedFlapAlpha = 1.0;
                          if (flapRad > math.pi * 0.38) {
                            closedFlapAlpha =
                                (1.0 - (flapRad - math.pi * 0.38) / (math.pi * 0.12))
                                    .clamp(0.0, 1.0);
                          }

                          double openFlapAlpha = 1.0;
                          if (flapRad < math.pi * 0.50) {
                            openFlapAlpha =
                                ((flapRad - math.pi * 0.38) / (math.pi * 0.12))
                                    .clamp(0.0, 1.0);
                          }

                          final openFlapAngle =
                              (math.pi - flapRad).clamp(0.0, math.pi / 2);

                          // Total Y-axis angle combines emergence launch flip + tap flip + 15deg teaser tilt
                          final totalYAngle =
                              _launchFlip.value +
                              _tapFlipAnimation.value +
                              _teaserAnimation.value;
                          final normalizedAngle = totalYAngle % (2 * math.pi);
                          final isCardFlipped =
                              (normalizedAngle >= math.pi / 2 &&
                              normalizedAngle <= 3 * math.pi / 2);

                          return RepaintBoundary(
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // ── Layer 1: Envelope Back Side (animate_middle.svg) (Fades Out) ──
                                if (envOpacity > 0.0)
                                  Positioned(
                                    top: 216.29.h,
                                    left: 47.w,
                                    width: 296.w,
                                    height: 171.h,
                                    child: Opacity(
                                      opacity: envOpacity,
                                      child: SvgPicture.asset(
                                        AppAssets.animateMiddle,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),

                                // ── Layer 2: Open Top Flap (Behind Envelope Back, 3D Rotates Open & Cross-fades) ──
                                if (flapRad >= math.pi * 0.38 && envOpacity > 0.0)
                                  Positioned(
                                    top: 123.86.h,
                                    left: 45.w,
                                    width: 300.w,
                                    height: 95.43.h,

                                    child: Opacity(
                                      opacity: envOpacity * openFlapAlpha,
                                      child: Transform(
                                        alignment: Alignment.bottomCenter,
                                        transform: Matrix4.identity()
                                          ..setEntry(3, 2, 0.001)
                                          ..rotateX(-openFlapAngle),
                                        child: SvgPicture.asset(
                                          AppAssets.animateTop,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),


                                // ── Layer 3: Animated Card (Launches to Max Size & Flips cleanly) ──
                                Positioned(
                                  top: _cardTop.value.h,
                                  left: 92.w,
                                  width: 211.w,
                                  height: _cardHeight.value.h,
                                  child: Transform.translate(
                                    offset: Offset(
                                      0,
                                      _cardTranslation.value.dy * 180.h,
                                    ),
                                    child: Transform.scale(
                                      scale: _cardScale.value,
                                      child: Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()
                                          ..setEntry(3, 2, 0.001)
                                          ..rotateY(totalYAngle),
                                        child: GestureDetector(
                                          onTap: _toggleCardFlip,
                                          child: Container(
                                            width: 211.w,
                                            height: _cardHeight.value.h,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.zero,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(0x0D000000),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.zero,
                                              child: isCardFlipped
                                                  ? Transform.scale(
                                                      scaleX:
                                                          -1, // Un-mirror back side after 180deg flip
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          Image.asset(
                                                            AppAssets.backSide,
                                                            fit: BoxFit.fill,
                                                            alignment: Alignment
                                                                .topCenter,
                                                            filterQuality:
                                                                FilterQuality
                                                                    .low,
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                double.infinity,
                                                          ),
                                                          if (effectiveBackMsg
                                                              .isNotEmpty)
                                                            Positioned(
                                                              top: 20.h,
                                                              bottom: 20.h,
                                                              left: 24.w,
                                                              right: 24.w,
                                                              child: Center(
                                                                child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.center,
                                                                  child: SizedBox(
                                                                    width: 163.w,
                                                                    child: Text(
                                                                      effectiveBackMsg
                                                                          .toUpperCase(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: AppTextStyles.bizudMincho400Regular12(
                                                                        color: const Color(
                                                                          0xFF2C2C2C,
                                                                        ),
                                                                        fontSize:
                                                                            10.sp,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  : Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        if (effectiveCoverUrl !=
                                                                null &&
                                                            effectiveCoverUrl
                                                                .isNotEmpty)
                                                          CachedNetworkImage(
                                                            imageUrl:
                                                                effectiveCoverUrl,
                                                            fit: BoxFit.fill,
                                                            alignment: Alignment
                                                                .topCenter,
                                                            filterQuality:
                                                                FilterQuality
                                                                    .low,
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                double.infinity,
                                                            placeholder:
                                                                (
                                                                  context,
                                                                  url,
                                                                ) => Container(
                                                                  color: Colors
                                                                      .grey[200],
                                                                ),
                                                            errorWidget:
                                                                (
                                                                  context,
                                                                  url,
                                                                  err,
                                                                ) => Image.asset(
                                                                  AppAssets
                                                                      .backSide,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  filterQuality:
                                                                      FilterQuality
                                                                          .low,
                                                                  width: double
                                                                      .infinity,
                                                                  height: double
                                                                      .infinity,
                                                                ),
                                                          )
                                                        else
                                                          Image.asset(
                                                            AppAssets.backSide,
                                                            fit: BoxFit.fill,
                                                            alignment: Alignment
                                                                .topCenter,
                                                            filterQuality:
                                                                FilterQuality
                                                                    .low,
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                double.infinity,
                                                          ),
                                                        if (widget.frontMessage !=
                                                                null &&
                                                            widget
                                                                .frontMessage!
                                                                .isNotEmpty)
                                                          Positioned(
                                                            top: 220.h,
                                                            bottom: 24.h,
                                                            left: 24.w,
                                                            right: 24.w,
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child: FittedBox(
                                                                fit: BoxFit.scaleDown,
                                                                alignment: Alignment.topCenter,
                                                                child: SizedBox(
                                                                  width: 163.w,
                                                                  child: Text(
                                                                    widget
                                                                        .frontMessage!
                                                                        .toUpperCase(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: AppTextStyles.bizudMincho400Regular12(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          10.sp,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        if (_showFlipHint &&
                                                            !isCardFlipped)
                                                          Positioned(
                                                            bottom: 4.h,
                                                            child: AnimatedOpacity(
                                                              opacity: 1.0,
                                                              duration:
                                                                  const Duration(
                                                                    milliseconds:
                                                                        300,
                                                                  ),
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10.w,
                                                                      vertical:
                                                                          4.h,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      const Color.fromARGB(
                                                                        42,
                                                                        0,
                                                                        0,
                                                                        0,
                                                                      ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        12.r,
                                                                      ),
                                                                ),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .flip_rounded,
                                                                      color: Colors
                                                                          .white,
                                                                      size:
                                                                          14.sp,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          5.w,
                                                                    ),
                                                                    Text(
                                                                      'TAP TO FLIP',
                                                                      style: AppTextStyles.bizudMincho400Regular12(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            9.sp,
                                                                      ),
                                                                    ),
                                                                  ],
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
                                    ),
                                  ),
                                ),

                                // ── Layer 4: Envelope Front Pocket (Envelope_front.png) (Fades Out) ──
                                if (envOpacity > 0.0)
                                  Positioned(
                                    top: 220.92.h,
                                    width: 320.w,
                                    height: 200.37.h,
                                    child: Opacity(
                                      opacity: envOpacity,
                                      child: Image.asset(
                                        AppAssets.envelopeFront,
                                        fit: BoxFit.fill,
                                        filterQuality: FilterQuality.low,
                                      ),
                                    ),
                                  ),

                                // ── Layer 5: Closed 3D Rotating Top Flap (closed_top.svg) (3D Rotates & Cross-fades) ──
                                if (flapRad <= math.pi * 0.50 && envOpacity > 0.0)
                                  Positioned(
                                    top: 211.29.h,
                                    left: 44.w,
                                    width: 302.w,
                                    height: 133.h,
                                    child: Opacity(
                                      opacity: envOpacity * closedFlapAlpha,
                                      child: Transform(
                                        alignment: Alignment.topCenter,
                                        transform: Matrix4.identity()
                                          ..setEntry(3, 2, 0.001)
                                          ..rotateX(flapRad.clamp(0.0, math.pi / 2)),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(
                                                  0x1A000000,
                                                ), // #0000001A
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: SvgPicture.asset(
                                            AppAssets.closedTop,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Replay Button at Bottom (Consistent with App Design System)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: PrimaryButton(
                text: 'Replay Animation',
                onPressed: () {
                  _hintTimer?.cancel();
                  _controller.reset();
                  _controller.forward();
                  _flipController.reset();
                  _teaserController.reset();
                  setState(() {
                    _isFlipped = false;
                    _showFlipHint = false;
                  });
                },

              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
