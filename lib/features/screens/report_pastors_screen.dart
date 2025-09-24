import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/data/models/pastor_model.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:genet_church_portal/shared_widgets/custom_dropdown.dart';

class ReportPastorsScreen extends HookConsumerWidget {
  const ReportPastorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pastorsAsync = ref.watch(pastorsProvider);
    final searchQuery = useState('');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pastor Records',
                style: Theme.of(context).textTheme.headlineMedium),
            ElevatedButton.icon(
              onPressed: () => context.go('/add-pastors'),
              icon: const Icon(Iconsax.add, size: 18),
              label: const Text('Add New Pastor'),
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ContentCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ModernTextField(
                  hintText: 'Search by name or email...',
                  icon: Iconsax.search_normal_1,
                  onChanged: (value) => searchQuery.value = value,
                ),
              ),
              const Divider(height: 1),
              pastorsAsync.when(
                data: (pastors) {
                  final filteredPastors = pastors.where((pastor) {
                    if (searchQuery.value.isEmpty) return true;
                    final query = searchQuery.value.toLowerCase();
                    return pastor.user.fullName
                        .toLowerCase()
                        .contains(query) ||
                        pastor.user.email.toLowerCase().contains(query);
                  }).toList();

                  if (filteredPastors.isEmpty) {
                    return Center(
                      heightFactor: 5,
                      child: Text(searchQuery.value.isEmpty
                          ? 'No pastors found.'
                          : 'No pastors match your search.'),
                    );
                  }
                  return StyledDataTable(
                    columns: const [
                      '#',
                      'Full Name',
                      'Email',
                      'Assigned Church ID',
                      'Actions'
                    ],
                    rows: filteredPastors.asMap().entries.map((entry) {
                      final index = entry.key;
                      final pastor = entry.value;
                      return DataRow(cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(pastor.user.fullName)),
                        DataCell(Text(pastor.user.email)),
                        DataCell(Text(pastor.churchId ?? 'N/A')),
                        DataCell(Row(
                          children: [
                            TableActionButton(
                              label: 'ASSIGN',
                              color: AppTheme.accentTeal,
                              icon: Iconsax.building,
                              onPressed: () =>
                                  _showAssignChurchDialog(context, ref, pastor),
                            ),
                            const SizedBox(width: 8),
                            TableActionButton(
                              label: 'EDIT',
                              color: AppTheme.primaryBlue,
                              icon: Iconsax.edit,
                              onPressed: () =>
                                  _showEditPastorDialog(context, ref, pastor),
                            ),
                            const SizedBox(width: 8),
                            TableActionButton(
                              label: 'DELETE',
                              color: AppTheme.destructiveRed,
                              icon: Iconsax.trash,
                              onPressed: () {
                                ref.read(pastorsProvider.notifier).removePastor(pastor.userId);
                              },
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  );
                },
                loading: () =>
                const Center(heightFactor: 10, child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(heightFactor: 5, child: Text('Failed to load pastors: $err')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditPastorDialog(
      BuildContext context, WidgetRef ref, Pastor pastor) {
    final nameController = TextEditingController(text: pastor.user.fullName);
    final emailController = TextEditingController(text: pastor.user.email);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pastor'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModernTextField(
                controller: nameController,
                hintText: 'Full Name',
                icon: Iconsax.user,
                validator: (val) => val!.isEmpty ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 16),
              ModernTextField(
                controller: emailController,
                hintText: 'Email Address',
                icon: Iconsax.direct_right,
                validator: (val) =>
                val!.isEmpty ? 'Email cannot be empty' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await ref.read(pastorsProvider.notifier).updatePastor(
                  pastorId: pastor.id,
                  fullName: nameController.text,
                  email: emailController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAssignChurchDialog(
      BuildContext context, WidgetRef ref, Pastor pastor) {
    final churchesAsync = ref.watch(churchesProvider);
    String? selectedChurchId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Church to ${pastor.user.fullName}'),
        content: churchesAsync.when(
          data: (churches) => CustomDropdown(
            hintText: 'Select a Church',
            items: churches.map((c) => c.name).toList(),
            onChanged: (churchName) {
              if (churchName != null) {
                selectedChurchId =
                    churches.firstWhere((c) => c.name == churchName).id;
              }
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const Text('Could not load churches.'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (selectedChurchId != null) {
                await ref.read(pastorsProvider.notifier).assignChurchToPastor(
                  pastorId: pastor.id,
                  churchId: selectedChurchId!,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}