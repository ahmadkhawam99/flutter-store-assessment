import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigator/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/validation/auth/auth_validators.dart';
import '../widgets/auth_password_form_field.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_text_form_field.dart';
import '../bloc/sign_up_bloc/sign_up_bloc.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          _passwordController.clear();
          AuthMessageBanner.showSuccess(
            context,
            'Registration request accepted. Fake Store does not save new users, so use a built-in demo account to sign in.',
          );
          context.goNamed(AppRoutes.signInName);
        } else if (state is SignUpFailure) {
          _passwordController.clear();
          AuthMessageBanner.showError(context, state.message);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Stack(
            children: [
              Positioned(
                top: -70.h,
                right: -55.w,
                child: Container(
                  width: 190.r,
                  height: 190.r,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.cyan],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 58.h,
                right: 30.w,
                child: Container(
                  width: 34.r,
                  height: 34.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withAlpha(28),
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24.w, 72.h, 24.w, 28.h),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Create account',
                              style: context.textTheme.headlineMedium,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'A few details and you are ready to explore.',
                              style: context.textTheme.bodyLarge,
                            ),
                            SizedBox(height: 30.h),
                            AuthTextFormField(
                              controller: _usernameController,
                              label: 'Username',
                              prefixIcon: Icons.person_outline,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newUsername],
                              validator: AuthValidators.username,
                            ),
                            SizedBox(height: 14.h),
                            AuthTextFormField(
                              controller: _emailController,
                              label: 'Email',
                              prefixIcon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              validator: AuthValidators.email,
                            ),
                            SizedBox(height: 14.h),
                            AuthPasswordFormField(
                              controller: _passwordController,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              validator: AuthValidators.password,
                            ),
                            SizedBox(height: 24.h),
                            BlocBuilder<SignUpBloc, SignUpState>(
                              builder: (context, state) {
                                final isLoading = state is SignUpLoading;
                                return FilledButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            context.read<SignUpBloc>().add(
                                              SignUpSubmittedEvent(
                                                id: 0,
                                                username: _usernameController
                                                    .text
                                                    .trim(),
                                                email: _emailController.text
                                                    .trim(),
                                                password:
                                                    _passwordController.text,
                                              ),
                                            );
                                          }
                                        },
                                  child: isLoading
                                      ? const SizedBox.square(
                                          dimension: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text('Sign Up'),
                                );
                              },
                            ),
                            SizedBox(height: 20.h),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text('Already have an account?'),
                                TextButton(
                                  onPressed: () =>
                                      context.goNamed(AppRoutes.signInName),
                                  child: const Text('Sign In'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
