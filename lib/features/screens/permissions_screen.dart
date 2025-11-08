import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:iconsax/iconsax.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Role Permissions',
          description: 'Configure access levels for different user roles.',
          action: PrimaryButton(
            text: 'Save Changes',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permissions saved! (Simulation)'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: Iconsax.save_2,
          ),
        ),
        const SizedBox(height: 24),
        const _PermissionRoleCard(
          roleName: 'Super Admin',
          roleDescription:
          'Has unrestricted access to all features, including system settings and user management.',
          icon: Iconsax.crown_1,
          iconColor: Color(0xFFF5A623),
          initialPermissions: {
            'Create, Read, Update, Delete Churches': true,
            'Manage All Pastors & Users': true,
            'View Financial Reports': true,
            'Configure System Settings': true,
            'Send Global Communications': true,
          },
          isLocked: true,
        ),
        const SizedBox(height: 24),
        _PermissionRoleCard(
          roleName: 'Pastor',
          roleDescription:
          'Manages members, events, and departments within their assigned church.',
          icon: Iconsax.user_octagon,
          iconColor: theme.colorScheme.primary,
          initialPermissions: const {
            'Add & Manage Church Members': true,
            'Create & Manage Departments': true,
            'View Own Church Reports': true,
            'Send Church-level Communications': true,
            'Manage Servants & Volunteers': false,
          },
        ),
        const SizedBox(height: 24),
        _PermissionRoleCard(
          roleName: 'Servant',
          roleDescription:
          'Assists with managing members and activities within their assigned department.',
          icon: Iconsax.lifebuoy,
          iconColor: theme.colorScheme.secondary,
          initialPermissions: const {
            'View Members in Own Department': true,
            'Mark Member Attendance': true,
            'View Departmental Reports': false,
            'Edit Member Profiles': false,
          },
        ),
      ],
    );
  }
}

class _PermissionRoleCard extends HookWidget {
  final String roleName;
  final String roleDescription;
  final IconData icon;
  final Color iconColor;
  final Map<String, bool> initialPermissions;
  final bool isLocked;

  const _PermissionRoleCard({
    required this.roleName,
    required this.roleDescription,
    required this.icon,
    required this.iconColor,
    required this.initialPermissions,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final permissionsState = useState(initialPermissions);
    final appColors = Theme.of(context).extension<AppColors>()!;

    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.1),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(roleName,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(roleDescription,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              if (isLocked) ...[
                const SizedBox(width: 16),
                Icon(Iconsax.lock, color: appColors.textSecondary, size: 20),
              ]
            ],
          ),
          const Divider(height: 40),
          ...permissionsState.value.entries.map((entry) {
            return _PermissionToggle(
              label: entry.key,
              value: entry.value,
              onChanged: isLocked
                  ? null
                  : (newValue) {
                final newPermissions =
                Map<String, bool>.from(permissionsState.value);
                newPermissions[entry.key] = newValue;
                permissionsState.value = newPermissions;
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _PermissionToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _PermissionToggle({
    required this.label,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: onChanged == null
                    ? appColors.textSecondary
                    : appColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
            inactiveThumbColor: appColors.border,
          ),
        ],
      ),
    );
  }
}