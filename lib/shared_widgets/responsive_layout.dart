import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget tabletBody;
  final Widget desktopBody;
  final double mobileBreakpoint;
  final double tabletBreakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    Widget? tabletBody,
    required this.desktopBody,
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 1024,
  }) : tabletBody = tabletBody ?? desktopBody;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              ),
            );
          },
          child: _buildResponsiveChild(constraints.maxWidth),
        );
      },
    );
  }

  Widget _buildResponsiveChild(double width) {
    if (width < mobileBreakpoint) {
      return Container(
        key: const ValueKey('mobile'),
        child: mobileBody,
      );
    } else if (width < tabletBreakpoint) {
      return Container(
        key: const ValueKey('tablet'),
        child: tabletBody,
      );
    } else {
      return Container(
        key: const ValueKey('desktop'),
        child: desktopBody,
      );
    }
  }
}