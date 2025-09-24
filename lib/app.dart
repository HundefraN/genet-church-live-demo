import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/app_router.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Genet Church Portal',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router(ref),
    );
  }
}