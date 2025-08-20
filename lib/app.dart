import 'package:flutter/material.dart';
import 'package:genet_church_portal/app_router.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'dart:math' as math;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp.router(
      title: 'Genet Church Portal',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}