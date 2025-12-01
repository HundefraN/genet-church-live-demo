
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/models/member_model.dart';
import 'package:genet_church_portal/shared_widgets/api_error_widget.dart';
import 'package:genet_church_portal/shared_widgets/modern_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_loading.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class MemberDetailsScreen extends ConsumerWidget {
  final String memberId;
  const MemberDetailsScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberDetailsProvider(memberId));
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;

    return memberAsync.when(
      data: (member) {
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              children: [
                ModernCard(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.1),
                        child: Text(
                          member.fullName.isNotEmpty
                              ? member.fullName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(member.fullName,
                          style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          member.memberStatus.name,
                          style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600),
                        ),
                        backgroundColor:
                        theme.colorScheme.secondary.withOpacity(0.1),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Personal Information',
                          style: theme.textTheme.headlineSmall),
                      const Divider(height: 32),
                      _InfoRow(
                          icon: Iconsax.call,
                          label: 'Phone',
                          value: member.phoneNumber),
                      _InfoRow(
                          icon: Iconsax.calendar_1,
                          label: 'Birth Date',
                          value: DateFormat.yMMMMd()
                              .format(DateTime.parse(member.birthDate))),
                      _InfoRow(
                          icon: Iconsax.location,
                          label: 'Birth Place',
                          value: member.birthPlace),
                      _InfoRow(
                          icon: member.gender == Gender.MALE
                              ? Iconsax.man
                              : Iconsax.woman,
                          label: 'Gender',
                          value: member.gender.name),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Membership Details',
                          style: theme.textTheme.headlineSmall),
                      const Divider(height: 32),
                      _InfoRow(
                          icon: Iconsax.verify,
                          label: 'Status',
                          value: member.memberStatus.name),
                      if (member.statusChangedAt != null)
                        _InfoRow(
                            icon: Iconsax.clock,
                            label: 'Status Changed',
                            value: DateFormat.yMMMMd().format(
                                DateTime.parse(member.statusChangedAt!))),
                      if (member.baptizedAt != null)
                        _InfoRow(
                            icon: Iconsax.drop,
                            label: 'Baptized Date',
                            value: DateFormat.yMMMMd().format(
                                DateTime.parse(member.baptizedAt!))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Address', style: theme.textTheme.headlineSmall),
                      const Divider(height: 32),
                      _InfoRow(
                          icon: Iconsax.buildings,
                          label: 'City / Sub-City',
                          value:
                          '${member.address.city} / ${member.address.subCity}'),
                      _InfoRow(
                          icon: Iconsax.routing,
                          label: 'Woreda',
                          value: member.address.woreda),
                      _InfoRow(
                          icon: Iconsax.location_tick,
                          label: 'Place Name',
                          value: member.address.placeName),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: ModernLoading(size: 40)),
      error: (err, stack) => Center(child: ApiErrorWidget(error: err)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: appColors.textSecondary, size: 20),
          const SizedBox(width: 20),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: appColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: appColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}