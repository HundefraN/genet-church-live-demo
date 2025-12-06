import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/shared_widgets/advanced_filter_bar.dart';
import 'package:genet_church_portal/shared_widgets/card_shimmer_loader.dart';
import 'package:genet_church_portal/shared_widgets/modern_button.dart';
import 'package:genet_church_portal/shared_widgets/modern_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_data_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_dropdown.dart';
import 'package:genet_church_portal/shared_widgets/modern_input.dart';
import 'package:genet_church_portal/shared_widgets/modern_report_list.dart';
import 'package:genet_church_portal/shared_widgets/notification_system.dart';
import 'package:genet_church_portal/state/new_item_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/models/pastor_model.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/api_error_widget.dart';
import 'package:iconsax/iconsax.dart';

class ReportPastorsScreen extends HookConsumerWidget {
  const ReportPastorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final pastorsAsync = ref.watch(pastorsProvider);
    final churchesAsync = ref.watch(churchesProvider);
    final newlyAddedItemId = ref.watch(newlyAddedItemIdProvider);

    // Filter states
    final searchQuery = useState('');
    final selectedChurchFilter = useState<String?>(null);
    final isDeleting = useState<String?>(null);

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

    // Build church filter dropdown options
    final churches = churchesAsync.valueOrNull ?? [];
    final churchMap = {for (var c in churches) c.id: c.name};

