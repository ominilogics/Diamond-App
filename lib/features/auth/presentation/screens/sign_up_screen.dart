import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/app_labelled_text_field.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    if (_formKey.currentState!.validate()) {
      // Proceed with sign up (to be hooked up with Riverpod provider)
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
                  'Create an Account',
                  style: AppTextStyles.colitez400Italic32(),
                ),
                SizedBox(height: 9.h),
                Text(
                  'Join and start creating meaningful moments with\nbeautiful cards for every occasion.',
                  style: AppTextStyles.roboto300Light13(),
                ),
                SizedBox(height: 29.h),

                AppLabelledTextField(
                  label: 'Full Name',
                  hintText: 'Enter your full name here.',
                  controller: _nameController,
                  validator: AppValidators.validateName,
                ),
                SizedBox(height: 16.h),

                AppLabelledTextField(
                  label: 'Email',
                  hintText: 'Enter your email here.',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: AppValidators.validateEmail,
                ),
                SizedBox(height: 16.h),

                AppLabelledTextField(
                  label: 'Password',
                  hintText: 'Enter your password here.',
                  isPassword: true,
                  controller: _passwordController,
                  validator: AppValidators.validatePassword,
                ),
                SizedBox(height: 16.h),

                AppLabelledTextField(
                  label: 'Confirm Password',
                  hintText: 'Enter password again.',
                  isPassword: true,
                  controller: _confirmPasswordController,
                  validator: (value) => AppValidators.validateConfirmPassword(value, _passwordController.text),
                ),

                SizedBox(height: 35.h),

                PrimaryButton(text: 'Sign Up', onPressed: _onSignUpPressed),
                SizedBox(height: 16.h),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to Login
                      context.goNamed(AppRoute.login.name);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
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
                SizedBox(height: 40.h), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}
