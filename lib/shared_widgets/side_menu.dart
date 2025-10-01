import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

enum UserRole {
  superAdmin,
  pastor,
  servant,
  servantSupporter,
}

final userRoleProvider = StateProvider<UserRole>((ref) => UserRole.superAdmin);

class SideMenu extends ConsumerWidget {
  final bool isCollapsed;
  const SideMenu({super.key, required this.isCollapsed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final currentRole = ref.watch(userRoleProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubicEmphasized,
      width: isCollapsed ? 85 : 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appColors.surface,
            appColors.surface.withOpacity(0.8),
            appColors.surface,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border(
          right: BorderSide(
            color: appColors.border.withOpacity(0.6),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(8, 0),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.02),
            blurRadius: 64,
            offset: const Offset(16, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Column(
            children: [
              _Header(isCollapsed: isCollapsed),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 32,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          _buildMenuItemsForRole(
                              currentRole, context, isCollapsed),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _RoleSwitcher(isCollapsed: isCollapsed),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideX(
      begin: -1,
      duration: 600.ms,
      curve: Curves.easeInOutCubicEmphasized,
    )
        .fadeIn(duration: 400.ms, delay: 100.ms);
  }

  List<Widget> _buildMenuItemsForRole(
      UserRole role, BuildContext context, bool collapsed) {
    final currentRoute =
    GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    List<Widget> menuItems = [];

    Widget addSection(Widget item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: item,
      );
    }

    menuItems.add(addSection(_MenuItem(
      title: 'Dashboard',
      icon: Iconsax.category,
      isSelected: currentRoute.startsWith('/dashboard'),
      onTap: () => context.go('/dashboard'),
      isCollapsed: collapsed,
    )));

    if (role == UserRole.superAdmin) {
      menuItems.add(addSection(_ExpansionMenuItem(
        title: 'Church Admin',
        icon: Iconsax.building_4,
        isCollapsed: collapsed,
        children: {
          'Churches': '/report-churchs',
          'Pastors': '/report-pastors',
          'Departments': '/report-departments',
          'Servants': '/report-servants',
        },
      )));
    }

    if (role == UserRole.superAdmin ||
        role == UserRole.pastor ||
        role == UserRole.servant) {
      menuItems.add(addSection(_ExpansionMenuItem(
        title: 'Members',
        icon: Iconsax.people,
        isCollapsed: collapsed,
        children: {
          'Add Member': '/add-members',
          'Show Members': '/show-members',
        },
      )));
    }

    if (role == UserRole.servantSupporter) {
      menuItems.add(addSection(_MenuItem(
        title: 'Show Members',
        icon: Iconsax.people,
        isSelected: currentRoute.startsWith('/show-members'),
        onTap: () => context.go('/show-members'),
        isCollapsed: collapsed,
      )));
    }

    if (role == UserRole.superAdmin) {
      menuItems.add(addSection(_MenuItem(
        title: 'Analytics',
        icon: Iconsax.chart_21,
        isSelected: currentRoute.startsWith('/advanced-reports'),
        onTap: () => context.go('/advanced-reports'),
        isCollapsed: collapsed,
      )));
    }

    if (role == UserRole.pastor) {
      menuItems.add(addSection(_MenuItem(
        title: 'Categories',
        icon: Iconsax.folder_2,
        isSelected: currentRoute.startsWith('/categories'),
        onTap: () => context.go('/categories'),
        isCollapsed: collapsed,
      )));
    }

    if (role == UserRole.superAdmin) {
      menuItems.add(addSection(_MenuItem(
        title: 'Permissions',
        icon: Iconsax.shield_tick,
        isSelected: currentRoute.startsWith('/permissions'),
        onTap: () => context.go('/permissions'),
        isCollapsed: collapsed,
      )));
    }

    return menuItems;
  }
}

class _Header extends StatelessWidget {
  final bool isCollapsed;
  const _Header({required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubicEmphasized,
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            appColors.surface,
            appColors.surface.withOpacity(0.95),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: appColors.border.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Center(
        child: isCollapsed
            ? Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Image.asset(
            'assets/images/logo.png',
            height: 40,
          ),
        )
            .animate()
            .scale(
          begin: const Offset(0.8, 0.8),
          duration: 300.ms,
          delay: 200.ms,
          curve: Curves.easeOutBack,
        )
            .fadeIn(delay: 150.ms)
            : Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Image.asset('assets/images/logo.png', height: 44),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ethiopian Genet Church',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: appColors.textPrimary,
                      letterSpacing: -0.5,
                      height: 1.0,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Church Management',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
            .animate()
            .slideX(
          begin: -0.3,
          duration: 400.ms,
          delay: 200.ms,
          curve: Curves.easeOutCubic,
        )
            .fadeIn(delay: 150.ms),
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCollapsed;

  const _MenuItem({
    required this.title,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
    this.isCollapsed = false,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;

    return Tooltip(
      message: widget.isCollapsed ? widget.title : '',
      waitDuration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColors.border),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      textStyle: TextStyle(
        color: appColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            _animationController.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _animationController.reverse();
          },
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubicEmphasized,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: widget.isSelected
                              ? LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              theme.primaryColor.withOpacity(0.15),
                              theme.primaryColor.withOpacity(0.08),
                              theme.primaryColor.withOpacity(0.05),
                            ],
                          )
                              : _isHovered
                              ? LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              theme.primaryColor.withOpacity(0.08),
                              theme.primaryColor.withOpacity(0.04),
                              Colors.transparent,
                            ],
                          )
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          border: widget.isSelected
                              ? Border.all(
                            color: theme.primaryColor.withOpacity(0.2),
                            width: 1,
                          )
                              : _isHovered
                              ? Border.all(
                            color:
                            theme.primaryColor.withOpacity(0.1),
                            width: 1,
                          )
                              : null,
                          boxShadow: widget.isSelected
                              ? [
                            BoxShadow(
                              color:
                              theme.primaryColor.withOpacity(0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color:
                              theme.primaryColor.withOpacity(0.05),
                              blurRadius: 32,
                              offset: const Offset(0, 8),
                            ),
                          ]
                              : _isHovered
                              ? [
                            BoxShadow(
                              color: theme.primaryColor
                                  .withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ]
                              : null,
                        ),
                      ),
                      if (widget.isSelected)
                        Positioned(
                          left: 0,
                          top: 12,
                          bottom: 12,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  theme.primaryColor,
                                  theme.primaryColor.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(2, 0),
                                ),
                              ],
                            ),
                          ),
                        ).animate().scaleY(
                          begin: 0.5,
                          duration: 300.ms,
                          curve: Curves.easeOutBack,
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.isCollapsed ? 18 : 20,
                        ),
                        child: Row(
                          mainAxisAlignment: widget.isCollapsed
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: widget.isSelected
                                    ? theme.primaryColor.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                widget.icon,
                                size: 22,
                                color: widget.isSelected
                                    ? theme.primaryColor
                                    : _isHovered
                                    ? theme.primaryColor.withOpacity(0.8)
                                    : appColors.textSecondary,
                              ),
                            ),
                            if (!widget.isCollapsed) ...[
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: widget.isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: widget.isSelected
                                        ? theme.primaryColor
                                        : _isHovered
                                        ? appColors.textPrimary
                                        : appColors.textSecondary,
                                    letterSpacing: widget.isSelected ? -0.2 : 0,
                                  ),
                                ),
                              ),
                              if (widget.isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Iconsax.arrow_right_3,
                                    size: 14,
                                    color: theme.primaryColor,
                                  ),
                                ).animate().scale(
                                  begin: const Offset(0.8, 0.8),
                                  duration: 200.ms,
                                  delay: 100.ms,
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpansionMenuItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isCollapsed;
  final Map<String, String> children;

  const _ExpansionMenuItem({
    required this.title,
    required this.icon,
    required this.isCollapsed,
    required this.children,
  });

  @override
  State<_ExpansionMenuItem> createState() => _ExpansionMenuItemState();
}

