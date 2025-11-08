import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/shared_widgets/api_error_widget.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';
import 'package:genet_church_portal/shared_widgets/table_action_button.dart';
import 'package:genet_church_portal/shared_widgets/table_shimmer_loader.dart';
import 'package:genet_church_portal/state/church_selection_provider.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../shared_widgets/primary_button.dart';

class ShowMembersScreen extends HookConsumerWidget {
  const ShowMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final selectedChurchId = ref.watch(currentChurchProvider);
    final membersAsync = ref.watch(membersListProvider);
    final searchQuery = useState('');
    final scrollController = useScrollController();

    useEffect(() {
      void listener() {
        final notifier = ref.read(membersListProvider.notifier);
        final state = ref.read(membersListProvider);
        if (state.valueOrNull?.isFetchingNextPage == false &&
            state.valueOrNull?.hasMore == true &&
            scrollController.position.pixels >=
                scrollController.position.maxScrollExtent - 200) {
          notifier.fetchNextPage();
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          PageHeader(
            title: 'Member Records',
            description:
            'A searchable and filterable list of all registered members in the church.',
            action: PrimaryButton(
              text: 'Add New Member',
              icon: Iconsax.add,
              onPressed: () async => context.go('/add-members'),
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
                      'Please select a church from the header to view members.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16, color: appColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ContentCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    child: ModernTextField(
                      hintText: 'Search by name or phone number...',
                      icon: Iconsax.search_normal_1,
                      onChanged: (value) => searchQuery.value = value,
                    ),
                  ),
                  Container(height: 1, color: appColors.border),
                  membersAsync.when(
                    data: (memberState) {
                      final members = memberState.members;
                      final filteredMembers = members.where((member) {
                        if (searchQuery.value.isEmpty) return true;
                        final query = searchQuery.value.toLowerCase();
                        return member.fullName.toLowerCase().contains(query) ||
                            member.phoneNumber.contains(query);
                      }).toList();

                      if (filteredMembers.isEmpty &&
                          !memberState.isFetchingNextPage) {
                        return Center(
                          heightFactor: 5,
                          child: Text(
                            searchQuery.value.isEmpty
                                ? 'No members found for this church.'
                                : 'No members match your search.',
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: StyledDataTable(
                          columns: const [
                            '#',
                            'Full Name',
                            'Phone Number',
                            'Gender',
                            'Status',
                            'Actions'
                          ],
                          rows: [
                            ...filteredMembers.asMap().entries.map((entry) {
                              final index = entry.key;
                              final member = entry.value;
                              return DataRow(cells: [
                                DataCell(Text((index + 1).toString())),
                                DataCell(Text(member.fullName)),
                                DataCell(Text(member.phoneNumber)),
                                DataCell(Text(member.gender.name)),
                                DataCell(
                                  Chip(
                                    label: Text(
                                      member.memberStatus.name,
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                    backgroundColor: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    side: BorderSide.none,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                  ),
                                ),
                                DataCell(Row(
                                  children: [
                                    TableActionButton(
                                      label: 'VIEW',
                                      color: theme.colorScheme.primary,
                                      icon: Iconsax.eye,
                                      onPressed: () {},
                                    ),
                                    const SizedBox(width: 8),
                                    TableActionButton(
                                      label: 'DELETE',
                                      color: theme.colorScheme.error,
                                      icon: Iconsax.trash,
                                      onPressed: () {},
                                    ),
                                  ],
                                )),
                              ]);
                            }),
                            if (memberState.isFetchingNextPage)
                              DataRow(
                                cells: List.generate(
                                  6,
                                      (index) => DataCell(
                                    index == 0
                                        ? const Center(
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    loading: () =>
                    const TableShimmerLoader(rowCount: 8, columnCount: 6),
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
}