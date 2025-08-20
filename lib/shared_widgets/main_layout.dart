import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/shared_widgets/side_menu.dart';

import 'hheader_bar.dart';

class MainLayout extends HookWidget {
  final Widget child;
  final List<String> breadcrumbs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  MainLayout({
    super.key,
    required this.child,
    required this.breadcrumbs,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final isCollapsed = useState(false);

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: const SideMenu(isCollapsed: false),
        body: CustomScrollView(
          slivers: [
            HeaderBar(
              breadcrumbs: breadcrumbs,
              isMobile: true,
              onMenuPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _BackgroundPainter(isCollapsed: isCollapsed.value),
            ),
          ),
          Row(
            children: [
              SideMenu(isCollapsed: isCollapsed.value),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    HeaderBar(
                      breadcrumbs: breadcrumbs,
                      isMobile: false,
                      onMenuPressed: () {
                        isCollapsed.value = !isCollapsed.value;
                      },
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final bool isCollapsed;
  _BackgroundPainter({required this.isCollapsed});

  @override
  void paint(Canvas canvas, Size size) {
    final sideMenuPaint = Paint()..color = const Color(0xFFF0F4FF);
    final contentPaint = Paint()..color = const Color(0xFFEAF2FF);
    final sideMenuWidth = isCollapsed ? 100.0 : 260.0;
    final headerHeight = 140.0;

    final sidePath = Path();
    sidePath.moveTo(sideMenuWidth, 0);
    sidePath.lineTo(sideMenuWidth - 100, 0);
    sidePath.cubicTo(
      sideMenuWidth,
      size.height * 0.2,
      sideMenuWidth - 150,
      size.height * 0.8,
      sideMenuWidth,
      size.height,
    );
    sidePath.lineTo(sideMenuWidth, 0);
    canvas.drawPath(sidePath, sideMenuPaint);

    final contentPath = Path();
    contentPath.moveTo(sideMenuWidth, headerHeight);
    contentPath.lineTo(size.width, headerHeight);
    contentPath.lineTo(size.width, size.height * 0.15 + headerHeight);
    contentPath.cubicTo(
      size.width * 0.8,
      size.height * 0.45,
      size.width * 0.5,
      size.height * 0.1 + headerHeight,
      sideMenuWidth,
      size.height * 0.25,
    );
    contentPath.close();
    canvas.drawPath(contentPath, contentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}