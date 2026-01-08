import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gdev_frontend/core/theme/app_colors.dart';
import 'package:gdev_frontend/core/theme/visual_effects.dart';
import 'package:gdev_frontend/data/models/user_model.dart';
import 'package:gdev_frontend/data/repositories/auth_repository.dart';
import 'package:gdev_frontend/shared_widgets/modern_button.dart';
import 'package:gdev_frontend/shared_widgets/modern_card.dart';
import 'package:gdev_frontend/shared_widgets/modern_input.dart';
import 'package:gdev_frontend/shared_widgets/notification_system.dart';
import 'package:gdev_frontend/state/church_selection_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:ui';

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
    
    // We can potentially fetch church name if needed, but for now we'll just show the role
    // or use the churchId from currentChurchProvider

    void showEditProfileDialog() {
      context.showInfoNotification(
        title: 'Coming Soon',
        message: 'Edit profile feature is being developed.',
      );
    }

    void showChangePasswordDialog() {
      final currentPasswordController = TextEditingController();
      final newPasswordController = TextEditingController();
      final confirmPasswordController = TextEditingController();
      final formKey = GlobalKey<FormState>();

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          final dialogSize = MediaQuery.of(dialogContext).size;
          final isMobile = dialogSize.width < 600;

          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : dialogSize.width * 0.2,
              vertical: 24,
            ),
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: ModernCard(
                    variant: CardVariant.glass,
                    padding: EdgeInsets.zero,
                    backgroundColor: appColors.surface.withValues(alpha: 0.9),
                    borderRadius: 24,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header with gradient
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: 0.15),
                                theme.colorScheme.secondary.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Iconsax.key,
                                  color: theme.colorScheme.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Change Password',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: appColors.textPrimary,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Text(
                                      'Update your account security',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                icon: Icon(
                                  Iconsax.close_circle,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                PasswordInput(
                                  controller: currentPasswordController,
                                  label: 'Current Password',
                                  hintText: 'Enter your current password',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Current password is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                PasswordInput(
                                  controller: newPasswordController,
                                  label: 'New Password',
                                  hintText: 'Enter at least 6 characters',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'New password is required';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                PasswordInput(
                                  controller: confirmPasswordController,
                                  label: 'Confirm New Password',
                                  hintText: 'Repeat your new password',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your new password';
                                    }
                                    if (value != newPasswordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GhostButton(
                                        text: 'Cancel',
                                        onPressed: () => Navigator.pop(dialogContext),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ModernButton(
                                        text: 'Update',
                                        variant: ButtonVariant.primary,
                                        onPressedAsync: () async {
                                          if (formKey.currentState?.validate() ?? false) {
                                            try {
                                              final authRepo = ref.read(authRepositoryProvider);
                                              await authRepo.changePassword(
                                                currentPasswordController.text,
                                                newPasswordController.text,
                                              );
                                              if (dialogContext.mounted) {
                                                Navigator.pop(dialogContext);
                                              }
                                              if (context.mounted) {
                                                context.showSuccessNotification(
                                                  title: 'Success!',
                                                  message: 'Your password has been updated.',
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                String errorMessage =
                                                    'Failed to change password. Please try again.';
                                                if (e is DioException) {
                                                  if (e.response?.statusCode == 404) {
                                                    errorMessage = 'Endpoint not found. Please contact support.';
                                                  } else {
                                                    final errorData = e.response?.data;
                                                    if (errorData is Map &&
                                                        errorData['message'] != null) {
                                                      errorMessage = errorData['message'];
                                                    } else if (errorData is String) {
                                                      errorMessage = errorData;
                                                    }
                                                  }
                                                }
                                                context.showErrorNotification(
                                                  title: 'Error',
                                                  message: errorMessage,
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: isSmallScreen ? 20 : 40),
              // Ultra-modern avatar with glow effect
              Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: VisualEffects.createGlow(
                        color: theme.colorScheme.primary,
                        intensity: 0.4,
                        blur: 32,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.7),
                            theme.colorScheme.secondary,
                          ],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: isSmallScreen ? 40 : 60,
                        backgroundColor: appColors.surface,
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            userInitial,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 32 : 48,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 28),
              // Name with gradient effect
              ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        appColors.textPrimary,
                        theme.colorScheme.primary,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      user.fullName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        fontSize: isSmallScreen ? 24 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOut),
              const SizedBox(height: 12),
              // Holographic role badge
              Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                          theme.colorScheme.secondary.withValues(alpha: 0.2),
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.crown_15,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user.role.replaceAll('_', ' ').toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOut),
              const SizedBox(height: 40),
              // Glass card for profile info
              Builder(
                    builder: (context) => ModernCard(
                      variant: CardVariant.glass,
                      child: Column(
                        children: [
                          _ProfileInfoRow(
                            icon: Iconsax.direct_right,
                            label: 'Email',
                            value: user.email,
                            gradientColors: const [
                              Color(0xFF667eea),
                              Color(0xFF764ba2),
                            ],
                          ),
                          Divider(
                            color: appColors.border.withValues(alpha: 0.3),
                          ),
                          _ProfileInfoRow(
                            icon: Iconsax.key,
                            label: 'Password',
                            value: '••••••••',
                            gradientColors: const [
                              Color(0xFFf093fb),
                              Color(0xFFf5576c),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: 0.15, curve: Curves.easeOut),
              const SizedBox(height: 32),
              Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: OutlineButton(
                          text: 'Change Password',
                          onPressed: showChangePasswordDialog,
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
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms)
                  .slideY(begin: 0.1, curve: Curves.easeOut),
              SizedBox(height: isSmallScreen ? 20 : 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradientColors;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradientColors,
  });

  @override
  State<_ProfileInfoRow> createState() => _ProfileInfoRowState();
}

class _ProfileInfoRowState extends State<_ProfileInfoRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: _isHovered
              ? theme.colorScheme.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradientColors,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradientColors.first.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(widget.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: appColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: appColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
