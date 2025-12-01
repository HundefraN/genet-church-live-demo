import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:genet_church_portal/shared_widgets/modern_button.dart';
import 'package:genet_church_portal/shared_widgets/modern_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_input.dart';
import 'package:genet_church_portal/shared_widgets/notification_system.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/models/department_model.dart';
import 'package:genet_church_portal/data/models/user_model.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:genet_church_portal/state/church_selection_provider.dart';
import 'package:genet_church_portal/shared_widgets/api_error_widget.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';
import 'package:iconsax/iconsax.dart';

class ReportDepartmentsScreen extends HookConsumerWidget {
  const ReportDepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final departmentsAsync = ref.watch(departmentsProvider);
    final selectedChurchId = ref.watch(currentChurchProvider);
    final userRole = ref.watch(authStateProvider)?.roleEnum;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Department Records',
            description:
            'Manage all departments within the currently selected church.',
            action: userRole == UserRole.PASTOR
                ? PrimaryButton(
              text: 'Add New Department',
              icon: Iconsax.add,
              onPressed: () async {
                if (selectedChurchId == null) {
                  context.showErrorNotification(
                    title: 'Action Required',
                    message:
                    'Please select a church from the header first.',
                  );
                  return;
                }
                _showAddDepartmentDialog(context, ref);
              },
            )
                : null,
          ),
          const SizedBox(height: 24),
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
                      'Please select a church from the header to manage departments.',
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
              child: departmentsAsync.when(
                data: (departments) {
                  if (departments.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(64),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.folder_open,
                            size: 48,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No Departments Found',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color:
                              theme.colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            userRole == UserRole.PASTOR
                                ? 'Add your first department to organize your servants.'
                                : 'No departments have been created for this church yet.',
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
                  return StyledDataTable(
                    columns: const [
                      '#',
                      'Department Name',
                      'Department ID',
                      'Actions',
                    ],
                    rows: departments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final department = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Text((index + 1).toString())),
                          DataCell(Text(department.name)),
                          DataCell(Text(department.id)),
                          DataCell(
                            userRole == UserRole.PASTOR
                                ? Row(
                              children: [
                                ModernButton(
                                  text: 'EDIT',
                                  variant: ButtonVariant.outline,
                                  size: ButtonSize.small,
                                  customColor: theme.colorScheme.primary,
                                  icon: Iconsax.edit,
                                  onPressed: () =>
                                      _showEditDepartmentDialog(
                                        context,
                                        ref,
                                        department,
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
                                        department.id,
                                        department.name,
                                      ),
                                ),
                              ],
                            )
                                : const Text('No actions'),
                          ),
                        ],
                      );
                    }).toList(),
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

  void _showAddDepartmentDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Department'),
        content: Form(
          key: formKey,
          child: ModernInput(
            controller: nameController,
            label: 'Department Name',
            prefixIcon: Iconsax.folder,
            validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Add Department',
            onPressedAsync: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await ref
                      .read(departmentsProvider.notifier)
                      .addDepartment(name: nameController.text);
                  if (context.mounted) {
                    context.showSuccessNotification(
                      title: 'Success',
                      message:
                      'Department "${nameController.text}" added successfully.',
                    );
                    context.pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showErrorNotification(
                      title: 'Failed to Add',
                      message: e is DioException
                          ? (e.response?.data['message'] ?? 'An error occurred')
                          : 'An unknown error occurred.',
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

  void _showEditDepartmentDialog(
      BuildContext context,
      WidgetRef ref,
      Department department,
      ) {
    final nameController = TextEditingController(text: department.name);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit "${department.name}"'),
        content: Form(
          key: formKey,
          child: ModernInput(
            controller: nameController,
            label: 'Department Name',
            prefixIcon: Iconsax.folder,
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
                      .read(departmentsProvider.notifier)
                      .updateDepartment(
                    departmentId: department.id,
                    name: nameController.text,
                  );
                  if (context.mounted) {
                    context.showSuccessNotification(
                      title: 'Success',
                      message: 'Department updated successfully.',
                    );
                    context.pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showErrorNotification(
                      title: 'Update Failed',
                      message: 'Could not update department. Please try again.',
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
      String departmentId,
      String departmentName,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete the department "$departmentName"? This action cannot be undone.',
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
                Navigator.of(dialogContext).pop();
                try {
                  await ref
                      .read(departmentsProvider.notifier)
                      .removeDepartment(departmentId);
                  if (context.mounted) {
                    context.showSuccessNotification(
                      title: 'Deleted',
                      message: 'Department "$departmentName" was removed.',
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showErrorNotification(
                      title: 'Error',
                      message: 'Could not delete department. Please try again.',
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}