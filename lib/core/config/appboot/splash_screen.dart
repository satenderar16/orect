import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _jumpController;
  late final Animation<double> _jumpAnimation;

  late final AnimationController _dotController;
  int _activeDot = 0;

  @override
  void initState() {
    super.initState();

    // Jump animation
    _jumpController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _jumpAnimation = Tween<double>(begin: 0, end: -30).animate(
      CurvedAnimation(parent: _jumpController, curve: Curves.easeOut),
    );

    _jumpController.repeat(reverse: true);

    // Dot animation
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..addListener(_updateDotIndex);

    _dotController.repeat();
  }

  void _updateDotIndex() {
    //also update dots state :
    final newIndex = (_dotController.value * 4).floor() % 4;
    if (newIndex != _activeDot) {
      setState(() => _activeDot = newIndex);
    }
  }

  @override
  void dispose() {
    _jumpController
      ..stop()
      ..dispose();

    _dotController
      ..removeListener(_updateDotIndex)
      ..stop()
      ..dispose();

    super.dispose();
  }

  Widget _buildLoadingDots(Color activeColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        //no of dots
        children: List.generate(4, (index) {
          final isActive = index == _activeDot;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor
                  : activeColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(), // top spacer
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _jumpAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _jumpAnimation.value),
                    child: child,
                  );
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary,
                  ),
                  child: const Icon(
                    Icons.flutter_dash,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ORECT',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          _buildLoadingDots(primary),
        ],
      ),
    );
  }
}
