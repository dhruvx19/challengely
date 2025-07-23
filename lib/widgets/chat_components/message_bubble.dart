import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/chat_message.dart';
import '../../utils/constants.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    this.onLongPress,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildMessageContent(),
          );
        },
      ),
    );
  }

  Widget _buildMessageContent() {
    final isUser = widget.message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              _buildAvatar(),
              const SizedBox(width: AppDimensions.paddingSmall),
            ],
            Flexible(
              child: _buildBubble(isUser),
            ),
            if (isUser) ...[
              const SizedBox(width: AppDimensions.paddingSmall),
              _buildMessageStatus(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.psychology_rounded,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildBubble(bool isUser) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.padding,
        vertical: AppDimensions.paddingSmall + 2,
      ),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMessageText(isUser),
          if (widget.message.isPending || widget.message.isFailed)
            _buildMessageIndicator(),
        ],
      ),
    );
  }

  Widget _buildMessageText(bool isUser) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: widget.message.isPending
          ? _buildTypingAnimation()
          : SelectableText(
              widget.message.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isUser ? Colors.white : AppColors.textPrimary,
                height: 1.4,
              ),
            ),
    );
  }

  Widget _buildTypingAnimation() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sending',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 20,
          height: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              return Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .fadeIn(
                duration: 600.ms,
                delay: (index * 200).ms,
              )
              .then()
              .fadeOut(duration: 600.ms);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageIndicator() {
    if (widget.message.isPending) {
      return Container(
        margin: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Sending...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.message.isFailed) {
      return Container(
        margin: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 12,
              color: Colors.red.shade300,
            ),
            const SizedBox(width: 4),
            Text(
              'Failed to send',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red.shade300,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMessageStatus() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Icon(
        _getStatusIcon(),
        size: 14,
        color: AppColors.textTertiary,
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (widget.message.status) {
      case MessageStatus.sending:
        return Icons.schedule_rounded;
      case MessageStatus.sent:
        return Icons.check_rounded;
      case MessageStatus.delivered:
        return Icons.done_all_rounded;
      case MessageStatus.failed:
        return Icons.error_outline_rounded;
    }
  }
}

class StreamingMessageBubble extends StatefulWidget {
  final String content;
  final Duration streamingDuration;
  final VoidCallback? onComplete;

  const StreamingMessageBubble({
    super.key,
    required this.content,
    this.streamingDuration = const Duration(milliseconds: 1000),
    this.onComplete,
  });

  @override
  State<StreamingMessageBubble> createState() => _StreamingMessageBubbleState();
}

class _StreamingMessageBubbleState extends State<StreamingMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.streamingDuration,
      vsync: this,
    );
    
    _characterCount = IntTween(
      begin: 0,
      end: widget.content.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.padding,
        vertical: AppDimensions.paddingSmall + 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _characterCount,
        builder: (context, child) {
          final displayText = widget.content.substring(0, _characterCount.value);
          return RichText(
            text: TextSpan(
              text: displayText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              children: [
                if (_characterCount.value < widget.content.length)
                  TextSpan(
                    text: '|',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}