import 'dart:math';
import '../models/challenges.dart';
import '../models/chat_message.dart';
import '../utils/constants.dart';

class HardcodedResponseService {
  static final HardcodedResponseService _instance = HardcodedResponseService._internal();
  factory HardcodedResponseService() => _instance;
  HardcodedResponseService._internal();

  final Random _random = Random();
  final Map<String, List<String>> _lastUsedResponses = {};

  // Response categories
  final Map<String, List<String>> _responses = {
    // General encouragement
    'nervous|scared|worried|anxious': [
      "That's totally normal! Start small and build confidence. You've got this! 💪",
      "Everyone feels that way sometimes. Take a deep breath and begin when ready. 🌟",
      "Feeling nervous means you're about to do something brave! I believe in you! 🦋",
      "Those butterflies? They're just excitement in disguise! Let's turn that nervous energy into action! ✨",
    ],
    
    'distracted|unfocused|lost': [
      "Try the 5-4-3-2-1 grounding technique: 5 things you see, 4 you hear, 3 you touch, 2 you smell, 1 you taste. 🧘‍♀️",
      "Distractions are normal. Gently redirect your attention back to the challenge. 🎯",
      "When your mind wanders, just notice it without judgment and come back to the present moment. 🌊",
      "It's like training a puppy - be patient and kind with yourself as you guide your attention back! 🐕",
    ],
    
    'struggling|difficult|hard|tough': [
      "Challenges are meant to be... well, challenging! That means you're growing! 🌱",
      "The struggle is where the magic happens. You're building mental muscle right now! 💪",
      "Break it down into smaller steps. What's the tiniest thing you can do right now? 🪜",
      "Remember: you don't have to be perfect, you just have to keep going! 🚀",
    ],
    
    'motivation|encourage|support': [
      "You're already amazing for trying! That's more than most people do. Keep going! 🌟",
      "Every small step counts. You're building something beautiful, one challenge at a time! 🏗️",
      "Think about how proud you'll feel when you complete this. That feeling is waiting for you! 🏆",
      "You've overcome challenges before, and you'll overcome this one too! 🔥",
    ],
    
    'help|confused|how': [
      "I'm here to help! What specific part would you like guidance on? 🤝",
      "Let's break this down step by step. What's your first question? 📝",
      "No question is too small! What can I clarify for you? 💡",
      "Think of me as your challenge buddy - I'm here to support you through this! 👫",
    ],
    
    // Challenge-specific responses
    'meditation|breathe|breathing': [
      "Focus on your natural breath - don't try to change it, just observe it. 🌬️",
      "If thoughts come up, imagine them as clouds passing through the sky of your mind. ☁️",
      "Your breath is always with you - it's the perfect anchor for your attention. ⚓",
      "Even 30 seconds of focused breathing counts! Start where you are. 🧘‍♀️",
    ],
    
    'gratitude|thankful|grateful': [
      "Try to be specific - instead of 'my family', think 'my sister's encouraging text this morning'. 💕",
      "Small things count too! A good cup of coffee or a sunny morning are perfect gratitude material. ☕",
      "Notice how focusing on gratitude shifts your energy. Pretty amazing, right? ✨",
      "Gratitude is like a muscle - the more you use it, the stronger it gets! 💪",
    ],
    
    'creative|art|draw|sketch': [
      "Don't worry about making it 'good' - focus on really seeing your subject. 👁️",
      "Notice the shadows, the shapes, the details you normally miss. That's the real magic! 🎨",
      "Every artist started with their first sketch. You're in good company! 👩‍🎨",
      "Art is about observation, not perfection. You're training your eyes to really see! 🔍",
    ],
    
    'exercise|fitness|workout|walk': [
      "Listen to your body and go at your own pace. Movement is movement! 🚶‍♀️",
      "Focus on how good you feel during and after, not just the numbers. 😊",
      "Your body is amazing and capable. Celebrate what it can do! 🎉",
      "Even a gentle walk counts as taking care of yourself. You're doing great! 🌳",
    ],
    
    // Progress and completion
    'done|completed|finished|good|great|awesome': [
      "Amazing work! How do you feel right now? 🌟",
      "You did it! That's another step forward in your growth journey. 🎯",
      "Fantastic! What was the best part of that challenge for you? ✨",
      "You should be so proud! You showed up and followed through. 🏆",
    ],
    
    'streak|progress|days': [
      "Your consistency is building something powerful! Every day counts. 🔥",
      "Look at you creating positive habits! This is how transformation happens. 📈",
      "Each day you show up, you're proving to yourself that you can do hard things. 💪",
      "Your future self is going to thank you for the habits you're building today! 🙏",
    ],
    
    // Default responses
    'default': [
      "I'm here to support you through your challenge journey! What's on your mind? 🤗",
      "Every challenge is a chance to grow. How can I help you with today's challenge? 🌱",
      "You're doing something amazing by committing to daily challenges! What do you need? ✨",
      "I believe in your ability to grow and overcome challenges! How are you feeling? 💫",
    ],
  };

