import 'package:flutter/material.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:iconsax/iconsax.dart';

class HeaderBar extends StatelessWidget {
  final List<String> breadcrumbs;
  final bool isMobile;
  final VoidCallback? onMenuPressed;

  const HeaderBar({
    super.key,
    required this.breadcrumbs,
    this.isMobile = false,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final newBoxShadow = [
      BoxShadow(
        color: AppTheme.primaryBlue.withOpacity(0.35),
        blurRadius: 25,
        offset: const Offset(0, 10),
        spreadRadius: -5,
      ),
    ];

    if (isMobile) {
      return SliverAppBar(
        expandedHeight: 180.0,
        floating: true,
        pinned: false,
        snap: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: onMenuPressed != null
            ? IconButton(
          icon: const Icon(Iconsax.menu, color: AppTheme.surfaceWhite),
          onPressed: onMenuPressed,
        )
            : null,
        title: Text(
          breadcrumbs.isNotEmpty ? breadcrumbs.last : 'Dashboard',
          style: const TextStyle(
            color: AppTheme.surfaceWhite,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Iconsax.search_normal_1, color: AppTheme.surfaceWhite, size: 24),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Iconsax.notification,
                    color: AppTheme.surfaceWhite, size: 24),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppTheme.destructiveRed,
                    shape: BoxShape.circle,
                  ),
                  constraints:
                  const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: const Text(
                    '3',
                    style: TextStyle(color: AppTheme.surfaceWhite, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: ClipPath(
            clipper: _HeaderClipper(),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                boxShadow: newBoxShadow,
              ),
            ),
          ),
        ),
      );
    }

    return SliverAppBar(
      expandedHeight: 200.0,
      floating: true,
      snap: false,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(
              clipper: _HeaderClipper(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  boxShadow: newBoxShadow,
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: 50,
              child: Row(
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
                          color: AppTheme.surfaceWhite.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                              color: AppTheme.surfaceWhite.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          style: const TextStyle(color: AppTheme.surfaceWhite),
                          decoration: InputDecoration(
                            hintText: 'Search Records...',
                            hintStyle: TextStyle(
                                color: AppTheme.surfaceWhite.withOpacity(0.8)),
                            prefixIcon: Icon(
                              Iconsax.search_normal_1,
                              color: AppTheme.surfaceWhite.withOpacity(0.8),
                              size: 22,
                            ),
                            filled: false,
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
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
                              color: AppTheme.surfaceWhite.withOpacity(0.2),
                              border: Border.all(
                                  color: AppTheme.surfaceWhite.withOpacity(0.3)),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                  Iconsax.notification,
                                  color: AppTheme.surfaceWhite,
                                  size: 28),
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
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.destructiveRed
                                        .withOpacity(0.5),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                  minWidth: 18, minHeight: 18),
                              child: const Text(
                                '3',
                                style: TextStyle(
                                    color: AppTheme.surfaceWhite,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.transparent,
                          child: Text(
                            "A",
                            style: TextStyle(
                                fontSize: 20,
                                color: AppTheme.surfaceWhite,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Breadcrumbs extends StatelessWidget {
  final List<String> items;
  const _Breadcrumbs({required this.items});

  @override
  Widget build(BuildContext context) {
    String title = items.lastWhere(
            (item) =>
        item.isNotEmpty &&
            item != 'GCD' &&
            item != 'App' &&
            item != 'Layout' &&
            item != 'Grid Layout' &&
            item != 'Report' &&
            item != 'Church' &&
            item != 'Show',
        orElse: () => 'Dashboard');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border:
            Border.all(color: AppTheme.surfaceWhite.withOpacity(0.3)),
          ),
          child: Text(
            title.replaceAll('-', ' '),
            style: const TextStyle(
              color: AppTheme.surfaceWhite,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(items.length, (index) {
            final isLast = index == items.length - 1;
            return Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isLast
                        ? AppTheme.surfaceWhite.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    items[index],
                    style: TextStyle(
                      color: isLast
                          ? AppTheme.surfaceWhite
                          : AppTheme.surfaceWhite.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight:
                      isLast ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      Iconsax.arrow_right_3,
                      color: AppTheme.surfaceWhite.withOpacity(0.7),
                      size: 16,
                    ),
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
    path.lineTo(0, size.height - 30);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height - 20);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 0.75, size.height - 40);
    final secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}