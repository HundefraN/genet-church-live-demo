import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/shared_widgets/modern_button.dart';
import 'package:genet_church_portal/shared_widgets/modern_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_input.dart';
import 'package:genet_church_portal/shared_widgets/notification_system.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/models/servant_model.dart';
import 'package:genet_church_portal/data/models/user_model.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:genet_church_portal/state/church_selection_provider.dart';
import 'package:genet_church_portal/shared_widgets/api_error_widget.dart';
import 'package:genet_church_portal/state/new_item_provider.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/modern_dropdown.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';
import 'package:iconsax/iconsax.dart';

class ReportServantsScreen extends HookConsumerWidget {
  const ReportServantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final selectedChurchId = ref.watch(currentChurchProvider);
    final servantsAsync = ref.watch(servantsProvider);
    final newlyAddedItemId = ref.watch(newlyAddedItemIdProvider);
    final userRole = ref.watch(authStateProvider)?.roleEnum;

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
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: PageHeader(
              title: 'Servant Records',
              description:
              'Manage all servants within the currently selected church.',
              action: userRole == UserRole.PASTOR
                  ? PrimaryButton(
                text: 'Add New Servant',
                icon: Iconsax.add,
                onPressed: () async {
                  if (selectedChurchId == null) {
                    context.showErrorNotification(
                      title: 'Action Required',
                      message:
                      'Please select a church from the header to add a servant.',
                    );
                    return;
                  }
                  _showAddServantDialog(context, ref);
                },
              )
                  : null,
            ),
          ),
          if (selectedChurchId == null)
            ModernCard(
              child: Center(
                heightFactor: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.building_4,
                      size: 48,
                      color: appColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Please select a church from the header to manage servants.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ModernCard(
              padding: EdgeInsets.zero,
              child: servantsAsync.when(
                data: (servants) {
                  if (servants.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(64),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.people,
                            size: 48,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No Servants Found',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color:
                              theme.colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            userRole == UserRole.PASTOR
                                ? 'Add your first servant to begin building your ministry team.'
                                : 'There are no servants registered for this church yet.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color:
                              theme.colorScheme.onSurface.withOpacity(0.4),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: StyledDataTable(
                      columns: const [
                        '#',
                        'Full Name',
                        'Email',
                        'Department ID',
                        'Actions',
                      ],
                      rows: servants.asMap().entries.map((entry) {
                        final index = entry.key;
                        final servant = entry.value;
                        final isNew = servant.id == newlyAddedItemId;
                        final rowWidget = DataRow(
                          cells: [
                            DataCell(Text((index + 1).toString())),
                            DataCell(Text(servant.user?.fullName ?? '')),
                            DataCell(Text(servant.user?.email ?? '')),
                            DataCell(Text(servant.departmentId ?? 'N/A')),
                            DataCell(
                              userRole == UserRole.PASTOR
                                  ? Row(
                                children: [
                                  ModernButton(
                                    text: 'ASSIGN',
                                    variant: ButtonVariant.outline,
                                    customColor:
                                    theme.colorScheme.secondary,
                                    size: ButtonSize.small,
                                    icon: Iconsax.building,
                                    onPressed: () =>
                                        _showAssignDepartmentDialog(
                                          context,
                                          ref,
                                          servant,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  ModernButton(
                                    text: 'EDIT',
                                    variant: ButtonVariant.outline,
                                    customColor:
                                    theme.colorScheme.primary,
                                    size: ButtonSize.small,
                                    icon: Iconsax.edit,
                                    onPressed: () =>
                                        _showEditServantDialog(
                                          context,
                                          ref,
                                          servant,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  DestructiveButton(
                                    text: 'DELETE',
                                    size: ButtonSize.small,
                                    icon: Iconsax.trash,
                                    onPressed: () =>
                                        _showDeleteConfirmationDialog(
                                          context,
                                          ref,
                                          servant,
                                        ),
                                  ),
                                ],
                              )
                                  : const Text('No actions'),
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
                                      duration: Duration(milliseconds: 600),
                                    ),
                                    SlideEffect(
                                      begin: Offset(0, 0.2),
                                      duration: Duration(milliseconds: 600),
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
                loading: () => const Center(
                  heightFactor: 5,
                  child: CircularProgressIndicator(),
                ),
                error: (err, stack) =>
                    Center(heightFactor: 5, child: ApiErrorWidget(error: err)),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddServantDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Servant'),
        content: Form(
          key: formKey,
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
                validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Add Servant',
            onPressedAsync: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final newServant = await ref
                      .read(servantsProvider.notifier)
                      .addServant(
                    fullName: nameController.text,
                    email: emailController.text,
                    password: passwordController.text,
                    // churchId is handled by the provider reading currentChurchProvider
                  );
                  ref
                      .read(newlyAddedItemIdProvider.notifier)
                      .set(newServant.id);
                  if (context.mounted) {
                    context.showSuccessNotification(
                      title: 'Success',
                      message:
                      'Servant "${nameController.text}" added successfully.',
                    );
                    context.pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showErrorNotification(
                      title: 'Error',
                      message: 'Failed to add servant. Please try again.',
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditServantDialog(
      BuildContext context,
      WidgetRef ref,
      Servant servant,
      ) {
    final nameController = TextEditingController(
      text: servant.user?.fullName ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Servant'),
        content: Form(
          key: formKey,
          child: ModernInput(
            controller: nameController,
            label: 'New Full Name',
            prefixIcon: Iconsax.user,
            validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Save Changes',
            onPressedAsync: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await ref
                      .read(servantsProvider.notifier)
                      .updateServant(
                    servantId: servant.id,
                    fullName: nameController.text,
                  );
                  if (context.mounted) {
                    context.showSuccessNotification(
                      title: 'Success',
                      message: 'Servant information has been updated.',
                    );
                    context.pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showErrorNotification(
                      title: 'Error',
                      message: 'Failed to update servant.',
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context,
      WidgetRef ref,
      Servant servant,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete servant "${servant.user?.fullName ?? ''}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(servantsProvider.notifier)
                    .removeServant(servant.id);
                if (context.mounted) {
                  context.showSuccessNotification(
                    title: 'Deleted',
                    message:
                    'Servant "${servant.user?.fullName ?? ''}" has been removed.',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  context.showErrorNotification(
                    title: 'Error',
                    message: 'Failed to remove servant.',
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAssignDepartmentDialog(
      BuildContext context,
      WidgetRef ref,
      Servant servant,
      ) {
    final departmentsAsync = ref.watch(departmentsProvider);

    showDialog(
      context: context,
      builder: (context) {
        return HookConsumer(
          builder: (context, ref, child) {
            final selectedDepartmentId = useState(servant.departmentId);

            return AlertDialog(
              title: const Text('Assign Department'),
              content: departmentsAsync.when(
                data: (departments) => ModernDropdown<String>(
                  hintText: 'Select a Department',
                  icon: Iconsax.folder,
                  value: selectedDepartmentId.value,
                  items: departments
                      .map(
                        (d) =>
                        DropdownMenuItem(value: d.id, child: Text(d.name)),
                  )
                      .toList(),
                  onChanged: (val) => selectedDepartmentId.value = val,
                  validator: (v) => v == null ? 'Please select' : null,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const Text('Could not load departments.'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                PrimaryButton(
                  text: 'Assign',
                  onPressedAsync: () async {
                    if (selectedDepartmentId.value == null) return;
                    try {
                      await ref
                          .read(servantsProvider.notifier)
                          .assignToDepartment(
                        departmentId: selectedDepartmentId.value!,
                        servantId: servant.id,
                      );
                      if (context.mounted) {
                        context.showSuccessNotification(
                          title: 'Success',
                          message: 'Department assigned.',
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        context.showErrorNotification(
                          title: 'Error',
                          message: 'Failed to assign department.',
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