import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/state/church_selection_provider.dart';
import 'package:genet_church_portal/shared_widgets/api_error_widget.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';
import 'package:iconsax/iconsax.dart';
import '../../shared_widgets/primary_button.dart';
import '../../shared_widgets/table_action_button.dart';

class ReportDepartmentsScreen extends HookConsumerWidget {
  const ReportDepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final departmentsAsync = ref.watch(departmentsProvider);
    final selectedChurchId = ref.watch(currentChurchProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Department Records',
          description:
          'Manage all departments within the currently selected church.',
          action: PrimaryButton(
            text: 'Add New Department',
            icon: Iconsax.add,
            onPressed: () async {
              if (selectedChurchId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Please select a church from the header first.'),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
                return;
              }
              _showAddDepartmentDialog(context, ref);
            },
          ),
        ),
        const SizedBox(height: 24),
        if (selectedChurchId == null)
          ContentCard(
            child: Center(
              heightFactor: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.building_4,
                      size: 48, color: appColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'Please select a church from the header to manage departments.',
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontSize: 16, color: appColors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          ContentCard(
            padding: EdgeInsets.zero,
            child: departmentsAsync.when(
              data: (departments) {
                if (departments.isEmpty) {
                  return const Center(
                    heightFactor: 5,
                    child: Text('No departments found for this church.'),
                  );
                }
                return StyledDataTable(
                  columns: const [
                    '#',
                    'Department Name',
                    'Department ID',
                    'Actions'
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
                          TableActionButton(
                            label: 'DELETE',
                            color: theme.colorScheme.error,
                            icon: Iconsax.trash,
                            onPressed: () => _showDeleteConfirmationDialog(
                                context, ref, department.id, department.name),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
              loading: () =>
              const Center(heightFactor: 5, child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(heightFactor: 5, child: ApiErrorWidget(error: err)),
            ),
          ),
      ],
    );
  }

  void _showAddDepartmentDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Department'),
        content: Form(
          key: formKey,
          child: ModernTextField(
            controller: nameController,
            hintText: 'Department Name',
            icon: Iconsax.folder,
            validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          PrimaryButton(
            text: 'Add Department',
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await ref
                      .read(departmentsProvider.notifier)
                      .addDepartment(name: nameController.text);
                  await Future.delayed(const Duration(seconds: 2));
                  if (context.mounted) context.pop();
                } on DioException catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Failed to add department: ${e.response?.data?['error'] ?? 'Please select a church first.'}'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                  throw e;
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref,
      String departmentId, String departmentName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete the department "$departmentName"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref
                    .read(departmentsProvider.notifier)
                    .removeDepartment(departmentId);
              },
            ),
          ],
        );
      },
    );
  }
}