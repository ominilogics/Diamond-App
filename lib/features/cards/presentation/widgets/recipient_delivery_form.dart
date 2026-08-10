import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../domain/entities/country_code.dart';
import '../../domain/entities/delivery_method.dart';
import 'country_picker_bottom_sheet.dart';


class RecipientDeliveryForm extends HookWidget {
  final TextEditingController? phoneController;

  /// Called when the user taps Send with valid input.
  /// Provides the E.164 formatted phone number and the selected delivery method.
  final void Function(String e164Phone, DeliveryMethod method)? onSendPressed;
  final bool isLoading;

  const RecipientDeliveryForm({
    super.key,
    this.phoneController,
    this.onSendPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final selectedMethod = useState<DeliveryMethod>(DeliveryMethod.sms);
    final isConfirmed = useState<bool>(false);
    final selectedCountry = useState<CountryCode>(CountryCode.defaultCountry);

    final internalPhoneController = useTextEditingController();
    final effectivePhoneController = phoneController ?? internalPhoneController;
    final texts = AppLocalizations.of(context)!;

    // Intelligent dial code listener (+44..., 03...)
    useEffect(() {
      void listener() {
        final text = effectivePhoneController.text;
        if (text.isNotEmpty) {
          final result = CountryCode.detectFromInput(
            text,
            currentFallback: selectedCountry.value,
          );
          if (result.country != selectedCountry.value) {
            selectedCountry.value = result.country;
          }
          final clean = result.cleanNumber.length > 10
              ? result.cleanNumber.substring(0, 10)
              : result.cleanNumber;
          if (clean != text) {
            effectivePhoneController.value = TextEditingValue(
              text: clean,
              selection: TextSelection.collapsed(offset: clean.length),
            );
          }
        }
      }

      effectivePhoneController.addListener(listener);
      return () => effectivePhoneController.removeListener(listener);
    }, [effectivePhoneController]);

    // Native Contacts Picker
    Future<void> pickNativeContact() async {
      final status = await Permission.contacts.status;
      if (status.isPermanentlyDenied) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (dialogCtx) => ConfirmationDialog(
            title: 'Contacts Access Disabled',
            message:
                'Contacts permission is disabled in your device settings. Please enable contacts permission in your phone settings to select a recipient from your contacts.',
            confirmText: 'Settings',
            cancelText: texts.cancel,
            onConfirm: () async {
              Navigator.pop(dialogCtx);
              await openAppSettings();
            },
            onCancel: () => Navigator.pop(dialogCtx),
          ),
        );
        return;
      }

      final permission = await Permission.contacts.request();
      if (permission.isGranted) {
        try {
          final contact = await FlutterContacts.openExternalPick();
          if (contact != null && contact.phones.isNotEmpty) {
            final rawPhone = contact.phones.first.number;
            final result = CountryCode.detectFromInput(
              rawPhone,
              currentFallback: selectedCountry.value,
            );
            selectedCountry.value = result.country;
            final clean = result.cleanNumber.length > 10
                ? result.cleanNumber.substring(result.cleanNumber.length - 10)
                : result.cleanNumber;
            effectivePhoneController.text = clean;
          }
        } catch (e) {
          if (!context.mounted) return;
          CustomSnackbar.showError(context, 'Unable to open contacts picker.');
        }
      } else if (permission.isPermanentlyDenied) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (dialogCtx) => ConfirmationDialog(
            title: 'Contacts Access Disabled',
            message:
                'Contacts permission is disabled in your device settings. Please enable contacts permission in your phone settings to select a recipient from your contacts.',
            confirmText: 'Settings',
            cancelText: texts.cancel,
            onConfirm: () async {
              Navigator.pop(dialogCtx);
              await openAppSettings();
            },
            onCancel: () => Navigator.pop(dialogCtx),
          ),
        );
      } else {
        if (!context.mounted) return;
        CustomSnackbar.showError(
          context,
          'Permission to access contacts was denied.',
        );
      }
    }

    // Form Submission & Validation
    void handleSend() {
      final phoneText = effectivePhoneController.text.replaceAll(
        RegExp(r'\D'),
        '',
      );

      // TEMPORARY: Bypass form validation for testing.
      // To revert: uncomment the two blocks below marked PRODUCTION.
      //
      // ── PRODUCTION: 10-digit phone validation (commented out) ────────────
      // if (phoneText.length != 10) {
      //   CustomSnackbar.showError(
      //     context,
      //     'Please enter a 10-digit phone number.',
      //   );
      //   return;
      // }
      // ── END PRODUCTION ───────────────────────────────────────────────────

      // ── PRODUCTION: Confirmation checkbox validation (commented out) ──────
      // if (!isConfirmed.value) {
      //   CustomSnackbar.showError(
      //     context,
      //     'Please check the confirmation box before sending.',
      //   );
      //   return;
      // }
      // ── END PRODUCTION ───────────────────────────────────────────────────

      // Build an E.164 formatted phone number for the backend
      final e164Phone = '${selectedCountry.value.dialCode}$phoneText';
      onSendPressed?.call(e164Phone, selectedMethod.value);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. SMS & WhatsApp Selector Container ─────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final pillWidth = (constraints.maxWidth - 8.w) / 2;
            final isSms = selectedMethod.value == DeliveryMethod.sms;
            return Container(
              width: double.infinity,
              height: 48.h,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.black, width: 0.5.w),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutCubic,
                    left: isSms ? 0 : pillWidth,
                    top: 0,
                    bottom: 0,
                    width: pillWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5E60),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // SMS Chip
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => selectedMethod.value = DeliveryMethod.sms,
                          child: Container(
                            height: double.infinity,
                            alignment: Alignment.center,
                            child: Text(
                              'SMS',
                              style: AppTextStyles.colitez400Italic16(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // WhatsApp Chip
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => selectedMethod.value = DeliveryMethod.whatsApp,
                          child: Container(
                            height: double.infinity,
                            alignment: Alignment.center,
                            child: Text(
                              'WhatsApp',
                              style: AppTextStyles.colitez400Italic16(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        SizedBox(height: 24.h),

        // ── 2. Add Recipient Title (Font Size 20px) ────────────────────────
        Text(texts.addRecipient, style: AppTextStyles.colitez400Italic20()),

        SizedBox(height: 15.h),

        // ── 3. Phone Number Input Field ──────────────────────────────────
        Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.black, width: 0.5.w),
          ),
          child: Row(
            children: [
              // Flag & Country Code (Whole area tapable)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final picked = await CountryPickerBottomSheet.show(
                    context,
                    selectedCountry: selectedCountry.value,
                  );
                  if (picked != null) {
                    selectedCountry.value = picked;
                  }
                },
                child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Text(
                        '${selectedCountry.value.flag}  ${selectedCountry.value.dialCode}',
                        style: AppTextStyles.roboto300Light12(
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      const Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
              // Vertical Divider line
              Container(width: 0.5.w, height: 20.h, color: Colors.black),
              SizedBox(width: 10.w),
              // Phone Input Field (easily clickable across full height)
              Expanded(
                child: Container(
                  height: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: effectivePhoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: AppTextStyles.roboto300Light12(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Enter 10-digit phone number',
                      hintStyle: AppTextStyles.roboto300Light12(
                        color: Colors.black54,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
              ),

              // Trailing Contacts Icon (Native Contacts OS Picker)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: pickNativeContact,
                child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icons/contacts.svg',
                    width: 24.w,
                    height: 24.h,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 31.h),

        // ── 4. Circular Confirmation Checkbox & Dynamic Text ──────────────
        GestureDetector(
          onTap: () => isConfirmed.value = !isConfirmed.value,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Circular Checkbox (Active Gradient + White Checkmark)
              Container(
                width: 18.w,
                height: 18.h,
                margin: EdgeInsets.only(top: 2.h),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isConfirmed.value
                      ? AppColors.primaryButtonGradient
                      : null,
                  border: Border.all(
                    color: isConfirmed.value
                        ? Colors.transparent
                        : Colors.black,
                    width: 1.2.w,
                  ),
                ),
                child: isConfirmed.value
                    ? Icon(Icons.check, size: 12.w, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 10.w),
              // Dynamic Confirmation Text (SMS vs WhatsApp)
              Expanded(
                child: Text(
                  selectedMethod.value == DeliveryMethod.sms
                      ? "By checking this box, I confirm that I want to send this digital card and its accompanying message directly to the recipient's phone number via SMS."
                      : "By checking this box, I confirm that I want to send this digital card and its accompanying message directly to the recipient's phone number via WhatsApp.",
                  style: AppTextStyles.roboto300Light12(
                    color: Colors.black,
                    height: 1.37,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 32.h),

        // ── 5. Send Button ────────────────────────────────────────────────
        PrimaryButton(
          text: texts.sendButton,
          isLoading: isLoading,
          onPressed: handleSend,
        ),
      ],
    );
  }
}
