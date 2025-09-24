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

    Widget buildBody(bool mobile) {
      return Column(
        children: [
          SizedBox(
            height: headerHeight,
            child: CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                HeaderBar(
                  breadcrumbs: breadcrumbs,
                  isMobile: mobile,
                  height: headerHeight,
                  onMenuPressed: () {
                    if (mobile) {
                      _scaffoldKey.currentState?.openDrawer();
                    } else {
                      isCollapsed.value = !isCollapsed.value;
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
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