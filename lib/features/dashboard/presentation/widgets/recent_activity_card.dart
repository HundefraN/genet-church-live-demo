import 'package:flutter/material.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_theme.dart';

class RecentActivityCard extends StatefulWidget {
  const RecentActivityCard({super.key});

  @override
  State<RecentActivityCard> createState() => _RecentActivityCardState();
}

class _RecentActivityCardState extends State<RecentActivityCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimations = List.generate(4, (index) {
      return Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(
          index * 0.15,
          0.6 + (index * 0.1),
          curve: Curves.elasticOut,
        ),
      ));
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            SlideTransition(
              position: _slideAnimations[0],
              child: const _ActivityItem(
                time: '11:20 AM',
                title: 'New Sermon Series Added',
                subtitle: 'The "Foundations of Faith" series is now available.',
                isLast: false,
                icon: Iconsax.book_1,
                color: AppTheme.primaryBlue,
              ),
            ),
            SlideTransition(
              position: _slideAnimations[1],
              child: const _ActivityItem(
                time: 'Yesterday',
                title: 'Community Outreach Event',
                subtitle: 'Successfully completed the monthly food drive.',
                isLast: false,
                icon: Iconsax.heart,
                color: Color(0xFF16D0A7),
              ),
            ),
            SlideTransition(
              position: _slideAnimations[2],
              child: const _ActivityItem(
                time: '11 Oct 2023',
                title: 'Pastor John Added a Testimony',
                subtitle: 'A new testimony of healing has been shared.',
                isLast: false,
                icon: Iconsax.microphone_2,
                color: Color(0xFF0091FF),
              ),
            ),
            SlideTransition(
              position: _slideAnimations[3],
              child: const _ActivityItem(
                time: 'Last week',
                title: 'Tithe Records Updated',
                subtitle: 'Last Sunday\'s tithe and offering records are complete.',
                isLast: true,
                icon: Iconsax.wallet_3,
                color: Color(0xFFFEC53D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatefulWidget {
  final String time;
  final String title;
  final String subtitle;
  final bool isLast;
  final IconData icon;
  final Color color;

  const _ActivityItem({
    required this.time,
    required this.title,
    required this.subtitle,
    this.isLast = false,
    required this.icon,
    required this.color,
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
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _isHovered ? widget.color.withOpacity(0.05) : Colors.transparent,
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
                        widget.color,
                        widget.color.withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: _isHovered ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
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
                          widget.color.withOpacity(0.5),
                          widget.color.withOpacity(0.1),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.time,
                      style: TextStyle(
                        color: widget.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _isHovered ? widget.color : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
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
                    color: widget.color,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}