import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class ProductSearchField extends StatelessWidget {
  const ProductSearchField({
    required this.onChanged,
    this.onPrimaryBackground = false,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final bool onPrimaryBackground;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search products',
        hintStyle: context.textTheme.bodyLarge,
        prefixIcon: const Icon(Icons.search_rounded),
        prefixIconColor: AppColors.secondaryText,
        filled: true,
        fillColor: onPrimaryBackground ? Colors.white : AppColors.fieldFill,
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
