import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/challenges.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';
import '../utils/constants.dart';

class ChallengeController extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  
  Challenge? _currentChallenge;
  List<Challenge> _upcomingChallenges = [];
  List<Challenge> _completedChallenges = [];
  UserProfile? _userProfile;
  
  bool _isLoading = true;
  bool _isRefreshing = false;
  DateTime? _challengeStartTime;
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;

  // Getters
  Challenge? get currentChallenge => _currentChallenge;
  List<Challenge> get upcomingChallenges => _upcomingChallenges;
  List<Challenge> get completedChallenges => _completedChallenges;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  Duration get elapsedTime => _elapsedTime;
  int get currentStreak => _userProfile?.currentStreak ?? 0;
  int get totalCompleted => _userProfile?.totalChallengesCompleted ?? 0;
  
  bool get hasTodaysChallenge => _currentChallenge != null;
  bool get canStartChallenge => _currentChallenge?.state == ChallengeState.available;
  bool get isChallengeInProgress => _currentChallenge?.state == ChallengeState.inProgress;
  bool get isChallengeCompleted => _currentChallenge?.state == ChallengeState.completed;
  bool get isChallengeAvailable => _currentChallenge?.isAvailable ?? false;

  ChallengeController() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _storage.init();
      await _loadUserProfile();
      await _loadChallenges();
      await _checkAndUpdateStreak();
      
    } catch (e) {
      print('Error initializing challenge controller: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    _userProfile = _storage.getUserProfile();
    notifyListeners();
  }

  Future<void> _loadChallenges() async {
    // Load saved challenges
    final savedChallenges = _storage.getChallenges();
    
    // Generate today's challenge if needed
    await _generateTodaysChallenge();
    
    // Load upcoming challenges
    _upcomingChallenges = ChallengeData.getUpcomingChallenges();
    
    // Load completed challenges
    _completedChallenges = savedChallenges
        .where((c) => c.state == ChallengeState.completed)
        .toList()
        ..sort((a, b) => (b.completionTime ?? DateTime.now())
            .compareTo(a.completionTime ?? DateTime.now()));
    
    notifyListeners();
  }

  Future<void> _generateTodaysChallenge() async {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    // Check if we already have today's challenge
    final savedChallenges = _storage.getChallenges();
    final existingChallenge = savedChallenges.firstWhere(
      (c) => c.isToday,
      orElse: () => ChallengeData.getTodaysChallenge(),
    );
    
    if (existingChallenge.isToday) {
      _currentChallenge = existingChallenge;
    } else {
      // Generate new challenge for today
      _currentChallenge = _generatePersonalizedChallenge();
      await _storage.saveChallenge(_currentChallenge!);
    }
    
    notifyListeners();
  }

  Challenge _generatePersonalizedChallenge() {
    final random = Random();
    final allChallenges = ChallengeData.getSampleChallenges();
    final userInterests = _userProfile?.interests ?? ChallengeCategory.values;
    final userDifficulty = _userProfile?.difficulty ?? Difficulty.medium;
    
    // Filter challenges based on user preferences
    var suitableChallenges = allChallenges.where((challenge) {
      return userInterests.contains(challenge.category) &&
             (challenge.difficulty == userDifficulty ||
              (userDifficulty == Difficulty.medium && 
               challenge.difficulty != Difficulty.hard));
    }).toList();
    
    // If no suitable challenges, use all challenges
    if (suitableChallenges.isEmpty) {
      suitableChallenges = allChallenges;
    }
    
    // Select a random challenge
    final selectedChallenge = suitableChallenges[random.nextInt(suitableChallenges.length)];
    
    return selectedChallenge.copyWith(
      availableDate: DateTime.now(),
      state: ChallengeState.available,
    );
  }

  Future<void> refreshChallenge() async {
    if (_isRefreshing) return;
    
    _isRefreshing = true;
    notifyListeners();
    
    try {
      // Simulate loading delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate new challenge for today
      _currentChallenge = _generatePersonalizedChallenge();
      await _storage.saveChallenge(_currentChallenge!);
      
    } catch (e) {
      print('Error refreshing challenge: $e');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> startChallenge() async {
    if (_currentChallenge == null || !canStartChallenge) return;
    
    _challengeStartTime = DateTime.now();
    _elapsedTime = Duration.zero;
    
    _currentChallenge = _currentChallenge!.copyWith(
      state: ChallengeState.inProgress,
      startTime: _challengeStartTime,
    );
    
    await _storage.saveChallenge(_currentChallenge!);
    _startTimer();
    
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_challengeStartTime != null && _currentChallenge?.state == ChallengeState.inProgress) {
        _elapsedTime = DateTime.now().difference(_challengeStartTime!);
        notifyListeners();
      }
    });
  }

  Future<void> completeChallenge() async {
    if (_currentChallenge == null || !isChallengeInProgress) return;
    
    _timer?.cancel();
    final completionTime = DateTime.now();
    
    _currentChallenge = _currentChallenge!.copyWith(
      state: ChallengeState.completed,
      completionTime: completionTime,
    );
    
    await _storage.saveChallenge(_currentChallenge!);
    
    // Update user stats
    await _updateUserStats();
    
    // Add to completed challenges
    _completedChallenges.insert(0, _currentChallenge!);
    
    notifyListeners();
  }

  Future<void> _updateUserStats() async {
    if (_userProfile == null) return;
    
    final today = DateTime.now();
    final lastChallengeDate = _userProfile!.lastChallengeDate;
    
    int newStreak = _userProfile!.currentStreak;
    
    // Update streak logic
    if (lastChallengeDate == null) {
      newStreak = 1;
    } else {
      final daysSinceLastChallenge = today.difference(lastChallengeDate).inDays;
      if (daysSinceLastChallenge <= 1) {
        newStreak++;
      } else {
        newStreak = 1; // Reset streak
      }
    }
    
    final updatedProfile = _userProfile!.copyWith(
      currentStreak: newStreak,
      totalChallengesCompleted: _userProfile!.totalChallengesCompleted + 1,
      lastChallengeDate: today,
    );
    
    await _storage.saveUserProfile(updatedProfile);
    _userProfile = updatedProfile;
    
    notifyListeners();
  }

  Future<void> _checkAndUpdateStreak() async {
    if (_userProfile == null) return;
    
    final today = DateTime.now();
    final lastChallengeDate = _userProfile!.lastChallengeDate;
    
    if (lastChallengeDate != null) {
      final daysSinceLastChallenge = today.difference(lastChallengeDate).inDays;
      
      // If more than 1 day has passed, reset streak
      if (daysSinceLastChallenge > 1) {
        final updatedProfile = _userProfile!.copyWith(currentStreak: 0);
        await _storage.saveUserProfile(updatedProfile);
        _userProfile = updatedProfile;
        notifyListeners();
      }
    }
  }

  String getTimeUntilNextChallenge() {
    if (_currentChallenge?.state == ChallengeState.completed) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final midnight = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      final timeUntilMidnight = midnight.difference(DateTime.now());
      
      final hours = timeUntilMidnight.inHours;
      final minutes = timeUntilMidnight.inMinutes % 60;
      
      if (hours > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${minutes}m';
      }
    }
    
    return '';
  }

  String getProgressText() {
    if (_currentChallenge == null) return '';
    
    switch (_currentChallenge!.state) {
      case ChallengeState.locked:
        return 'Challenge locked until ${getTimeUntilNextChallenge()}';
      case ChallengeState.available:
        return 'Ready to start!';
      case ChallengeState.inProgress:
        final elapsed = _elapsedTime;
        final estimated = _currentChallenge!.estimatedTime;
        final progress = elapsed.inSeconds / estimated.inSeconds;
        return 'Progress: ${(progress * 100).clamp(0, 100).toInt()}%';
      case ChallengeState.completed:
        return 'Completed! Next challenge in ${getTimeUntilNextChallenge()}';
    }
  }

  Future<void> shareChallenge() async {
    if (_currentChallenge == null) return;
    
    try {
      final shareText = _currentChallenge!.shareText;
      // In a real app, you would use the share_plus package here
      print('Sharing: $shareText');
      
    } catch (e) {
      print('Error sharing challenge: $e');
    }
  }

  // Get achievement message based on streak
  String getAchievementMessage() {
    final streak = currentStreak;
    
    if (streak == 0) return 'Start your journey today! 🚀';
    if (streak == 1) return 'Great start! Keep it up! 🌟';
    if (streak == 7) return 'One week streak! You\'re building habits! 🔥';
    if (streak == 30) return 'One month strong! You\'re unstoppable! 💪';
    if (streak == 100) return 'Century club! You\'re a legend! 👑';
    if (streak % 10 == 0) return '$streak days! You\'re on fire! 🔥';
    
    return 'Day $streak of your amazing journey! 💫';
  }

  // Get personalized encouragement
  String getEncouragementMessage() {
    if (_currentChallenge == null) return 'Ready for your next challenge?';
    
    final category = _currentChallenge!.category;
    final difficulty = _currentChallenge!.difficulty;
    
    final messages = {
      ChallengeCategory.mindfulness: [
        'Take a deep breath and be present 🧘‍♀️',
        'Your mindful moments create lasting peace ✨',
        'Every breath is a chance to center yourself 🌸',
      ],
      ChallengeCategory.fitness: [
        'Your body is capable of amazing things! 💪',
        'Movement is medicine for the soul 🏃‍♀️',
        'Every step counts towards a stronger you! 👟',
      ],
      ChallengeCategory.creative: [
        'Let your creativity flow freely! 🎨',
        'There are no mistakes in art, only discoveries! ✨',
        'Your unique perspective matters! 🌈',
      ],
      ChallengeCategory.learning: [
        'Every day is a chance to grow! 📚',
        'Curiosity is your superpower! 🔍',
        'Knowledge opens infinite doors! 🗝️',
      ],
      ChallengeCategory.social: [
        'Connection creates beautiful moments! 💕',
        'Your kindness ripples outward! 🌊',
        'Authentic relationships enrich life! 🤝',
      ],
      ChallengeCategory.personal: [
        'You\'re becoming your best self! 🌱',
        'Growth happens one step at a time! 👣',
        'Believe in your potential! 🌟',
      ],
    };
    
    final categoryMessages = messages[category] ?? messages[ChallengeCategory.personal]!;
    final random = Random();
    return categoryMessages[random.nextInt(categoryMessages.length)];
  }

  // Clear all data for logout/reset functionality
  Future<void> clearAllData() async {
    try {
      // Clear all stored data
      final storage = LocalStorageService();
      await storage.clearAllData();
      
      // Reset controller state
      _currentChallenge = null;
      _upcomingChallenges.clear();
      _completedChallenges.clear();
      _userProfile = null;
      _challengeStartTime = null;
      _elapsedTime = Duration.zero;
      
      // Cancel any running timers
      _timer?.cancel();
      _timer = null;
      
      notifyListeners();
      
    } catch (e) {
      print('Error clearing challenge data: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}