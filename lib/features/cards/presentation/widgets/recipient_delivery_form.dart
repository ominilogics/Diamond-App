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
import '../../domain/entities/country_code.dart';
import 'country_picker_bottom_sheet.dart';

enum DeliveryMethod { sms, whatsApp }

class RecipientDeliveryForm extends HookWidget {
  final TextEditingController? phoneController;
  final VoidCallback? onSendPressed;
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
        if (text.startsWith('+') || text.startsWith('03')) {
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
      if (phoneText.length != 10) {
        CustomSnackbar.showError(
          context,
          'Please enter a 10-digit phone number.',
        );
        return;
      }

      if (!isConfirmed.value) {
        CustomSnackbar.showError(
          context,
          'Please check the confirmation box before sending.',
        );
        return;
      }
      onSendPressed?.call();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. SMS & WhatsApp Selector Container ─────────────────────────
        Container(
          width: double.infinity,
          height: 48.h,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.black, width: 0.5.w),
          ),
          child: Row(
            children: [
              // SMS Chip
              Expanded(
                child: GestureDetector(
                  onTap: () => selectedMethod.value = DeliveryMethod.sms,
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: selectedMethod.value == DeliveryMethod.sms
                          ? const Color(0xFFFF5E60)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
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
                  onTap: () => selectedMethod.value = DeliveryMethod.whatsApp,
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: selectedMethod.value == DeliveryMethod.whatsApp
                          ? const Color(0xFFFF5E60)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
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
        ),

        SizedBox(height: 24.h),

        // ── 2. Add Recipient Title (Font Size 20px) ────────────────────────
        Text(texts.addRecipient, style: AppTextStyles.colitez400Italic20()),

        SizedBox(height: 15.h),

        // ── 3. Phone Number Input Field ──────────────────────────────────
        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.black, width: 0.5.w),
          ),

          child: Row(
            children: [
              // Flag & Country Code (Interactive Picker Trigger)
              GestureDetector(
                onTap: () async {
                  final picked = await CountryPickerBottomSheet.show(
                    context,
                    selectedCountry: selectedCountry.value,
                  );
                  if (picked != null) {
                    selectedCountry.value = picked;
                  }
                },
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
              SizedBox(width: 10.w),
              // Vertical Divider line
              Container(width: 0.5.w, height: 20.h, color: Colors.black),
              SizedBox(width: 10.w),
              // Phone Input Field
              Expanded(
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
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // Trailing Contacts Icon (Native Contacts OS Picker)
              GestureDetector(
                onTap: pickNativeContact,
                child: SvgPicture.asset(
                  'assets/icons/contacts.svg',
                  width: 24.w,
                  height: 24.h,
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
