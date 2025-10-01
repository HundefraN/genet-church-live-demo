import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/core/theme/theme_provider.dart';
import 'package:genet_church_portal/data/models/search_command_model.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:genet_church_portal/data/services/search_service.dart';
import 'package:genet_church_portal/shared_widgets/search_overlay.dart';
import 'package:genet_church_portal/shared_widgets/side_menu.dart';
import 'package:genet_church_portal/state/church_selection_provider.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:ui';

class HeaderBar extends HookConsumerWidget {
  final List<String> breadcrumbs;
  final VoidCallback? onMenuPressed;
  final bool pinned;
  final bool floating;
  final bool snap;
  final bool stretch;

  const HeaderBar({
    super.key,
    required this.breadcrumbs,
    this.onMenuPressed,
    this.pinned = false,
    this.floating = false,
    this.snap = false,
    this.stretch = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 950;

    return SliverAppBar(
      backgroundColor: appColors.surface.withOpacity(0.85),
      elevation: 0,
      scrolledUnderElevation: 8.0,
      shadowColor: appColors.shadow.withOpacity(0.2),
      surfaceTintColor: Colors.transparent,
      pinned: pinned,
      floating: floating,
      snap: snap,
      stretch: stretch,
      toolbarHeight: 80,
      leadingWidth: isSmallScreen ? 72 : 0,
      leading: isSmallScreen
          ? Center(
        child: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(Iconsax.menu, color: theme.primaryColor),
            onPressed: onMenuPressed,
          ),
        ),
      )
          : const SizedBox.shrink(),
      titleSpacing: 0,
      title: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: 80,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 32,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: appColors.border.withOpacity(0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isSmallScreen) Expanded(child: _Breadcrumbs(items: breadcrumbs)),
                if (isSmallScreen)
                  Text(
                    breadcrumbs.isNotEmpty ? breadcrumbs.last : 'Dashboard',
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.5,
                    ),
                  ),
                const Spacer(),
                _HeaderActions(isSmallScreen: isSmallScreen),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderActions extends ConsumerWidget {
  final bool isSmallScreen;
  const _HeaderActions({required this.isSmallScreen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(userRoleProvider);

    if (isSmallScreen) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentRole == UserRole.superAdmin) const _CompactChurchSelector(),
          const _CompactGlobalSearch(),
          const SizedBox(width: 8),
          const _UserProfileButton(),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentRole == UserRole.superAdmin) ...[
            const ChurchSelector(),
            const SizedBox(width: 16),
          ],
          const SizedBox(width: 200, child: GlobalSearchField()),
          const SizedBox(width: 24),
          const _UserProfileButton(),
        ],
      );
    }
  }
}

class _UserProfileButton extends ConsumerStatefulWidget {
  const _UserProfileButton();

  @override
  ConsumerState<_UserProfileButton> createState() => _UserProfileButtonState();
}

