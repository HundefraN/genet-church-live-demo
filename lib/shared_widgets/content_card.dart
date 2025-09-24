import 'package:flutter/material.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';

class ContentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ContentCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}