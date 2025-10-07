import 'package:flutter/material.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:iconsax/iconsax.dart';

class ShowMembersScreen extends StatelessWidget {
  const ShowMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Column(
      children: [
        const PageHeader(
          title: 'Member Records',
          description:
          'A searchable and filterable list of all registered members in the church.',
        ),
        const SizedBox(height: 24),
        ContentCard(
          child: Center(
            heightFactor: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.code_1, size: 48, color: appColors.textSecondary),
                const SizedBox(height: 24),
                Text(
                  'Feature In Development',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This screen is waiting for the backend developer to provide the\n`GET /church-members/all` endpoint.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appColors.textSecondary,
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