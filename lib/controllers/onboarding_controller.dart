import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';
import '../utils/constants.dart';

class OnboardingController extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final PageController pageController = PageController();
  
  bool _isLoading = true;
  bool _isCompleted = false;
  int _currentPage = 0;
  final int _totalPages = 6; // Welcome, Interests, Difficulty, Goals, Summary, Complete
  
  // User data collection
  String _userName = '';
  final Set<ChallengeCategory> _selectedInterests = {};
  Difficulty _selectedDifficulty = Difficulty.medium;
  String _selectedGoal = '';

  // Getters
  bool get isLoading => _isLoading;
  bool get isCompleted => _isCompleted;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  double get progress => (_currentPage + 1) / _totalPages;
  
  String get userName => _userName;
  Set<ChallengeCategory> get selectedInterests => _selectedInterests;
  Difficulty get selectedDifficulty => _selectedDifficulty;
  String get selectedGoal => _selectedGoal;
  
  bool get canGoNext {
    switch (_currentPage) {
      case 0: // Welcome
        return true;
      case 1: // Name input
        return _userName.trim().isNotEmpty;
      case 2: // Interests
        return _selectedInterests.isNotEmpty;
      case 3: // Difficulty
        return true; // Always has a default value
      case 4: // Goals
        return _selectedGoal.isNotEmpty;
      case 5: // Summary
        return true;
      default:
        return false;
    }
  }

  OnboardingController() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _storage.init();
      _isCompleted = _storage.isOnboardingCompleted;
      
      // If onboarding is completed, load existing user profile
      if (_isCompleted) {
        final profile = _storage.getUserProfile();
        if (profile != null) {
          _userName = profile.name;
          _selectedInterests.addAll(profile.interests);
          _selectedDifficulty = profile.difficulty;
          _selectedGoal = profile.goal;
        }
      }
    } catch (e) {
      print('Error initializing onboarding controller: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset to initial page when onboarding screen is rebuilt
  void resetPageController() {
    if (pageController.hasClients) {
      _currentPage = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pageController.hasClients) {
          pageController.animateToPage(
            0,
            duration: AnimationConstants.pageTransition,
            curve: AnimationConstants.defaultCurve,
          );
        }
      });
    }
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void toggleInterest(ChallengeCategory category) {
    if (_selectedInterests.contains(category)) {
      _selectedInterests.remove(category);
    } else {
      _selectedInterests.add(category);
    }
    notifyListeners();
  }

  void setDifficulty(Difficulty difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }

  void setGoal(String goal) {
    _selectedGoal = goal;
    notifyListeners();
  }

  Future<void> nextPage() async {
    if (!canGoNext) return;
    
    if (_currentPage < _totalPages - 1) {
      _currentPage++;
      notifyListeners();
      
      await pageController.animateToPage(
        _currentPage,
        duration: AnimationConstants.pageTransition,
        curve: AnimationConstants.defaultCurve,
      );
    }
  }

  Future<void> previousPage() async {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
      
      await pageController.animateToPage(
        _currentPage,
        duration: AnimationConstants.pageTransition,
        curve: AnimationConstants.defaultCurve,
      );
    }
  }

  Future<void> goToPage(int page) async {
    if (page >= 0 && page < _totalPages) {
      _currentPage = page;
      notifyListeners();
      
      await pageController.animateToPage(
        _currentPage,
        duration: AnimationConstants.pageTransition,
        curve: AnimationConstants.defaultCurve,
      );
    }
  }

  Future<void> skipOnboarding() async {
    // Set default values
    if (_userName.isEmpty) _userName = 'Challenger';
    if (_selectedInterests.isEmpty) {
      _selectedInterests.addAll([
        ChallengeCategory.mindfulness,
        ChallengeCategory.personal,
        ChallengeCategory.fitness,
      ]);
    }
    if (_selectedGoal.isEmpty) _selectedGoal = 'Build positive daily habits';
    
    await completeOnboarding();
  }

  Future<void> completeOnboarding() async {
    try {
      // Create user profile
      final profile = UserProfile(
        id: const Uuid().v4(),
        name: _userName.isEmpty ? 'Challenger' : _userName,
        interests: _selectedInterests.toList(),
        difficulty: _selectedDifficulty,
        goal: _selectedGoal.isEmpty ? 'Build positive daily habits' : _selectedGoal,
        createdAt: DateTime.now(),
      );
      
      // Save to storage
      await _storage.saveUserProfile(profile);
      await _storage.setOnboardingCompleted(true);
      
      _isCompleted = true;
      notifyListeners();
      
    } catch (e) {
      print('Error completing onboarding: $e');
      // Handle error - maybe show a snackbar
    }
  }

  // Validation helpers
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 30) {
      return 'Name must be less than 30 characters';
    }
    return null;
  }

  String? validateGoal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a goal';
    }
    if (value.trim().length < 5) {
      return 'Goal must be at least 5 characters';
    }
    if (value.trim().length > 100) {
      return 'Goal must be less than 100 characters';
    }
    return null;
  }

  // Reset onboarding (for testing or if user wants to redo)
  Future<void> resetOnboarding() async {
    _currentPage = 0;
    _userName = '';
    _selectedInterests.clear();
    _selectedDifficulty = Difficulty.medium;
    _selectedGoal = '';
    
    await _storage.setOnboardingCompleted(false);
    await _storage.deleteUserProfile();
    
    _isCompleted = false;
    notifyListeners();
    
    // Don't try to animate PageController as it may not be attached
    // The navigation will be handled by the main app state change
  }

  // Get personalized welcome message
  String getWelcomeMessage() {
    final timeOfDay = DateTime.now().hour;
    String greeting;
    
    if (timeOfDay < 12) {
      greeting = 'Good morning';
    } else if (timeOfDay < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }
    
    if (_userName.isNotEmpty) {
      return '$greeting, $_userName! 🌟';
    } else {
      return '$greeting! 🌟';
    }
  }

  // Get personalized summary
  Map<String, String> getSummary() {
    return {
      'name': _userName.isNotEmpty ? _userName : 'Challenger',
      'interests': _selectedInterests.map((e) => e.displayName).join(', '),
      'difficulty': _selectedDifficulty.displayName,
      'goal': _selectedGoal.isNotEmpty ? _selectedGoal : 'Build positive daily habits',
      'estimatedTime': _getEstimatedTimeText(),
    };
  }

  String _getEstimatedTimeText() {
    switch (_selectedDifficulty) {
      case Difficulty.easy:
        return '5-15 minutes per day';
      case Difficulty.medium:
        return '15-30 minutes per day';
      case Difficulty.hard:
        return '30-60 minutes per day';
    }
  }

  // Dispose
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}