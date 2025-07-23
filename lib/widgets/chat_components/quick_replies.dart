import 'package:challengely/widgets/animated_components/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/chat_message.dart';
import '../../utils/constants.dart';

class QuickRepliesWidget extends StatefulWidget {
  final List<QuickReply> quickReplies;
  final Function(QuickReply) onReplyPressed;

  const QuickRepliesWidget({
    super.key,
    required this.quickReplies,
    required this.onReplyPressed,
  });

  @override
  State<QuickRepliesWidget> createState() => _QuickRepliesWidgetState();
}

class _QuickRepliesWidgetState extends State<QuickRepliesWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
    if (widget.quickReplies.isEmpty) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.padding,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Quick replies',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.paddingSmall),
            
            // Quick reply chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.quickReplies.length,
                itemBuilder: (context, index) {
                  final reply = widget.quickReplies[index];
                  return _buildQuickReplyChip(reply, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReplyChip(QuickReply reply, int index) {
    return Container(
      margin: EdgeInsets.only(
        right: AppDimensions.paddingSmall,
        left: index == 0 ? 0 : 0,
      ),
      child: AnimatedButton(
        onPressed: () {
          _handleReplyPressed(reply);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.padding,
            vertical: AppDimensions.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (reply.emoji != null) ...[
                Text(
                  reply.emoji!,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                reply.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    )
    .animate(delay: (index * 100).ms)
    .fadeIn(duration: 400.ms)
    .slideX(begin: 0.3, end: 0);
  }

  void _handleReplyPressed(QuickReply reply) {
    // Animate out
    _slideController.reverse().then((_) {
      widget.onReplyPressed(reply);
    });
  }
}

class QuickReplyChip extends StatefulWidget {
  final QuickReply reply;
  final VoidCallback onPressed;
  final bool isSelected;

  const QuickReplyChip({
    super.key,
    required this.reply,
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  State<QuickReplyChip> createState() => _QuickReplyChipState();
}

class _QuickReplyChipState extends State<QuickReplyChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: AppColors.surfaceVariant,
      end: AppColors.primary.withOpacity(0.1),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.2),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.reply.emoji != null) ...[
                    Text(
                      widget.reply.emoji!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    widget.reply.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: widget.isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  if (widget.isSelected) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SuggestedActionsWidget extends StatelessWidget {
  final List<SuggestedAction> actions;
  final Function(SuggestedAction) onActionPressed;

  const SuggestedActionsWidget({
    super.key,
    required this.actions,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested actions',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Wrap(
            spacing: AppDimensions.paddingSmall,
            runSpacing: AppDimensions.paddingSmall,
            children: actions.map((action) {
              return _buildActionChip(context, action);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, SuggestedAction action) {
    return AnimatedButton(
      onPressed: () => onActionPressed(action),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          gradient: action.color != null
              ? LinearGradient(
                  colors: [
                    action.color!,
                    action.color!.withOpacity(0.8),
                  ],
                )
              : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (action.color ?? AppColors.primary).withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (action.icon != null) ...[
              Icon(
                action.icon,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              action.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuggestedAction {
  final String id;
  final String title;
  final IconData? icon;
  final Color? color;
  final Map<String, dynamic>? data;

  const SuggestedAction({
    required this.id,
    required this.title,
    this.icon,
    this.color,
    this.data,
  });
}