  // Context-specific responses
  final Map<String, List<String>> _contextResponses = {
    'pre_challenge': [
      "Ready to tackle today's challenge? I'm here if you need any support! 🚀",
      "Today's challenge is a great opportunity to grow. You've got this! 🌟",
      "Take a moment to set your intention for this challenge. What do you want to get out of it? 🎯",
      "Remember, the goal isn't perfection - it's progress. Let's do this! 💪",
    ],
    
    'during_challenge': [
      "You're in the middle of it now! How are you feeling? 🔄",
      "Remember to breathe and stay present. You're doing great! 🌬️",
      "If it feels challenging, that's exactly where growth happens! Keep going! 🌱",
      "Take it one step at a time. What's the next small thing you can do? 👣",
    ],
    
    'post_challenge': [
      "How did that feel? What did you notice about yourself during the challenge? 🤔",
      "You completed another challenge! What was the most surprising part? ✨",
      "Take a moment to appreciate what you just accomplished. You showed up! 🎉",
      "What would you tell someone else who was about to try this challenge? 💬",
    ],
  };

  // Challenge-specific context responses
  final Map<ChallengeCategory, Map<String, List<String>>> _categoryResponses = {
    ChallengeCategory.mindfulness: {
      'encouragement': [
        "Mindfulness is about being present, not about having a quiet mind. Notice what comes up! 🧘‍♀️",
        "Each moment of awareness is a victory, even if your mind wanders. You're training attention! 🎯",
        "There's no 'wrong' way to be mindful. Just be curious about your experience. 🔍",
      ],
      'tips': [
        "Try setting a gentle timer so you don't worry about time. ⏲️",
        "Find a comfortable position where you can stay alert but relaxed. 🪑",
        "Notice your breath without trying to change it - just observe. 👀",
      ],
    },
    
    ChallengeCategory.fitness: {
      'encouragement': [
        "Your body is incredible! It's carrying you through life every day. 💪",
        "Movement is medicine. You're taking care of yourself right now! 💊",
        "Every step, every rep, every minute counts. You're investing in yourself! 📈",
      ],
      'tips': [
        "Start with a gentle warm-up to prepare your body. 🔥",
        "Focus on form over speed or intensity. Quality matters! ✨",
        "Listen to your body - it's smarter than you think! 👂",
      ],
    },
    
    ChallengeCategory.creative: {
      'encouragement': [
        "Creativity isn't about talent - it's about courage to try! You're being brave! 🎨",
        "There's no wrong way to be creative. Your unique perspective matters! 🌈",
        "Every creative act is an act of self-expression. Let yourself be seen! 👁️",
      ],
      'tips': [
        "Set aside perfectionism - this is about exploration, not perfection! 🗺️",
        "Pay attention to what delights or intrigues you. Follow that curiosity! ✨",
        "Give yourself permission to be a beginner. That's where the magic starts! 🌟",
      ],
    },
    
    ChallengeCategory.learning: {
      'encouragement': [
        "Your brain is creating new connections right now! Learning is literally changing you! 🧠",
        "Curiosity is one of the most beautiful human qualities. Keep exploring! 🔍",
        "Every question leads to new discoveries. You're on an adventure! 🗺️",
      ],
      'tips': [
        "Try to connect new information to something you already know. 🔗",
        "Ask 'why' and 'how' questions to go deeper. 🤔",
        "Teaching someone else what you learned helps it stick! 👥",
      ],
    },
    
    ChallengeCategory.social: {
      'encouragement': [
        "Connection is one of our deepest human needs. You're nurturing something beautiful! 💕",
        "Small acts of kindness create ripple effects you may never see. Keep going! 🌊",
        "You're making someone's day brighter just by reaching out! ☀️",
      ],
      'tips': [
        "Be genuine - authentic connection matters more than perfect words. 💯",
        "Listen with curiosity and without judgment. 👂",
        "Small gestures often mean the most. Don't overthink it! 💝",
      ],
    },
    
    ChallengeCategory.personal: {
      'encouragement': [
        "Personal growth takes courage. You're investing in your best self! 🌱",
        "Every small step forward is worth celebrating. Progress isn't always linear! 📈",
        "You're exactly where you need to be on your journey. Trust the process! ✨",
      ],
      'tips': [
        "Be patient and compassionate with yourself. Growth takes time! ⏰",
        "Notice what you're learning about yourself through this process. 🪞",
        "Celebrate small wins - they add up to big changes! 🎉",
      ],
    },
  };

