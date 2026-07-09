import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_assets.dart';

class AnimatedLikeButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onTap;
  final double size;
  final EdgeInsetsGeometry? padding;

  const AnimatedLikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
    this.size = 24.0,
    this.padding,
  });

  @override
  State<AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 300ms is the sweet spot for a snappy, non-sluggish interaction
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Sequence creates the "bouncy pop" effect:
    // 1. Instantly starts scaling up to 1.3x size
    // 2. Snaps back down to 1.0x size
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger the animation on both like and dislike
    if (widget.isLiked != oldWidget.isLiked) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque, // Ensures the entire box is clickable
      // ScaleTransition is heavily optimized. It runs directly on the GPU
      // and skips the Flutter layout/paint phases during animation ticks.
      child: Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SvgPicture.asset(
            widget.isLiked ? AppAssets.favouriteFilled : AppAssets.favourite,
            width: widget.size,
            height: widget.size,
          ),
        ),
      ),
    );
  }
}
