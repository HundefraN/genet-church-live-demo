import 'package:flutter/material.dart';
import 'package:gdev_frontend/shared_widgets/modern_loading.dart';

typedef LibraryLoader = Future<void> Function();

class DeferredLoader extends StatefulWidget {
  final LibraryLoader loader;
  final WidgetBuilder builder;
  final Widget? placeholder;

  const DeferredLoader({
    super.key,
    required this.loader,
    required this.builder,
    this.placeholder,
  });

  @override
  State<DeferredLoader> createState() => _DeferredLoaderState();
}

class _DeferredLoaderState extends State<DeferredLoader> {
  late Future<void> _libraryFuture;

  @override
  void initState() {
    super.initState();
    _libraryFuture = widget.loader();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _libraryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return widget.builder(context);
        }
        return widget.placeholder ?? const Scaffold(body: Center(child: ModernLoading()));
      },
    );
  }
}
