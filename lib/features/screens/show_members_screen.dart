import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/models/member_model.dart';
import 'package:genet_church_portal/data/models/user_model.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:genet_church_portal/shared_widgets/advanced_filter_bar.dart';
import 'package:genet_church_portal/shared_widgets/api_error_widget.dart';
import 'package:genet_church_portal/shared_widgets/card_shimmer_loader.dart';
import 'package:genet_church_portal/shared_widgets/modern_button.dart';
import 'package:genet_church_portal/shared_widgets/modern_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_data_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_report_list.dart';
import 'package:genet_church_portal/shared_widgets/notification_system.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/state/church_selection_provider.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class ShowMembersScreen extends HookConsumerWidget {
  const ShowMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedChurchId = ref.watch(currentChurchProvider);
    final membersAsync = ref.watch(membersListProvider);
    final userRole = ref.watch(authStateProvider)?.roleEnum;

    // Filter states
    final searchQuery = useState('');
    final selectedGender = useState<String?>(null);
    final selectedStatusFilters = useState<Set<String>>({});
    final scrollController = useScrollController();

    // Infinite scroll listener
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

    final canManageMembers =
        userRole == UserRole.PASTOR || userRole == UserRole.SERVANT;

    // Build gender filter dropdown
    final genderDropdowns = <FilterDropdownConfig>[
      FilterDropdownConfig(
        label: 'Gender',
        icon: Iconsax.user,
        options: [
          const FilterOption(label: 'Male', value: 'MALE'),
          const FilterOption(label: 'Female', value: 'FEMALE'),
        ],
        selectedValue: selectedGender.value,
        onChanged: (val) => selectedGender.value = val,
      ),
    ];

    // Build status filter chips
    final statusChips = <FilterOption>[
      FilterOption(
        label: 'New Believer',
        value: 'NEW_BELIEVER',
        icon: Iconsax.star,
        isSelected: selectedStatusFilters.value.contains('NEW_BELIEVER'),
      ),
      FilterOption(
        label: 'Active',
        value: 'ACTIVE',
        icon: Iconsax.tick_circle,
        isSelected: selectedStatusFilters.value.contains('ACTIVE'),
      ),
      FilterOption(
        label: 'Inactive',
        value: 'INACTIVE',
        icon: Iconsax.minus_cirlce,
        isSelected: selectedStatusFilters.value.contains('INACTIVE'),
      ),
    ];

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Member Records',
            description:
                'A searchable and filterable list of all registered members in the church.',
            action: canManageMembers
                ? PrimaryButton(
                    text: 'Add New Member',
                    icon: Iconsax.add,
                    onPressed: () => context.go('/add-members'),
                  )
                : null,
          ),
          const SizedBox(height: 24),
          if (selectedChurchId == null)
            const NoChurchSelectedState(
              message:
                  'Please select a church from the header to view members.',
            )
          else
            Column(
              children: [
                // Advanced Filter Bar
                AdvancedFilterBar(
                  searchHint: 'Search by name or phone number...',
                  searchValue: searchQuery.value,
                  onSearchChanged: (val) => searchQuery.value = val,
                  filterDropdowns: genderDropdowns,
                  filterChips: statusChips,
                  onChipToggled: (chip) {
                    final newSet = Set<String>.from(
                      selectedStatusFilters.value,
                    );
                    if (chip.isSelected) {
                      newSet.remove(chip.value);
                    } else {
                      newSet.add(chip.value);
                    }
                    selectedStatusFilters.value = newSet;
                  },
                  onClearAll: () {
                    searchQuery.value = '';
                    selectedGender.value = null;
                    selectedStatusFilters.value = {};
                  },
                ),
                const SizedBox(height: 24),
                // Member Content
                membersAsync.when(
                  data: (memberState) {
                    final members = memberState.members;

                    // Apply filters
                    final filteredMembers = members.where((member) {
                      // Search filter
                      if (searchQuery.value.isNotEmpty) {
                        final query = searchQuery.value.toLowerCase();
                        if (!member.fullName.toLowerCase().contains(query) &&
                            !member.phoneNumber.contains(query)) {
                          return false;
                        }
                      }
                      // Gender filter
                      if (selectedGender.value != null) {
                        if (member.gender.name != selectedGender.value) {
                          return false;
                        }
                      }
                      // Status filter
                      if (selectedStatusFilters.value.isNotEmpty) {
                        if (!selectedStatusFilters.value.contains(
                          member.memberStatus.name,
                        )) {
                          return false;
                        }
                      }
                      return true;
                    }).toList();

                    if (filteredMembers.isEmpty &&
                        !memberState.isFetchingNextPage) {
                      return _buildEmptyState(
                        context,
                        hasFilters:
                            searchQuery.value.isNotEmpty ||
                            selectedGender.value != null ||
                            selectedStatusFilters.value.isNotEmpty,
                        canManageMembers: canManageMembers,
                      );
                    }

                    return Column(
                      children: [
                        ModernDataGrid.responsive(
                          context: context,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: filteredMembers.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final member = entry.value;

                            return ModernDataCard(
                              index: index,
                              leading: DataCardAvatar(
                                initials: getInitials(member.fullName),
                                backgroundColor: member.gender.name == 'MALE'
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.secondary,
                              ),
                              title: member.fullName,
                              subtitle: member.phoneNumber,
                              chips: [
                                DataChip(
                                  label: member.gender.name,
                                  icon: member.gender.name == 'MALE'
                                      ? Iconsax.man
                                      : Iconsax.woman,
                                  color: member.gender.name == 'MALE'
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.secondary,
                                ),
                                DataChip(
                                  label: _formatStatus(
                                    member.memberStatus.name,
                                  ),
                                  icon: _getStatusIcon(
                                    member.memberStatus.name,
                                  ),
                                  color: _getStatusColor(
                                    theme,
                                    member.memberStatus.name,
                                  ),
                                ),
                              ],
                              actions: [
                                DataAction(
                                  label: 'VIEW',
                                  icon: Iconsax.eye,
                                  color: theme.colorScheme.primary,
                                  onPressed: () {
                                    if (member.id != null) {
                                      context.go('/show-members/${member.id}');
                                    }
                                  },
                                ),
                                if (canManageMembers)
                                  DataAction(
                                    label: 'DELETE',
                                    icon: Iconsax.trash,
                                    isDestructive: true,
                                    onPressed: () =>
                                        _showDeleteMemberConfirmationDialog(
                                          context,
                                          ref,
                                          member,
                                        ),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                        // Loading more indicator
                        if (memberState.isFetchingNextPage)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: const InlineShimmerLoader(
                              width: 200,
                              height: 40,
                            ),
                          ),
                      ],
                    );
                  },
                  loading: () => CardGridShimmerLoader.responsive(
                    context: context,
                    cardCount: 8,
                  ),
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
    BuildContext context, {
    required bool hasFilters,
    required bool canManageMembers,
  }) {
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
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.primary.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Iconsax.search_zoom_out : Iconsax.people,
                size: 48,
                color: theme.colorScheme.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters ? 'No Members Match Your Filters' : 'No Members Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: appColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilters
                  ? 'Try adjusting your search or filter criteria.'
                  : canManageMembers
                  ? 'Add your first member to get started.'
                  : 'No members have been registered for this church yet.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: appColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (!hasFilters && canManageMembers) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Add First Member',
                icon: Iconsax.add,
                onPressed: () => GoRouter.of(context).go('/add-members'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'NEW_BELIEVER':
        return Iconsax.star;
      case 'ACTIVE':
        return Iconsax.tick_circle;
      case 'INACTIVE':
        return Iconsax.minus_cirlce;
      default:
        return Iconsax.info_circle;
    }
  }

  Color _getStatusColor(ThemeData theme, String status) {
    switch (status) {
      case 'NEW_BELIEVER':
        return const Color(0xFFF5A623);
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.primary;
    }
  }

  void _showDeleteMemberConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    Member member,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete member "${member.fullName}"? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if (member.id == null) return;
                try {
                  await ref
                      .read(membersListProvider.notifier)
                      .removeMember(member.id!);
                  if (context.mounted) {
                    context.showSuccessNotification(
                      title: 'Success',
                      message: 'Member deleted successfully.',
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showErrorNotification(
                      title: 'Error',
                      message: 'Failed to delete member.',
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
