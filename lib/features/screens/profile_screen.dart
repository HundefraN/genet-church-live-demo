import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:genet_church_portal/shared_widgets/modern_button.dart';
import 'package:genet_church_portal/shared_widgets/modern_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_input.dart';
import 'package:genet_church_portal/shared_widgets/notification_system.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final user = ref.watch(authStateProvider);
    final pastor = ref.watch(currentPastorProvider);
    final churchesAsync = ref.watch(churchesProvider);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userInitial =
    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?';

    String? churchName;
    final churches = churchesAsync.valueOrNull;
    final churchIdToUse = pastor.value?.churchId;
    if (churchIdToUse != null && churches != null) {
      churchName = churches
          .where((c) => c.id == churchIdToUse)
          .map((c) => c.name)
          .cast<String?>()
          .firstWhere(
            (name) => name != null && name.isNotEmpty,
        orElse: () => null,
      );
    }

    void showEditProfileDialog() {
      final nameController = TextEditingController(text: user.fullName);
      final emailController = TextEditingController(text: user.email);

      showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: ModernCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Profile',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ModernInput(
                    controller: nameController,
                    label: 'Full Name',
                    prefixIcon: Iconsax.user,
                  ),
                  const SizedBox(height: 16),
                  EmailInput(
                    controller: emailController,
                    label: 'Email Address',
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlineButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(dialogContext),
                        size: ButtonSize.medium,
                      ),
                      const SizedBox(width: 12),
                      ModernButton(
                        text: 'Save',
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          context.showSuccessNotification(
                            title: 'Profile Updated',
                            message:
                            'Your profile has been updated successfully.',
                          );
                        },
                        size: ButtonSize.medium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // FIX: Removed expanded Container and Alignment to prevent infinite height error
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 60,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                userInitial,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user.fullName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: appColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.role.replaceAll('_', ' ').toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ModernCard(
              child: Column(
                children: [
                  _ProfileInfoRow(
                    icon: Iconsax.direct_right,
                    label: 'Email',
                    value: user.email,
                  ),
                  if (churchName != null) ...[
                    const Divider(),
                    _ProfileInfoRow(
                      icon: Iconsax.building_4,
                      label: 'Assigned Church',
                      value: churchName,
                    ),
                  ],
                  const Divider(),
                  const _ProfileInfoRow(
                    icon: Iconsax.key,
                    label: 'Password',
                    value: '••••••••',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlineButton(
                    text: 'Change Password',
                    onPressed: () {
                      context.showInfoNotification(
                        title: 'Coming Soon',
                        message:
                        'Password change feature is currently being developed.',
                      );
                    },
                    icon: Iconsax.key,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ModernButton(
                    text: 'Edit Profile',
                    onPressed: showEditProfileDialog,
                    icon: Iconsax.edit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: appColors.scaffold,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: appColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: appColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}