import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/shared_widgets/side_menu.dart';
import 'header_bar.dart';

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
    const double headerHeight = 130.0;

    Widget buildBody(bool mobile) {
      return CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          HeaderBar(
            breadcrumbs: breadcrumbs,

            onMenuPressed: () {
              if (mobile) {
                _scaffoldKey.currentState?.openDrawer();
              } else {
                isCollapsed.value = !isCollapsed.value;
              }
            },
            pinned: false,
            floating: true,
            snap: true,
            stretch: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(mobile ? 16.0 : 32.0),
              child: child,
            ),
          ),
        ],
      );
    }

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: const SideMenu(isCollapsed: false),
        body: buildBody(true),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          SideMenu(isCollapsed: isCollapsed.value),
          Expanded(child: buildBody(false)),
        ],
      ),
    );
  }
}