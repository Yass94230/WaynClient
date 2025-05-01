import 'package:flutter/material.dart';

class SlidingPanel extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool isVisible;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onClose;
  final bool isDismissible;

  const SlidingPanel({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.isVisible = false,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.onClose,
    this.isDismissible = true,
  });

  @override
  State<SlidingPanel> createState() => _SlidingPanelState();
}

class _SlidingPanelState extends State<SlidingPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SlidingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isDismissible && !widget.isVisible ? widget.onClose : null,
      child: Container(
        color: widget.isVisible
            ? Colors.black.withOpacity(0.3)
            : Colors.transparent,
        child: Stack(
          children: [
            if (widget.isVisible && widget.isDismissible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.onClose,
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _offsetAnimation,
                child: Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? Colors.white,
                    borderRadius: widget.borderRadius ??
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
