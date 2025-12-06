import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/data/models/user_model.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:genet_church_portal/shared_widgets/advanced_filter_bar.dart';
import 'package:genet_church_portal/shared_widgets/card_shimmer_loader.dart';
import 'package:genet_church_portal/shared_widgets/modern_button.dart';
import 'package:genet_church_portal/shared_widgets/modern_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_data_card.dart';
import 'package:genet_church_portal/state/new_item_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/data/services/url_launcher_service.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/api_error_widget.dart';
import 'package:genet_church_portal/shared_widgets/modern_input.dart';
import 'package:genet_church_portal/shared_widgets/notification_system.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';

class ReportChurchsScreen extends HookConsumerWidget {
  const ReportChurchsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final churchesAsync = ref.watch(churchesProvider);
    final newlyAddedItemId = ref.watch(newlyAddedItemIdProvider);
    final userRole = ref.watch(authStateProvider)?.roleEnum;
    final searchQuery = useState('');
    final isDeleting = useState<String?>(null);
    final urlLauncher = UrlLauncherService();

    useEffect(() {
      if (newlyAddedItemId != null) {
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            ref.read(newlyAddedItemIdProvider.notifier).set(null);
          }
        });
      }
      return null;
    }, [newlyAddedItemId]);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            margin: const EdgeInsets.only(bottom: 32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Church Records',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage all church branches within the ministry network',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (userRole == UserRole.SUPER_ADMIN) ...[
                  const SizedBox(width: 24),
                  PrimaryButton(
                    onPressed: () => _showAddChurchDialog(context, ref),
                    text: 'Add New Church',
                    icon: Iconsax.add,
                  ),
                ],
              ],
            ),
          ),
          // Filter Bar
          AdvancedFilterBar(
            searchHint: 'Search by church name...',
            searchValue: searchQuery.value,
            onSearchChanged: (val) => searchQuery.value = val,
            onClearAll: () => searchQuery.value = '',
          ),
          const SizedBox(height: 24),
          // Content
          churchesAsync.when(
            data: (churches) {
              final filteredChurches = churches.where((church) {
                if (searchQuery.value.isEmpty) return true;
                return church.name.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                );
              }).toList();

              if (filteredChurches.isEmpty) {
                return _EmptyState(
                  hasFilters: searchQuery.value.isNotEmpty,
                  onAddPressed: () => _showAddChurchDialog(context, ref),
                  userCanAdd: userRole == UserRole.SUPER_ADMIN,
                );
              }

              return ModernDataGrid.responsive(
                context: context,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: filteredChurches.asMap().entries.map((entry) {
                  final index = entry.key;
                  final church = entry.value;
                  final isNew = church.id == newlyAddedItemId;
                  final hasLocation =
                      church.locationLink != null &&
                      Uri.tryParse(church.locationLink!)?.isAbsolute == true;

                  return ModernDataCard(
                    index: index,
                    isNew: isNew,
                    leading: DataCardAvatar(
                      icon: Iconsax.building,
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    title: church.name,
                    subtitle: church.establishmentDate != null
                        ? 'Est. ${church.establishmentDate}'
                        : null,
                    description: church.headOfficeId != null
                        ? 'Head Office ID: ${church.headOfficeId}'
                        : null,
                    chips: [
                      if (hasLocation)
                        DataChip(
                          label: 'View on Map',
                          icon: Iconsax.location,
                          color: theme.colorScheme.secondary,
                        ),
                    ],
                    onTap: hasLocation
                        ? () => urlLauncher.openInNewTab(church.locationLink!)
                        : null,
                    actions: userRole == UserRole.SUPER_ADMIN
                        ? [
                            DataAction(
                              label: 'EDIT',
                              icon: Iconsax.edit,
                              color: theme.colorScheme.primary,
                              onPressed: () =>
                                  _showEditChurchDialog(context, ref, church),
                            ),
                            DataAction(
                              label: 'DELETE',
                              icon: Iconsax.trash,
                              isDestructive: true,
                              isLoading: isDeleting.value == church.id,
                              onPressed: () => _showDeleteConfirmationDialog(
                                context,
                                ref,
                                church,
                                isDeleting,
                              ),
                            ),
                          ]
                        : null,
                  );
                }).toList(),
              );
            },
            loading: () => CardGridShimmerLoader.responsive(context: context),
            error: (err, stack) => ModernCard(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: ApiErrorWidget(error: err),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    Church church,
    ValueNotifier<String?> isDeleting,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete the church "${church.name}"? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
              onPressed: () async {
                isDeleting.value = church.id;
                Navigator.of(dialogContext).pop();
                try {
                  await ref
                      .read(churchesProvider.notifier)
                      .removeChurch(church.id);
                  if (context.mounted) {
                    context.showSuccessNotification(
                      title: 'Church Deleted',
                      message:
                          '"${church.name}" has been successfully removed from the database.',
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showErrorNotification(
                      title: 'Delete Failed',
                      message: 'Failed to delete church. Please try again.',
                    );
                  }
                } finally {
                  if (context.mounted) {
                    isDeleting.value = null;
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddChurchDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final establishmentDateController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Church'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ModernInput(
                        controller: nameController,
                        label: 'Church Name',
                        prefixIcon: Iconsax.building,
                      ),
                      const SizedBox(height: 20),
                      ModernInput(
                        controller: locationController,
                        label: 'Google Maps Link (Optional)',
                        prefixIcon: Iconsax.map_1,
                      ),
                      const SizedBox(height: 20),
                      ModernInput(
                        controller: establishmentDateController,
                        label: 'Establishment Date (YYYY-MM-DD)',
                        prefixIcon: Iconsax.calendar_1,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                PrimaryButton(
                  text: 'Add Church',
                  onPressedAsync: () async {
                    if (nameController.text.trim().isEmpty) {
                      context.showWarningNotification(
                        title: 'Validation Error',
                        message: 'Church name is required.',
                      );
                      return;
                    }
                    try {
                      final newChurchData = Church(
                        id: '',
                        name: nameController.text.trim(),
                        locationLink: locationController.text.trim().isEmpty
                            ? null
                            : locationController.text.trim(),
                        establishmentDate:
                            establishmentDateController.text.trim().isEmpty
                            ? null
                            : establishmentDateController.text.trim(),
                        headOfficeId: AppConstants.addisAbabaHeadOfficeId,
                      );
                      final newChurch = await ref
                          .read(churchesProvider.notifier)
                          .addChurch(newChurchData);
                      ref
                          .read(newlyAddedItemIdProvider.notifier)
                          .set(newChurch.id);
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                        context.showSuccessNotification(
                          title: 'Church Added!',
                          message:
                              '"${nameController.text.trim()}" has been successfully added to the database.',
                        );
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        context.showErrorNotification(
                          title: 'Add Failed',
                          message: 'Error: ${e.toString()}',
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditChurchDialog(
    BuildContext context,
    WidgetRef ref,
    Church church,
  ) {
    final nameController = TextEditingController(text: church.name);
    final locationController = TextEditingController(text: church.locationLink);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Church'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ModernInput(
                        controller: nameController,
                        label: 'Church Name',
                        prefixIcon: Iconsax.building,
                      ),
                      const SizedBox(height: 20),
                      ModernInput(
                        controller: locationController,
                        label: 'Location Link (Optional)',
                        prefixIcon: Iconsax.map_1,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                PrimaryButton(
                  text: 'Save Changes',
                  onPressedAsync: () async {
                    if (nameController.text.trim().isEmpty) {
                      context.showWarningNotification(
                        title: 'Validation Error',
                        message: 'Church name is required.',
                      );
                      return;
                    }
                    try {
                      final updatedChurch = Church(
                        id: church.id,
                        name: nameController.text.trim(),
                        locationLink: locationController.text.trim().isEmpty
                            ? null
                            : locationController.text.trim(),
                        establishmentDate: church.establishmentDate,
                        headOfficeId: church.headOfficeId,
                        dateCreated: church.dateCreated,
                      );
                      await ref
                          .read(churchesProvider.notifier)
                          .updateChurch(
                            churchId: church.id,
                            church: updatedChurch,
                          );
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                        context.showSuccessNotification(
                          title: 'Church Updated!',
                          message:
                              'Changes to "${nameController.text.trim()}" have been saved successfully.',
                        );
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        context.showErrorNotification(
                          title: 'Update Failed',
                          message: 'Error: ${e.toString()}',
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onAddPressed;
  final bool userCanAdd;

  const _EmptyState({
    required this.hasFilters,
    required this.onAddPressed,
    required this.userCanAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;

    return ModernCard(
      child: Container(
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.primary.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Iconsax.search_zoom_out : Iconsax.building,
                size: 48,
                color: theme.colorScheme.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters
                  ? 'No Churches Match Your Search'
                  : 'No Churches Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: appColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilters
                  ? 'Try adjusting your search terms.'
                  : 'Add your first church to get started.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: appColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (!hasFilters && userCanAdd) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: onAddPressed,
                text: 'Add First Church',
                icon: Iconsax.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
