import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/dream_provider.dart';
import '../../state/graph_provider.dart';
import '../../theme/cosmic_theme.dart';
import '../../widgets/botanical_divider.dart';
import '../main_navigation_shell.dart';

/// Atmospheric animated splash screen celebrating the cosmic constellation graph.
class SplashScreen extends StatefulWidget {
  final bool autoNavigate;
  final VoidCallback? onFinished;

  const SplashScreen({
    super.key,
    this.autoNavigate = true,
    this.onFinished,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Trigger data warmup and navigation
    if (widget.autoNavigate) {
      _initAndNavigate();
    }
  }

  Future<void> _initAndNavigate() async {
    // Warm up providers in background
    try {
      final dreamProvider = Provider.of<DreamProvider>(context, listen: false);
      final graphProvider = Provider.of<GraphProvider>(context, listen: false);
      await Future.wait([
        dreamProvider.refresh(),
        graphProvider.loadGraph(),
      ]);
    } catch (_) {
      // Ignore if called in test wrapper without full providers
    }

    _navigationTimer = Timer(const Duration(milliseconds: 2200), () {
      _navigateToHome();
    });
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    if (widget.onFinished != null) {
      widget.onFinished!();
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosmicColors.background,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.autoNavigate ? _navigateToHome : null,
        child: Stack(
          children: [
            // Background cosmic radial gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.15),
                    radius: 1.1,
                    colors: [
                      Color(0xFF221A45),
                      Color(0xFF131428),
                      CosmicColors.background,
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // Animated content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Breathing glowing constellation emblem
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 148,
                                height: 148,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: CosmicColors.celestialCyan.withOpacity(
                                        0.25 * _pulseAnimation.value,
                                      ),
                                      blurRadius: 36 * _pulseAnimation.value,
                                      spreadRadius: 6 * _pulseAnimation.value,
                                    ),
                                    BoxShadow(
                                      color: CosmicColors.astralViolet.withOpacity(
                                        0.35 * _pulseAnimation.value,
                                      ),
                                      blurRadius: 54 * _pulseAnimation.value,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: child,
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(74),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F1024),
                                  border: Border.all(
                                    color: CosmicColors.starlightGold.withOpacity(0.35),
                                    width: 1.5,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  'assets/icon/app_icon.png',
                                  width: 148,
                                  height: 148,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),

                          // App Title
                          Text(
                            'COSMIC TWILIGHT',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4.0,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: CosmicColors.celestialCyan.withOpacity(0.6),
                                      blurRadius: 18,
                                    ),
                                  ],
                                ),
                          ),
                          const SizedBox(height: 10),

                          // Subtitle
                          Text(
                            'DREAM JOURNAL & LUCID EXPLORER',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.5,
                                  color: CosmicColors.celestialCyan,
                                ),
                          ),
                          const SizedBox(height: 28),

                          // Botanical Divider
                          const BotanicalDivider(width: 180),
                          const SizedBox(height: 24),

                          // Epigraph / Philosophy
                          Text(
                            '“The feedback loop between your\nwaking and dreaming mind.”',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: CosmicColors.textSecondary.withOpacity(0.85),
                                  height: 1.5,
                                ),
                          ),
                          const SizedBox(height: 48),

                          // Subtle touch to skip hint
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: CosmicColors.starlightGold,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'TAP ANYWHERE TO ENTER',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.8,
                                  color: CosmicColors.textMuted.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: CosmicColors.starlightGold,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
