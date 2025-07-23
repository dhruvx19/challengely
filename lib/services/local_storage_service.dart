import 'dart:convert';
import 'package:challengely/models/challenges.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/chat_message.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyUserProfile = 'user_profile';
  static const String _keyChallenges = 'challenges';
  static const String _keyChatMessages = 'chat_messages';
  static const String _keyCurrentStreak = 'current_streak';
  static const String _keyLastChallengeDate = 'last_challenge_date';
  static const String _keyTotalChallengesCompleted = 'total_challenges_completed';
  static const String _keyAppTheme = 'app_theme';
  static const String _keyNotificationsEnabled = 'notifications_enabled';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    assert(_prefs != null, 'LocalStorageService not initialized. Call init() first.');
    return _prefs!;
  }

  // Onboarding
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await prefs.setBool(_keyOnboardingCompleted, completed);
  }

  bool get isOnboardingCompleted {
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  // User Profile
  Future<bool> saveUserProfile(UserProfile profile) async {
    final jsonString = jsonEncode(profile.toJson());
    return await prefs.setString(_keyUserProfile, jsonString);
  }

  UserProfile? getUserProfile() {
    final jsonString = prefs.getString(_keyUserProfile);
    if (jsonString == null) return null;
    
    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProfile.fromJson(jsonMap);
    } catch (e) {
      print('Error parsing user profile: $e');
      return null;
    }
  }

  Future<bool> deleteUserProfile() async {
    return await prefs.remove(_keyUserProfile);
  }

  // Challenges
  Future<bool> saveChallenges(List<Challenge> challenges) async {
    final jsonList = challenges.map((challenge) => challenge.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    return await prefs.setString(_keyChallenges, jsonString);
  }

  List<Challenge> getChallenges() {
    final jsonString = prefs.getString(_keyChallenges);
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => Challenge.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error parsing challenges: $e');
      return [];
    }
  }

  Future<bool> saveChallenge(Challenge challenge) async {
    final challenges = getChallenges();
    final existingIndex = challenges.indexWhere((c) => c.id == challenge.id);
    
    if (existingIndex >= 0) {
      challenges[existingIndex] = challenge;
    } else {
      challenges.add(challenge);
    }
    
    return await saveChallenges(challenges);
  }

  // Chat Messages
  Future<bool> saveChatMessages(List<ChatMessage> messages) async {
    final jsonList = messages.map((message) => message.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    return await prefs.setString(_keyChatMessages, jsonString);
  }

  List<ChatMessage> getChatMessages({String? challengeId}) {
    final jsonString = prefs.getString(_keyChatMessages);
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final messages = jsonList.map((json) => ChatMessage.fromJson(json as Map<String, dynamic>)).toList();
      
      if (challengeId != null) {
        return messages.where((message) => message.challengeId == challengeId).toList();
      }
      
      return messages;
    } catch (e) {
      print('Error parsing chat messages: $e');
      return [];
    }
  }

  Future<bool> saveChatMessage(ChatMessage message) async {
    final messages = getChatMessages();
    messages.add(message);
    return await saveChatMessages(messages);
  }

  Future<bool> clearChatMessages({String? challengeId}) async {
    if (challengeId == null) {
      return await prefs.remove(_keyChatMessages);
    } else {
      final messages = getChatMessages();
      final filteredMessages = messages.where((message) => message.challengeId != challengeId).toList();
      return await saveChatMessages(filteredMessages);
    }
  }

  // Streak and Progress
  Future<bool> setCurrentStreak(int streak) async {
    return await prefs.setInt(_keyCurrentStreak, streak);
  }

  int get currentStreak {
    return prefs.getInt(_keyCurrentStreak) ?? 0;
  }

  Future<bool> setLastChallengeDate(DateTime date) async {
    return await prefs.setString(_keyLastChallengeDate, date.toIso8601String());
  }

  DateTime? get lastChallengeDate {
    final dateString = prefs.getString(_keyLastChallengeDate);
    if (dateString == null) return null;
    
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing last challenge date: $e');
      return null;
    }
  }

  Future<bool> setTotalChallengesCompleted(int total) async {
    return await prefs.setInt(_keyTotalChallengesCompleted, total);
  }

  int get totalChallengesCompleted {
    return prefs.getInt(_keyTotalChallengesCompleted) ?? 0;
  }

  Future<bool> incrementChallengesCompleted() async {
    final current = totalChallengesCompleted;
    return await setTotalChallengesCompleted(current + 1);
  }

  // App Settings
  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  bool get notificationsEnabled {
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  Future<bool> setAppTheme(String theme) async {
    return await prefs.setString(_keyAppTheme, theme);
  }

  String get appTheme {
    return prefs.getString(_keyAppTheme) ?? 'system';
  }

  // Utility Methods
  Future<bool> clearAllData() async {
    return await prefs.clear();
  }

  Future<bool> resetToDefaults() async {
    await clearAllData();
    await setOnboardingCompleted(false);
    await setNotificationsEnabled(true);
    await setAppTheme('system');
    return true;
  }

  // Debug Methods
  void printAllKeys() {
    final keys = prefs.getKeys();
    print('All SharedPreferences keys: $keys');
    for (final key in keys) {
      final value = prefs.get(key);
      print('$key: $value');
    }
  }

  Map<String, dynamic> getAllData() {
    final keys = prefs.getKeys();
    final data = <String, dynamic>{};
    for (final key in keys) {
      data[key] = prefs.get(key);
    }
    return data;
  }

  // Backup and Restore
  Map<String, dynamic> exportData() {
    return getAllData();
  }

  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      await clearAllData();
      
      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;
        
        if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is String) {
          await prefs.setString(key, value);
        } else if (value is List<String>) {
          await prefs.setStringList(key, value);
        }
      }
      
      return true;
    } catch (e) {
      print('Error importing data: $e');
      return false;
    }
  }
}