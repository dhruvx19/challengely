import 'dart:ui';

import '../utils/constants.dart';

class UserProfile {
  final String id;
  final String name;
  final List<ChallengeCategory> interests;
  final Difficulty difficulty;
  final String goal;
  final DateTime createdAt;
  final int currentStreak;
  final int totalChallengesCompleted;
  final DateTime? lastChallengeDate;

  const UserProfile({
    required this.id,
    required this.name,
    required this.interests,
    required this.difficulty,
    required this.goal,
    required this.createdAt,
    this.currentStreak = 0,
    this.totalChallengesCompleted = 0,
    this.lastChallengeDate,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    List<ChallengeCategory>? interests,
    Difficulty? difficulty,
    String? goal,
    DateTime? createdAt,
    int? currentStreak,
    int? totalChallengesCompleted,
    DateTime? lastChallengeDate,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      interests: interests ?? this.interests,
      difficulty: difficulty ?? this.difficulty,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
      currentStreak: currentStreak ?? this.currentStreak,
      totalChallengesCompleted: totalChallengesCompleted ?? this.totalChallengesCompleted,
      lastChallengeDate: lastChallengeDate ?? this.lastChallengeDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'interests': interests.map((e) => e.name).toList(),
      'difficulty': difficulty.name,
      'goal': goal,
      'createdAt': createdAt.toIso8601String(),
      'currentStreak': currentStreak,
      'totalChallengesCompleted': totalChallengesCompleted,
      'lastChallengeDate': lastChallengeDate?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      interests: (json['interests'] as List<dynamic>)
          .map((e) => ChallengeCategory.values.firstWhere((category) => category.name == e))
          .toList(),
      difficulty: Difficulty.values.firstWhere((d) => d.name == json['difficulty']),
      goal: json['goal'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      currentStreak: json['currentStreak'] as int? ?? 0,
      totalChallengesCompleted: json['totalChallengesCompleted'] as int? ?? 0,
      lastChallengeDate: json['lastChallengeDate'] != null 
          ? DateTime.parse(json['lastChallengeDate'] as String)
          : null,
    );
  }

  bool get hasCompletedTodaysChallenge {
    if (lastChallengeDate == null) return false;
    final today = DateTime.now();
    final lastDate = lastChallengeDate!;
    return lastDate.year == today.year &&
           lastDate.month == today.month &&
           lastDate.day == today.day;
  }

  bool get shouldUpdateStreak {
    if (lastChallengeDate == null) return true;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final lastDate = lastChallengeDate!;
    
    // If last challenge was yesterday, maintain streak
    // If last challenge was today, no update needed
    // If last challenge was before yesterday, reset streak
    return (lastDate.year == yesterday.year &&
            lastDate.month == yesterday.month &&
            lastDate.day == yesterday.day) ||
           (lastDate.year < yesterday.year ||
            lastDate.month < yesterday.month ||
            lastDate.day < yesterday.day);
  }

  String get streakText {
    if (currentStreak == 0) return 'Start your streak!';
    if (currentStreak == 1) return '1 day streak 🔥';
    return '$currentStreak days streak 🔥';
  }

  String get achievementLevel {
    if (totalChallengesCompleted < 7) return 'Beginner';
    if (totalChallengesCompleted < 30) return 'Challenger';
    if (totalChallengesCompleted < 100) return 'Achiever';
    if (totalChallengesCompleted < 365) return 'Master';
    return 'Legend';
  }

  Color get achievementColor {
    switch (achievementLevel) {
      case 'Beginner':
        return const Color(0xFF10B981);
      case 'Challenger':
        return const Color(0xFF3B82F6);
      case 'Achiever':
        return const Color(0xFF8B5CF6);
      case 'Master':
        return const Color(0xFFF59E0B);
      case 'Legend':
        return const Color(0xFFEF4444);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, interests: $interests, difficulty: $difficulty, streak: $currentStreak)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
           other.id == id &&
           other.name == name &&
           other.interests.toString() == interests.toString() &&
           other.difficulty == difficulty &&
           other.goal == goal;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      interests,
      difficulty,
      goal,
    );
  }
}