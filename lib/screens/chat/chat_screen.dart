import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/challenge_controller.dart';
import '../../models/chat_message.dart';
import '../../utils/constants.dart';
import '../../utils/animations.dart';
import '../../widgets/chat_components/message_bubble.dart';
import '../../widgets/chat_components/chat_input.dart';
import '../../widgets/chat_components/quick_replies.dart';
import '../../widgets/chat_components/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();
    
    // Set current challenge in chat controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final challengeController = context.read<ChallengeController>();
      context.read<ChatController>().setCurrentChallenge(
        challengeController.currentChallenge,
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<ChatController>(
        builder: (context, chatController, child) {
          if (chatController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // Messages list
              Expanded(
                child: _buildMessagesList(chatController),
              ),
              
              // Quick replies
              if (chatController.quickReplies.isNotEmpty)
                QuickRepliesWidget(
                  quickReplies: chatController.quickReplies,
                  onReplyPressed: chatController.sendQuickReply,
                ),
              
              // Typing indicator
              if (chatController.isTyping)
                const TypingIndicatorWidget(),
              
              // Chat input
              ChatInputWidget(
                controller: chatController,
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: AppColors.cardShadow,
      title: Row(
        children: [
          // AI Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 20,
            ),
          )
          .animate()
          .scale(duration: 600.ms, curve: Curves.elasticOut),
          
          const SizedBox(width: 12),
          
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Challenge Assistant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Consumer<ChallengeController>(
                  builder: (context, challengeController, child) {
                    final challenge = challengeController.currentChallenge;
                    if (challenge != null) {
                      return Text(
                        'Helping with: ${challenge.title}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      );
                    }
                    return const Text(
                      'Ready to help you grow',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3, end: 0),
      actions: [
        Consumer<ChatController>(
          builder: (context, chatController, child) {
            return IconButton(
              icon: const Icon(Icons.refresh_rounded),
              color: AppColors.textSecondary,
              onPressed: () {
                _showClearChatDialog(chatController);
              },
              tooltip: 'Clear chat',
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessagesList(ChatController chatController) {
    final messages = chatController.messages;
    
    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeController.value,
          child: ListView.builder(
            controller: chatController.scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.padding,
            ),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final previousMessage = index > 0 ? messages[index - 1] : null;
              final showTimestamp = _shouldShowTimestamp(message, previousMessage);
              
              return Column(
                children: [
                  if (showTimestamp)
                    _buildTimestamp(message.timestamp),
                  
                  MessageBubble(
                    message: message,
                    onLongPress: () => _showMessageOptions(message, chatController),
                  )
                  .animate(delay: (index * 50).ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: AppDimensions.paddingSmall),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 60,
            ),
          )
          .animate()
          .scale(duration: 800.ms, curve: Curves.elasticOut)
          .then()
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scaleXY(duration: 2000.ms, begin: 1.0, end: 1.1),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          Text(
            'Start a conversation',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: AppDimensions.paddingSmall),
          
          Text(
            'Ask me anything about your challenge\nor just say hello! 👋',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    String timeText;
    
    if (difference.inDays > 0) {
      timeText = '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      timeText = '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      timeText = '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      timeText = 'Just now';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.padding),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.textTertiary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            timeText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowTimestamp(ChatMessage current, ChatMessage? previous) {
    if (previous == null) return true;
    
    final timeDifference = current.timestamp.difference(previous.timestamp);
    return timeDifference.inMinutes > 5;
  }

  void _showMessageOptions(ChatMessage message, ChatController chatController) {
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
              
              // Message content
              Container(
                padding: const EdgeInsets.all(AppDimensions.padding),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                ),
                child: Text(
                  message.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              
              const SizedBox(height: AppDimensions.paddingLarge),
              
              // Actions
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('Copy message'),
                onTap: () {
                  Navigator.pop(context);
                  // Copy to clipboard logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message copied to clipboard')),
                  );
                },
              ),
              
              if (message.isUser)
                ListTile(
                  leading: const Icon(Icons.delete_rounded),
                  title: const Text('Delete message'),
                  textColor: AppColors.error,
                  iconColor: AppColors.error,
                  onTap: () {
                    Navigator.pop(context);
                    chatController.deleteMessage(message.id);
                  },
                ),
              
              const SizedBox(height: AppDimensions.padding),
            ],
          ),
        );
      },
    );
  }

  void _showClearChatDialog(ChatController chatController) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          ),
          title: const Text('Clear Chat'),
          content: const Text(
            'Are you sure you want to clear all messages? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                chatController.clearMessages();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chat cleared'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}