  String getResponse(String userMessage, {
    Challenge? currentChallenge,
    String? context,
    int? userStreak,
  }) {
    final normalizedMessage = userMessage.toLowerCase().trim();
    
    // First, try to match specific keywords
    for (final entry in _responses.entries) {
      final keywords = entry.key.split('|');
      for (final keyword in keywords) {
        if (normalizedMessage.contains(keyword)) {
          return _getRandomResponse(entry.key, entry.value);
        }
      }
    }
    
    // Try context-specific responses
    if (context != null && _contextResponses.containsKey(context)) {
      return _getRandomResponse(context, _contextResponses[context]!);
    }
    
    // Try challenge category-specific responses
    if (currentChallenge != null) {
      final categoryResponses = _categoryResponses[currentChallenge.category];
      if (categoryResponses != null) {
        if (normalizedMessage.contains('help') || normalizedMessage.contains('tip')) {
          return _getRandomResponse('tips_${currentChallenge.category.name}', categoryResponses['tips']!);
        } else {
          return _getRandomResponse('encouragement_${currentChallenge.category.name}', categoryResponses['encouragement']!);
        }
      }
    }
    
    // Default response
    return _getRandomResponse('default', _responses['default']!);
  }

  String _getRandomResponse(String key, List<String> responses) {
    // Ensure we don't repeat the same response too often
    final lastUsed = _lastUsedResponses[key] ?? [];
    List<String> availableResponses = responses;
    
    // If we've used more than half the responses recently, clear the history
    if (lastUsed.length >= responses.length / 2) {
      _lastUsedResponses[key] = [];
      availableResponses = responses;
    } else {
      // Filter out recently used responses
      availableResponses = responses.where((response) => !lastUsed.contains(response)).toList();
      if (availableResponses.isEmpty) {
        availableResponses = responses;
      }
    }
    
    final selectedResponse = availableResponses[_random.nextInt(availableResponses.length)];
    
    // Track this response as used
    _lastUsedResponses[key] = [...lastUsed, selectedResponse];
    
    return selectedResponse;
  }

  List<String> getWelcomeMessages(Challenge challenge) {
    return [
      "Hey there! 👋 I'm your challenge assistant. I'm here to help you with today's challenge!",
      "Today's challenge is: *${challenge.title}* ${challenge.emoji}",
      "It should take about ${challenge.estimatedTimeText} and is ${challenge.difficulty.displayName.toLowerCase()} level.",
      "How are you feeling about it? I'm here if you need any tips or encouragement! 💪",
    ];
  }

  List<String> getChallengeStartMessages(Challenge challenge) {
    final categoryResponses = _categoryResponses[challenge.category];
    final tips = categoryResponses?['tips'] ?? [];
    
    return [
      "Great! You're starting the ${challenge.title} challenge! 🚀",
      if (tips.isNotEmpty) _getRandomResponse('start_tip_${challenge.category.name}', tips),
      "Remember, I'm here if you need support during the challenge. You've got this! 💪",
    ];
  }

  List<String> getChallengeCompletionMessages(Challenge challenge, Duration timeSpent) {
    final messages = [
      "Congratulations! 🎉 You completed the ${challenge.title} challenge!",
      "You spent ${_formatDuration(timeSpent)} on it. How do you feel?",
    ];
    
    if (timeSpent < challenge.estimatedTime) {
      messages.add("You finished even faster than expected! Awesome work! ⚡");
    } else if (timeSpent > challenge.estimatedTime * 1.5) {
      messages.add("You took your time and really committed to it. That's dedication! 🌟");
    } else {
      messages.add("Perfect timing! You gave it exactly what it needed. 👌");
    }
    
    return messages;
  }

  String getStreakMessage(int streak) {
    if (streak == 0) {
      return "Ready to start your challenge streak? Every journey begins with a single step! 🚀";
    } else if (streak == 1) {
      return "You've started your streak! One day down, many more adventures ahead! 🌟";
    } else if (streak < 7) {
      return "You're building momentum! $streak days strong and growing! 💪";
    } else if (streak < 30) {
      return "Wow! $streak days of consistency! You're creating real change! 🔥";
    } else if (streak < 100) {
      return "Incredible! $streak days of growth! You're becoming unstoppable! 🏆";
    } else {
      return "LEGENDARY! $streak days of dedication! You're an inspiration! 👑";
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes} minutes';
    }
  }

  // Get responses based on user's emotional state
  String getEmotionalResponse(String emotion) {
    final responses = {
      'excited': [
        "I love your enthusiasm! That energy is going to carry you far! 🚀",
        "Yes! That excitement is infectious! Let's channel it into your challenge! ⚡",
        "Your enthusiasm is beautiful! I'm excited to see what you accomplish! 🌟",
      ],
      'confident': [
        "That confidence is well-earned! You've got the skills and mindset to succeed! 💪",
        "I can feel your confidence from here! You're ready for anything! 🦾",
        "Confidence looks good on you! Go show this challenge what you're made of! ✨",
      ],
      'grateful': [
        "Gratitude is such a powerful mindset! It's going to serve you well today! 🙏",
        "I love that you're starting from a place of appreciation! That's wisdom! 💝",
        "Your grateful heart is going to make this challenge even more meaningful! ☀️",
      ],
      'determined': [
        "That determination is your superpower! Nothing can stop you with that attitude! 🔥",
        "I can feel your resolve! That's the spirit that moves mountains! ⛰️",
        "Your determination is inspiring! You're going to crush this challenge! 💥",
      ],
    };
    
    return _getRandomResponse(emotion, responses[emotion] ?? responses['confident']!);
  }
}