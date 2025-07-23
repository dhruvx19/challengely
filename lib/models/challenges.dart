import 'dart:ui';

import '../utils/constants.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final Duration estimatedTime;
  final Difficulty difficulty;
  final ChallengeCategory category;
  final String detailedInstructions;
  final List<String> tips;
  final ChallengeState state;
  final DateTime? startTime;
  final DateTime? completionTime;
  final DateTime availableDate;
  final String emoji;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedTime,
    required this.difficulty,
    required this.category,
    required this.detailedInstructions,
    this.tips = const [],
    this.state = ChallengeState.locked,
    this.startTime,
    this.completionTime,
    required this.availableDate,
    required this.emoji,
  });

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    Duration? estimatedTime,
    Difficulty? difficulty,
    ChallengeCategory? category,
    String? detailedInstructions,
    List<String>? tips,
    ChallengeState? state,
    DateTime? startTime,
    DateTime? completionTime,
    DateTime? availableDate,
    String? emoji,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      detailedInstructions: detailedInstructions ?? this.detailedInstructions,
      tips: tips ?? this.tips,
      state: state ?? this.state,
      startTime: startTime ?? this.startTime,
      completionTime: completionTime ?? this.completionTime,
      availableDate: availableDate ?? this.availableDate,
      emoji: emoji ?? this.emoji,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'estimatedTimeMinutes': estimatedTime.inMinutes,
      'difficulty': difficulty.name,
      'category': category.name,
      'detailedInstructions': detailedInstructions,
      'tips': tips,
      'state': state.name,
      'startTime': startTime?.toIso8601String(),
      'completionTime': completionTime?.toIso8601String(),
      'availableDate': availableDate.toIso8601String(),
      'emoji': emoji,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      estimatedTime: Duration(minutes: json['estimatedTimeMinutes'] as int),
      difficulty: Difficulty.values.firstWhere((d) => d.name == json['difficulty']),
      category: ChallengeCategory.values.firstWhere((c) => c.name == json['category']),
      detailedInstructions: json['detailedInstructions'] as String,
      tips: List<String>.from(json['tips'] as List),
      state: ChallengeState.values.firstWhere((s) => s.name == json['state']),
      startTime: json['startTime'] != null 
          ? DateTime.parse(json['startTime'] as String)
          : null,
      completionTime: json['completionTime'] != null 
          ? DateTime.parse(json['completionTime'] as String)
          : null,
      availableDate: DateTime.parse(json['availableDate'] as String),
      emoji: json['emoji'] as String,
    );
  }

  bool get isAvailable {
    final now = DateTime.now();
    final available = DateTime(
      availableDate.year,
      availableDate.month,
      availableDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    return today.isAtSameMomentAs(available) || today.isAfter(available);
  }

  bool get isToday {
    final now = DateTime.now();
    return availableDate.year == now.year &&
           availableDate.month == now.month &&
           availableDate.day == now.day;
  }

  Duration? get timeSpent {
    if (startTime == null) return null;
    final endTime = completionTime ?? DateTime.now();
    return endTime.difference(startTime!);
  }

  String get timeSpentText {
    final spent = timeSpent;
    if (spent == null) return '0 minutes';
    
    final hours = spent.inHours;
    final minutes = spent.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String get estimatedTimeText {
    final hours = estimatedTime.inHours;
    final minutes = estimatedTime.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes} min';
    }
  }

  String get shareText {
    return 'I just completed the "$title" challenge in Challengely! $emoji\n\n'
           'Time spent: $timeSpentText\n'
           'Category: ${category.displayName}\n'
           'Difficulty: ${difficulty.displayName}\n\n'
           '#ChallengeAccepted #PersonalGrowth #Challengely';
  }

  Color get categoryColor => category.color;
  Color get difficultyColor => difficulty.color;
  Color get stateColor => state.color;

  @override
  String toString() {
    return 'Challenge(id: $id, title: $title, state: $state, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Challenge &&
           other.id == id &&
           other.title == title &&
           other.state == state;
  }

  @override
  int get hashCode => Object.hash(id, title, state);
}

