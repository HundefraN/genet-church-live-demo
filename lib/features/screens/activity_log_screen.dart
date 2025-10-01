import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/models/activity_log_model.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ActivityLogScreen extends ConsumerWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final activitiesAsync = ref.watch(activityLogProvider);

    return activitiesAsync.when(
      data: (activities) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Activity Log',
              description:
              'A chronological list of all major events and changes in the system.',
            ),
            const SizedBox(height: 24),
            if (activities.isEmpty)
              const Center(child: Text('No activities found.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shadowColor: appColors.shadow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () => context.go(activity.path),
                      leading: CircleAvatar(
                        backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.1),
                        child: Icon(activity.icon,
                            color: theme.colorScheme.primary),
                      ),
                      title: Text(activity.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(activity.subtitle),
                      trailing: Text(
                        DateFormat.yMMMd().add_jm().format(activity.timestamp),
                        style: TextStyle(
                            fontSize: 12, color: appColors.textSecondary),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
      loading: () => Shimmer.fromColors(
        baseColor: appColors.shimmerBase,
        highlightColor: appColors.shimmerHighlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              width: 400,
              color: appColors.surface,
              margin: const EdgeInsets.only(bottom: 24),
            ),
            ...List.generate(
                10,
                    (index) => Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading:
                    CircleAvatar(backgroundColor: appColors.surface),
                    title: Container(
                        height: 16,
                        color: appColors.surface,
                        margin: const EdgeInsets.only(right: 50)),
                    subtitle: Container(
                        height: 12,
                        width: 100,
                        color: appColors.surface,
                        margin: const EdgeInsets.only(top: 8, right: 100)),
                  ),
                )),
          ],
        ),
      ),
      error: (err, stack) =>
          Center(child: Text('Failed to load activities: $err')),
    );
  }
}