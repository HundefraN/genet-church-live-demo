import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/shared_widgets/modern_button.dart';
import 'package:genet_church_portal/shared_widgets/modern_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_input.dart';
import 'package:genet_church_portal/shared_widgets/notification_system.dart';
import 'package:genet_church_portal/state/new_item_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/models/pastor_model.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/api_error_widget.dart';
import 'package:genet_church_portal/shared_widgets/modern_dropdown.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';
import 'package:iconsax/iconsax.dart';
import '../../shared_widgets/table_shimmer_loader.dart';

class ReportPastorsScreen extends HookConsumerWidget {
  const ReportPastorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final pastorsAsync = ref.watch(pastorsProvider);
    final churchesAsync = ref.watch(churchesProvider);
    final newlyAddedItemId = ref.watch(newlyAddedItemIdProvider);
    final searchQuery = useState('');
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          ModernCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  child: ModernInput(
                    label: 'Search by name or email...',
                    prefixIcon: Iconsax.search_normal_1,
                    onChanged: (value) => searchQuery.value = value,
                  ),
                ),
                Container(height: 1, color: appColors.border),
                churchesAsync.when(
                  data: (churches) {
                    final churchMap = {for (var c in churches) c.id: c.name};
                    return pastorsAsync.when(
                      data: (pastors) {
                        final filteredPastors = pastors.where((pastor) {
                          if (searchQuery.value.isEmpty) return true;
                          final query = searchQuery.value.toLowerCase();
                          final fullName = pastor.user?.fullName ?? '';
                          final email = pastor.user?.email ?? '';
                          return fullName.toLowerCase().contains(query) ||
                              email.toLowerCase().contains(query);
                        }).toList();

                        if (filteredPastors.isEmpty) {
                          return _EmptyState(
                            searchQuery: searchQuery.value,
                            onAddPressed: () =>
                                _showAddPastorDialog(context, ref),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: StyledDataTable(
                            columns: const [
                              '#',
                              'Full Name',
                              'Email',
                              'Assigned Church',
                              'Actions',
                            ],
                            rows: filteredPastors.asMap().entries.map((entry) {
                              final index = entry.key;
                              final pastor = entry.value;
                              final isNew = pastor.id == newlyAddedItemId;
                              final rowWidget = DataRow(
                                cells: [
                                  DataCell(Text((index + 1).toString())),
                                  DataCell(Text(pastor.user?.fullName ?? '')),
                                  DataCell(Text(pastor.user?.email ?? '')),
                                  DataCell(
                                    pastor.churchId == null
                                        ? Text(
                                      'N/A',
                                      style: TextStyle(
                                        color: appColors.textSecondary,
                                      ),
                                    )
                                        : Chip(
                                      avatar: Icon(
                                        Iconsax.building,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                      label: Text(
                                        churchMap[pastor.churchId] ??
                                            'Unknown Church',
                                        style: TextStyle(
                                          color:
                                          theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      backgroundColor: theme
                                          .colorScheme.primary
                                          .withOpacity(0.1),
                                      side: BorderSide.none,
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        ModernButton(
                                          text: 'ASSIGN',
                                          variant: ButtonVariant.outline,
                                          size: ButtonSize.small,
                                          customColor:
                                          theme.colorScheme.secondary,
                                          icon: Iconsax.building,
                                          onPressed: () =>
                                              _showAssignChurchDialog(
                                                context,
                                                ref,
                                                pastor,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        ModernButton(
                                          text: 'EDIT',
                                          variant: ButtonVariant.outline,
                                          size: ButtonSize.small,
                                          customColor:
                                          theme.colorScheme.primary,
                                          icon: Iconsax.edit,
                                          onPressed: () =>
                                              _showEditPastorDialog(
                                                context,
                                                ref,
                                                pastor,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        DestructiveButton(
                                          text: 'DELETE',
                                          size: ButtonSize.small,
                                          icon: Iconsax.trash,
                                          isLoading:
                                          isDeleting.value == pastor.id,
                                          onPressed: () =>
                                              _showDeleteConfirmationDialog(
                                                context,
                                                ref,
                                                pastor,
                                                isDeleting,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );

                              if (isNew) {
                                return DataRow(
                                  cells: rowWidget.cells
                                      .map(
                                        (cell) => DataCell(
                                      Animate(
                                        effects: const [
                                          FadeEffect(
                                            duration: Duration(
                                              milliseconds: 600,
                                            ),
                                          ),
                                          SlideEffect(
                                            begin: Offset(0, 0.2),
                                            duration: Duration(
                                              milliseconds: 600,
                                            ),
                                            curve: Curves.easeOutCubic,
                                          ),
                                        ],
                                        child: cell.child,
                                      ),
                                      showEditIcon: cell.showEditIcon,
                                      placeholder: cell.placeholder,
                                      onTap: cell.onTap,
                                    ),
                                  )
                                      .toList(),
                                );
                              }
                              return rowWidget;
                            }).toList(),
                          ),
                        );
                      },
                      loading: () => const TableShimmerLoader(columnCount: 5),
                      error: (err, stack) => Padding(
                        padding: const EdgeInsets.all(64.0),
                        child: ApiErrorWidget(error: err),
                      ),
                    );
                  },
                  loading: () => const TableShimmerLoader(columnCount: 5),
                  error: (err, stack) => Padding(
                    padding: const EdgeInsets.all(64.0),
                    child: ApiErrorWidget(error: err),
                  ),
                ),
              ],
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
                        loading: () => const SizedBox(
                          height: 48,
                          child: Center(child: CircularProgressIndicator()),
                        ),
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
                    await ref.read(pastorsProvider.notifier).updatePastor(
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
            pastor.churchId != null && validChurchIds.contains(pastor.churchId)
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
                              value: c.id, child: Text(c.name)),
                        ),
                      ],
                      onChanged: (val) {
                        selectedChurchId.value = val;
                      },
                    ),
                    loading: () =>
                    const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Text('Could not load churches.'),
                  ),
                  if (initialChurchId != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .errorContainer
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withOpacity(0.5))),
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
                            if (context.mounted) isUnassigning.value = false;
                          }
                        },
                        child: isUnassigning.value
                            ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                Theme.of(context).colorScheme.error))
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.minus_square,
                                color:
                                Theme.of(context).colorScheme.error,
                                size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "Unassign Church",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
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
                              title: "Success", message: "Church assigned.");
                        }
                      } catch (e) {
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          context.showErrorNotification(
                              title: "Error", message: e.toString());
                        }
                      }
                    }),
              ],
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onAddPressed;

  const _EmptyState({required this.searchQuery, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery.isEmpty
                ? Iconsax.user_octagon
                : Iconsax.search_zoom_out,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isEmpty
                ? 'No Pastors Found'
                : 'No Pastors Match Your Search',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Add your first pastor to get started.'
                : 'Try adjusting your search terms.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: onAddPressed,
              text: 'Add First Pastor',
              icon: Iconsax.add,
            ),
          ],
        ],
      ),
    );
  }
}