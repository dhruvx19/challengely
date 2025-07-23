import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6B73FF);
  static const Color primaryDark = Color(0xFF5A63E6);
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color accent = Color(0xFF00E5FF);
  
  static const Color background = Color(0xFFFAFBFC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F7FA);
  
  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  
  static const Color cardShadow = Color(0x1A000000);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B9D), Color(0xFFF093FB)],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );
}

class AppDimensions {
  static const double padding = 16.0;
  static const double paddingSmall = 8.0;
  static const double paddingLarge = 24.0;
  static const double paddingXL = 32.0;
  
  static const double borderRadius = 12.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXL = 24.0;
  
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeLarge = 32.0;
  
  static const double buttonHeight = 52.0;
  static const double buttonHeightSmall = 40.0;
}

class AppStrings {
  static const String appName = 'Challengely';
  static const String tagline = 'Transform your daily routine with personalized challenges';
  
  // Onboarding
  static const String welcomeTitle = 'Welcome to Challengely';
  static const String welcomeSubtitle = 'Discover new habits and push your limits with daily challenges tailored just for you';
  static const String getStarted = 'Get Started';
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String finish = 'Start Challenging';
  
  // Categories
  static const String selectInterests = 'What interests you?';
  static const String selectInterestsSubtitle = 'Choose areas you\'d like to be challenged in';
  
  // Difficulty
  static const String selectDifficulty = 'Choose your level';
  static const String selectDifficultySubtitle = 'How challenging should your daily tasks be?';
  
  // Goals
  static const String setGoals = 'What\'s your goal?';
  static const String setGoalsSubtitle = 'Tell us what you want to achieve';
  
  // Chat
  static const String chatPlaceholder = 'Message...';
  static const String aiTyping = 'AI is typing...';
  static const String characterLimit = '200 character limit';
}

class AnimationConstants {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration staggerDelay = Duration(milliseconds: 100);
  static const Duration buttonPress = Duration(milliseconds: 150);
  static const Duration confetti = Duration(milliseconds: 3000);
  
  // Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;
}

class Assets {
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  
  // You would add actual asset paths here
  static const String logo = '${imagesPath}logo.png';
  static const String onboardingWelcome = '${imagesPath}onboarding_welcome.png';
}

enum ChallengeState {
  locked,
  available,
  inProgress,
  completed,
}

enum ChallengeCategory {
  fitness,
  creative,
  mindfulness,
  learning,
  social,
  personal,
}

enum Difficulty {
  easy,
  medium,
  hard,
}

extension ChallengeStateExtension on ChallengeState {
  String get displayName {
    switch (this) {
      case ChallengeState.locked:
        return 'Locked';
      case ChallengeState.available:
        return 'Available';
      case ChallengeState.inProgress:
        return 'In Progress';
      case ChallengeState.completed:
        return 'Completed';
    }
  }
  
  Color get color {
    switch (this) {
      case ChallengeState.locked:
        return AppColors.textTertiary;
      case ChallengeState.available:
        return AppColors.primary;
      case ChallengeState.inProgress:
        return AppColors.warning;
      case ChallengeState.completed:
        return AppColors.success;
    }
  }
}

extension ChallengeCategoryExtension on ChallengeCategory {
  String get displayName {
    switch (this) {
      case ChallengeCategory.fitness:
        return 'Fitness & Movement';
      case ChallengeCategory.creative:
        return 'Creative Expression';
      case ChallengeCategory.mindfulness:
        return 'Mindfulness & Wellness';
      case ChallengeCategory.learning:
        return 'Learning & Growth';
      case ChallengeCategory.social:
        return 'Social Connection';
      case ChallengeCategory.personal:
        return 'Personal Development';
    }
  }
  
  String get emoji {
    switch (this) {
      case ChallengeCategory.fitness:
        return '🏋️';
      case ChallengeCategory.creative:
        return '🎨';
      case ChallengeCategory.mindfulness:
        return '🧘';
      case ChallengeCategory.learning:
        return '📚';
      case ChallengeCategory.social:
        return '👥';
      case ChallengeCategory.personal:
        return '🌱';
    }
  }
  
  Color get color {
    switch (this) {
      case ChallengeCategory.fitness:
        return const Color(0xFF10B981);
      case ChallengeCategory.creative:
        return const Color(0xFFFF6B9D);
      case ChallengeCategory.mindfulness:
        return const Color(0xFF6B73FF);
      case ChallengeCategory.learning:
        return const Color(0xFFF59E0B);
      case ChallengeCategory.social:
        return const Color(0xFF8B5CF6);
      case ChallengeCategory.personal:
        return const Color(0xFF06B6D4);
    }
  }
}

extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }
  
  String get description {
    switch (this) {
      case Difficulty.easy:
        return '5-15 minutes\nPerfect for beginners';
      case Difficulty.medium:
        return '15-30 minutes\nFor regular challengers';
      case Difficulty.hard:
        return '30-60 minutes\nFor the ambitious';
    }
  }
  
  Color get color {
    switch (this) {
      case Difficulty.easy:
        return AppColors.success;
      case Difficulty.medium:
        return AppColors.warning;
      case Difficulty.hard:
        return AppColors.error;
    }
  }
  
  int get level {
    switch (this) {
      case Difficulty.easy:
        return 1;
      case Difficulty.medium:
        return 2;
      case Difficulty.hard:
        return 3;
    }
  }
}