import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
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
            // Use ListView.builder directly for the list content
              ListView.builder(
                shrinkWrap: true, // Important when nesting scrolls
                physics: const NeverScrollableScrollPhysics(), // Parent handles scroll
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () => context.go(activity.path),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                        child:
                        Icon(activity.icon, color: AppTheme.primaryBlue),
                      ),
                      title: Text(activity.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(activity.subtitle),
                      trailing: Text(
                        DateFormat.yMMMd().add_jm().format(activity.timestamp),
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
      loading: () => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmer for the PageHeader
            Container(height: 60, width: 400, color: Colors.white, margin: const EdgeInsets.only(bottom: 24),),
            // Shimmer for the ListView
            ...List.generate(10, (index) => Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.white),
                title: Container(height: 16, color: Colors.white, margin: const EdgeInsets.only(right: 50)),
                subtitle: Container(height: 12, width: 100, color: Colors.white, margin: const EdgeInsets.only(top: 8, right: 100)),
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