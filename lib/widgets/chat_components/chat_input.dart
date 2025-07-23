import 'package:challengely/widgets/animated_components/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/chat_controller.dart';
import '../../utils/constants.dart';

class ChatInputWidget extends StatefulWidget {
  final ChatController controller;

  const ChatInputWidget({
    super.key,
    required this.controller,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget>
    with TickerProviderStateMixin {
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonScale;
  late AnimationController _containerController;
  late Animation<double> _containerHeight;
  
  double _baseHeight = 60;
  double _maxHeight = 160;

  @override
  void initState() {
    super.initState();
    
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sendButtonScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.elasticOut,
    ));
    
    _containerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _containerHeight = Tween<double>(
      begin: _baseHeight,
      end: _baseHeight,
    ).animate(CurvedAnimation(
      parent: _containerController,
      curve: Curves.easeInOut,
    ));

    // Listen to text changes
    widget.controller.textController.addListener(_onTextChanged);
    widget.controller.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _sendButtonController.dispose();
    _containerController.dispose();
    widget.controller.textController.removeListener(_onTextChanged);
    widget.controller.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.textController.text.trim().isNotEmpty;
    
    if (hasText && !_sendButtonController.isCompleted) {
      _sendButtonController.forward();
    } else if (!hasText && _sendButtonController.isCompleted) {
      _sendButtonController.reverse();
    }
    
    setState(() {});
  }

  void _onFocusChanged() {
    if (widget.controller.focusNode.hasFocus) {
      widget.controller.onKeyboardAppeared();
    } else {
      widget.controller.onKeyboardDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Input field
              Expanded(
                child: _buildInputField(),
              ),
              
              const SizedBox(width: AppDimensions.paddingSmall),
              
              // Send button
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      constraints: BoxConstraints(
        minHeight: 48,
        maxHeight: _maxHeight - 12, // Account for padding
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.controller.focusNode.hasFocus
              ? AppColors.primary.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment button (optional)
          IconButton(
            icon: const Icon(
              Icons.add_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: _showAttachmentOptions,
            tooltip: 'Add attachment',
          ),
          
          // Text input
          Expanded(
            child: TextField(
              controller: widget.controller.textController,
              focusNode: widget.controller.focusNode,
              maxLines: null,
              minLines: 1,
              maxLength: widget.controller.maxCharacters,
              textInputAction: TextInputAction.newline,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.chatPlaceholder,
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
                counterText: '', // Hide default counter
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  _sendMessage();
                }
              },
            ),
          ),
          
          // Character counter
          _buildCharacterCounter(),
          
          const SizedBox(width: AppDimensions.paddingSmall),
        ],
      ),
    );
  }

  Widget _buildCharacterCounter() {
    final count = widget.controller.characterCount;
    final max = widget.controller.maxCharacters;
    final percentage = count / max;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: widget.controller.characterCountColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: widget.controller.characterCountColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    final canSend = widget.controller.textController.text.trim().isNotEmpty &&
                   !widget.controller.isAtCharacterLimit &&
                   !widget.controller.isTyping;

    return AnimatedBuilder(
      animation: _sendButtonScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _sendButtonScale.value,
          child: AnimatedButton(
            onPressed: canSend ? _sendMessage : null,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: canSend 
                    ? AppColors.primaryGradient
                    : const LinearGradient(
                        colors: [AppColors.textTertiary, AppColors.textTertiary],
                      ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: canSend ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  void _sendMessage() {
    final text = widget.controller.textController.text.trim();
    if (text.isNotEmpty && !widget.controller.isAtCharacterLimit) {
      widget.controller.sendMessage(text);
      
      // Add send animation
      _sendButtonController.reverse().then((_) {
        _sendButtonController.forward();
      });
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(height: AppDimensions.paddingLarge),
              
              // Quick actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickAction(
                    Icons.camera_alt_rounded,
                    'Camera',
                    AppColors.primary,
                    () {
                      Navigator.pop(context);
                      // Handle camera
                    },
                  ),
                  _buildQuickAction(
                    Icons.photo_library_rounded,
                    'Gallery',
                    AppColors.secondary,
                    () {
                      Navigator.pop(context);
                      // Handle gallery
                    },
                  ),
                  _buildQuickAction(
                    Icons.mic_rounded,
                    'Voice',
                    AppColors.success,
                    () {
                      Navigator.pop(context);
                      // Handle voice
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.paddingLarge),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final int maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const ExpandableTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.maxLength = 500,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<ExpandableTextField> createState() => _ExpandableTextFieldState();
}

class _ExpandableTextFieldState extends State<ExpandableTextField> {
  late ScrollController _scrollController;
  double _textHeight = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.controller.addListener(_updateHeight);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    widget.controller.removeListener(_updateHeight);
    super.dispose();
  }

  void _updateHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final newHeight = renderBox.size.height;
        if (newHeight != _textHeight) {
          setState(() {
            _textHeight = newHeight;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 40,
        maxHeight: 120,
      ),
      child: Scrollbar(
        controller: _scrollController,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          scrollController: _scrollController,
          maxLines: null,
          minLines: 1,
          maxLength: widget.maxLength,
          textInputAction: TextInputAction.newline,
          onChanged: widget.onChanged,
          onSubmitted: (_) => widget.onSubmitted?.call(),
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            counterText: '',
          ),
        ),
      ),
    );
  }
}