class _ExpansionMenuItemState extends State<_ExpansionMenuItem>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final currentRoute =
    GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    final bool isExpanded =
    widget.children.values.any((route) => currentRoute.startsWith(route));

    if (widget.isCollapsed) {
      return Tooltip(
        message: widget.title,
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: appColors.border),
          boxShadow: [
            BoxShadow(
              color: appColors.shadow.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: PopupMenuButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 16,
          color: appColors.surface,
          shadowColor: appColors.shadow.withOpacity(0.2),
          itemBuilder: (context) {
            return widget.children.entries.map((entry) {
              return PopupMenuItem(
                value: entry.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.arrow_right_3,
                        size: 16,
                        color: appColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: appColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList();
          },
          onSelected: (path) => context.go(path),
          child: MouseRegion(
            onEnter: (_) {
              setState(() => _isHovered = true);
              _hoverController.forward();
            },
            onExit: (_) {
              setState(() => _isHovered = false);
              _hoverController.reverse();
            },
            child: AnimatedBuilder(
              animation: _hoverController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _hoverAnimation.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubicEmphasized,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: isExpanded
                            ? LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            theme.primaryColor.withOpacity(0.15),
                            theme.primaryColor.withOpacity(0.05),
                          ],
                        )
                            : _isHovered
                            ? LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            theme.primaryColor.withOpacity(0.08),
                            Colors.transparent,
                          ],
                        )
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        border: isExpanded
                            ? Border.all(
                          color: theme.primaryColor.withOpacity(0.2),
                          width: 1,
                        )
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          widget.icon,
                          size: 22,
                          color: isExpanded
                              ? theme.primaryColor
                              : _isHovered
                              ? theme.primaryColor.withOpacity(0.8)
                              : appColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _hoverController.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _hoverController.reverse();
        },
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: _hoverAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: isExpanded
                      ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      theme.primaryColor.withOpacity(0.1),
                      theme.primaryColor.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  )
                      : _isHovered
                      ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      theme.primaryColor.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  )
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  border: isExpanded
                      ? Border.all(
                    color: theme.primaryColor.withOpacity(0.15),
                    width: 1,
                  )
                      : null,
                ),
                child: Theme(
                  data: theme.copyWith(
                    dividerColor: Colors.transparent,
                    expansionTileTheme: ExpansionTileThemeData(
                      backgroundColor: Colors.transparent,
                      collapsedBackgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: isExpanded,
                    leading: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? theme.primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 22,
                        color: isExpanded
                            ? theme.primaryColor
                            : _isHovered
                            ? theme.primaryColor.withOpacity(0.8)
                            : appColors.textSecondary,
                      ),
                    ),
                    title: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                        isExpanded ? FontWeight.w700 : FontWeight.w500,
                        color: isExpanded
                            ? theme.primaryColor
                            : _isHovered
                            ? appColors.textPrimary
                            : appColors.textSecondary,
                        letterSpacing: isExpanded ? -0.2 : 0,
                      ),
                    ),
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                    childrenPadding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 12,
                      top: 8,
                    ),
                    trailing: Icon(
                      isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_2,
                      size: 18,
                      color: isExpanded
                          ? theme.primaryColor
                          : appColors.textSecondary,
                    ),
                    children: widget.children.entries.map((entry) {
                      final isSelected = currentRoute.startsWith(entry.value);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _MenuItem(
                          title: entry.key,
                          icon: Iconsax.arrow_right_3,
                          isCollapsed: false,
                          isSelected: isSelected,
                          onTap: () => context.go(entry.value),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoleSwitcher extends ConsumerStatefulWidget {
  final bool isCollapsed;
  const _RoleSwitcher({required this.isCollapsed});

  @override
  ConsumerState<_RoleSwitcher> createState() => _RoleSwitcherState();
}

class _RoleSwitcherState extends ConsumerState<_RoleSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCollapsed) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final currentRole = ref.watch(userRoleProvider);

    return MouseRegion(
      onEnter: (_) => _animationController.forward(),
      onExit: (_) => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    appColors.scaffold,
                    appColors.scaffold.withOpacity(0.8),
                    appColors.surface,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: appColors.border.withOpacity(0.6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: appColors.shadow.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.03),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Iconsax.user_tag,
                          size: 16,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "CURRENT ROLE",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: appColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<UserRole>(
                        value: currentRole,
                        isExpanded: true,
                        icon: Icon(
                          Iconsax.arrow_down_1,
                          color: theme.primaryColor,
                          size: 18,
                        ),
                        style: TextStyle(
                          color: appColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        dropdownColor: appColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        items: UserRole.values.map((UserRole role) {
                          final roleName = role
                              .toString()
                              .split('.')
                              .last
                              .replaceAllMapped(
                            RegExp(r'[A-Z]'),
                                (match) => ' ${match.group(0)}',
                          )
                              .trim();

                          return DropdownMenuItem<UserRole>(
                            value: role,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color:
                                      theme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getRoleIcon(role),
                                      size: 16,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    roleName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: appColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (UserRole? newRole) {
                          if (newRole != null) {
                            ref.read(userRoleProvider.notifier).state =
                                newRole;
                            const initialRoute = '/dashboard';
                            if (GoRouter.of(context)
                                .routerDelegate
                                .currentConfiguration
                                .uri
                                .toString() !=
                                initialRoute) {
                              Future.microtask(() => context.go(initialRoute));
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Iconsax.crown_1;
      case UserRole.pastor:
        return Iconsax.book_1;
      case UserRole.servant:
        return Iconsax.user_octagon;
      case UserRole.servantSupporter:
        return Iconsax.user;
    }
  }
}