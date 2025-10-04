import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/data/services/url_launcher_service.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/api_error_widget.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import '../../shared_widgets/table_action_button.dart';

class ReportChurchsScreen extends HookConsumerWidget {
  const ReportChurchsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final churchesAsync = ref.watch(churchesProvider);
    final searchQuery = useState('');
    final urlLauncher = UrlLauncherService();

    return Column(
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
                      'Church Records',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage all church branches within the ministry network',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              PrimaryButton(
                onPressed: () => context.go('/add-church'),
                text: 'Add New Church',
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
                padding: const EdgeInsets.all(24.0),
                child: ModernTextField(
                  hintText: 'Search by church name...',
                  icon: Iconsax.search_normal_1,
                  onChanged: (value) => searchQuery.value = value,
                ),
              ),
              Container(height: 1, color: appColors.border),
              churchesAsync.when(
                data: (churches) {
                  final filteredChurches = churches.where((church) {
                    if (searchQuery.value.isEmpty) return true;
                    return church.name
                        .toLowerCase()
                        .contains(searchQuery.value.toLowerCase());
                  }).toList();

                  if (filteredChurches.isEmpty) {
                    return _EmptyState(
                      searchQuery: searchQuery.value,
                      onAddPressed: () => context.go('/add-church'),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: StyledDataTable(
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
                          DataCell(
                            church.locationLink != null &&
                                Uri.tryParse(church.locationLink!)
                                    ?.isAbsolute ==
                                    true
                                ? InkWell(
                                onTap: () => urlLauncher
                                    .openInNewTab(church.locationLink!),
                                child: Text('View on Map',
                                    style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        decoration:
                                        TextDecoration.underline)))
                                : Text(church.locationLink ?? 'N/A'),
                          ),
                          DataCell(Row(
                            children: [
                              TableActionButton(
                                label: 'EDIT',
                                color: theme.colorScheme.primary,
                                icon: Iconsax.edit,
                                onPressed: () =>
                                    _showEditChurchDialog(context, ref, church),
                              ),
                              const SizedBox(width: 8),
                              TableActionButton(
                                label: 'DELETE',
                                color: theme.colorScheme.error,
                                icon: Iconsax.trash,
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
                    ),
                  );
                },
                loading: () => _ShimmerLoader(appColors: appColors),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.all(64.0),
                  child: ApiErrorWidget(error: err),
                ),
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
      barrierDismissible: false,
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
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  ModernTextField(
                    controller: locationController,
                    hintText: 'Location Link',
                    icon: Iconsax.map_1,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                  if (formKey.currentState!.validate()) {
                    isSaving.value = true;
                    final updatedChurch = Church(
                      id: church.id,
                      name: nameController.text,
                      locationLink: locationController.text,
                      establishmentDate: church.establishmentDate,
                      headOfficeId: church.headOfficeId,
                      dateCreated: church.dateCreated,
                    );
                    try {
                      await ref
                          .read(churchesProvider.notifier)
                          .updateChurch(
                        churchId: church.id,
                        church: updatedChurch,
                      );
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      // ... error handling
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
                    : const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
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
            searchQuery.isEmpty ? Iconsax.building : Iconsax.search_zoom_out,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isEmpty
                ? 'No Churches Found'
                : 'No Churches Match Your Search',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Add your first church to get started.'
                : 'Try adjusting your search terms.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.4)),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: onAddPressed,
              text: 'Add First Church',
              icon: Iconsax.add,
            ),
          ]
        ],
      ),
    );
  }
}

class _ShimmerLoader extends StatelessWidget {
  final AppColors appColors;
  const _ShimmerLoader({required this.appColors});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: appColors.shimmerBase,
      highlightColor: appColors.shimmerHighlight,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: List.generate(
            5,
                (index) => Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(width: 40, height: 20, color: Colors.white),
                  const SizedBox(width: 40),
                  Expanded(child: Container(height: 20, color: Colors.white)),
                  const SizedBox(width: 40),
                  Expanded(child: Container(height: 20, color: Colors.white)),
                  const SizedBox(width: 40),
                  Expanded(child: Container(height: 20, color: Colors.white)),
                  const SizedBox(width: 40),
                  Expanded(
                      flex: 2, child: Container(height: 36, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}