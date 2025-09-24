import 'package:flutter/material.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';

class ModernTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const ModernTextField({
    super.key,
    this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.scaffoldBackground,
        hintText: hintText,
        hintStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
}