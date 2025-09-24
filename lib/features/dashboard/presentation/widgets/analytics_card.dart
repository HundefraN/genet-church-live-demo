import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/features/dashboard/presentation/widgets/clock_painter.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:intl/intl.dart';

class AnalyticsCard extends HookConsumerWidget {
  const AnalyticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clockController = useAnimationController(
      duration: const Duration(seconds: 60),
    )..repeat();

    final chartController = useAnimationController(
      duration: const Duration(milliseconds: 2000),
    );

    final pulseController = useAnimationController(
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    final barAnimations = useMemoized(() {
      return List.generate(12, (index) {
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: chartController,
            curve: Interval(
              index * 0.05,
              0.6 + (index * 0.03),
              curve: Curves.elasticOut,
            ),
          ),
        );
      });
    }, [chartController]);

    useEffect(() {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) chartController.forward();
      });
      return null;
    }, [chartController]);

    final statsAsync = ref.watch(dashboardStatsProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF16D0A7),
                const Color(0xFF13B894),
                const Color(0xFF0EA57A),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16D0A7).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _Calendar(pulseController: pulseController),
              ),
              const SizedBox(width: 28),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimatedBuilder(
                          animation: clockController,
                          builder: (context, child) => CustomPaint(
                            painter: ClockPainter(
                              animationProgress: clockController.value,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border:
                        Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Next Service',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => context.go('/advanced-reports'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(28),
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
              child: statsAsync.when(
                data: (stats) {
                  final totalItems = stats.totalChurches +
                      stats.totalPastors +
                      stats.totalServants;

                  return Column(
                    children: [
                      Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          _IconStat(
                            icon: Iconsax.building,
                            value: stats.totalChurches.toString(),
                            label: 'Churches',
                            color: AppTheme.primaryBlue,
                            pulseController: pulseController,
                          ),
                          _IconStat(
                            icon: Iconsax.user_octagon,
                            value: stats.totalPastors.toString(),
                            label: 'Pastors',
                            color: const Color(0xFF16D0A7),
                            pulseController: pulseController,
                          ),
                          _IconStat(
                            icon: Iconsax.lifebuoy,
                            value: stats.totalServants.toString(),
                            label: 'Servants',
                            color: const Color(0xFF0091FF),
                            pulseController: pulseController,
                          ),
                          const _ComingSoonStat(
                            icon: Iconsax.wallet_3,
                            label: 'Donations',
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Container(
                        height: 240,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Monthly Activity',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                    AppTheme.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    DateFormat('yyyy').format(DateTime.now()),
                                    style: const TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                                children: List.generate(12, (index) {
                                  final baseHeight =
                                      (math.sin(index * 0.5) + 1.5) *
                                          (totalItems > 0
                                              ? totalItems
                                              : 5) +
                                          20.0;
                                  final isOrange = index % 2 == 0;
                                  final color = isOrange
                                      ? const Color(0xFFFEC53D)
                                      : AppTheme.primaryBlue;

                                  return AnimatedBuilder(
                                    animation: barAnimations[index],
                                    builder: (context, child) => Container(
                                      width: 14,
                                      height: baseHeight *
                                          barAnimations[index].value,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            color,
                                            color.withOpacity(0.7),
                                          ],
                                        ),
                                        borderRadius:
                                        const BorderRadius.vertical(
                                          top: Radius.circular(6),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: color.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) =>
                const Center(child: Text('Could not load activity data')),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _Calendar extends StatelessWidget {
  final AnimationController pulseController;

  const _Calendar({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcomingSunday =
    now.add(Duration(days: DateTime.sunday - now.weekday));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(now),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            AnimatedBuilder(
              animation: pulseController,
              builder: (context, child) => Transform.scale(
                scale: 1.0 + (pulseController.value * 0.1),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Iconsax.calendar_1,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                .map((day) => Expanded(
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 35,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final firstDayOfMonth = DateTime(now.year, now.month, 1);
              final dayOffset = firstDayOfMonth.weekday - 1;
              final day = index - dayOffset + 1;
              final isValid =
                  day > 0 && day <= DateTime(now.year, now.month + 1, 0).day;
              final isToday = isValid && day == now.day;
              final isUpcomingSunday = isValid &&
                  day == upcomingSunday.day &&
                  upcomingSunday.month == now.month;

              return Container(
                decoration: BoxDecoration(
                  gradient: isToday
                      ? LinearGradient(
                    colors: [Colors.white, Colors.grey.shade100],
                  )
                      : null,
                  color: isUpcomingSunday && !isToday
                      ? Colors.white.withOpacity(0.25)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday || isUpcomingSunday
                      ? Border.all(color: Colors.white.withOpacity(0.5))
                      : null,
                  boxShadow: isToday
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    isValid ? day.toString() : '',
                    style: TextStyle(
                      color:
                      isToday ? const Color(0xFF16D0A7) : Colors.white,
                      fontWeight: isToday || isUpcomingSunday
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: isToday ? 16 : 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _IconStat extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final AnimationController pulseController;

  const _IconStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.pulseController,
  });

  @override
  State<_IconStat> createState() => _IconStatState();
}

class _IconStatState extends State<_IconStat> with TickerProviderStateMixin {
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
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
          _isHovered ? widget.color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: _isHovered
              ? Border.all(color: widget.color.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: widget.pulseController,
              builder: (context, child) => Transform.scale(
                scale: 1.0 + (widget.pulseController.value * 0.1),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.color, widget.color.withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                      _isHovered ? widget.color : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ComingSoonStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ComingSoonStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.grey.shade500, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '-',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}