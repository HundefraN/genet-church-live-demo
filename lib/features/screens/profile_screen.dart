import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:genet_church_portal/shared_widgets/secondary_button.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final user = ref.watch(authStateProvider);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userInitial =
    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?';

    void showEditProfileDialog() {
      final nameController = TextEditingController(text: user.fullName);
      final emailController = TextEditingController(text: user.email);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ModernTextField(
                  controller: nameController,
                  hintText: 'Full Name',
                  icon: Iconsax.user,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  controller: emailController,
                  hintText: 'Email Address',
                  icon: Iconsax.direct_right,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ContentCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(
                  userInitial,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                user.fullName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  user.role.replaceAll('_', ' ').toLowerCase(),
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                side: BorderSide.none,
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              const Divider(height: 48),
              _ProfileInfoRow(
                  icon: Iconsax.direct_right,
                  label: 'Email',
                  value: user.email),
              const SizedBox(height: 24),
              _ProfileInfoRow(
                  icon: Iconsax.key, label: 'Password', value: '••••••••'),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SecondaryButton(
                    text: 'Change Password',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon!')),
                      );
                    },
                    icon: Iconsax.key,
                  ),
                  const SizedBox(width: 16),
                  PrimaryButton(
                    text: 'Edit Profile',
                    onPressed: () async => showEditProfileDialog(),
                    icon: Iconsax.edit,
                  ),
                ],
              ),
            ],
          ),
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
    return Row(
      children: [
        Icon(icon, color: appColors.textSecondary, size: 20),
        const SizedBox(width: 16),
        Text(
          label,
          style: TextStyle(
            color: appColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: appColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}