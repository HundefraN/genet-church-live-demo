import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;
  const ResponsiveLayout(
      {super.key, required this.mobileBody, required this.desktopBody});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
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
  late final Map<String, String> _randomAnnouncement;
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
    _randomAnnouncement = _getRandomAnnouncement();

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
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
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

  Map<String, String> _getRandomAnnouncement() {
    final announcements = [
      {
        'title': 'Sunday\nService',
        'subtitle':
        'Join us this Sunday at 10:00 AM for a special sermon series on Faith and Community. All are welcome to worship together.',
      },
      {
        'title': 'Youth\nConference',
        'subtitle':
        'Our annual youth conference is approaching next month. Registration is now open through the church office.',
      },
      {
        'title': 'Community\nOutreach',
        'subtitle':
        'Monthly food drive happening this Saturday. Thank you for your continued generosity and community support.',
      },
      {
        'title': 'Bible\nStudy',
        'subtitle':
        'New weekly Bible study on the Book of John begins this Wednesday evening at 7:00 PM. Everyone welcome.',
      }
    ];
    return announcements[Random().nextInt(announcements.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileBody: _LoginMobileView(
          randomAnnouncement: _randomAnnouncement,
          fadeAnimation: _fadeAnimation,
          slideAnimation: _slideAnimation,
          scaleAnimation: _scaleAnimation,
          backgroundController: _backgroundController,
        ),
        desktopBody: _LoginDesktopView(
          randomAnnouncement: _randomAnnouncement,
          fadeAnimation: _fadeAnimation,
          slideAnimation: _slideAnimation,
          scaleAnimation: _scaleAnimation,
          backgroundController: _backgroundController,
        ),
      ),
    );
  }
}

class _LoginDesktopView extends StatelessWidget {
  final Map<String, String> randomAnnouncement;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> scaleAnimation;
  final AnimationController backgroundController;

  const _LoginDesktopView({
    required this.randomAnnouncement,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.scaleAnimation,
    required this.backgroundController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4FADE3),
                  Color(0xFF2A8BC4),
                ],
              ),
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
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Text(
                              'GENET CHURCH PORTAL',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            randomAnnouncement['title']!,
                            style: const TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 0.9,
                              letterSpacing: -4,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 480),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white.withOpacity(0.12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Text(
                              randomAnnouncement['subtitle']!,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.95),
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                              ),
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
            color: const Color(0xFFFAFAFA),
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
            child: Image.asset(
              'assets/images/logo.png',
              height: 50,
              width: 50,
            ),
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

class _LoginMobileView extends StatelessWidget {
  final Map<String, String> randomAnnouncement;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> scaleAnimation;
  final AnimationController backgroundController;

  const _LoginMobileView({
    required this.randomAnnouncement,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.scaleAnimation,
    required this.backgroundController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 500,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4FADE3),
                  Color(0xFF2A8BC4),
                ],
              ),
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
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: const Text(
                            'GENET CHURCH',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          randomAnnouncement['title']!.replaceAll('\n', ' '),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.0,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Text(
                            randomAnnouncement['subtitle']!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.95),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFFFAFAFA),
            padding: const EdgeInsets.symmetric(vertical: 40),
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

  const _LoginForm({
    required this.scaleAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rememberMe = useState(false);
    final isPasswordVisible = useState(false);
    final buttonController = useAnimationController(
      duration: const Duration(milliseconds: 150),
    );
    final buttonScale = useAnimation(
      Tween<double>(begin: 1.0, end: 0.98).animate(
        CurvedAnimation(parent: buttonController, curve: Curves.easeInOut),
      ),
    );

    final emailController =
    useTextEditingController(text: 'super@admin.com');
    final passwordController = useTextEditingController(text: 'password');

    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to access your administrative portal',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildModernTextField(
                    controller: emailController,
                    hintText: 'Username or Email',
                    icon: Iconsax.user,
                  ),
                  const SizedBox(height: 20),
                  _buildModernTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    icon: Iconsax.lock_1,
                    obscureText: !isPasswordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible.value
                            ? Iconsax.eye
                            : Iconsax.eye_slash,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: () =>
                      isPasswordVisible.value = !isPasswordVisible.value,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Transform.scale(
                            scale: 0.9,
                            child: Checkbox(
                              value: rememberMe.value,
                              onChanged: (val) =>
                              rememberMe.value = val ?? false,
                              activeColor: const Color(0xFF4FADE3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          Text(
                            'Remember me',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: Color(0xFF4FADE3),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Transform.scale(
                    scale: buttonScale,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4FADE3), Color(0xFF2A8BC4)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4FADE3).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            buttonController.forward();
                            try {
                              final authRepo = ref.read(authRepositoryProvider);
                              await authRepo.login(
                                emailController.text,
                                passwordController.text,
                              );
                              if (context.mounted) {
                                context.go('/dashboard');
                              }
                            } catch (e) {
                              if(context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Login Failed: Invalid credentials'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              buttonController.reverse();
                            }
                          },
                          child: const Center(
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.message_question,
                            color: Colors.blue.shade600, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Need help? Contact your administrator',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 14,
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
    );
  }

  Widget _buildModernTextField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4FADE3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4FADE3),
              size: 20,
            ),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF4FADE3), width: 2),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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

      path.addOval(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: radius,
      ));

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

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}