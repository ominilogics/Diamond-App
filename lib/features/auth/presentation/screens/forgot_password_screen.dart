import 'package:daimond/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/app_labelled_text_field.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendPressed() {
    if (_formKey.currentState!.validate()) {
      // Proceed with password reset
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 72.h),
                Text(
                  'Forgot Password?',
                  style: AppTextStyles.colitez400Italic32(),
                ),
                SizedBox(height: 9.h),
                Text(
                  'No worries. Enter your email and we\'ll send you a link to\nreset your password.',
                  style: AppTextStyles.roboto300Light13(),
                ),
                SizedBox(height: 29.h),
                
                AppLabelledTextField(
                  label: 'Email', 
                  hintText: 'Enter your email here.',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: AppValidators.validateEmail,
                ),
                
                SizedBox(height: 35.h),
                
                PrimaryButton(
                  text: 'Send',
                  onPressed: _onSendPressed,
                ),
                SizedBox(height: 16.h),
                
                Center(
                  child: GestureDetector(
                    onTap: () {
                      context.goNamed(AppRoute.login.name);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Remember your password? ',
                        style: AppTextStyles.roboto300Light13(),
                        children: [
                          TextSpan(
                            text: 'Log In',
                            style: AppTextStyles.roboto400Regular13(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
