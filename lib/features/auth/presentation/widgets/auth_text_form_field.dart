import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class AuthTextFormField extends StatelessWidget {
  const AuthTextFormField({
    required this.controller,
    required this.label,
    required this.prefixIcon,
    super.key,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onTapOutside: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      validator: validator,
      obscureText: obscureText,
      cursorColor: AppColors.primary,
      style: context.textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: context.textTheme.labelLarge,
        floatingLabelStyle: context.textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: AppColors.secondaryText,
          size: 21.sp,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.fieldFill,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 17.h),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary, width: 1.5),
        errorBorder: _border(AppColors.error),
        focusedErrorBorder: _border(AppColors.error, width: 1.5),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
