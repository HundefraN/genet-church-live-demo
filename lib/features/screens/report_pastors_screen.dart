import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/models/pastor_model.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/api_error_widget.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';
import 'package:iconsax/iconsax.dart';
import 'package:genet_church_portal/shared_widgets/custom_dropdown.dart';
import '../../core/lib/shared_widgets/table_shimmer_loader.dart';
import '../../shared_widgets/primary_button.dart';
import '../../shared_widgets/table_action_button.dart';

class ReportPastorsScreen extends HookConsumerWidget {
  const ReportPastorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final pastorsAsync = ref.watch(pastorsProvider);
    final searchQuery = useState('');
    final isDeleting = useState<String?>(null);

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
                        style: theme.textTheme.headlineLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
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
          ContentCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  child: ModernTextField(
                    hintText: 'Search by name or email...',
                    icon: Iconsax.search_normal_1,
                    onChanged: (value) => searchQuery.value = value,
                  ),
                ),
                Container(height: 1, color: appColors.border),
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
                      return _EmptyState(
                        searchQuery: searchQuery.value,
                        onAddPressed: () => _showAddPastorDialog(context, ref),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: StyledDataTable(
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
                          return DataRow(
                            cells: [
                              DataCell(Text((index + 1).toString())),
                              DataCell(Text(pastor.user.fullName)),
                              DataCell(Text(pastor.user.email)),
                              DataCell(Text(pastor.churchId ?? 'N/A')),
                              DataCell(
                                Row(
                                  children: [
                                    TableActionButton(
                                      label: 'ASSIGN',
                                      color: theme.colorScheme.secondary,
                                      icon: Iconsax.building,
                                      onPressed: () => _showAssignChurchDialog(
                                          context, ref, pastor),
                                    ),
                                    const SizedBox(width: 8),
                                    TableActionButton(
                                      label: 'EDIT',
                                      color: theme.colorScheme.primary,
                                      icon: Iconsax.edit,
                                      onPressed: () => _showEditPastorDialog(
                                          context, ref, pastor),
                                    ),
                                    const SizedBox(width: 8),
                                    TableActionButton(
                                      label: 'DELETE',
                                      color: theme.colorScheme.error,
                                      icon: Iconsax.trash,
                                      isLoading: isDeleting.value == pastor.userId,
                                      onPressed: () => _showDeleteConfirmationDialog(context, ref, pastor, isDeleting),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
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

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, Pastor pastor, ValueNotifier<String?> isDeleting) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete pastor ${pastor.user.fullName}? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Delete'),
              onPressed: () async {
                isDeleting.value = pastor.userId;
                Navigator.of(dialogContext).pop();
                await ref.read(pastorsProvider.notifier).removePastor(pastor.userId); // CORRECT ID USED HERE
                isDeleting.value = null;
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
      builder: (context) {
        return HookConsumer(builder: (context, ref, child) {
          final isLoading = useState(false);
          return AlertDialog(
            title: const Text('Add New Pastor'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ModernTextField(
                    controller: nameController,
                    hintText: 'Full Name',
                    icon: Iconsax.user,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  ModernTextField(
                    controller: emailController,
                    hintText: 'Email Address',
                    icon: Iconsax.direct_right,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  ModernTextField(
                    controller: passwordController,
                    hintText: 'Temporary Password',
                    icon: Iconsax.key,
                    obscureText: true,
                    validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              PrimaryButton(
                isLoading: isLoading.value,
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    isLoading.value = true;
                    try {
                      await ref.read(pastorsProvider.notifier).addPastor(
                        fullName: nameController.text,
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      if (context.mounted) Navigator.pop(context);
                    } finally {
                      if (context.mounted) isLoading.value = false;
                    }
                  }
                },
                text: 'Add Pastor',
              ),
            ],
          );
        });
      },
    );
  }


  void _showEditPastorDialog(BuildContext context, WidgetRef ref, Pastor pastor) {
    final nameController = TextEditingController(text: pastor.user.fullName);
    final emailController = TextEditingController(text: pastor.user.email);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return HookConsumer(
          builder: (context, ref, child) {
            final isSaving = useState(false);
            return AlertDialog(
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
                      validator: (val) =>
                      val!.isEmpty ? 'Name cannot be empty' : null,
                    ),
                    const SizedBox(height: 20),
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
                  child: const Text('Cancel'),
                ),
                PrimaryButton(
                  isLoading: isSaving.value,
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      isSaving.value = true;
                      try {
                        await ref.read(pastorsProvider.notifier).updatePastor(
                          pastorId: pastor.id,
                          fullName: nameController.text,
                          email: emailController.text,
                        );
                        if(context.mounted) Navigator.pop(context);
                      } finally {
                        if(context.mounted) isSaving.value = false;
                      }
                    }
                  },
                  text: 'Save Changes',
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAssignChurchDialog(BuildContext context, WidgetRef ref, Pastor pastor) {
    final churchesAsync = ref.watch(churchesProvider);
    String? selectedChurchId;

    showDialog(
      context: context,
      builder: (context) {
        return HookConsumer(
          builder: (context, ref, child) {
            final isAssigning = useState(false);
            return AlertDialog(
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
                  child: const Text('Cancel'),
                ),
                PrimaryButton(
                  isLoading: isAssigning.value,
                  onPressed: () async {
                    if (selectedChurchId != null) {
                      isAssigning.value = true;
                      try {
                        await ref.read(pastorsProvider.notifier).assignChurchToPastor(
                          pastorId: pastor.id,
                          churchId: selectedChurchId!,
                        );
                        if(context.mounted) Navigator.pop(context);
                      } finally {
                        if(context.mounted) isAssigning.value = false;
                      }
                    }
                  },
                  text: 'Assign Church',
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
            searchQuery.isEmpty ? Iconsax.user_octagon : Iconsax.search_zoom_out,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isEmpty
                ? 'No Pastors Found'
                : 'No Pastors Match Your Search',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Add your first pastor to get started.'
                : 'Try adjusting your search terms.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.4)),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: onAddPressed,
              text: 'Add First Pastor',
              icon: Iconsax.add,
            ),
          ]
        ],
      ),
    );
  }
}