    final filterDropdowns = <FilterDropdownConfig>[
      FilterDropdownConfig(
        label: 'Church',
        icon: Iconsax.building,
        options: churches
            .map((c) => FilterOption(label: c.name, value: c.id))
            .toList(),
        selectedValue: selectedChurchFilter.value,
        onChanged: (val) => selectedChurchFilter.value = val,
      ),
    ];

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
                        'Pastor Records',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage and oversee all pastoral staff across your ministry',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                PrimaryButton(
                  onPressed: () => _showAddPastorDialog(context, ref),
                  text: 'Add New Pastor',
                  icon: Iconsax.add,
                ),
              ],
            ),
          ),
          // Filter Bar
          AdvancedFilterBar(
            searchHint: 'Search by name or email...',
            searchValue: searchQuery.value,
            onSearchChanged: (val) => searchQuery.value = val,
            filterDropdowns: filterDropdowns,
            onClearAll: () {
              searchQuery.value = '';
              selectedChurchFilter.value = null;
            },
          ),
          const SizedBox(height: 24),
          // Content
          churchesAsync.when(
            data: (_) => pastorsAsync.when(
              data: (pastors) {
                // Apply filters
                final filteredPastors = pastors.where((pastor) {
                  // Search filter
                  if (searchQuery.value.isNotEmpty) {
                    final query = searchQuery.value.toLowerCase();
                    final fullName = pastor.user?.fullName ?? '';
                    final email = pastor.user?.email ?? '';
                    if (!fullName.toLowerCase().contains(query) &&
                        !email.toLowerCase().contains(query)) {
                      return false;
                    }
                  }
                  // Church filter
                  if (selectedChurchFilter.value != null) {
                    if (pastor.churchId != selectedChurchFilter.value) {
                      return false;
                    }
                  }
                  return true;
                }).toList();

                if (filteredPastors.isEmpty) {
                  return _EmptyState(
                    hasFilters:
                        searchQuery.value.isNotEmpty ||
                        selectedChurchFilter.value != null,
                    onAddPressed: () => _showAddPastorDialog(context, ref),
                  );
                }

                return ModernDataGrid.responsive(
                  context: context,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: filteredPastors.asMap().entries.map((entry) {
                    final index = entry.key;
                    final pastor = entry.value;
                    final isNew = pastor.id == newlyAddedItemId;
                    final churchName =
                        churchMap[pastor.churchId] ?? 'Unassigned';

                    return ModernDataCard(
                      index: index,
                      isNew: isNew,
                      leading: DataCardAvatar(
                        initials: getInitials(pastor.user?.fullName),
                        backgroundColor: theme.colorScheme.secondary,
                      ),
                      title: pastor.user?.fullName ?? 'Unknown',
                      subtitle: pastor.user?.email ?? '',
                      chips: [
                        DataChip(
                          label: churchName,
                          icon: Iconsax.building,
                          color: pastor.churchId != null
                              ? theme.colorScheme.primary
                              : appColors.textSecondary,
                        ),
                      ],
                      actions: [
                        DataAction(
                          label: 'ASSIGN',
                          icon: Iconsax.building,
                          color: theme.colorScheme.secondary,
                          onPressed: () =>
                              _showAssignChurchDialog(context, ref, pastor),
                        ),
                        DataAction(
                          label: 'EDIT',
                          icon: Iconsax.edit,
                          color: theme.colorScheme.primary,
                          onPressed: () =>
                              _showEditPastorDialog(context, ref, pastor),
                        ),
                        DataAction(
                          label: 'DELETE',
                          icon: Iconsax.trash,
                          isDestructive: true,
                          isLoading: isDeleting.value == pastor.id,
                          onPressed: () => _showDeleteConfirmationDialog(
                            context,
                            ref,
                            pastor,
                            isDeleting,
                          ),
                        ),
                      ],
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
    Pastor pastor,
    ValueNotifier<String?> isDeleting,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete pastor ${pastor.user?.fullName ?? ''}? This action cannot be undone.',
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
                isDeleting.value = pastor.id;
                Navigator.of(dialogContext).pop();
                try {
                  await ref
                      .read(pastorsProvider.notifier)
                      .removePastor(pastor.id);
                  if (context.mounted) {
                    context.showSuccessNotification(
                      title: 'Success',
                      message:
                          '${pastor.user?.fullName ?? ''} has been deleted.',
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    String message = 'Failed to delete pastor.';
                    if (e is DioException && e.response?.statusCode == 500) {
                      message =
                          'Server Error: Unable to delete pastor. This may be due to existing records linked to this account.';
                    }
                    context.showErrorNotification(
                      title: 'Error',
                      message: message,
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

  void _showAddPastorDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return HookConsumer(
          builder: (context, ref, child) {
            final selectedChurchId = useState<String?>(null);
            final churchesAsync = ref.watch(churchesProvider);

            return AlertDialog(
              title: const Text('Add New Pastor'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ModernInput(
                        controller: nameController,
                        label: 'Full Name',
                        prefixIcon: Iconsax.user,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      EmailInput(
                        controller: emailController,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      PasswordInput(
                        controller: passwordController,
                        label: 'Temporary Password',
                        validator: (v) =>
                            v!.length < 6 ? 'Min 6 characters' : null,
                      ),
                      const SizedBox(height: 20),
                      churchesAsync.when(
                        data: (churches) => ModernDropdown<String?>(
                          hintText: 'Assign to Church (Optional)',
                          icon: Iconsax.building,
                          value: selectedChurchId.value,
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('None (Unassigned)'),
                            ),
                            ...churches.map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ),
                            ),
                          ],
                          onChanged: (val) => selectedChurchId.value = val,
                        ),
                        loading: () =>
                            const InlineShimmerLoader(width: 200, height: 48),
                        error: (e, s) => const Text('Could not load churches'),
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
                  text: 'Add Pastor',
                  onPressedAsync: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        final newPastor = await ref
                            .read(pastorsProvider.notifier)
                            .addPastor(
                              fullName: nameController.text,
                              email: emailController.text,
                              password: passwordController.text,
                            );

                        if (selectedChurchId.value != null) {
                          await ref
                              .read(pastorsProvider.notifier)
                              .assignChurchToPastor(
                                pastorId: newPastor.id,
                                churchId: selectedChurchId.value!,
                              );
                        }

                        ref
                            .read(newlyAddedItemIdProvider.notifier)
                            .set(newPastor.id);

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          context.showSuccessNotification(
                            title: "Pastor Added",
                            message:
                                "${nameController.text} has been successfully added.",
                          );
                        }
                      } catch (e) {
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          context.showErrorNotification(
                            title: "Failed to Add",
                            message:
                                "An error occurred while adding the pastor.",
                          );
                        }
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

  void _showEditPastorDialog(
    BuildContext context,
    WidgetRef ref,
    Pastor pastor,
  ) {
    final nameController = TextEditingController(
      text: pastor.user?.fullName ?? '',
    );
    final emailController = TextEditingController(
      text: pastor.user?.email ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Pastor'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ModernInput(
                  controller: nameController,
                  label: 'Full Name',
                  prefixIcon: Iconsax.user,
                  validator: (val) =>
                      val!.isEmpty ? 'Name cannot be empty' : null,
                ),
                const SizedBox(height: 20),
                EmailInput(
                  controller: emailController,
                  validator: (val) =>
                      val!.isEmpty ? 'Email cannot be empty' : null,
                ),
              ],
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
                if (formKey.currentState!.validate()) {
                  try {
                    await ref
                        .read(pastorsProvider.notifier)
                        .updatePastor(
                          pastorId: pastor.id,
                          fullName: nameController.text,
                          email: emailController.text,
                        );
                    if (dialogContext.mounted) {
                      context.showSuccessNotification(
                        title: 'Success',
                        message: 'Pastor details have been updated.',
                      );
                      Navigator.pop(dialogContext);
                    }
                  } catch (e) {
                    if (dialogContext.mounted) {
                      context.showErrorNotification(
                        title: 'Error',
                        message: 'Failed to update details.',
                      );
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAssignChurchDialog(
    BuildContext context,
    WidgetRef ref,
    Pastor pastor,
  ) {
    final churchesAsync = ref.watch(churchesProvider);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return HookConsumer(
          builder: (context, ref, child) {
            final validChurchIds =
                churchesAsync.valueOrNull?.map((c) => c.id).toSet() ?? {};
            final initialChurchId =
                pastor.churchId != null &&
                    validChurchIds.contains(pastor.churchId)
                ? pastor.churchId
                : null;

            final selectedChurchId = useState(initialChurchId);
            final isUnassigning = useState(false);

            return AlertDialog(
              title: Text('Assign Church to ${pastor.user?.fullName ?? ''}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  churchesAsync.when(
                    data: (churches) => ModernDropdown<String?>(
                      hintText: 'Select a Church',
                      icon: Iconsax.building,
                      value: selectedChurchId.value,
                      items: [
                        ...churches.map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        selectedChurchId.value = val;
                      },
                    ),
                    loading: () =>
                        const InlineShimmerLoader(width: 200, height: 48),
                    error: (e, s) => const Text('Could not load churches.'),
                  ),
                  if (initialChurchId != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.errorContainer.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.5),
                        ),
                      ),
                      child: TextButton(
                        onPressed: isUnassigning.value
                            ? null
                            : () async {
                                isUnassigning.value = true;
                                try {
                                  await ref
                                      .read(pastorsProvider.notifier)
                                      .unassignChurch(pastorId: pastor.id);

                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                    context.showSuccessNotification(
                                      title: "Unassigned Successfully",
                                      message:
                                          "Pastor has been removed from the church.",
                                    );
                                  }
                                } catch (e) {
                                  if (dialogContext.mounted) {
                                    context.showErrorNotification(
                                      title: "Failed to Unassign",
                                      message:
                                          "Could not remove church assignment.",
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    isUnassigning.value = false;
                                  }
                                }
                              },
                        child: isUnassigning.value
                            ? const InlineShimmerLoader(width: 100, height: 20)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.minus_square,
                                    color: Theme.of(context).colorScheme.error,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Unassign Church",
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                PrimaryButton(
                  text: 'Assign Church',
                  onPressedAsync: () async {
                    if (selectedChurchId.value == null) return;
                    try {
                      await ref
                          .read(pastorsProvider.notifier)
                          .assignChurchToPastor(
                            pastorId: pastor.id,
                            churchId: selectedChurchId.value,
                          );
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                        context.showSuccessNotification(
                          title: "Success",
                          message: "Church assigned.",
                        );
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                        context.showErrorNotification(
                          title: "Error",
                          message: e.toString(),
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

  const _EmptyState({required this.hasFilters, required this.onAddPressed});

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
                    theme.colorScheme.secondary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Iconsax.search_zoom_out : Iconsax.user_octagon,
                size: 48,
                color: theme.colorScheme.secondary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters ? 'No Pastors Match Your Filters' : 'No Pastors Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: appColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilters
                  ? 'Try adjusting your search or filter criteria.'
                  : 'Add your first pastor to get started.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: appColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (!hasFilters) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: onAddPressed,
                text: 'Add First Pastor',
                icon: Iconsax.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
