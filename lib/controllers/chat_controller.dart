import 'dart:async';
import 'dart:math';
import 'package:challengely/services/responses_services.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/challenges.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';
import '../utils/constants.dart';

class ChatController extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final HardcodedResponseService _responseService = HardcodedResponseService();
  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  
  List<ChatMessage> _messages = [];
  List<QuickReply> _quickReplies = [];
  bool _isTyping = false;
  bool _isLoading = true;
  String _currentInput = '';
  Challenge? _currentChallenge;
  UserProfile? _userProfile;
  int _characterCount = 0;
  static const int _maxCharacters = 200;
  Timer? _typingTimer;
  Timer? _debounceTimer;
  
  // Edge case handling
  bool _isSending = false;
  String? _lastSentMessage;
  DateTime? _lastSentTime;
  int _rapidMessageCount = 0;
  Timer? _rapidMessageTimer;
  static const int _maxRapidMessages = 3; // Reduced for better UX
  static const Duration _rapidMessageWindow = Duration(seconds: 15); // Increased window
  
  // App lifecycle handling
  bool _appInBackground = false;
  
  // Keyboard handling
  bool _keyboardVisible = false;

  // Getters
  List<ChatMessage> get messages => _messages;
  List<QuickReply> get quickReplies => _quickReplies;
  bool get isTyping => _isTyping;
  bool get isLoading => _isLoading;
  String get currentInput => _currentInput;
  int get characterCount => _characterCount;
  int get maxCharacters => _maxCharacters;
  bool get isAtCharacterLimit => _characterCount >= _maxCharacters;
  
  Color get characterCountColor {
    final percentage = _characterCount / _maxCharacters;
    if (percentage < 0.7) return AppColors.success;
    if (percentage < 0.9) return AppColors.warning;
    return AppColors.error;
  }

  ChatController() {
    textController.addListener(_onTextChanged);
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _storage.init();
      await _loadUserProfile();
      await _loadMessages();
      await _initializeChat();
      
    } catch (e) {
      print('Error initializing chat controller: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    _userProfile = _storage.getUserProfile();
  }

  Future<void> _loadMessages() async {
    _messages = _storage.getChatMessages(challengeId: _currentChallenge?.id);
    _scrollToBottom();
    notifyListeners();
  }

  Future<void> _initializeChat() async {
    // If no messages exist, send welcome messages
    if (_messages.isEmpty && _currentChallenge != null) {
      final welcomeMessages = _responseService.getWelcomeMessages(_currentChallenge!);
      
      for (int i = 0; i < welcomeMessages.length; i++) {
        await Future.delayed(Duration(milliseconds: 800 * i));
        await _addAIMessage(welcomeMessages[i]);
      }
      
      _updateQuickReplies();
    }
  }

  void _onTextChanged() {
    final text = textController.text;
    _currentInput = text;
    _characterCount = text.length;
    
    // Debounce typing indicator
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      // User stopped typing
    });
    
    notifyListeners();
  }

  void setCurrentChallenge(Challenge? challenge) {
    _currentChallenge = challenge;
    _loadMessages();
    _updateQuickReplies();
  }

  Future<void> sendMessage(String text) async {
    // Edge case: Prevent empty messages
    if (text.trim().isEmpty) {
      _showErrorFeedback('Please enter a message');
      return;
    }
    
    // Edge case: Prevent messages over character limit
    if (text.length > _maxCharacters) {
      _showErrorFeedback('Message too long (${text.length}/$_maxCharacters characters)');
      return;
    }
    
    // Edge case: Prevent rapid message sending (spam protection)
    if (_isSending) {
      _showErrorFeedback('Please wait, sending message...');
      return;
    }
    
    // Edge case: Check for duplicate/repeated messages
    if (_isDuplicateMessage(text)) {
      _showErrorFeedback('Message already sent recently');
      return;
    }
    
    // Edge case: Rate limiting
    if (_isRateLimited()) {
      _showErrorFeedback('Please slow down. Wait a moment before sending another message.');
      return;
    }
    
    _isSending = true;
    _updateRateLimiting();
    
    try {
      // Add user message
      final userMessage = ChatMessage(
        id: const Uuid().v4(),
        content: text.trim(),
        type: MessageType.user,
        timestamp: DateTime.now(),
        challengeId: _currentChallenge?.id,
        status: MessageStatus.sending,
      );
      
      _messages.add(userMessage);
      await _storage.saveChatMessage(userMessage);
      
      // Update last sent message for duplicate detection
      _lastSentMessage = text.trim().toLowerCase();
      _lastSentTime = DateTime.now();
      
      // Clear input
      textController.clear();
      _currentInput = '';
      _characterCount = 0;
      
      notifyListeners();
      _scrollToBottom();
      
      // Update message status to sent
      final sentMessage = userMessage.copyWith(status: MessageStatus.sent);
      _updateMessage(sentMessage);
      
      // Show typing indicator and generate response
      await _simulateTypingAndRespond(text);
      
      _updateQuickReplies();
      
    } catch (e) {
      print('Error sending message: $e');
      _showErrorFeedback('Failed to send message. Please try again.');
    } finally {
      _isSending = false;
    }
  }

  bool _isDuplicateMessage(String text) {
    if (_lastSentMessage == null || _lastSentTime == null) return false;
    
    final now = DateTime.now();
    final timeSinceLastMessage = now.difference(_lastSentTime!);
    
    // Consider duplicate if same message sent within 5 seconds
    return _lastSentMessage == text.trim().toLowerCase() && 
           timeSinceLastMessage.inSeconds < 5;
  }

  bool _isRateLimited() {
    return _rapidMessageCount >= _maxRapidMessages;
  }

  void _updateRateLimiting() {
    _rapidMessageCount++;
    
    // Reset rapid message timer
    _rapidMessageTimer?.cancel();
    _rapidMessageTimer = Timer(_rapidMessageWindow, () {
      _rapidMessageCount = 0;
    });
  }

  void _updateMessage(ChatMessage updatedMessage) {
    final index = _messages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      _messages[index] = updatedMessage;
      _storage.saveChatMessage(updatedMessage);
      notifyListeners();
    }
  }

  void _showErrorFeedback(String message) {
    // You could show a snackbar or toast here
    print('Chat Error: $message');
  }

  Future<void> _simulateTypingAndRespond(String userMessage) async {
    // Start typing indicator
    _isTyping = true;
    notifyListeners();
    
    // Random delay between 1-3 seconds for realism
    final random = Random();
    final delay = Duration(milliseconds: 1000 + random.nextInt(2000));
    
    await Future.delayed(delay);
    
    // Get response with fallback for unrecognized input
    final context = _getCurrentContext();
    String response;
    
    try {
      response = _responseService.getResponse(
        userMessage,
        currentChallenge: _currentChallenge,
        context: context,
        userStreak: _userProfile?.currentStreak,
      );
    } catch (e) {
      // Fallback for any errors
      response = "I'm here to help! Could you tell me more about what you need assistance with?";
    }
    
    // Stop typing and add AI message
    _isTyping = false;
    await _addAIMessage(response);
  }

  String _getCurrentContext() {
    if (_currentChallenge == null) return 'general';
    
    switch (_currentChallenge!.state) {
      case ChallengeState.available:
        return 'pre_challenge';
      case ChallengeState.inProgress:
        return 'during_challenge';
      case ChallengeState.completed:
        return 'post_challenge';
      default:
        return 'general';
    }
  }

  Future<void> _addAIMessage(String content) async {
    final aiMessage = ChatMessage(
      id: const Uuid().v4(),
      content: content,
      type: MessageType.ai,
      timestamp: DateTime.now(),
      challengeId: _currentChallenge?.id,
    );
    
    _messages.add(aiMessage);
    await _storage.saveChatMessage(aiMessage);
    
    notifyListeners();
    _scrollToBottom();
    
    // Add streaming effect
    await _simulateStreamingText(content);
  }

  Future<void> _simulateStreamingText(String text) async {
    // This would simulate the streaming text effect
    // For now, we just scroll to bottom after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    _scrollToBottom();
  }

  void _updateQuickReplies() {
    if (_currentChallenge == null) {
      _quickReplies = QuickReplyData.getGeneralReplies();
      return;
    }
    
    switch (_currentChallenge!.state) {
      case ChallengeState.available:
        _quickReplies = QuickReplyData.getPreChallengeReplies();
        break;
      case ChallengeState.inProgress:
        _quickReplies = QuickReplyData.getDuringChallengeReplies();
        break;
      case ChallengeState.completed:
        _quickReplies = QuickReplyData.getPostChallengeReplies();
        break;
      default:
        _quickReplies = QuickReplyData.getGeneralReplies();
    }
    
    notifyListeners();
  }

  Future<void> sendQuickReply(QuickReply reply) async {
    await sendMessage(reply.text);
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void focusInput() {
    focusNode.requestFocus();
  }

  void unfocusInput() {
    focusNode.unfocus();
  }

  Future<void> clearMessages() async {
    _messages.clear();
    await _storage.clearChatMessages(challengeId: _currentChallenge?.id);
    notifyListeners();
  }

  Future<void> deleteMessage(String messageId) async {
    _messages.removeWhere((message) => message.id == messageId);
    await _storage.saveChatMessages(_messages);
    notifyListeners();
  }

  // Handle challenge state changes
  Future<void> onChallengeStarted(Challenge challenge) async {
    final startMessages = _responseService.getChallengeStartMessages(challenge);
    
    for (final message in startMessages) {
      await Future.delayed(const Duration(milliseconds: 500));
      await _addAIMessage(message);
    }
    
    _updateQuickReplies();
  }

  Future<void> onChallengeCompleted(Challenge challenge, Duration timeSpent) async {
    final completionMessages = _responseService.getChallengeCompletionMessages(
      challenge, 
      timeSpent
    );
    
    for (final message in completionMessages) {
      await Future.delayed(const Duration(milliseconds: 800));
      await _addAIMessage(message);
    }
    
    _updateQuickReplies();
  }

  Future<void> onStreakUpdated(int newStreak) async {
    if (newStreak > 0 && newStreak % 5 == 0) {
      final streakMessage = _responseService.getStreakMessage(newStreak);
      await Future.delayed(const Duration(milliseconds: 1000));
      await _addAIMessage(streakMessage);
    }
  }

  // Handle keyboard events with enhanced scrolling
  void onKeyboardAppeared() {
    _keyboardVisible = true;
    notifyListeners();
    
    // Enhanced scroll to bottom with multiple attempts
    _scrollToBottomAggressively();
  }

  void onKeyboardDismissed() {
    _keyboardVisible = false;
    unfocusInput();
    notifyListeners();
  }

  void _scrollToBottomAggressively() {
    // Multiple delayed attempts to ensure proper scrolling
    final delays = [100, 300, 500, 800];
    
    for (final delay in delays) {
      Future.delayed(Duration(milliseconds: delay), () {
        if (scrollController.hasClients && _keyboardVisible) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // Handle app lifecycle changes
  void onAppLifecycleChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _appInBackground = true;
        // Save current state
        _saveCurrentState();
        break;
      case AppLifecycleState.resumed:
        if (_appInBackground) {
          _appInBackground = false;
          // Restore state and refresh if needed
          _restoreState();
        }
        break;
      case AppLifecycleState.inactive:
        // Handle brief interruptions
        break;
    }
  }

  void _saveCurrentState() {
    // Save any pending messages or state
    if (_currentInput.isNotEmpty) {
      // Could save draft message here
      print('Saving draft: $_currentInput');
    }
  }

  void _restoreState() {
    // Restore any saved state
    // Refresh connection status if needed
    print('App resumed - restoring chat state');
    notifyListeners();
  }

  // Export chat
  List<Map<String, dynamic>> exportChat() {
    return _messages.map((message) => message.toJson()).toList();
  }

  // Get chat statistics
  Map<String, int> getChatStats() {
    final userMessages = _messages.where((m) => m.isUser).length;
    final aiMessages = _messages.where((m) => m.isAI).length;
    final totalMessages = _messages.length;
    
    return {
      'userMessages': userMessages,
      'aiMessages': aiMessages,
      'totalMessages': totalMessages,
    };
  }

  // Get last message time
  DateTime? getLastMessageTime() {
    if (_messages.isEmpty) return null;
    return _messages.last.timestamp;
  }

  // Check if user has been active recently
  bool get isUserActiveRecently {
    final lastMessage = getLastMessageTime();
    if (lastMessage == null) return false;
    
    final timeSinceLastMessage = DateTime.now().difference(lastMessage);
    return timeSinceLastMessage.inMinutes < 30;
  }

  // Clear all data for logout/reset functionality
  Future<void> clearAllData() async {
    try {
      // Clear all stored data
      await _storage.clearChatMessages();
      
      // Reset controller state
      _messages.clear();
      _quickReplies.clear();
      _isTyping = false;
      _isSending = false;
      _currentInput = '';
      _currentChallenge = null;
      _userProfile = null;
      _characterCount = 0;
      _lastSentMessage = null;
      _lastSentTime = null;
      _rapidMessageCount = 0;
      
      // Clear text input
      textController.clear();
      
      // Cancel timers
      _typingTimer?.cancel();
      _debounceTimer?.cancel();
      _rapidMessageTimer?.cancel();
      _typingTimer = null;
      _debounceTimer = null;
      _rapidMessageTimer = null;
      
      notifyListeners();
      
    } catch (e) {
      print('Error clearing chat data: $e');
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    textController.dispose();
    focusNode.dispose();
    _typingTimer?.cancel();
    _debounceTimer?.cancel();
    _rapidMessageTimer?.cancel();
    super.dispose();
  }
}