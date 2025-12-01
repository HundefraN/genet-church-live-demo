import 'package:flutter/material.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/shared_widgets/modern_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return InfoCard(
      title: 'Manage Categories',
      subtitle:
      'Add, edit, or remove member categories and groups from this section.',
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      trailing: Center(
        child: Text(
          'Content Coming Soon',
          style: TextStyle(fontSize: 18, color: appColors.textSecondary),
        ),
      ),
    );
  }
}