import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../events/presentation/widgets/custom_date_picker_dialog.dart';

class EditProfileScreen extends HookConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? l10n.profileEmail;
    final rawName =
        user?.userMetadata?['custom_name'] as String? ??
        user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        l10n.profileName;
    final rawDob = user?.userMetadata?['date_of_birth'] as String? ?? '';
    final initial = rawName.isNotEmpty ? rawName[0].toUpperCase() : 'U';
    final avatarUrl = user?.userMetadata?['avatar_url'] as String? ??
                      user?.userMetadata?['picture'] as String?;

    final nameController = useTextEditingController(text: rawName);
    final dobController = useTextEditingController(text: rawDob);
    final selectedDobState = useState<DateTime?>(null);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = ref.watch(authProvider);

    void onSave() {
      if (formKey.currentState!.validate()) {
        FocusScope.of(context).unfocus();

        final newName = nameController.text.trim();
        final newDob = dobController.text.trim();
        if (newName == rawName && newDob == rawDob) {
          if (context.mounted) {
            CustomSnackbar.showError(context, 'No changes detected.');
          }
          return;
        }

        ref
            .read(authProvider.notifier)
            .updateProfile(
              newName,
              newDob.isEmpty ? null : newDob,
              (errorMessage) {
                if (context.mounted) {
                  CustomSnackbar.showError(context, errorMessage);
                }
              },
              () {
                if (context.mounted) {
                  CustomSnackbar.showSuccess(
                    context,
                    'Profile updated successfully',
                  );
                  context.pop();
                }
              },
            );
      }
    }

    return GradientScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),
            AppBar2(title: l10n.editProfile),
            SizedBox(height: 32.h),

            // Avatar
            Center(
              child: Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  color: AppColors.card2,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF000000),
                    width: 0.5.w,
                  ),
                ),
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          avatarUrl,
                          width: 90.w,
                          height: 90.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              initial,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w300,
                                fontSize: 40.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w300,
                            fontSize: 40.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
              ),
            ),

            SizedBox(height: 40.h),

            // Form Fields
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.fullNameLabel,
                      style: AppTextStyles.colitez400Italic16(),
                    ),
                    SizedBox(height: 8.h),
                    AppTextField(
                      controller: nameController,
                      validator: AppValidators.validateName,
                      textInputAction: TextInputAction.done,
                      maxLength: 30,
                      onFieldSubmitted: (_) => onSave(),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      l10n.emailLabel,
                      style: AppTextStyles.colitez400Italic16(),
                    ),
                    SizedBox(height: 8.h),
                    AppTextField(hintText: email, readOnly: true),
                    SizedBox(height: 24.h),
                    Text(
                      l10n.dateOfBirthLabel,
                      style: AppTextStyles.colitez400Italic16(),
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final initialDate = selectedDobState.value ?? now;
                        final selectedDate = await CustomDatePickerDialog.show(
                          context,
                          initialDate,
                          minDate: DateTime(1900, 1, 1),
                          maxDate: now,
                        );
                        if (selectedDate != null) {
                          selectedDobState.value = selectedDate;
                          dobController.text = DateFormat(
                            'MMM dd, yyyy',
                          ).format(selectedDate).toUpperCase();
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: AbsorbPointer(
                        child: AppTextField(
                          controller: dobController,
                          hintText: l10n.dateOfBirthHint,
                          readOnly: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    PrimaryButton(
                      text: l10n.saveChanges,
                      isLoading: isLoading,
                      onPressed: onSave,
                    ),
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
