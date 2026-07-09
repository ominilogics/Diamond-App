import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:daimond/l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/gradient_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget _buildBodyText(String text) {
    final baseStyle = AppTextStyles.roboto400Regular14(
      color: const Color(0xFF525252),
    ).copyWith(height: 1.5);

    const email = 'support.ominilogics@gmail.com';

    if (text.contains(email)) {
      final parts = text.split(email);
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: parts[0]),
            TextSpan(
              text: email,
              style: baseStyle.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF000000),
              ),
            ),
            if (parts.length > 1) TextSpan(text: parts[1]),
          ],
        ),
        style: baseStyle,
      );
    }
    return Text(text, style: baseStyle);
  }

  List<Widget> _buildFormattedContent(String content) {
    final sections = content.split('\n\n');
    return sections.map((section) {
      if (section.startsWith(RegExp(r'^\d+\.'))) {
        final parts = section.split('\n');
        final header = parts.first;
        final body = parts.skip(1).join('\n');

        return Padding(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(header, style: AppTextStyles.colitez400Italic20()),
              if (body.isNotEmpty) ...[
                SizedBox(height: 8.h),
                _buildBodyText(body),
              ],
            ],
          ),
        );
      } else {
        return Padding(
          padding: EdgeInsets.only(bottom: 24.h),
          child: _buildBodyText(section),
        );
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;

    return GradientScaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final isScrolled = constraints.scrollOffset > 0;
                return SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: isScrolled
                      ? const Color(0xFFE7FFEC)
                      : Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 3.0,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 60.h,
                  titleSpacing: 0,
                  title: Column(
                    children: [
                      SizedBox(height: 12.h),
                      AppBar2(title: texts.privacyPolicy),
                    ],
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    ..._buildFormattedContent(texts.privacyPolicyContent),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
