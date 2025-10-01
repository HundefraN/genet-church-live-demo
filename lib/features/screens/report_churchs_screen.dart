import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/data/services/url_launcher_service.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';
import 'package:iconsax/iconsax.dart';

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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appColors.scaffold,
            appColors.scaffold.withOpacity(0.95),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.05),
                  theme.colorScheme.primary.withOpacity(0.02),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: PageHeader(
              title: 'Church Records',
              action: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/add-church'),
                  icon: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Iconsax.add, size: 18),
              ),
                  label: const Text('Add New Church'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ContentCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors.surface,
                          appColors.surface.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: ModernTextField(
                      hintText: 'Search by church name...',
                      icon: Iconsax.search_normal_1,
                      onChanged: (value) => searchQuery.value = value,
                    ),
                  ),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.1),
                          theme.colorScheme.primary.withOpacity(0.05),
                          theme.colorScheme.primary.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                  churchesAsync.when(
                    data: (churches) {
                      final filteredChurches = churches.where((church) {
                        if (searchQuery.value.isEmpty) return true;
                        return church.name
                            .toLowerCase()
                            .contains(searchQuery.value.toLowerCase());
                      }).toList();

                      if (filteredChurches.isEmpty) {
                        return Container(
                          height: 300,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                appColors.surface.withOpacity(0.3),
                                appColors.surface.withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.building,
                                  size: 64,
                                  color: appColors.textSecondary.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  searchQuery.value.isEmpty
                                      ? 'No churches found.'
                                      : 'No churches match your search.',
                                  style: TextStyle(
                                    color: appColors.textSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary.withOpacity(0.1),
                                        theme.colorScheme.primary.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(
                                church.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              )),
                              DataCell(Text(church.headOfficeId ?? 'N/A')),
                              DataCell(
                                church.locationLink != null &&
                                    Uri.tryParse(church.locationLink!)?.isAbsolute == true
                                    ? Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary.withOpacity(0.1),
                                        theme.colorScheme.primary.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => urlLauncher.openInNewTab(church.locationLink!),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Iconsax.location,
                                            size: 16,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'View on Map',
                                            style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              decoration: TextDecoration.underline,
                                              decorationColor: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                    : Text(church.locationLink ?? 'N/A'),
                              ),
                              DataCell(Row(
                                spacing: 12,
                                children: [
                                  TableActionButton(
                                    label: 'EDIT',
                                    color: theme.colorScheme.primary,
                                    icon: Iconsax.edit,
                                    onPressed: () => _showEditChurchDialog(context, ref, church),
                                  ),
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
                    loading: () => Container(
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            appColors.surface.withOpacity(0.3),
                            appColors.surface.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading churches...',
                              style: TextStyle(
                                color: appColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    error: (err, stack) => Container(
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.error.withOpacity(0.05),
                            theme.colorScheme.error.withOpacity(0.02),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.warning_2,
                              size: 64,
                              color: theme.colorScheme.error.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load churches: $err',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditChurchDialog(BuildContext context, WidgetRef ref, Church church) {
    final nameController = TextEditingController(text: church.name);
    final locationController = TextEditingController(text: church.locationLink);
    final formKey = GlobalKey<FormState>();
    final isSaving = ValueNotifier<bool>(false);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ValueListenableBuilder<bool>(
        valueListenable: isSaving,
        builder: (context, loading, child) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.1),
                                theme.colorScheme.primary.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Iconsax.edit,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Edit Church',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
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
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: loading ? null : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
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
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to update church.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) isSaving.value = false;
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: loading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}