import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'auth_text_form_field.dart';

class AuthPasswordFormField extends StatefulWidget {
  const AuthPasswordFormField({
    required this.controller,
    super.key,
    this.label = 'Password',
    this.textInputAction,
    this.autofillHints,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;

  @override
  State<AuthPasswordFormField> createState() => _AuthPasswordFormFieldState();
}

class _AuthPasswordFormFieldState extends State<AuthPasswordFormField> {
  var _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AuthTextFormField(
      controller: widget.controller,
      label: widget.label,
      prefixIcon: Icons.lock_outline,
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      suffixIcon: IconButton(
        tooltip: _obscureText ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _obscureText = !_obscureText),
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.secondaryText,
        ),
      ),
    );
  }
}
