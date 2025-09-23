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
    final isCollapsed = useState(isMobile ? true : false);
    const double headerHeight = 120.0;

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: const SideMenu(isCollapsed: false),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            HeaderBar(
              breadcrumbs: breadcrumbs,
              isMobile: true,
              height: headerHeight,
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
      body: Row(
        children: [
          SideMenu(isCollapsed: isCollapsed.value),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                HeaderBar(
                  breadcrumbs: breadcrumbs,
                  isMobile: false,
                  height: headerHeight,
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
    );
  }
}