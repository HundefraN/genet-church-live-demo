import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gdev_frontend/app_router.dart';
import 'package:gdev_frontend/core/theme/app_theme.dart';
import 'package:gdev_frontend/core/theme/theme_provider.dart';
import 'package:gdev_frontend/shared_widgets/notification_system.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeNotifierProvider);

    if (!kIsWeb) {
      FlutterNativeSplash.remove();
    }

    return MaterialApp.router(
      title: 'Ethiopian Genet church church management',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
      ],
      builder: (context, child) {
        return Material(
          child: Stack(
            children: [
              if (child != null) child,
              const NotificationOverlay(),
            ],
          ),
        );
      },
    );
  }
}