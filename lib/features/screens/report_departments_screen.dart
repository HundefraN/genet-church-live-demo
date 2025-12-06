import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/shared_widgets/advanced_filter_bar.dart';
import 'package:genet_church_portal/shared_widgets/card_shimmer_loader.dart';
import 'package:genet_church_portal/shared_widgets/modern_button.dart';
import 'package:genet_church_portal/shared_widgets/modern_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_data_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_input.dart';
import 'package:genet_church_portal/shared_widgets/modern_report_list.dart';
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
import 'package:iconsax/iconsax.dart';

class ReportDepartmentsScreen extends HookConsumerWidget {
  const ReportDepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final departmentsAsync = ref.watch(departmentsProvider);
    final selectedChurchId = ref.watch(currentChurchProvider);
    final userRole = ref.watch(authStateProvider)?.roleEnum;

    // Filter state
    final searchQuery = useState('');

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
            const NoChurchSelectedState(
              message:
                  'Please select a church from the header to manage departments.',
            )
          else
            Column(
              children: [
                // Filter Bar
                AdvancedFilterBar(
                  searchHint: 'Search by department name...',
                  searchValue: searchQuery.value,
                  onSearchChanged: (val) => searchQuery.value = val,
                  onClearAll: () => searchQuery.value = '',
                ),
                const SizedBox(height: 24),
                // Content
                departmentsAsync.when(
                  data: (departments) {
                    final filteredDepartments = departments.where((dept) {
                      if (searchQuery.value.isEmpty) return true;
                      return dept.name.toLowerCase().contains(
                        searchQuery.value.toLowerCase(),
                      );
                    }).toList();

                    if (filteredDepartments.isEmpty) {
                      return _buildEmptyState(
                        context,
                        searchQuery.value.isNotEmpty,
                        userRole,
                        ref,
                      );
                    }

                    return ModernDataGrid.responsive(
                      context: context,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: filteredDepartments.asMap().entries.map((
                        entry,
                      ) {
                        final index = entry.key;
                        final department = entry.value;

                        return ModernDataCard(
                          index: index,
                          leading: DataCardAvatar(
                            icon: Iconsax.folder,
                            backgroundColor: theme.colorScheme.secondary,
                          ),
                          title: department.name,
                          subtitle: 'ID: ${department.id}',
                          chips: [
                            DataChip(
                              label: 'Department',
                              icon: Iconsax.category,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                          actions: userRole == UserRole.PASTOR
                              ? [
                                  DataAction(
                                    label: 'EDIT',
                                    icon: Iconsax.edit,
                                    color: theme.colorScheme.primary,
                                    onPressed: () => _showEditDepartmentDialog(
                                      context,
                                      ref,
                                      department,
                                    ),
                                  ),
                                  DataAction(
                                    label: 'DELETE',
                                    icon: Iconsax.trash,
                                    isDestructive: true,
                                    onPressed: () =>
                                        _showDeleteConfirmationDialog(
                                          context,
                                          ref,
                                          department.id,
                                          department.name,
                                        ),
                                  ),
                                ]
                              : null,
                        );
                      }).toList(),
                    );
                  },
                  loading: () =>
                      CardGridShimmerLoader.responsive(context: context),
                  error: (err, stack) => ModernCard(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: ApiErrorWidget(error: err),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool hasFilters,
    UserRole? userRole,
    WidgetRef ref,
  ) {
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
                hasFilters ? Iconsax.search_zoom_out : Iconsax.folder_open,
                size: 48,
                color: theme.colorScheme.secondary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters
                  ? 'No Departments Match Your Search'
                  : 'No Departments Found',
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
                  : userRole == UserRole.PASTOR
                  ? 'Add your first department to organize your servants.'
                  : 'No departments have been created for this church yet.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: appColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (!hasFilters && userRole == UserRole.PASTOR) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Add First Department',
                icon: Iconsax.add,
                onPressed: () => _showAddDepartmentDialog(context, ref),
              ),
            ],
          ],
        ),
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
