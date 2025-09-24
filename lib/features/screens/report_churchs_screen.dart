import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class ReportChurchsScreen extends HookConsumerWidget {
  const ReportChurchsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchesAsync = ref.watch(churchesProvider);
    final searchQuery = useState('');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Church Records',
          action: ElevatedButton.icon(
            onPressed: () => context.go('/add-church'),
            icon: const Icon(Iconsax.add, size: 18),
            label: const Text('Add New Church'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ContentCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ModernTextField(
                  hintText: 'Search by church name...',
                  icon: Iconsax.search_normal_1,
                  onChanged: (value) => searchQuery.value = value,
                ),
              ),
              const Divider(height: 1),
              churchesAsync.when(
                data: (churches) {
                  final filteredChurches = churches.where((church) {
                    if (searchQuery.value.isEmpty) return true;
                    return church.name
                        .toLowerCase()
                        .contains(searchQuery.value.toLowerCase());
                  }).toList();

                  if (filteredChurches.isEmpty) {
                    return Center(
                      heightFactor: 5,
                      child: Text(searchQuery.value.isEmpty
                          ? 'No churches found.'
                          : 'No churches match your search.'),
                    );
                  }
                  return StyledDataTable(
                    columns: const [
                      '#',
                      'Church Name',
                      'Head Office ID',
                      'Location Link',
                      'Actions'
                    ],
                    rows: filteredChurches.asMap().entries.map((entry) {
                      final index = entry.key;
                      final church = entry.value;
                      return DataRow(cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(church.name)),
                        DataCell(Text(church.headOfficeId ?? 'N/A')),
                        DataCell(Text(church.locationLink ?? 'N/A')),
                        DataCell(Row(
                          children: [
                            TableActionButton(
                              label: 'EDIT',
                              color: AppTheme.primaryBlue,
                              icon: Iconsax.edit,
                              onPressed: () =>
                                  _showEditChurchDialog(context, ref, church),
                            ),
                            const SizedBox(width: 8),
                            TableActionButton(
                              label: 'DELETE',
                              color: AppTheme.destructiveRed,
                              onPressed: () async {
                                await ref
                                    .read(churchesProvider.notifier)
                                    .removeChurch(church.id);
                              },
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  );
                },
                loading: () => const Center(
                    heightFactor: 10, child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                    heightFactor: 5,
                    child: Text('Failed to load churches: $err')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditChurchDialog(
      BuildContext context, WidgetRef ref, Church church) {
    final nameController = TextEditingController(text: church.name);
    final locationController = TextEditingController(text: church.locationLink);
    final formKey = GlobalKey<FormState>();
    final isSaving = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<bool>(
        valueListenable: isSaving,
        builder: (context, loading, child) {
          return AlertDialog(
            title: const Text('Edit Church'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ModernTextField(
                      controller: nameController,
                      hintText: 'Church Name',
                      icon: Iconsax.building,
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 16),
                  ModernTextField(
                      controller: locationController,
                      hintText: 'Location Link',
                      icon: Iconsax.map_1),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: loading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: loading ? null : () async {
                  if (formKey.currentState!.validate()) {
                    isSaving.value = true;
                    final updatedChurch = Church(
                        id: church.id,
                        name: nameController.text,
                        locationLink: locationController.text,
                        establishmentDate: church.establishmentDate,
                        headOfficeId: church.headOfficeId);
                    try {
                      await ref.read(churchesProvider.notifier).updateChurch(
                          churchId: church.id, church: updatedChurch);
                      if (context.mounted) Navigator.pop(context);
                    } finally {
                      if (context.mounted) isSaving.value = false;
                    }
                  }
                },
                child: loading
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}