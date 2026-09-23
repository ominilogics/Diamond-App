import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../admin_theme.dart';

/// Data point for admin charts
class ChartDataPoint {
  final String label;
  final double value;
  final String? displayValue;

  const ChartDataPoint({
    required this.label,
    required this.value,
    this.displayValue,
  });
}

/// A smooth, high-fidelity Area Line Chart with gradient fill
/// Inspired by Shopeers "Total Profit" analytics chart.
class AdminAreaLineChart extends StatefulWidget {
  final List<ChartDataPoint> points;
  final double height;
  final Color lineColor;
  final String? title;
  final String? subtitle;
  final String? mainValue;
  final String? badgeText;
  final Color? badgeColor;
  final Widget? trailing;

  const AdminAreaLineChart({
    super.key,
    required this.points,
    this.height = 260,
    this.lineColor = kPrimary,
    this.title,
    this.subtitle,
    this.mainValue,
    this.badgeText,
    this.badgeColor,
    this.trailing,
  });

  @override
  State<AdminAreaLineChart> createState() => _AdminAreaLineChartState();
}

class _AdminAreaLineChartState extends State<AdminAreaLineChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kCardDecoration,
      padding: const EdgeInsets.all(kCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart Header
          if (widget.title != null || widget.mainValue != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.title != null)
                      Text(
                        widget.title!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kLabelColor,
                        ),
                      ),
                    if (widget.mainValue != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            widget.mainValue!,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: kTitleColor,
                              letterSpacing: -0.4,
                            ),
                          ),
                          if (widget.badgeText != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: (widget.badgeColor ?? kSuccess)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.badgeText!,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: widget.badgeColor ?? kSuccess,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: kMutedColor,
                        ),
                      ),
                    ],
                  ],
                ),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Chart Canvas
          SizedBox(
            height: widget.height,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return MouseRegion(
                  onHover: (event) {
                    final boxWidth = constraints.maxWidth;
                    if (widget.points.isEmpty || boxWidth <= 0) return;
                    final stepX = boxWidth / (widget.points.length - 1);
                    final index = (event.localPosition.dx / stepX).round().clamp(
                          0,
                          widget.points.length - 1,
                        );
                    if (_hoveredIndex != index) {
                      setState(() => _hoveredIndex = index);
                    }
                  },
                  onExit: (_) {
                    if (_hoveredIndex != null) {
                      setState(() => _hoveredIndex = null);
                    }
                  },
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(constraints.maxWidth, widget.height),
                        painter: _AreaChartPainter(
                          points: widget.points,
                          lineColor: widget.lineColor,
                          hoveredIndex: _hoveredIndex,
                        ),
                      ),
                      // Hover Tooltip
                      if (_hoveredIndex != null &&
                          _hoveredIndex! < widget.points.length)
                        _buildTooltip(constraints.maxWidth, widget.height),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip(double width, double height) {
    final pt = widget.points[_hoveredIndex!];
    final stepX = width / (widget.points.length - 1);
    final posX = _hoveredIndex! * stepX;

    // Find min and max
    double minVal = widget.points.first.value;
    double maxVal = widget.points.first.value;
    for (final p in widget.points) {
      if (p.value < minVal) minVal = p.value;
      if (p.value > maxVal) maxVal = p.value;
    }
    final range = maxVal - minVal == 0 ? 1.0 : (maxVal - minVal);
    final normalized = (pt.value - minVal) / range;
    final chartH = height - 28;
    final posY = (1.0 - normalized) * chartH + 10;

    return Positioned(
      left: (posX - 40).clamp(0.0, width - 80),
      top: (posY - 44).clamp(0.0, height - 40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: kTitleColor,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pt.displayValue ?? pt.value.toStringAsFixed(1),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              pt.label,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  final List<ChartDataPoint> points;
  final Color lineColor;
  final int? hoveredIndex;

  _AreaChartPainter({
    required this.points,
    required this.lineColor,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final bottomPadding = 26.0;
    final topPadding = 12.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final chartWidth = size.width;

    double minVal = points.first.value;
    double maxVal = points.first.value;
    for (final p in points) {
      if (p.value < minVal) minVal = p.value;
      if (p.value > maxVal) maxVal = p.value;
    }
    if (maxVal == minVal) {
      maxVal += 10;
      minVal = math.max(0, minVal - 10);
    }
    final range = maxVal - minVal;

    // 1. Draw subtle horizontal grid lines (3 lines)
    final gridPaint = Paint()
      ..color = kDashBorder.withValues(alpha: 0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 3; i++) {
      final y = topPadding + (chartHeight / 2) * i;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    // 2. Compute coordinates
    final stepX = chartWidth / (points.length - 1);
    final coords = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final norm = (points[i].value - minVal) / range;
      final x = i * stepX;
      final y = topPadding + (1.0 - norm) * chartHeight;
      coords.add(Offset(x, y));
    }

    // 3. Build Smooth Bezier Path
    final path = Path();
    path.moveTo(coords[0].dx, coords[0].dy);

    for (int i = 0; i < coords.length - 1; i++) {
      final current = coords[i];
      final next = coords[i + 1];
      final control1 = Offset(current.dx + (next.dx - current.dx) / 2, current.dy);
      final control2 = Offset(current.dx + (next.dx - current.dx) / 2, next.dy);
      path.cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        next.dx,
        next.dy,
      );
    }

    // 4. Fill Area Gradient Under Path
    final fillPath = Path.from(path);
    fillPath.lineTo(coords.last.dx, topPadding + chartHeight);
    fillPath.lineTo(coords.first.dx, topPadding + chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.22),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, topPadding, chartWidth, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 5. Stroke Line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // 6. Draw X-axis label markers
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final labelStep = (points.length / 5).ceil().clamp(1, points.length);

    for (int i = 0; i < points.length; i += labelStep) {
      final pt = points[i];
      final coord = coords[i];

      textPainter.text = TextSpan(
        text: pt.label,
        style: GoogleFonts.inter(
          color: kMutedColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (coord.dx - textPainter.width / 2).clamp(0.0, chartWidth - textPainter.width),
          size.height - 18,
        ),
      );
    }

    // 7. Draw Hover Point
    if (hoveredIndex != null && hoveredIndex! < coords.length) {
      final hCoord = coords[hoveredIndex!];

      // Vertical guide line
      final guidePaint = Paint()
        ..color = lineColor.withValues(alpha: 0.35)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(hCoord.dx, topPadding),
        Offset(hCoord.dx, topPadding + chartHeight),
        guidePaint,
      );

      // Outer glow circle
      canvas.drawCircle(
        hCoord,
        7,
        Paint()..color = lineColor.withValues(alpha: 0.2),
      );
      // Inner dot
      canvas.drawCircle(
        hCoord,
        4.5,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        hCoord,
        3,
        Paint()..color = lineColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor;
  }
}

/// A modern vertical Bar Chart with active day highlight
/// Inspired by Shopeers "Most Day Active" weekly chart.
class AdminWeeklyBarChart extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<ChartDataPoint> data;
  final int highlightedIndex;
  final Color activeColor;
  final Color inactiveColor;

  const AdminWeeklyBarChart({
    super.key,
    required this.title,
    this.subtitle,
    required this.data,
    this.highlightedIndex = 2, // e.g. Tuesday
    this.activeColor = kPrimary,
    this.inactiveColor = const Color(0xFFE2E8F0),
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = data.fold<double>(
      1.0,
      (max, d) => d.value > max ? d.value : max,
    );

    return Container(
      decoration: kCardDecoration,
      padding: const EdgeInsets.all(kCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kLabelColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: kMutedColor,
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: kDashBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 16,
                  color: kLabelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 105,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(data.length, (i) {
                final item = data[i];
                final isHighlighted = i == highlightedIndex;
                final heightFactor = (item.value / maxVal).clamp(0.08, 1.0);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isHighlighted)
                          Container(
                            margin: const EdgeInsets.only(bottom: 3),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: activeColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              item.displayValue ?? item.value.toInt().toString(),
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: heightFactor,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isHighlighted
                                      ? activeColor
                                      : (inactiveColor == const Color(0xFFE2E8F0) ? kDashBorder : inactiveColor),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: isHighlighted
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isHighlighted ? kTitleColor : kMutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// A high-definition Donut / Retention Chart with center statistics
/// Inspired by Shopeers "Repeat Customer Rate" (68%).
class AdminDonutChart extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double percentage; // 0.0 to 100.0
  final String centerLabel;
  final String targetText;
  final Color primaryColor;
  final Color trackColor;

  const AdminDonutChart({
    super.key,
    required this.title,
    this.subtitle,
    required this.percentage,
    required this.centerLabel,
    this.targetText = 'On track for 80% target',
    this.primaryColor = kPrimary,
    this.trackColor = const Color(0xFFF1F5F9),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kCardDecoration,
      padding: const EdgeInsets.all(kCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kLabelColor,
                ),
              ),
              const Icon(
                Icons.more_horiz_rounded,
                size: 16,
                color: kMutedColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: SizedBox(
              width: 108,
              height: 108,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(108, 108),
                    painter: _DonutChartPainter(
                      percentage: percentage,
                      primaryColor: primaryColor,
                      trackColor: trackColor == const Color(0xFFF1F5F9) ? kDashDivider : trackColor,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        centerLabel,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: kTitleColor,
                          letterSpacing: -0.4,
                        ),
                      ),
                      Text(
                        'Retained',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: kMutedColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              targetText,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: kSuccess,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double percentage;
  final Color primaryColor;
  final Color trackColor;

  _DonutChartPainter({
    required this.percentage,
    required this.primaryColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Draw track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw progress arc
    final sweepAngle = (percentage / 100.0) * 2 * math.pi;
    final progressPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.primaryColor != primaryColor;
  }
}
