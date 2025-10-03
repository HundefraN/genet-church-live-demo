import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/app.dart';
import 'package:genet_church_portal/core/js_interop.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
  if (kIsWeb) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      hideLoadingIndicator();
    });
  }
}