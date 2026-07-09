import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';

class MyEventCard extends StatelessWidget {
  final String date;
  final String title;
  final String reminder;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  const MyEventCard({
    super.key,
    required this.date,
    required this.title,
    required this.reminder,
    this.onEdit,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 21.w, top: 16.h, bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF000000), width: 0.5.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date,
                  style: AppTextStyles.roboto400Regular12(
                    color: const Color(0xFF525252),
                    letterSpacing: -0.36,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: AppTextStyles.colitez400Italic24(
                    color: const Color(0xFF000000),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  reminder,
                  style: AppTextStyles.roboto400Regular12(
                    color: const Color(0xFF525252),
                    letterSpacing: -0.36,
                  ),
                ),
              ],
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit?.call();
                } else if (value == 'remove') {
                  onRemove?.call();
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              color: Colors.white,
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(left: 16.w, right: 21.w, top: 10.h, bottom: 10.h),
                child: Icon(Icons.more_vert, color: Colors.black, size: 24.w),
              ),
              itemBuilder: (context) {
                final itemStyle = AppTextStyles.roboto400Regular13(
                  color: Colors.black,
                );
                return [
                  PopupMenuItem(
                    value: 'edit',
                    height: 32.h,
                    child: Text("Edit", style: itemStyle),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    height: 32.h,
                    child: Text(
                      "Remove",
                      style: itemStyle.copyWith(color: Colors.red),
                    ),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }
}
