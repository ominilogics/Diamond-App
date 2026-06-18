import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/app_labelled_text_field.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      // Proceed with login logic
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
                  'Login',
                  style: AppTextStyles.colitez400Italic32(),
                ),
                SizedBox(height: 9.h),
                Text(
                  'Sign in to access your favorite cards, saved drafts, and\npersonal collections.',
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
                SizedBox(height: 16.h),
                
                AppLabelledTextField(
                  label: 'Password',
                  hintText: 'Enter your password here.',
                  isPassword: true,
                  controller: _passwordController,
                  validator: AppValidators.validateLoginPassword,
                ),
                SizedBox(height: 8.h),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      context.pushNamed(AppRoute.forgotPassword.name);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.roboto300Light13(),
                    ),
                  ),
                ),
                
                SizedBox(height: 32.h),
                
                PrimaryButton(
                  text: 'Login',
                  onPressed: _onLoginPressed,
                ),
                SizedBox(height: 16.h),
                
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to Sign Up
                      context.goNamed(AppRoute.signup.name);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: AppTextStyles.roboto300Light13(),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
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
