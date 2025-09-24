import 'package:flutter/material.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:iconsax/iconsax.dart';

class ShowMembersScreen extends StatelessWidget {
  const ShowMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageHeader(
          title: 'Member Records',
          description:
          'A list of all registered members in the church will be displayed here.',
        ),
        const SizedBox(height: 24),
        ContentCard(
          child: Center(
            heightFactor: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.code_1, size: 48, color: AppTheme.textSecondary),
                const SizedBox(height: 24),
                const Text(
                  'Feature Awaiting Backend API',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }
}