// Predefined challenges
class ChallengeData {
  static List<Challenge> getSampleChallenges() {
    final now = DateTime.now();
    
    return [
      // Today's challenge
      Challenge(
        id: 'meditation-5min',
        title: '5-Minute Meditation',
        description: 'Find a quiet space and focus on your breath for 5 minutes',
        estimatedTime: const Duration(minutes: 5),
        difficulty: Difficulty.easy,
        category: ChallengeCategory.mindfulness,
        detailedInstructions: '''1. Find a comfortable, quiet space
2. Sit with your back straight and eyes closed
3. Focus on your natural breathing
4. When your mind wanders, gently return to your breath
5. Continue for 5 minutes''',
        tips: [
          'Start with shorter sessions if 5 minutes feels too long',
          'Use a meditation app or timer',
          'Don\'t worry about "doing it right" - just breathe',
          'Consistency matters more than duration',
        ],
        availableDate: now,
        emoji: '🧘‍♀️',
      ),
      
      // Tomorrow's challenge
      Challenge(
        id: 'gratitude-notes',
        title: 'Write 3 Gratitude Notes',
        description: 'Write down 3 things you\'re grateful for today',
        estimatedTime: const Duration(minutes: 10),
        difficulty: Difficulty.easy,
        category: ChallengeCategory.personal,
        detailedInstructions: '''1. Get a pen and paper or open a notes app
2. Think about your day and recent experiences
3. Write down 3 specific things you're grateful for
4. For each item, write why you're grateful for it
5. Read through your list and feel the positivity''',
        tips: [
          'Be specific - instead of "family", write "my sister\'s encouraging text"',
          'Include small things - a good cup of coffee counts!',
          'Write in detail to deepen the feeling',
          'Keep a gratitude journal for ongoing benefits',
        ],
        availableDate: now.add(const Duration(days: 1)),
        emoji: '🙏',
      ),
      
      // Day after tomorrow
      Challenge(
        id: 'creative-sketch',
        title: 'Draw Something Around You',
        description: 'Spend 15 minutes sketching any object you can see',
        estimatedTime: const Duration(minutes: 15),
        difficulty: Difficulty.medium,
        category: ChallengeCategory.creative,
        detailedInstructions: '''1. Find a pencil and paper
2. Look around and choose any object that catches your eye
3. Spend 15 minutes sketching it
4. Don\'t worry about perfection - focus on observation
5. Notice details you might normally miss''',
        tips: [
          'Choose something interesting but not too complex',
          'Focus on shapes and shadows',
          'It\'s about observation, not artistic skill',
          'Take breaks to look at your subject',
        ],
        availableDate: now.add(const Duration(days: 2)),
        emoji: '🎨',
      ),
      
      Challenge(
        id: 'walk-nature',
        title: 'Mindful Nature Walk',
        description: 'Take a 20-minute walk and connect with nature',
        estimatedTime: const Duration(minutes: 20),
        difficulty: Difficulty.easy,
        category: ChallengeCategory.fitness,
        detailedInstructions: '''1. Go outside to a park, garden, or natural area
2. Walk at a comfortable pace
3. Use all your senses - what do you see, hear, smell?
4. Stop occasionally to observe plants, animals, or weather
5. Leave your phone in your pocket''',
        tips: [
          'Even urban areas have trees and sky to observe',
          'Focus on being present rather than reaching a destination',
          'Notice seasonal changes',
          'Breathe deeply and enjoy the fresh air',
        ],
        availableDate: now.add(const Duration(days: 3)),
        emoji: '🌳',
      ),
      
      Challenge(
        id: 'learn-fact',
        title: 'Learn One Fascinating Fact',
        description: 'Research and learn one interesting fact about a topic you\'re curious about',
        estimatedTime: const Duration(minutes: 15),
        difficulty: Difficulty.easy,
        category: ChallengeCategory.learning,
        detailedInstructions: '''1. Think of something you've always wondered about
2. Spend 10-15 minutes researching it online
3. Find one fascinating fact you didn't know before
4. Share it with someone or write it down
5. Let your curiosity lead you to related topics''',
        tips: [
          'Use reliable sources like Wikipedia, museums, or educational sites',
          'Follow your genuine interests',
          'Consider subscribing to fact-a-day content',
          'Keep a list of things you want to learn about',
        ],
        availableDate: now.add(const Duration(days: 4)),
        emoji: '📚',
      ),
      
      Challenge(
        id: 'compliment-someone',
        title: 'Give a Genuine Compliment',
        description: 'Give a heartfelt compliment to someone in your life',
        estimatedTime: const Duration(minutes: 5),
        difficulty: Difficulty.easy,
        category: ChallengeCategory.social,
        detailedInstructions: '''1. Think of someone who has positively impacted your day/week
2. Consider what specific quality or action you appreciate about them
3. Reach out via text, call, or in person
4. Give them a specific, genuine compliment
5. Notice how it makes both of you feel''',
        tips: [
          'Be specific about what they did or their quality',
          'Make it about them, not about you',
          'Don\'t expect anything in return',
          'Consider people you might not usually compliment',
        ],
        availableDate: now.add(const Duration(days: 5)),
        emoji: '💝',
      ),
      
      Challenge(
        id: 'declutter-space',
        title: 'Organize One Small Space',
        description: 'Spend 15 minutes decluttering and organizing one area of your home',
        estimatedTime: const Duration(minutes: 15),
        difficulty: Difficulty.medium,
        category: ChallengeCategory.personal,
        detailedInstructions: '''1. Choose a small area like a desk, drawer, or shelf
2. Remove everything from the space
3. Clean the empty area
4. Sort items into keep, donate, and discard piles
5. Put back only what you need and use regularly''',
        tips: [
          'Start small - even one drawer makes a difference',
          'Ask yourself: "Have I used this in the last 6 months?"',
          'Create designated spots for items you\'re keeping',
          'Celebrate the feeling of a clean, organized space',
        ],
        availableDate: now.add(const Duration(days: 6)),
        emoji: '🧹',
      ),
      
      Challenge(
        id: 'pushup-challenge',
        title: 'Do Your Maximum Push-ups',
        description: 'See how many push-ups you can do and celebrate your strength',
        estimatedTime: const Duration(minutes: 10),
        difficulty: Difficulty.medium,
        category: ChallengeCategory.fitness,
        detailedInstructions: '''1. Find a clear floor space
2. Warm up with arm circles and light stretching
3. Get into push-up position (modify if needed)
4. Do as many push-ups as you can with good form
5. Record your number and celebrate your effort!''',
        tips: [
          'Modify on your knees if needed - that counts too!',
          'Focus on form over quantity',
          'Take breaks between sets if needed',
          'Remember your number for next time',
        ],
        availableDate: now.add(const Duration(days: 7)),
        emoji: '💪',
      ),
      
      Challenge(
        id: 'phone-free-hour',
        title: 'One Phone-Free Hour',
        description: 'Spend one hour without looking at your phone or other screens',
        estimatedTime: const Duration(minutes: 60),
        difficulty: Difficulty.hard,
        category: ChallengeCategory.mindfulness,
        detailedInstructions: '''1. Choose an hour when you don't expect important calls
2. Put your phone in another room or turn it off
3. Engage in offline activities: read, cook, exercise, or create
4. Notice any urges to check your phone
5. Reflect on how you feel at the end of the hour''',
        tips: [
          'Let important people know you\'ll be unavailable',
          'Plan an engaging offline activity',
          'Notice the urge to reach for your phone',
          'Start with 30 minutes if an hour feels too long',
        ],
        availableDate: now.add(const Duration(days: 8)),
        emoji: '📵',
      ),
    ];
  }
  
  static Challenge getTodaysChallenge() {
    final challenges = getSampleChallenges();
    final today = DateTime.now();
    
    // Find today's challenge or return the first available one
    for (final challenge in challenges) {
      if (challenge.availableDate.year == today.year &&
          challenge.availableDate.month == today.month &&
          challenge.availableDate.day == today.day) {
        return challenge.copyWith(state: ChallengeState.available);
      }
    }
    
    // If no challenge for today, return the first one
    return challenges.first.copyWith(state: ChallengeState.available);
  }
  
  static List<Challenge> getUpcomingChallenges() {
    final challenges = getSampleChallenges();
    final today = DateTime.now();
    
    return challenges.where((challenge) {
      return challenge.availableDate.isAfter(today);
    }).take(3).toList();
  }
}