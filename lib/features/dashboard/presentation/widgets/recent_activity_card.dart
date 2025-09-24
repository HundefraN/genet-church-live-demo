import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/data/models/activity_log_model.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentActivityCard extends ConsumerWidget {
  const RecentActivityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(activityLogProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InfoCard(
        title: 'Recent Activity',
        description: '',
        child: activityAsync.when(
          data: (allActivities) {
            final recentActivities = allActivities.take(4).toList();
            return Column(
              children: [
                if (recentActivities.isEmpty)
                  const Center(
                    heightFactor: 4,
                    child: Text('No recent activity to display.'),
                  )
                else
                  ...List.generate(recentActivities.length, (index) {
                    final item = recentActivities[index];
                    return _ActivityItem(
                      activity: item,
                      isLast: index == recentActivities.length - 1,
                    );
                  }),
                const SizedBox(height: 16),
                if (allActivities.length > 4)
                  TextButton.icon(
                    onPressed: () => context.go('/activity-log'),
                    icon: const Icon(Iconsax.arrow_right_3),
                    label: const Text('See All Activity'),
                  )
              ],
            );
          },
          loading: () => const _ActivityShimmer(),
          error: (error, stack) =>
          const Center(child: Text('Could not load recent activity.')),
        ),
      ),
    );
  }
}

class _ActivityShimmer extends StatelessWidget {
  const _ActivityShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(4, (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 20, backgroundColor: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 80, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 16, width: double.infinity, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(height: 12, width: 150, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class _ActivityItem extends StatefulWidget {
  final ActivityLog activity;
  final bool isLast;

  const _ActivityItem({
    required this.activity,
    this.isLast = false,
  });

  @override
  State<_ActivityItem> createState() => _ActivityItemState();
}

class _ActivityItemState extends State<_ActivityItem>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.activity.type == ActivityType.pastor
        ? AppTheme.primaryBlue
        : const Color(0xFF16D0A7);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: InkWell(
        onTap: () => context.go(widget.activity.path),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color:
            _isHovered ? color.withOpacity(0.05) : Colors.transparent,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: _isHovered ? 12 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.activity.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  if (!widget.isLast)
                    Container(
                      width: 2,
                      height: 40,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            color.withOpacity(0.5),
                            color.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        timeago.format(widget.activity.timestamp),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.activity.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isHovered ? color : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.activity.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isHovered)
                AnimatedBuilder(
                  animation: _hoverController,
                  builder: (context, child) => Transform.scale(
                    scale: _hoverController.value,
                    child: Icon(
                      Iconsax.arrow_right_3,
                      color: color,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}