import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/theme/app_text_styles.dart';

class DraftCardWidget extends StatelessWidget {
  final String cardId;
  final String coverText;
  final String insideMessage;

  const DraftCardWidget({
    super.key,
    required this.cardId,
    required this.coverText,
    required this.insideMessage,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.black, width: 0.5.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${texts.draftPrefix}$cardId',
            style: AppTextStyles.colitez400Italic20(),
          ),
          SizedBox(height: 8.h),
          Text(
            '${texts.coverPrefix}$coverText',
            style: AppTextStyles.roboto300Light13(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            '${texts.insidePrefix}$insideMessage',
            style: AppTextStyles.roboto300Light13(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
