import 'package:flutter/material.dart';
import 'package:genet_church_portal/features/dashboard/presentation/widgets/clock_painter.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_theme.dart';

class AnalyticsCard extends StatefulWidget {
  const AnalyticsCard({super.key});

  @override
  State<AnalyticsCard> createState() => _AnalyticsCardState();
}

class _AnalyticsCardState extends State<AnalyticsCard>
    with TickerProviderStateMixin {
  late AnimationController _clockController;
  late AnimationController _chartController;
  late AnimationController _pulseController;
  late List<Animation<double>> _barAnimations;

  @override
  void initState() {
    super.initState();

    _clockController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();

    _chartController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _barAnimations = List.generate(12, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _chartController,
          curve: Interval(
            index * 0.05,
            0.6 + (index * 0.03),
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _chartController.forward();
    });
  }

  @override
  void dispose() {
    _clockController.stop();
    _clockController.dispose();
    _chartController.dispose();
    _pulseController.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                child: _Calendar(pulseController: _pulseController),
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
                          animation: _clockController,
                          builder: (context, child) => CustomPaint(
                            painter: ClockPainter(
                              animationProgress: _clockController.value,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
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
              child: Column(
                children: [
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      _IconStat(
                        icon: Iconsax.profile_2user,
                        value: '432',
                        label: 'Sunday School',
                        color:  AppTheme.primaryBlue,
                        pulseController: _pulseController,
                      ),
                      _IconStat(
                        icon: Iconsax.heart,
                        value: '98',
                        label: 'Outreach',
                        color: const Color(0xFF16D0A7),
                        pulseController: _pulseController,
                      ),
                      _IconStat(
                        icon: Iconsax.music_play,
                        value: '34',
                        label: 'Choir Members',
                        color: const Color(0xFF0091FF),
                        pulseController: _pulseController,
                      ),
                      _IconStat(
                        icon: Iconsax.receipt_2_1,
                        value: '1021',
                        label: 'Donations',
                        color: const Color(0xFFFEC53D),
                        pulseController: _pulseController,
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
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color:  AppTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '2023',
                                style: TextStyle(
                                  color:  AppTheme.primaryBlue,
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(12, (index) {
                              final baseHeight = (index % 5 + 1) * 25.0 + 30;
                              final isOrange = index % 2 == 0;
                              final color = isOrange ? const Color(0xFFFEC53D) :  AppTheme.primaryBlue;

                              return AnimatedBuilder(
                                animation: _barAnimations[index],
                                builder: (context, child) => Container(
                                  width: 14,
                                  height: baseHeight * _barAnimations[index].value,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        color,
                                        color.withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.vertical(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'October 2023',
              style: TextStyle(
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
              final day = index - 5;
              bool isCurrent = day == 22;
              bool isValid = day > 0 && day <= 31;
              bool isWeekend = (index % 7 == 5 || index % 7 == 6) && isValid;

              return Container(
                decoration: BoxDecoration(
                  gradient: isCurrent
                      ? LinearGradient(
                    colors: [Colors.white, Colors.grey.shade100],
                  )
                      : null,
                  color: isWeekend && !isCurrent
                      ? Colors.white.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isCurrent
                      ? Border.all(color: Colors.white.withOpacity(0.5))
                      : null,
                  boxShadow: isCurrent
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
                      color: isCurrent
                          ? const Color(0xFF16D0A7)
                          : Colors.white,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      fontSize: isCurrent ? 16 : 14,
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
          color: _isHovered ? widget.color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: _isHovered ? Border.all(color: widget.color.withOpacity(0.3)) : null,
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
                      color: _isHovered ? widget.color : Colors.grey.shade800,
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