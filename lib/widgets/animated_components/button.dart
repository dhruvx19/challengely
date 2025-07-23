import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  final double scaleDown;
  final bool hapticFeedback;
  final Duration debounceTime;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.duration = AnimationConstants.buttonPress,
    this.scaleDown = 0.95,
    this.hapticFeedback = true,
    this.debounceTime = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  DateTime? _lastPressTime;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _canPress() {
    if (_lastPressTime == null) return true;
    
    final now = DateTime.now();
    final timeSinceLastPress = now.difference(_lastPressTime!);
    return timeSinceLastPress >= widget.debounceTime;
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && _canPress()) {
      setState(() {
        _isPressed = true;
      });
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
      _controller.reverse();
      
      if (widget.onPressed != null && _canPress()) {
        _lastPressTime = DateTime.now();
        
        // Add slight delay for better visual feedback
        Future.delayed(const Duration(milliseconds: 50), () {
          widget.onPressed!();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;
  final EdgeInsets padding;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 24,
    this.tooltip,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationConstants.buttonPress,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      _controller.forward().then((_) {
        _controller.reverse();
        widget.onPressed!();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget button = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                size: widget.size,
                color: widget.color ?? (widget.onPressed != null
                    ? AppColors.textPrimary
                    : AppColors.textTertiary),
              ),
            ),
          ),
        );
      },
    );

    button = GestureDetector(
      onTap: _handleTap,
      child: button,
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

class PulseAnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration pulseDuration;
  final double pulseScale;
  final bool continuous;

  const PulseAnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.pulseDuration = const Duration(milliseconds: 1000),
    this.pulseScale = 1.1,
    this.continuous = true,
  });

  @override
  State<PulseAnimatedButton> createState() => _PulseAnimatedButtonState();
}

class _PulseAnimatedButtonState extends State<PulseAnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.pulseDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pulseScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.continuous) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      _controller.stop();
      _controller.forward().then((_) {
        _controller.reverse().then((_) {
          widget.onPressed!();
          if (widget.continuous) {
            _controller.repeat(reverse: true);
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class ShimmerButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color shimmerColor;
  final Duration shimmerDuration;

  const ShimmerButton({
    super.key,
    required this.child,
    this.onPressed,
    this.shimmerColor = Colors.white,
    this.shimmerDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<ShimmerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.shimmerDuration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    widget.shimmerColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  transform: _SlidingGradientTransform(slidePercent: _animation.value),
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcATop,
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}