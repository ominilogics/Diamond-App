import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';

class EditCardScreen extends HookConsumerWidget {
  final String cardId;

  const EditCardScreen({
    super.key,
    required this.cardId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = useState('Your custom message here');
    final textColor = useState<Color>(const Color(0xFF000000));
    final textPosition = useState<Offset>(Offset(100.w, 100.h));
    final isEditingText = useState(false);
    final textController = useTextEditingController(text: message.value);

    // Font selection
    final fontIndex = useState(0);
    final List<TextStyle Function({Color? color})> fonts = [
      ({Color? color}) => AppTextStyles.colitez400Italic24(color: color),
      ({Color? color}) => AppTextStyles.roboto400Regular20(color: color),
      ({Color? color}) => AppTextStyles.colitez400Italic32(color: color),
    ];

    // Colors
    final colors = [
      const Color(0xFF000000),
      const Color(0xFFFFFFFF),
      AppColors.card1,
      AppColors.card2,
      AppColors.card3,
      AppColors.card4,
      AppColors.card5,
    ];

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            const AppBar2(title: 'Customize Card'),
            SizedBox(height: 24.h),
            
            // Canvas Area
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFF000000), width: 0.5.w),
                  ),
                  child: Stack(
                    children: [
                      // Base Card SVG
                      Positioned.fill(
                        child: SvgPicture.asset(
                          AppAssets.gatta,
                          fit: BoxFit.contain,
                        ),
                      ),
                      
                      // Draggable Text
                      Positioned(
                        left: textPosition.value.dx,
                        top: textPosition.value.dy,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            textPosition.value = Offset(
                              textPosition.value.dx + details.delta.dx,
                              textPosition.value.dy + details.delta.dy,
                            );
                          },
                          onTap: () {
                            isEditingText.value = true;
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isEditingText.value ? Colors.blue : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              message.value,
                              style: fonts[fontIndex.value](color: textColor.value),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Editing Toolbar
            if (isEditingText.value) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        onChanged: (val) => message.value = val,
                        decoration: InputDecoration(
                          hintText: 'Enter your message',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.black, width: 0.5.w),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.black, width: 0.5.w),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => isEditingText.value = false,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ] else ...[
              // Tools
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Colors', style: AppTextStyles.roboto400Regular14()),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 40.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: colors.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12.w),
                        itemBuilder: (context, index) {
                          final color = colors[index];
                          final isSelected = textColor.value == color;
                          return GestureDetector(
                            onTap: () => textColor.value = color,
                            child: Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.black,
                                  width: isSelected ? 2.w : 0.5.w,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text('Fonts', style: AppTextStyles.roboto400Regular14()),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 40.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: fonts.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12.w),
                        itemBuilder: (context, index) {
                          final isSelected = fontIndex.value == index;
                          return GestureDetector(
                            onTap: () => fontIndex.value = index,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: Colors.black, width: 0.5.w),
                              ),
                              child: Text(
                                'Font ${index + 1}',
                                style: AppTextStyles.roboto400Regular14(
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: PrimaryButton(
                text: "Save & Continue",
                onPressed: () {
                  // Finalize logic here
                },
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
