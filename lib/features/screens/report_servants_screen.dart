import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/state/church_selection_provider.dart';
import 'package:genet_church_portal/shared_widgets/api_error_widget.dart';
import 'package:genet_church_portal/state/new_item_provider.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';
import 'package:iconsax/iconsax.dart';
import '../../shared_widgets/primary_button.dart';
import '../../shared_widgets/table_action_button.dart';

class ReportServantsScreen extends HookConsumerWidget {
  const ReportServantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final selectedChurchId = ref.watch(currentChurchProvider);
    final servantsAsync = ref.watch(servantsProvider);
    final newlyAddedItemId = ref.watch(newlyAddedItemIdProvider);

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 32),
          child: PageHeader(
            title: 'Servant Records',
            description:
            'Manage all servants within the currently selected church.',
            action: PrimaryButton(
              text: 'Add New Servant',
              icon: Iconsax.add,
              onPressed: () async {
                if (selectedChurchId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          'Please select a church from the header to add a servant.'),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                  return;
                }
                _showAddServantDialog(context, ref);
              },
            ),
          ),
        ),
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
                    'Please select a church from the header to manage servants.',
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
                          'Add your first servant to begin building your ministry team.',
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
                      'Servant ID',
                      'User ID',
                      'Department ID',
                      'Actions'
                    ],
                    rows: servants.asMap().entries.map((entry) {
                      final index = entry.key;
                      final servant = entry.value;
                      final isNew = servant.id == newlyAddedItemId;
                      final rowWidget = DataRow(
                        cells: [
                          DataCell(Text((index + 1).toString())),
                          DataCell(Text(servant.id)),
                          DataCell(Text(servant.userId)),
                          DataCell(Text(servant.departmentId ?? 'N/A')),
                          DataCell(
                            TableActionButton(
                              label: 'DELETE',
                              color: theme.colorScheme.error,
                              icon: Iconsax.trash,
                              onPressed: () => ref
                                  .read(servantsProvider.notifier)
                                  .removeServant(servant.id),
                            ),
                          ),
                        ],
                      );
                      if (isNew) {
                        return DataRow(
                            cells: rowWidget.cells
                                .map((cell) => DataCell(
                                Animate(
                                  effects: const [
                                    FadeEffect(
                                        duration:
                                        Duration(milliseconds: 600)),
                                    SlideEffect(
                                        begin: Offset(0, 0.2),
                                        duration:
                                        Duration(milliseconds: 600),
                                        curve: Curves.easeOutCubic)
                                  ],
                                  child: cell.child,
                                ),
                                showEditIcon: cell.showEditIcon,
                                placeholder: cell.placeholder,
                                onTap: cell.onTap))
                                .toList());
                      }
                      return rowWidget;
                    }).toList(),
                  ),
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

  void _showAddServantDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Servant'),
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
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Add Servant',
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final newServant =
                  await ref.read(servantsProvider.notifier).addServant(
                    fullName: nameController.text,
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  ref.read(newlyAddedItemIdProvider.notifier).set(newServant.id);
                  await Future.delayed(const Duration(seconds: 2));
                  if (context.mounted) context.pop();
                } on DioException catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Failed to add servant: ${e.response?.data?['error'] ?? 'Please select a church first.'}'),
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
}