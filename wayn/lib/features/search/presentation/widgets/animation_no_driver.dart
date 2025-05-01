import 'package:flutter/material.dart';
import 'package:wayn/features/core/config/size_config.dart';

class NoDriverAnimation extends StatefulWidget {
  const NoDriverAnimation({super.key});

  @override
  State<NoDriverAnimation> createState() => _NoDriverAnimationState();
}

class _NoDriverAnimationState extends State<NoDriverAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: MobileAdaptive.isSmallPhone ? 100.w : 120.w,
              height: MobileAdaptive.isSmallPhone ? 100.h : 120.h,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.car_crash_outlined,
                  color: Colors.red[400],
                  size: MobileAdaptive.isSmallPhone ? 50.sp : 60.sp,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
