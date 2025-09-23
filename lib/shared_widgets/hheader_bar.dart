import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:ui';

class HeaderBar extends HookWidget {
  final List<String> breadcrumbs;
  final bool isMobile;
  final double height;
  final VoidCallback? onMenuPressed;

  const HeaderBar({
    super.key,
    required this.breadcrumbs,
    this.isMobile = false,
    this.height = 120.0,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final glintController = useAnimationController(
      duration: const Duration(seconds: 8),
    );

    useEffect(() {
      glintController.repeat();
      return glintController.dispose;
    }, [glintController]);

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: false,
      floating: true,
      stretch: true,
      expandedHeight: height,
      leading: isMobile ? IconButton(
        icon: const Icon(Iconsax.menu, color: AppTheme.textPrimary),
        onPressed: onMenuPressed,
      ) : null,
      title: isMobile ? Text(
        breadcrumbs.isNotEmpty ? breadcrumbs.last : 'Dashboard',
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ) : null,
      actions: isMobile ? [
        IconButton(
          onPressed: () {},
          icon: const Icon(Iconsax.notification, color: AppTheme.textPrimary, size: 24),
        ),
      ] : null,
      flexibleSpace: FlexibleSpaceBar(
        background: ClipPath(
          clipper: _HeaderClipper(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _EtherealHeaderPainter(),
                ),
                AnimatedBuilder(
                  animation: glintController,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: const [Colors.transparent, Colors.white, Colors.transparent],
                          stops: [glintController.value - 0.3, glintController.value, glintController.value + 0.3],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: isMobile ? 0 : 24,
                    left: 32,
                    right: 32,
                    bottom: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.surfaceWhite.withOpacity(0.2), width: 1),
                    ),
                  ),
                  child: isMobile ? null : _buildDesktopContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Breadcrumbs(items: breadcrumbs),
        Row(
          children: [
            Container(
              width: 280,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 3, spreadRadius: -2)],
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search Records...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: Icon(Iconsax.search_normal_1, color: Colors.white.withOpacity(0.7), size: 22),
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 3, spreadRadius: -2)],
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Iconsax.notification, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.destructiveRed,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppTheme.destructiveRed.withOpacity(0.5), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: const Text('3', style: TextStyle(color: AppTheme.surfaceWhite, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                )
              ],
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                border: Border.all(color: AppTheme.surfaceWhite.withOpacity(0.4)),
                boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.transparent,
                child: Text("A", style: TextStyle(fontSize: 20, color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Breadcrumbs extends StatelessWidget {
  final List<String> items;
  const _Breadcrumbs({required this.items});

  @override
  Widget build(BuildContext context) {
    String title = items.lastWhere((item) =>
    item.isNotEmpty && item != 'GCD' && item != 'App' && item != 'Report' && item != 'Church' && item != 'Show',
        orElse: () => 'Dashboard');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.replaceAll('-', ' '),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            shadows: [
              Shadow(color: Colors.white70, blurRadius: 10),
              Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(items.length, (index) {
            final isLast = index == items.length - 1;
            return Row(
              children: [
                Text(
                  items[index],
                  style: TextStyle(
                    color: isLast ? AppTheme.textPrimary : AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Iconsax.arrow_right_3, color: AppTheme.textSecondary, size: 16),
                  )
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.2, size.height - 40, size.width * 0.5, size.height - 20);
    path.quadraticBezierTo(size.width * 0.8, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _EtherealHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final hotspotGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.8, -0.8),
        radius: 0.8,
        colors: [Colors.white.withOpacity(0.15), Colors.transparent],
      ).createShader(rect);
    canvas.drawRect(rect, hotspotGlow);

    final facetPaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final facetPath = Path()
      ..moveTo(size.width * -0.2, 0)
      ..lineTo(size.width * 0.7, size.height * 1.2)
      ..moveTo(0, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.2);
    canvas.drawPath(facetPath, facetPaint);

    final auroraPath = Path();
    auroraPath.moveTo(-50, size.height * 0.8);
    auroraPath.cubicTo(
      size.width * 0.3,
      size.height * 0.4,
      size.width * 0.7,
      size.height * 1.2,
      size.width + 50,
      size.height * 0.6,
    );

    final auroraGlowPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppTheme.accentTeal.withOpacity(0.3), AppTheme.primaryBlue.withOpacity(0.3)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final auroraCorePaint = Paint()
      ..shader = LinearGradient(
        colors: [AppTheme.accentTeal.withOpacity(0.5), AppTheme.primaryBlue.withOpacity(0.5)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawPath(auroraPath, auroraGlowPaint);
    canvas.drawPath(auroraPath, auroraCorePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}