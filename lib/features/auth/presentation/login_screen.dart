import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BibleVerse {
  final String reference;
  final String text;
  BibleVerse({required this.reference, required this.text});

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      reference: json['reference'] as String,
      text: (json['text'] as String).replaceAll('\n', ' ').trim(),
    );
  }
}

final bibleVerseProvider = FutureProvider.autoDispose<BibleVerse>((ref) async {
  final dio = Dio();
  final response = await dio.get('https://bible-api.com/random');
  return BibleVerse.fromJson(response.data);
});

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;
  const ResponsiveLayout(
      {super.key, required this.mobileBody, required this.desktopBody});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 850) {
          return mobileBody;
        } else {
          return desktopBody;
        }
      },
    );
  }
}

class LoginScreen extends StatefulHookConsumerWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _backgroundController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
        _scaleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _backgroundController.stop();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileBody: _LoginSmallScreenView(
          fadeAnimation: _fadeAnimation,
          slideAnimation: _slideAnimation,
          scaleAnimation: _scaleAnimation,
          backgroundController: _backgroundController,
        ),
        desktopBody: _LoginDesktopView(
          fadeAnimation: _fadeAnimation,
          slideAnimation: _slideAnimation,
          scaleAnimation: _scaleAnimation,
          backgroundController: _backgroundController,
        ),
      ),
    );
  }
}

