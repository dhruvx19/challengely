import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/constants.dart';

class TypingIndicatorWidget extends StatefulWidget {
  const TypingIndicatorWidget({super.key});

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.surfaceVariant,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // AI Avatar
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
            
            const SizedBox(width: AppDimensions.paddingSmall),
            
            // Typing text and animation
            Expanded(
              child: Row(
                children: [
                  Text(
                    AppStrings.aiTyping,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildTypingAnimation(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingAnimation() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: const BoxDecoration(
            color: AppColors.textTertiary,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(
          duration: 600.ms,
          delay: (index * 200).ms,
        )
        .then()
        .fadeOut(duration: 600.ms)
        .then()
        .scaleXY(
          duration: 400.ms,
          begin: 1.0,
          end: 1.2,
          delay: (index * 100).ms,
        )
        .then()
        .scaleXY(
          duration: 400.ms,
          begin: 1.2,
          end: 1.0,
        );
      }),
    );
  }
}

class CustomTypingIndicator extends StatefulWidget {
  final String message;
  final Color color;
  final Duration animationDuration;

  const CustomTypingIndicator({
    super.key,
    this.message = 'AI is typing',
    this.color = AppColors.primary,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<CustomTypingIndicator> createState() => _CustomTypingIndicatorState();
}

class _CustomTypingIndicatorState extends State<CustomTypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.4,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    _startAnimations();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.message,
            style: TextStyle(
              color: widget.color,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(_animations[index].value),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class PulseTypingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const PulseTypingIndicator({
    super.key,
    this.color = AppColors.primary,
    this.size = 6,
  });

  @override
  State<PulseTypingIndicator> createState() => _PulseTypingIndicatorState();
}

class _PulseTypingIndicatorState extends State<PulseTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_animation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_animation.value * 0.5),
                blurRadius: widget.size * _animation.value,
                spreadRadius: widget.size * _animation.value * 0.5,
              ),
            ],
          ),
        );
      },
    );
  }
}

class WaveTypingIndicator extends StatefulWidget {
  final Color color;
  final int dotCount;
  final double dotSize;
  final Duration duration;

  const WaveTypingIndicator({
    super.key,
    this.color = AppColors.primary,
    this.dotCount = 3,
    this.dotSize = 8,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<WaveTypingIndicator> createState() => _WaveTypingIndicatorState();
}

class _WaveTypingIndicatorState extends State<WaveTypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(widget.dotCount, (index) {
      return AnimationController(
        duration: widget.duration,
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0,
        end: -10,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    _startWaveAnimation();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startWaveAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Timer(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animations[index].value),
              child: Container(
                width: widget.dotSize,
                height: widget.dotSize,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}