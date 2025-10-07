import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class ModernDatePicker extends HookWidget {
  final String hintText;
  final IconData icon;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final String? Function(String?)? validator;

  const ModernDatePicker({
    super.key,
    required this.hintText,
    required this.icon,
    this.selectedDate,
    required this.onDateSelected,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final controller = useTextEditingController();

    useEffect(() {
      final newText = selectedDate != null
          ? DateFormat.yMMMMd().format(selectedDate!)
          : '';
      if (controller.text != newText) {
        controller.text = newText;
      }
      return null;
    }, [selectedDate]);

    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: theme.colorScheme.primary,
                  onPrimary: Colors.white,
                  onSurface: appColors.textPrimary,
                ),
                dialogBackgroundColor: appColors.surface,
                dialogTheme: DialogThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null && picked != selectedDate) {
          onDateSelected(picked);
        }
      },
      validator: validator,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        color: appColors.textPrimary,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: appColors.scaffold,
        hintText: hintText,
        hintStyle: TextStyle(color: appColors.textSecondary),
        prefixIcon: Icon(icon, color: appColors.textSecondary, size: 20),
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
          borderSide:
          BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
}