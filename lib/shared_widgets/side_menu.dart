import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
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
    final currentRole = ref.watch(userRoleProvider);
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: isCollapsed ? 85 : 320,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(8, 0),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _EtherealAuroraPainter(
                      primary: theme.primaryColor,
                      secondary: theme.colorScheme.secondary,
                    ),
                  ),
                ),
                Column(
                  children: [
                    _buildModernHeader(isCollapsed),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 16),
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [..._buildMenuItemsForRole(currentRole, context, isCollapsed)],
                        ),
                      ),
                    ),
                    if (!isCollapsed) _buildModernRoleSwitcher(context, ref),
                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideX(begin: -1, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  // ... (All other _build methods remain the same as the previous correct version)
  Widget _buildModernHeader(bool collapsed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      height: collapsed ? 85 : 170,
      padding: EdgeInsets.symmetric(
        horizontal: collapsed ? 12 : 24,
        vertical: collapsed ? 16 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.surfaceWhite.withOpacity(0.2),
            AppTheme.surfaceWhite.withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.surfaceWhite.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!collapsed) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.surfaceWhite.withOpacity(0.3),
                    AppTheme.surfaceWhite.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.surfaceWhite.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 45,
                width: 45,
              ),
            )
                .animate()
                .scale(delay: 200.ms, duration: 600.ms)
                .shimmer(delay: 400.ms, duration: 1000.ms),
            const SizedBox(height: 16),
            Text(
              "Genet Church Portal",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.surfaceWhite,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, delay: 400.ms, duration: 600.ms),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.surfaceWhite.withOpacity(0.3),
                    AppTheme.surfaceWhite.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.surfaceWhite.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 32,
                width: 32,
              ),
            )
                .animate()
                .scale(delay: 200.ms, duration: 400.ms)
                .shimmer(delay: 400.ms, duration: 800.ms),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildMenuItemsForRole(
      UserRole role, BuildContext context, bool collapsed) {
    final currentRoute =
    GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();

    switch (role) {
      case UserRole.superAdmin:
        return _buildSuperAdminMenu(context, currentRoute, collapsed);
      case UserRole.pastor:
        return _buildPastorMenu(context, currentRoute, collapsed);
      case UserRole.servant:
      case UserRole.servantSupporter:
        return _buildServantMenu(context, currentRoute, role, collapsed);
    }
  }

  List<Widget> _buildSuperAdminMenu(
      BuildContext context, String currentRoute, bool collapsed) {
    return [
      const SizedBox(height: 16),
      _buildModernMenuItem(
        title: 'Dashboard',
        icon: Iconsax.category,
        isSelected: currentRoute.startsWith('/dashboard'),
        onTap: () => context.go('/dashboard'),
        isCollapsed: collapsed,
      ),
      const SizedBox(height: 12),
      _buildModernExpansionTile(
        context,
        currentRoute,
        'Church Admin',
        Iconsax.building_4,
        {
          'Add Church': '/add-church',
          'Add Pastors': '/add-pastors',
          'Permissions': '/permissions',
        },
        collapsed,
      ),
      const SizedBox(height: 12),
      _buildModernExpansionTile(
        context,
        currentRoute,
        'Reports',
        Iconsax.status_up,
        {
          'Church Reports': '/report-churchs',
          'Pastor Reports': '/report-pastors',
        },
        collapsed,
      ),
      const SizedBox(height: 12),
      _buildModernMenuItem(
        title: 'Analytics',
        icon: Iconsax.chart_21,
        isSelected: currentRoute.startsWith('/advanced-reports'),
        onTap: () => context.go('/advanced-reports'),
        isCollapsed: collapsed,
      ),
      const SizedBox(height: 12),
      _buildModernMenuItem(
        title: 'Communication',
        icon: Iconsax.send_1,
        isSelected: currentRoute.startsWith('/communication-hub'),
        onTap: () => context.go('/communication-hub'),
        isCollapsed: collapsed,
      ),
    ];
  }

  List<Widget> _buildPastorMenu(
      BuildContext context, String currentRoute, bool collapsed) {
    return [
      const SizedBox(height: 16),
      _buildModernMenuItem(
        title: 'Dashboard',
        icon: Iconsax.category,
        isSelected: currentRoute.startsWith('/dashboard'),
        onTap: () => context.go('/dashboard'),
        isCollapsed: collapsed,
      ),
      const SizedBox(height: 12),
      _buildModernExpansionTile(
        context,
        currentRoute,
        'Church\'s',
        Iconsax.people,
        {
          'Add Members': '/add-members',
          'Show Members': '/show-members',
          'Categories': '/categories',
        },
        collapsed,
      ),
      const SizedBox(height: 12),
      _buildModernExpansionTile(
        context,
        currentRoute,
        'Report',
        Iconsax.document_text,
        {
          'Report Members': '/show-members',
        },
        collapsed,
      ),
      const SizedBox(height: 12),
      _buildModernMenuItem(
        title: 'Communication',
        icon: Iconsax.send_1,
        isSelected: currentRoute.startsWith('/communication-hub'),
        onTap: () => context.go('/communication-hub'),
        isCollapsed: collapsed,
      ),
    ];
  }

  List<Widget> _buildServantMenu(
      BuildContext context, String currentRoute, UserRole role, bool collapsed) {
    String title =
    role == UserRole.servant ? 'Servant' : 'Servant Supporter';
    return [
      const SizedBox(height: 16),
      _buildModernMenuItem(
        title: 'Dashboard',
        icon: Iconsax.category,
        isSelected: currentRoute.startsWith('/dashboard'),
        onTap: () => context.go('/dashboard'),
        isCollapsed: collapsed,
      ),
      const SizedBox(height: 12),
      _buildModernExpansionTile(
        context,
        currentRoute,
        title,
        Iconsax.lifebuoy,
        {
          'Add Members': '/add-members',
          'Show Members': '/show-members',
        },
        collapsed,
      ),
    ];
  }

  Widget _buildModernMenuItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isCollapsed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
          colors: [
            AppTheme.surfaceWhite.withOpacity(0.3),
            AppTheme.surfaceWhite.withOpacity(0.1),
          ],
        )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppTheme.surfaceWhite.withOpacity(0.4)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: AppTheme.surfaceWhite.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.all(isCollapsed ? 16 : 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [
                            AppTheme.surfaceWhite.withOpacity(0.4),
                            AppTheme.surfaceWhite.withOpacity(0.2)
                          ]
                              : [
                            AppTheme.surfaceWhite.withOpacity(0.2),
                            AppTheme.surfaceWhite.withOpacity(0.1)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.surfaceWhite.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: AppTheme.surfaceWhite,
                        size: 22,
                      ),
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: AppTheme.surfaceWhite,
                            fontSize: 15,
                            fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.surfaceWhite.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernExpansionTile(
      BuildContext context,
      String currentRoute,
      String title,
      IconData icon,
      Map<String, String> children,
      bool collapsed,
      ) {
    final bool isExpanded =
    children.values.any((route) => currentRoute.startsWith(route));

    if (collapsed) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          gradient: isExpanded
              ? LinearGradient(
            colors: [
              AppTheme.surfaceWhite.withOpacity(0.3),
              AppTheme.surfaceWhite.withOpacity(0.1),
            ],
          )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? AppTheme.surfaceWhite.withOpacity(0.4)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: PopupMenuButton(
              tooltip: title,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: AppTheme.primaryBlue.withOpacity(0.95),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.surfaceWhite.withOpacity(0.3),
                        AppTheme.surfaceWhite.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.surfaceWhite.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.surfaceWhite,
                    size: 22,
                  ),
                ),
              ),
              itemBuilder: (context) => children.entries.map((entry) {
                return PopupMenuItem(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: AppTheme.surfaceWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => context.go(entry.value),
                );
              }).toList(),
            ),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: isExpanded
            ? LinearGradient(
          colors: [
            AppTheme.surfaceWhite.withOpacity(0.2),
            AppTheme.surfaceWhite.withOpacity(0.05),
          ],
        )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? AppTheme.surfaceWhite.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              expansionTileTheme: const ExpansionTileThemeData(
                iconColor: AppTheme.surfaceWhite,
                collapsedIconColor: AppTheme.surfaceWhite,
              ),
            ),
            child: ExpansionTile(
              initiallyExpanded: isExpanded,
              tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.surfaceWhite.withOpacity(0.3),
                      AppTheme.surfaceWhite.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.surfaceWhite.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.surfaceWhite,
                  size: 20,
                ),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.surfaceWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              trailing: Icon(
                isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                color: AppTheme.surfaceWhite,
              ),
              childrenPadding:
              const EdgeInsets.only(left: 24, right: 16, bottom: 12),
              children: children.entries.map((entry) {
                final isSelected = currentRoute.startsWith(entry.value);
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                      colors: [
                        AppTheme.surfaceWhite.withOpacity(0.25),
                        AppTheme.surfaceWhite.withOpacity(0.1),
                      ],
                    )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.surfaceWhite.withOpacity(0.3)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.go(entry.value),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.surfaceWhite
                                    : AppTheme.surfaceWhite.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  color: AppTheme.surfaceWhite,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernRoleSwitcher(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(userRoleProvider);
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceWhite.withOpacity(0.2),
            AppTheme.surfaceWhite.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.surfaceWhite.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.surfaceWhite.withOpacity(0.3),
                            AppTheme.surfaceWhite.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.surfaceWhite.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Iconsax.shield_tick,
                        size: 18,
                        color: AppTheme.surfaceWhite,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "ROLE SWITCHER",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.surfaceWhite.withOpacity(0.9),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.surfaceWhite.withOpacity(0.2),
                        AppTheme.surfaceWhite.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.surfaceWhite.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<UserRole>(
                            value: currentRole,
                            isExpanded: true,
                            icon: Icon(
                              Iconsax.arrow_down_1,
                              color: AppTheme.surfaceWhite.withOpacity(0.8),
                            ),
                            dropdownColor: AppTheme.primaryBlue.withOpacity(0.95),
                            items: UserRole.values.map((UserRole role) {
                              return DropdownMenuItem<UserRole>(
                                value: role,
                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    role
                                        .toString()
                                        .split('.')
                                        .last
                                        .replaceAllMapped(
                                      RegExp(r'[A-Z]'),
                                          (match) => ' ${match.group(0)}',
                                    )
                                        .trim(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppTheme.surfaceWhite,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (UserRole? newRole) {
                              if (newRole != null) {
                                ref.read(userRoleProvider.notifier).state =
                                    newRole;
                                String initialRoute = '/dashboard';
                                if (GoRouter.of(context)
                                    .routerDelegate
                                    .currentConfiguration
                                    .uri
                                    .toString() !=
                                    initialRoute) {
                                  Future.microtask(
                                          () => context.go(initialRoute));
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EtherealAuroraPainter extends CustomPainter {
  final Color primary;
  final Color secondary;

  _EtherealAuroraPainter({required this.primary, required this.secondary});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final softGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-1.5, -0.5),
        radius: 1.0,
        colors: [secondary.withOpacity(0.15), Colors.transparent],
      ).createShader(rect);
    canvas.drawRect(rect, softGlow);

    final hotspotGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.8, -0.8),
        radius: 0.8,
        colors: [Colors.white.withOpacity(0.2), Colors.transparent],
      ).createShader(rect);
    canvas.drawRect(rect, hotspotGlow);

    final facetPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final facetPath = Path()
      ..moveTo(size.width * -0.2, size.height * 0.1)
      ..lineTo(size.width * 0.7, size.height * 1.1)
      ..moveTo(size.width * 0.1, size.height * -0.1)
      ..lineTo(size.width * 1.1, size.height * 0.9);
    canvas.drawPath(facetPath, facetPaint);

    final auroraPath = Path();
    auroraPath.moveTo(size.width * 0.2, -50);
    auroraPath.cubicTo(
      size.width * 1.2,
      size.height * 0.3,
      size.width * -0.2,
      size.height * 0.6,
      size.width * 0.8,
      size.height + 50,
    );

    final auroraGradient = LinearGradient(
      colors: [secondary.withOpacity(0.6), primary.withOpacity(0.6)],
    ).createShader(rect);

    final auroraGlowPaint = Paint()
      ..shader = auroraGradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    final auroraCorePaint = Paint()
      ..shader = auroraGradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final auroraThreadPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawPath(auroraPath, auroraGlowPaint);
    canvas.drawPath(auroraPath, auroraCorePaint);
    canvas.drawPath(auroraPath, auroraThreadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}