import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/app_helpers.dart';

class SearchBarWidget extends HookWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const SearchBarWidget({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    final internalController = controller ?? useTextEditingController();
    useListenable(internalController);
    final hasText = internalController.text.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: AppTextField(
        controller: internalController,
        onChanged: onChanged,
        hintText: texts.searchHint,
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 8.w),
          child: SvgPicture.asset(
            AppAssets.search,
            width: 20.w,
            height: 20.h,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
        ),
        suffixIcon: hasText
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  internalController.clear();
                  onChanged?.call('');
                  AppHelpers.dismissKeyboard();
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 16.w, left: 16.w),
                  child: UnconstrainedBox(
                    child: SvgPicture.asset(
                      AppAssets.cancel,
                      width: 15.w,
                      height: 15.w,
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