class _UserProfileButtonState extends ConsumerState<_UserProfileButton>
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
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final destructiveRed = theme.colorScheme.error;
    final currentTheme = ref.watch(appThemeNotifierProvider);
    final user = ref.watch(authStateProvider);
    final userInitial =
    user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : '?';
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 950;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'profile') {
                  context.go('/profile');
                } else if (value == 'logout') {
                  ref.read(authStateProvider.notifier).logout();
                  context.go('/login');
                } else if (value == 'light_mode') {
                  ref
                      .read(appThemeNotifierProvider.notifier)
                      .setTheme(ThemeMode.light);
                } else if (value == 'dark_mode') {
                  ref
                      .read(appThemeNotifierProvider.notifier)
                      .setTheme(ThemeMode.dark);
                }
              },
              tooltip: 'Profile Settings',
              offset: const Offset(0, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 16,
              color: appColors.surface,
              shadowColor: appColors.shadow.withOpacity(0.2),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Iconsax.user,
                            color: theme.primaryColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'My Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: appColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'light_mode',
                  child: Row(
                    children: [
                      Icon(Iconsax.sun_1, size: 16, color: appColors.textSecondary),
                      const SizedBox(width: 12),
                      const Text("Light Mode"),
                      const Spacer(),
                      if (currentTheme == ThemeMode.light)
                        Icon(Iconsax.tick_circle,
                            color: theme.primaryColor, size: 20),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'dark_mode',
                  child: Row(
                    children: [
                      Icon(Iconsax.moon, size: 16, color: appColors.textSecondary),
                      const SizedBox(width: 12),
                      const Text("Dark Mode"),
                      const Spacer(),
                      if (currentTheme == ThemeMode.dark)
                        Icon(Iconsax.tick_circle,
                            color: theme.primaryColor, size: 20),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: destructiveRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Iconsax.logout,
                            color: destructiveRed,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: destructiveRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: isCompact
                    ? const EdgeInsets.all(4)
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: _isHovered
                      ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor.withOpacity(0.1),
                      theme.primaryColor.withOpacity(0.05),
                    ],
                  )
                      : null,
                  border: Border.all(
                    color: _isHovered
                        ? theme.primaryColor.withOpacity(0.3)
                        : appColors.border.withOpacity(0.6),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(isCompact ? 12 : 24),
                  boxShadow: _isHovered
                      ? [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: isCompact
                    ? Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      userInitial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          userInitial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? "User",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: appColors.textPrimary,
                              fontSize: 14,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Iconsax.arrow_down_1,
                      size: 16,
                      color: appColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChurchSelector extends ConsumerWidget {
  const ChurchSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final churchesAsync = ref.watch(churchesProvider);
    final selectedChurchId = ref.watch(currentChurchProvider);

    return churchesAsync.when(
      data: (churches) {
        return Container(
          width: 200,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: appColors.scaffold,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: appColors.border.withOpacity(0.6),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedChurchId,
              isExpanded: true,
              hint: Row(
                children: [
                  Icon(Iconsax.building_4, size: 16, color: appColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Select Church',
                    style: TextStyle(
                        color: appColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              icon: Icon(Iconsax.arrow_down_1, color: appColors.textSecondary, size: 18),
              style: TextStyle(color: appColors.textPrimary, fontWeight: FontWeight.w600),
              dropdownColor: appColors.surface,
              borderRadius: BorderRadius.circular(14),
              elevation: 16,
              items: churches.map((church) {
                return DropdownMenuItem<String>(
                  value: church.id,
                  child: Row(
                    children: [
                      Icon(Iconsax.building, size: 14, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          church.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                ref.read(currentChurchProvider.notifier).selectChurch(value);
              },
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class GlobalSearchField extends HookConsumerWidget {
  const GlobalSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final searchFocusNode = useFocusNode();
    final searchController = useTextEditingController();
    final isFocused = useState(false);

    useEffect(() {
      void listener() => isFocused.value = searchFocusNode.hasFocus;
      searchFocusNode.addListener(listener);
      return () => searchFocusNode.removeListener(listener);
    }, [searchFocusNode]);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      decoration: BoxDecoration(
        color: appColors.scaffold,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused.value
              ? theme.primaryColor.withOpacity(0.4)
              : appColors.border.withOpacity(0.6),
          width: isFocused.value ? 1.5 : 1,
        ),
        boxShadow: isFocused.value
            ? [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ]
            : null,
      ),
      child: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        onTap: () => _showSearchDialog(context, ref),
        readOnly: true,
        style: TextStyle(color: appColors.textPrimary, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search actions...',
          hintStyle:
          TextStyle(color: appColors.textSecondary, fontWeight: FontWeight.w500),
          prefixIcon: Icon(
            Iconsax.search_normal_1,
            color: isFocused.value ? theme.primaryColor : appColors.textSecondary,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _CompactGlobalSearch extends StatelessWidget {
  const _CompactGlobalSearch();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return IconButton(
        icon: const Icon(Iconsax.search_normal_1),
        onPressed: () => _showSearchDialog(context, ref),
        tooltip: 'Search',
      );
    });
  }
}

class _CompactChurchSelector extends ConsumerWidget {
  const _CompactChurchSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchesAsync = ref.watch(churchesProvider);
    return churchesAsync.maybeWhen(
      data: (churches) => PopupMenuButton<String>(
        icon: const Icon(Iconsax.building_4),
        tooltip: 'Select Church',
        onSelected: (value) {
          ref.read(currentChurchProvider.notifier).selectChurch(value);
        },
        itemBuilder: (context) => churches.map((church) {
          return PopupMenuItem(value: church.id, child: Text(church.name));
        }).toList(),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

void _showSearchDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => const _SearchDialog(),
  );
}

class _SearchDialog extends HookConsumerWidget {
  const _SearchDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final searchResults = ref.watch(searchResultsProvider);
    final currentRole = ref.watch(userRoleProvider);

    useEffect(() {
      Future.microtask(() => searchFocusNode.requestFocus());
      return null;
    }, []);

    void runSearch(String query) {
      ref.read(searchQueryProvider.notifier).state = query;
      if (query.isEmpty) {
        ref.read(searchResultsProvider.notifier).state = [];
      } else {
        final allCommands =
        ref.read(searchServiceProvider).getCommandsForRole(currentRole);
        final results = allCommands
            .where((cmd) => cmd.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
        ref.read(searchResultsProvider.notifier).state = results;
      }
    }

    void handleCommandSelection(SearchCommand command) {
      context.go(command.path);
      Navigator.of(context).pop();
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                onChanged: runSearch,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search actions or pages...',
                  prefixIcon: const Icon(Iconsax.search_normal_1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            Expanded(
              child: searchResults.isEmpty && searchController.text.isNotEmpty
                  ? const Center(child: Text('No results found.'))
                  : ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final command = searchResults[index];
                  return ListTile(
                    leading: Icon(command.icon),
                    title: Text(command.title),
                    onTap: () => handleCommandSelection(command),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Breadcrumbs extends StatelessWidget {
  final List<String> items;
  const _Breadcrumbs({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isCompact = screenWidth < 1200;

    String title = items.lastWhere((item) => item.isNotEmpty, orElse: () => 'Dashboard');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.replaceAll('-', ' '),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: appColors.textPrimary,
            letterSpacing: -0.5,
            fontSize: isCompact ? 20 : 24,
          ),
        ),
        if (!isCompact) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: appColors.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: appColors.border.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(items.length, (index) {
                  final isLast = index == items.length - 1;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (index == 0)
                        Icon(Iconsax.home, size: 14, color: appColors.textSecondary),
                      if (index == 0) const SizedBox(width: 8),
                      Text(
                        items[index],
                        style: TextStyle(
                          color: isLast ? theme.primaryColor : appColors.textSecondary,
                          fontSize: 13,
                          fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      if (!isLast) ...[
                        const SizedBox(width: 8),
                        Icon(Iconsax.arrow_right_3, color: appColors.textSecondary, size: 14),
                        const SizedBox(width: 8),
                      ],
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ],
    );
  }
}