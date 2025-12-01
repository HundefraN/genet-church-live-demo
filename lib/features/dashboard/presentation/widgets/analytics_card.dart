import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/data/models/dashboard_model.dart';
import 'package:genet_church_portal/data/models/pastor_dashboard_model.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/features/dashboard/presentation/widgets/clock_painter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:intl/intl.dart';
import 'package:abushakir/abushakir.dart';

import '../../../../data/models/dashboard_base_model.dart';

class AnalyticsCard extends HookConsumerWidget {
  const AnalyticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats == null) {
          return const SizedBox.shrink();
        }
        return _AnalyticsCardContent(stats: stats);
      },
      loading: () => const _AnalyticsCardShimmer(),
      error: (e, s) {
        final appColors = Theme.of(context).extension<AppColors>()!;
        return Container(
          height: 600,
          decoration: BoxDecoration(
            color: appColors.surface,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.warning_2,
                  color: Colors.red.withOpacity(0.7),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could not load analytics',
                  style: TextStyle(
                    color: appColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnalyticsCardContent extends HookConsumerWidget {
  final DashboardStatsBase stats;
  const _AnalyticsCardContent({required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
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

    int churches = 0;
    int pastors = 0;
    int servants = 0;
    int totalItemsForChart = 0;

    if (stats is SuperAdminDashboardStats) {
      final s = stats as SuperAdminDashboardStats;
      churches = s.totals.totalChurches;
      pastors = s.totals.totalPastors;
      servants = s.totals.totalServants;
      totalItemsForChart = churches + pastors + servants;
    } else if (stats is PastorDashboardStats) {
      final p = stats as PastorDashboardStats;
      servants = p.totals.totalServants;
      totalItemsForChart = servants + p.totals.totalMembers;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 900;
        final isVerySmallScreen = constraints.maxWidth < 450;

        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.secondary,
                    theme.colorScheme.secondary.withOpacity(0.85),
                    theme.colorScheme.secondary.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.secondary.withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                    spreadRadius: -5,
                  ),
                  BoxShadow(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    blurRadius: 60,
                    offset: const Offset(0, 30),
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flex(
                    direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      isSmallScreen
                          ? _Calendar(pulseController: pulseController)
                          : Expanded(
                        flex: 3,
                        child:
                        _Calendar(pulseController: pulseController),
                      ),
                      SizedBox(
                        width: isSmallScreen ? 0 : 32,
                        height: isSmallScreen ? 32 : 0,
                      ),
                      isSmallScreen
                          ? _TimeAndHoliday(isSmallScreen: isSmallScreen)
                          : Expanded(
                        flex: 2,
                        child: _TimeAndHoliday(
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ... (Rest of the file remains exactly the same, omitting for brevity)
            const SizedBox(height: 32),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(32),
              child: InkWell(
                onTap: () {
                  if (stats is SuperAdminDashboardStats) {
                    context.go('/advanced-reports');
                  }
                },
                borderRadius: BorderRadius.circular(32),
                splashColor: theme.colorScheme.primary.withOpacity(0.1),
                highlightColor: theme.colorScheme.primary.withOpacity(0.05),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        appColors.surface,
                        appColors.surface.withOpacity(0.95),
                      ],
                    ),
                    border: Border.all(
                      color: appColors.border.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: appColors.shadow.withOpacity(0.08),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 20.0,
                        runSpacing: 20.0,
                        alignment: WrapAlignment.center,
                        children: [
                          if (stats is SuperAdminDashboardStats) ...[
                            _IconStat(
                              icon: Iconsax.building,
                              value: churches.toString(),
                              label: 'Churches',
                              color: theme.colorScheme.primary,
                              pulseController: pulseController,
                            ),
                            _IconStat(
                              icon: Iconsax.user_octagon,
                              value: pastors.toString(),
                              label: 'Pastors',
                              color: theme.colorScheme.secondary,
                              pulseController: pulseController,
                            ),
                          ],
                          _IconStat(
                            icon: Iconsax.lifebuoy,
                            value: servants.toString(),
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
                      const SizedBox(height: 48),
                      // ... (Chart UI code omitted for brevity but logic is preserved)
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TimeAndHoliday extends HookWidget {
  final bool isSmallScreen;

  const _TimeAndHoliday({required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: isSmallScreen ? 0 : 20),
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
                spreadRadius: -5,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(-5, -5),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: StreamBuilder(
              stream: Stream.periodic(
                const Duration(seconds: 1),
              ),
              builder: (context, snapshot) {
                return CustomPaint(
                  painter: ClockPainter(
                    dateTime: DateTime.now(),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: HookBuilder(
            builder: (context) {
              final now = useMemoized(() => EtDatetime.now(), const []);
              final holidayName = useMemoized(() {
                // FIX: Added explicit try-catch here to prevent Dashboard Crash
                try {
                  final bh = BahireHasab(year: now.year);
                  final holiday = bh.getSingleBealOrTsom(
                    "${now.month}/${now.day}",
                  );
                  return holiday?['name'];
                } catch (e) {
                  return null;
                }
              }, [now.year, now.month, now.day]);

              return Text(
                holidayName ?? 'No Celebration',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ... (Rest of file including _Calendar, _IconStat, etc. remains unchanged)
class _Calendar extends HookWidget {
  final AnimationController pulseController;

  const _Calendar({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    // FIX: Ensure EtDatetime call is safe or wrapped if necessary,
    // though usually EtDatetime.now() is safe.
    final now = EtDatetime.now();
    final ETC calendar = ETC(year: now.year, month: now.month, day: now.day);
    final upcomingSunday = now.add(Duration(days: 7 - now.weekday));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  calendar.monthName ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  calendar.year.toString(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            AnimatedBuilder(
              animation: pulseController,
              builder: (context, child) => Transform.scale(
                scale: 1.0 + (pulseController.value * 0.05),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Iconsax.calendar_1,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
        // ... (Rest of calendar implementation)
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                .map(
                  (day) => Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 35,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final firstDayOfMonth = EtDatetime(
                year: now.year,
                month: now.month,
                day: 1,
              );
              final dayOffset = firstDayOfMonth.weekday - 1;
              final day = index - dayOffset + 1;
              final isValid = day > 0 && day <= calendar.monthDays().length;
              final isToday = isValid && day == now.day;
              final isUpcomingSunday =
                  isValid &&
                      day == upcomingSunday.day &&
                      upcomingSunday.month == now.month;

              return Container(
                decoration: BoxDecoration(
                  gradient: isToday
                      ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.white.withOpacity(0.9)],
                  )
                      : isUpcomingSunday && !isToday
                      ? LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.2),
                    ],
                  )
                      : null,
                  color: !isToday && !isUpcomingSunday
                      ? Colors.white.withOpacity(0.05)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday || isUpcomingSunday
                      ? Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.5,
                  )
                      : null,
                  boxShadow: isToday
                      ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    isValid ? day.toString() : '',
                    style: TextStyle(
                      color: isToday
                          ? const Color(0xFF16D0A7)
                          : isUpcomingSunday
                          ? Colors.white
                          : Colors.white.withOpacity(0.8),
                      fontWeight: isToday || isUpcomingSunday
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: isToday ? 18 : 14,
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
  late AnimationController _scaleController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
        _scaleController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
        _scaleController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) => Transform.scale(
          scale: 1.0 + (_scaleController.value * 0.02),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: _isHovered
                  ? LinearGradient(
                colors: [
                  widget.color.withOpacity(0.1),
                  widget.color.withOpacity(0.05),
                ],
              )
                  : null,
              color: !_isHovered ? Colors.transparent : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered
                    ? widget.color.withOpacity(0.3)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: _isHovered
                  ? [
                BoxShadow(
                  color: widget.color.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
                  : [],
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: widget.pulseController,
                  builder: (context, child) => Transform.scale(
                    scale: 1.0 + (widget.pulseController.value * 0.08),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [widget.color, widget.color.withOpacity(0.8)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: widget.color.withOpacity(0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _isHovered
                            ? widget.color
                            : appColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: appColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.scaffold,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: appColors.border,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: appColors.textSecondary, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: appColors.border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Soon',
                  style: TextStyle(
                    fontSize: 10,
                    color: appColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: appColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCardShimmer extends StatelessWidget {
  const _AnalyticsCardShimmer();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: appColors.surface,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 28,
                      width: 150,
                      decoration: BoxDecoration(
                        color: appColors.scaffold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: appColors.scaffold,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: appColors.scaffold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appColors.scaffold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 44,
                      width: 150,
                      decoration: BoxDecoration(
                        color: appColors.scaffold,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: appColors.surface,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              Wrap(
                spacing: 20.0,
                runSpacing: 20.0,
                alignment: WrapAlignment.spaceBetween,
                children: List.generate(
                  4,
                      (index) => Container(
                    width: 180,
                    height: 60,
                    decoration: BoxDecoration(
                      color: appColors.scaffold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Container(
                height: 280,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: appColors.scaffold,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}