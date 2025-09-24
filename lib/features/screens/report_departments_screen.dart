import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';
import 'package:iconsax/iconsax.dart';

class ReportDepartmentsScreen extends HookConsumerWidget {
  const ReportDepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentsAsync = ref.watch(departmentsProvider);
    final nameController = useTextEditingController();
    final isLoading = useState(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Department Records',
          description:
          'Manage all departments within the currently selected church.',
          action: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Add New Department'),
                  content: ModernTextField(
                      controller: nameController,
                      hintText: 'Department Name',
                      icon: Iconsax.folder),
                  actions: [
                    TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty) {
                          isLoading.value = true;
                          try {
                            await ref
                                .read(departmentsProvider.notifier)
                                .addDepartment(name: nameController.text);
                            context.pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Failed to add department.'),
                                    backgroundColor: Colors.red));
                          } finally {
                            isLoading.value = false;
                          }
                        }
                      },
                      child: isLoading.value
                          ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Add'),
                    )
                  ],
                ),
              );
            },
            icon: const Icon(Iconsax.add, size: 18),
            label: const Text('Add New Department'),
            style: ElevatedButton.styleFrom(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ContentCard(
          padding: EdgeInsets.zero,
          child: departmentsAsync.when(
            data: (departments) {
              if (departments.isEmpty) {
                return const Center(
                    heightFactor: 5, child: Text('No departments found.'));
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
                  return DataRow(cells: [
                    DataCell(Text((index + 1).toString())),
                    DataCell(Text(department.name)),
                    DataCell(Text(department.id)),
                    DataCell(
                      TableActionButton(
                        label: 'DELETE',
                        color: AppTheme.destructiveRed,
                        icon: Iconsax.trash,
                        onPressed: () => ref
                            .read(departmentsProvider.notifier)
                            .removeDepartment(department.id),
                      ),
                    ),
                  ]);
                }).toList(),
              );
            },
            loading: () => const Center(
                heightFactor: 10, child: CircularProgressIndicator()),
            error: (err, stack) {
              if (err.toString().contains('403')) {
                return Center(
                  heightFactor: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.lock,
                          color: AppTheme.textSecondary, size: 32),
                      const SizedBox(height: 16),
                      const Text(
                        'Access Denied',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your user role does not have permission to view departments.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                );
              }
              return Center(
                  heightFactor: 5,
                  child: Text('Failed to load departments: $err'));
            },
          ),
        ),
      ],
    );
  }
}