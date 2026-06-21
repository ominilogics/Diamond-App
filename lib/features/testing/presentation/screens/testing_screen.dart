import 'package:daimond/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/utils/app_snackbars.dart';

class TestingScreen extends StatelessWidget {
  const TestingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GradientScaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PrimaryButton(
              text: 'Show Confirmation Dialog',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmationDialog(
                      title: l10n.logoutConfirmation,
                      message: l10n.mothersDayDesc,
                      confirmText: l10n.yes,
                      cancelText: l10n.no,
                      onConfirm: () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              },
            ),
            SizedBox(height: 24.h),
            PrimaryButton(
              text: 'Show Error Snackbar',
              onPressed: () {
                AppSnackbars.showError(
                  context,
                  title: l10n.loginFailedTitle,
                  message: l10n.loginFailedMessage,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
