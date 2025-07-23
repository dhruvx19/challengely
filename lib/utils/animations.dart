import 'package:flutter/material.dart';
import 'constants.dart';

class AppAnimations {
  // Page transition animation
  static SlideTransition slideTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child, {
    Offset? begin,
  }) {
    const curve = Curves.easeInOutCubic;
    final slideAnimation = Tween(
      begin: begin ?? const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    return SlideTransition(
      position: slideAnimation,
      child: child,
    );
  }

  // Fade and slide transition
  static Widget fadeSlideTransition(
    Animation<double> animation,
    Widget child, {
    Offset? begin,
    Duration? duration,
  }) {
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    final slideAnimation = Tween<Offset>(
      begin: begin ?? const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }

  // Scale animation for buttons
  static Widget scaleButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = AnimationConstants.buttonPress,
  }) {
    return _ScaleButton(
      onPressed: onPressed,
      duration: duration,
      child: child,
    );
  }

  // Staggered list animation
  static Widget staggeredAnimation({
    required Widget child,
    required int index,
    Duration delay = AnimationConstants.staggerDelay,
    Duration duration = AnimationConstants.medium,
  }) {
    return _StaggeredAnimation(
      index: index,
      delay: delay,
      duration: duration,
      child: child,
    );
  }

  // Bounce animation
  static Animation<double> bounceAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    ));
  }

  // Reveal animation for cards
  static Widget revealAnimation({
    required Widget child,
    required AnimationController controller,
    Offset? slideBegin,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final slideAnimation = Tween<Offset>(
          begin: slideBegin ?? const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
        ));

        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  // Typing indicator animation
  static Widget typingIndicator() {
    return const _TypingIndicator();
  }

  // Progress animation
  static Widget progressAnimation({
    required double progress,
    Duration duration = AnimationConstants.medium,
    Color? color,
  }) {
    return _ProgressAnimation(
      progress: progress,
      duration: duration,
      color: color ?? AppColors.primary,
    );
  }
}

class _ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Duration duration;

  const _ScaleButton({
    required this.child,
    required this.onPressed,
    required this.duration,
  });

  @override
  State<_ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<_ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
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

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
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
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _StaggeredAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;

  const _StaggeredAnimation({
    required this.child,
    required this.index,
    required this.delay,
    required this.duration,
  });

  @override
  State<_StaggeredAnimation> createState() => _StaggeredAnimationState();
}

class _StaggeredAnimationState extends State<_StaggeredAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Start animation with staggered delay
    Future.delayed(Duration(milliseconds: widget.index * widget.delay.inMilliseconds), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: 0.4 + (_animations[index].value * 0.6),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _ProgressAnimation extends StatefulWidget {
  final double progress;
  final Duration duration;
  final Color color;

  const _ProgressAnimation({
    required this.progress,
    required this.duration,
    required this.color,
  });

  @override
  State<_ProgressAnimation> createState() => _ProgressAnimationState();
}

class _ProgressAnimationState extends State<_ProgressAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _updateProgress();
  }

  @override
  void didUpdateWidget(_ProgressAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    _progressAnimation = Tween<double>(
      begin: _currentProgress,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.reset();
    _controller.forward();
    _currentProgress = widget.progress;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: _progressAnimation.value,
          backgroundColor: widget.color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
        );
      },
    );
  }
}