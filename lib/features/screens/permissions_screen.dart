import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/shared_widgets/modern_card.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/modern_button.dart';
import 'package:iconsax/iconsax.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Role Permissions',
            description: 'Configure access levels for different user roles.',
            action: PrimaryButton(
              text: 'Save Changes',
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Iconsax.tick_circle,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Permissions saved successfully!',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF11998e),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              icon: Iconsax.save_2,
            ),
          ),
          const SizedBox(height: 24),
          _PermissionRoleCard(
            roleName: 'Super Admin',
            roleDescription:
                'Has unrestricted access to all features, including system settings and user management.',
            icon: Iconsax.crown_1,
            gradientColors: const [Color(0xFFF5A623), Color(0xFFf76b1c)],
            initialPermissions: const {
              'Create, Read, Update, Delete Churches': true,
              'Manage All Pastors & Users': true,
              'View Financial Reports': true,
              'Configure System Settings': true,
              'Send Global Communications': true,
            },
            isLocked: true,
            index: 0,
          ),
          const SizedBox(height: 20),
          _PermissionRoleCard(
            roleName: 'Pastor',
            roleDescription:
                'Manages members, events, and departments within their assigned church.',
            icon: Iconsax.user_octagon,
            gradientColors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.7),
            ],
            initialPermissions: const {
              'Add & Manage Church Members': true,
              'Create & Manage Departments': true,
              'View Own Church Reports': true,
              'Send Church-level Communications': true,
              'Manage Servants & Volunteers': false,
            },
            index: 1,
          ),
          const SizedBox(height: 20),
          _PermissionRoleCard(
            roleName: 'Servant',
            roleDescription:
                'Assists with managing members and activities within their assigned department.',
            icon: Iconsax.lifebuoy,
            gradientColors: [
              theme.colorScheme.secondary,
              theme.colorScheme.secondary.withOpacity(0.7),
            ],
            initialPermissions: const {
              'View Members in Own Department': true,
              'Mark Member Attendance': true,
              'View Departmental Reports': false,
              'Edit Member Profiles': false,
            },
            index: 2,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PermissionRoleCard extends HookWidget {
  final String roleName;
  final String roleDescription;
  final IconData icon;
  final List<Color> gradientColors;
  final Map<String, bool> initialPermissions;
  final bool isLocked;
  final int index;

  const _PermissionRoleCard({
    required this.roleName,
    required this.roleDescription,
    required this.icon,
    required this.gradientColors,
    required this.initialPermissions,
    this.isLocked = false,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final permissionsState = useState(initialPermissions);
    final appColors = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    final isExpanded = useState(true);

    return Builder(
          builder: (context) => ModernCard(
            variant: isLocked ? CardVariant.neon : CardVariant.glass,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and role info
                InkWell(
                  onTap: () => isExpanded.value = !isExpanded.value,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // Gradient icon container
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradientColors,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: gradientColors[0].withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(icon, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    roleName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (isLocked) ...[
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: gradientColors,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Iconsax.lock,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Protected',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                roleDescription,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: appColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: isExpanded.value ? 0.5 : 0,
                          child: Icon(
                            Iconsax.arrow_down_1,
                            color: appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Permissions list with animation
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: isExpanded.value
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: [
                      const SizedBox(height: 16),
                      Divider(color: appColors.border.withOpacity(0.3)),
                      const SizedBox(height: 8),
                      ...permissionsState.value.entries.map((entry) {
                        return _PermissionToggle(
                          label: entry.key,
                          value: entry.value,
                          gradientColors: gradientColors,
                          onChanged: isLocked
                              ? null
                              : (newValue) {
                                  final newPermissions = Map<String, bool>.from(
                                    permissionsState.value,
                                  );
                                  newPermissions[entry.key] = newValue;
                                  permissionsState.value = newPermissions;
                                },
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: (index * 150).ms)
        .slideX(begin: 0.1, curve: Curves.easeOut);
  }
}

class _PermissionToggle extends StatefulWidget {
  final String label;
  final bool value;
  final List<Color> gradientColors;
  final ValueChanged<bool>? onChanged;

  const _PermissionToggle({
    required this.label,
    required this.value,
    required this.gradientColors,
    this.onChanged,
  });

  @override
  State<_PermissionToggle> createState() => _PermissionToggleState();
}

class _PermissionToggleState extends State<_PermissionToggle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _isHovered
              ? widget.gradientColors[0].withOpacity(0.05)
              : Colors.transparent,
          border: _isHovered
              ? Border.all(color: widget.gradientColors[0].withOpacity(0.2))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.value
                          ? widget.gradientColors[0]
                          : appColors.textSecondary.withOpacity(0.3),
                      boxShadow: widget.value
                          ? [
                              BoxShadow(
                                color: widget.gradientColors[0].withOpacity(
                                  0.5,
                                ),
                                blurRadius: 6,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: widget.onChanged == null
                            ? appColors.textSecondary
                            : _isHovered
                            ? widget.gradientColors[0]
                            : appColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.85,
              child: Switch(
                value: widget.value,
                onChanged: widget.onChanged,
                activeColor: widget.gradientColors[0],
                activeTrackColor: widget.gradientColors[0].withOpacity(0.3),
                inactiveThumbColor: appColors.border,
                inactiveTrackColor: appColors.border.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