class _LoginDesktopView extends ConsumerWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> scaleAnimation;
  final AnimationController backgroundController;

  const _LoginDesktopView({
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.scaleAnimation,
    required this.backgroundController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final verseAsync = ref.watch(bibleVerseProvider);

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              gradient: appColors.primaryGradient,
            ),
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: backgroundController,
                  builder: (context, child) => CustomPaint(
                    painter:
                    _ModernBackgroundPainter(backgroundController.value),
                    size: Size.infinite,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        appColors.glass.withOpacity(0.1),
                        appColors.glass.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: fadeAnimation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: size.width * 0.06),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModernLogo(),
                          const SizedBox(height: 60),
                          verseAsync.when(
                            data: (verse) => _VerseDisplay(
                              reference: verse.reference,
                              text: verse.text,
                            ),
                            loading: () => const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white)),
                            error: (e, s) => const _VerseDisplay(
                              reference: 'John 3:16',
                              text:
                              'For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.',
                            ),
                          ),
                          const SizedBox(height: 50),
                          Row(
                            children: [
                              _buildFeatureIndicator('Secure Access'),
                              const SizedBox(width: 20),
                              _buildFeatureIndicator('Admin Portal'),
                              const SizedBox(width: 20),
                              _buildFeatureIndicator('Data Driven Ministry'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            color: appColors.scaffold,
            child: _LoginForm(
              scaleAnimation: scaleAnimation,
              fadeAnimation: fadeAnimation,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withOpacity(0.15),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
          child: Center(
            child:
            Image.asset('assets/images/logo.png', height: 50, width: 50),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIndicator(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _VerseDisplay extends StatelessWidget {
  final String reference;
  final String text;
  final double bookFontSize;
  final double chapterVerseFontSize;
  final double textFontSize;
  final double? boxMaxWidth;
  final EdgeInsets boxPadding;
  final double gapHeight;

  const _VerseDisplay({
    required this.reference,
    required this.text,
    this.bookFontSize = 80,
    this.chapterVerseFontSize = 32,
    this.textFontSize = 18,
    this.boxMaxWidth = 480,
    this.boxPadding = const EdgeInsets.all(32),
    this.gapHeight = 30,
  });

  @override
  Widget build(BuildContext context) {
    final parts = reference.split(RegExp(r'\s(?=\d)'));
    final book = parts.length > 1 ? parts[0] : reference;
    final chapterVerse = parts.length > 1 ? parts[1] : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: max(8.0, bookFontSize * 0.2),
          runSpacing: 8.0,
          children: [
            Text(
              book,
              style: TextStyle(
                fontSize: bookFontSize,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
                letterSpacing: -2,
              ),
            ),
            if (chapterVerse.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: bookFontSize * 0.1),
                child: Text(
                  chapterVerse,
                  style: TextStyle(
                    fontSize: chapterVerseFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.0,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: gapHeight),
        Container(
          constraints: BoxConstraints(
              maxWidth: boxMaxWidth ?? MediaQuery.of(context).size.width),
          padding: boxPadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withOpacity(0.12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Text(
            '"$text"',
            style: TextStyle(
              fontSize: textFontSize,
              color: Colors.white.withOpacity(0.95),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginSmallScreenView extends ConsumerWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> scaleAnimation;
  final AnimationController backgroundController;

  const _LoginSmallScreenView({
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.scaleAnimation,
    required this.backgroundController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final verseAsync = ref.watch(bibleVerseProvider);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    final double headerHeight = max(size.height * 0.45, 380.0);
    final double logoSize = isTablet ? 70.0 : 50.0;
    final double logoIconSize = logoSize * 0.5;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: headerHeight,
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              gradient: appColors.primaryGradient,
            ),
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: backgroundController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter:
                      _ModernBackgroundPainter(backgroundController.value),
                      size: Size.infinite,
                    );
                  },
                ),
                FadeTransition(
                  opacity: fadeAnimation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32.0 : 20.0),
                      child: SafeArea(
                        bottom: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: isTablet ? 24 : 16),
                            Container(
                              width: logoSize,
                              height: logoSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white.withOpacity(0.15),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Center(
                                child: Image.asset('assets/images/logo.png',
                                    height: logoIconSize),
                              ),
                            ),
                            SizedBox(height: isTablet ? 24 : 16),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: verseAsync.when(
                                    data: (verse) => _VerseDisplay(
                                      reference: verse.reference,
                                      text: verse.text,
                                      bookFontSize: isTablet ? 42 : 32,
                                      chapterVerseFontSize:
                                      isTablet ? 24 : 20,
                                      textFontSize: isTablet ? 15 : 13.5,
                                      boxPadding: EdgeInsets.all(
                                          isTablet ? 20 : 16),
                                      boxMaxWidth: size.width * 0.85,
                                      gapHeight: isTablet ? 20 : 12,
                                    ),
                                    loading: () => const Center(
                                      child: SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2)),
                                    ),
                                    error: (e, s) => _VerseDisplay(
                                      reference: 'Ethiopian Genet Church',
                                      text: 'Welcome to the Ministry.',
                                      bookFontSize: isTablet ? 42 : 32,
                                      chapterVerseFontSize: 0,
                                      textFontSize: isTablet ? 15 : 14,
                                      boxPadding: EdgeInsets.all(
                                          isTablet ? 20 : 16),
                                      boxMaxWidth: size.width * 0.85,
                                      gapHeight: 10,
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
                ),
              ],
            ),
          ),
          Container(
            color: appColors.scaffold,
            constraints: BoxConstraints(minHeight: size.height * 0.55),
            padding: EdgeInsets.symmetric(
                vertical: isTablet ? 40 : 24, horizontal: 16),
            child: _LoginForm(
              scaleAnimation: scaleAnimation,
              fadeAnimation: fadeAnimation,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends HookConsumerWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;
  const _LoginForm(
      {required this.scaleAnimation, required this.fadeAnimation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 600;

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);
    final rememberMe = useState(false);
    final isPasswordVisible = useState(false);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final emailFocusNode = useFocusNode();
    final passwordFocusNode = useFocusNode();
    final buttonController = useAnimationController(
      duration: const Duration(milliseconds: 150),
    );
    final buttonScale = useAnimation(
      Tween<double>(begin: 1.0, end: 0.98).animate(
        CurvedAnimation(parent: buttonController, curve: Curves.easeInOut),
      ),
    );

    useEffect(() {
      SharedPreferences.getInstance().then((prefs) {
        final savedEmail = prefs.getString('email');
        if (savedEmail != null) {
          emailController.text = savedEmail;
          rememberMe.value = true;
        }
      });
      return null;
    }, []);

    void submitForm() async {
      if (!(formKey.currentState?.validate() ?? false)) {
        return;
      }
      if (isLoading.value) return;
      isLoading.value = true;
      buttonController.forward();
      try {
        await ref.read(authStateProvider.notifier).login(
          emailController.text,
          passwordController.text,
          rememberMe.value,
        );
        if (context.mounted) {
          context.go('/dashboard');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login Failed: Invalid credentials'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (context.mounted) {
          isLoading.value = false;
          buttonController.reverse();
        }
      }
    }

    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmall ? 8.0 : 32.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Welcome Back',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: appColors.textPrimary,
                          fontSize: isSmall ? 26 : null,
                        )),
                    SizedBox(height: isSmall ? 4 : 8),
                    Text('Sign in to access your portal',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: appColors.textSecondary,
                          fontSize: isSmall ? 14 : null,
                        )),
                    SizedBox(height: isSmall ? 32 : 48),
                    _buildModernTextField(
                      context: context,
                      controller: emailController,
                      focusNode: emailFocusNode,
                      hintText: 'Username or Email',
                      icon: Iconsax.user,
                      isSmall: isSmall,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(passwordFocusNode);
                      },
                    ),
                    SizedBox(height: isSmall ? 16 : 20),
                    _buildModernTextField(
                      context: context,
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      hintText: 'Password',
                      icon: Iconsax.lock_1,
                      isSmall: isSmall,
                      obscureText: !isPasswordVisible.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => submitForm(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible.value
                              ? Iconsax.eye
                              : Iconsax.eye_slash,
                          color: appColors.textSecondary,
                          size: isSmall ? 20 : 24,
                        ),
                        onPressed: () =>
                        isPasswordVisible.value = !isPasswordVisible.value,
                      ),
                    ),
                    SizedBox(height: isSmall ? 16 : 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Transform.scale(
                                scale: isSmall ? 0.8 : 0.9,
                                child: Checkbox(
                                  value: rememberMe.value,
                                  onChanged: (val) =>
                                  rememberMe.value = val ?? false,
                                  activeColor: theme.colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Remember me',
                                style: TextStyle(
                                  fontSize: isSmall ? 13 : 14,
                                  color: appColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                )),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('Forgot password?',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: isSmall ? 13 : 14,
                              )),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmall ? 24 : 32),
                    Transform.scale(
                      scale: buttonScale,
                      child: Container(
                        width: double.infinity,
                        height: isSmall ? 48 : 56,
                        decoration: BoxDecoration(
                          gradient: appColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: submitForm,
                            child: Center(
                              child: isLoading.value
                                  ? SizedBox(
                                height: isSmall ? 20 : 24,
                                width: isSmall ? 20 : 24,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                                  : Text('Sign In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmall ? 15 : 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmall ? 24 : 32),
                    Container(
                      padding: EdgeInsets.all(isSmall ? 12 : 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.message_question,
                              color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Need help? Contact your administrator',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: isSmall ? 13 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required BuildContext context,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    bool isSmall = false,
    Widget? suffixIcon,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
    TextInputAction? textInputAction,
  }) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final borderRadius = BorderRadius.circular(isSmall ? 12 : 16);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: appColors.surface,
        boxShadow: [
          BoxShadow(
            color: appColors.shadow.withOpacity(0.5),
            blurRadius: isSmall ? 10 : 15,
            offset: Offset(0, isSmall ? 2 : 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        textInputAction: textInputAction ?? TextInputAction.done,
        style: TextStyle(
          fontSize: isSmall ? 14 : 16,
          fontWeight: FontWeight.w500,
          color: appColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: appColors.textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: isSmall ? 14 : 16,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(isSmall ? 8 : 12),
            padding: EdgeInsets.all(isSmall ? 6 : 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isSmall ? 6 : 8),
            ),
            child: Icon(icon,
                color: theme.colorScheme.primary, size: isSmall ? 18 : 20),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: appColors.surface,
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: appColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: appColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
              horizontal: isSmall ? 16 : 20, vertical: isSmall ? 16 : 20),
          isDense: isSmall,
        ),
      ),
    );
  }
}

class _ModernBackgroundPainter extends CustomPainter {
  final double animationValue;
  _ModernBackgroundPainter(this.animationValue);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      final path = Path();
      final centerX = size.width * (0.2 + (i * 0.15));
      final centerY =
          size.height * (0.3 + sin(animationValue * 2 * pi + i) * 0.2);
      final radius = 40 + sin(animationValue * pi + i) * 20;
      path.addOval(
          Rect.fromCircle(center: Offset(centerX, centerY), radius: radius));
      canvas.drawPath(path, paint);
    }
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 5; i++) {
      final startX = size.width * (0.1 + i * 0.2);
      final startY = size.height * (0.2 + sin(animationValue * pi + i) * 0.3);
      final endX = size.width * (0.3 + i * 0.2);
      final endY = size.height * (0.8 - sin(animationValue * pi + i) * 0.3);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}