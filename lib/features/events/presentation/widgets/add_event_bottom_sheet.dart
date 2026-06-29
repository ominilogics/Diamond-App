import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/app_snackbars.dart';
import '../../domain/entities/event_entity.dart';
import '../providers/events_provider.dart';
import 'custom_date_picker_dialog.dart';

class AddEventBottomSheet extends HookConsumerWidget {
  const AddEventBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const AddEventBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;

    final titleController = useTextEditingController();
    final dateController = useTextEditingController();
    final reminderController = useTextEditingController();
    final selectedDateState = useState<DateTime?>(null);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return SafeArea(
      child: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.only(top: 24.h, bottom: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            texts.addReminderTitle,
                            style: AppTextStyles.colitez400Italic24(),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            texts.addReminderSubtitle,
                            style: AppTextStyles.roboto400Regular12(
                              color: const Color(0xFF525252),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 11.h),
              Divider(
                color: const Color(0xFFA8A8A8),
                thickness: 0.5.h,
                height: 0,
              ),
              SizedBox(height: 20.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Field
                    AppTextField(
                      controller: titleController,
                      labelText: texts.eventTitleLabel,
                      hintText: texts.eventTitleHint,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Reminder Field
                    Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                      child: PopupMenuButton<String>(
                        initialValue: reminderController.text,
                      onSelected: (val) => reminderController.text = val,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      color: Colors.white,
                      offset: Offset(MediaQuery.of(context).size.width, 44.h),
                      itemBuilder: (context) {
                        final itemStyle = AppTextStyles.roboto400Regular13(
                          color: Colors.black,
                        );
                        return [
                          PopupMenuItem(
                            value: "3 Days Before",
                            height: 32.h,
                            child: Text("3 Days Before", style: itemStyle),
                          ),
                          PopupMenuItem(
                            value: "A Week Before",
                            height: 32.h,
                            child: Text("A Week Before", style: itemStyle),
                          ),
                          PopupMenuItem(
                            value: "One Day Before",
                            height: 32.h,
                            child: Text("One Day Before", style: itemStyle),
                          ),
                        ];
                      },
                      child: AbsorbPointer(
                        child: AppTextField(
                          labelText: texts.eventReminderLabel,
                          hintText: texts.eventReminderHint,
                          controller: reminderController,
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a reminder';
                            }
                            return null;
                          },
                          suffixIcon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                            size: 24.w,
                          ),
                        ),
                      ),
                    ),
                    ),
                    SizedBox(height: 24.h),

                    // Date Field
                    GestureDetector(
                      onTap: () async {
                        final selectedDate = await CustomDatePickerDialog.show(
                          context,
                          DateTime.now(),
                        );
                        if (selectedDate != null) {
                          selectedDateState.value = selectedDate;
                          dateController.text = DateFormat(
                            'MMM dd, yyyy',
                          ).format(selectedDate).toUpperCase();
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: AbsorbPointer(
                        child: AppTextField(
                          controller: dateController,
                          labelText: texts.eventDateLabel,
                          hintText: texts.eventDateHint,
                          readOnly: true,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                selectedDateState.value == null) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      texts.eventDateSubtext,
                      style: AppTextStyles.roboto400Regular12(
                        color: const Color(0xFF525252),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Save Button
                    PrimaryButton(
                      text: texts.saveReminder,
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          try {
                            await ref
                                .read(eventsProvider.notifier)
                                .addEvent(
                                  EventEntity(
                                    id: -1,
                                    title: titleController.text,
                                    date: selectedDateState.value!,
                                    reminder: reminderController.text,
                                    isCustom: true,
                                  ),
                                );
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            if (context.mounted) {
                              AppSnackbars.showError(
                                context,
                                title: "Error",
                                message:
                                    "Failed to save event. Please try again.",
                              );
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
