import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/gradient_scaffold.dart';

class NotificationSettingsScreen extends HookConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;
    
    final pushNotifications = useState(true);
    final islamicEvents = useState(false);
    final newCardAlerts = useState(true);
    final eventReminders = useState(true);
    final specialOffers = useState(false);

    Widget buildToggleRow(String title, ValueNotifier<bool> state, {bool isEnabled = true}) {
      return IgnorePointer(
        ignoring: !isEnabled,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.4,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTextStyles.roboto400Regular16()),
                _GradientSwitch(
                  value: isEnabled ? state.value : false,
                  onChanged: (val) {
                    if (isEnabled) state.value = val;
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildDivider() {
      return Center(
        child: Container(
          width: double.infinity,
          height: 0.5.h,
          color: const Color(0xFFA8A8A8),
        ),
      );
    }

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            AppBar2(title: texts.notificationSettings),
            SizedBox(height: 24.h),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFF000000),
                        width: 0.5.w,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildToggleRow(texts.pushNotifications, pushNotifications),
                          buildDivider(),
                          buildToggleRow(texts.islamicEvents, islamicEvents, isEnabled: pushNotifications.value),
                          buildDivider(),
                          buildToggleRow(texts.newCardAlerts, newCardAlerts, isEnabled: pushNotifications.value),
                          buildDivider(),
                          buildToggleRow(texts.eventReminders, eventReminders, isEnabled: pushNotifications.value),
                          buildDivider(),
                          buildToggleRow(texts.specialOffers, specialOffers, isEnabled: pushNotifications.value),
                        ],
                      ),
                    ),
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

class _GradientSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _GradientSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50.w,
        height: 30.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          gradient: value ? AppColors.primaryButtonGradient : null,
          color: value ? null : const Color(0xFFE0E0E0),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: Container(
              width: 26.w,
              height: 26.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
