enum MessageType {
  user,
  ai,
  system,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  failed,
}

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final String? challengeId;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.challengeId,
    this.metadata,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    String? challengeId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      challengeId: challengeId ?? this.challengeId,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'challengeId': challengeId,
      'metadata': metadata,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere((t) => t.name == json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: MessageStatus.values.firstWhere((s) => s.name == json['status']),
      challengeId: json['challengeId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  bool get isUser => type == MessageType.user;
  bool get isAI => type == MessageType.ai;
  bool get isSystem => type == MessageType.system;
  bool get isPending => status == MessageStatus.sending;
  bool get isFailed => status == MessageStatus.failed;

  String get timeText {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, type: $type, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
           other.id == id &&
           other.content == content &&
           other.type == type;
  }

  @override
  int get hashCode => Object.hash(id, content, type);
}

class QuickReply {
  final String id;
  final String text;
  final String? emoji;
  final Map<String, dynamic>? data;

  const QuickReply({
    required this.id,
    required this.text,
    this.emoji,
    this.data,
  });

  @override
  String toString() => 'QuickReply(text: $text, emoji: $emoji)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuickReply && other.id == id && other.text == text;
  }

  @override
  int get hashCode => Object.hash(id, text);
}

// Predefined quick replies based on context
class QuickReplyData {
  static List<QuickReply> getPreChallengeReplies() {
    return [
      const QuickReply(
        id: 'help',
        text: 'I need help',
        emoji: '🙋‍♀️',
      ),
      const QuickReply(
        id: 'tips',
        text: 'Give me tips',
        emoji: '💡',
      ),
      const QuickReply(
        id: 'nervous',
        text: 'I\'m nervous',
        emoji: '😰',
      ),
      const QuickReply(
        id: 'ready',
        text: 'I\'m ready!',
        emoji: '🚀',
      ),
    ];
  }

  static List<QuickReply> getDuringChallengeReplies() {
    return [
      const QuickReply(
        id: 'struggling',
        text: 'I\'m struggling',
        emoji: '😅',
      ),
      const QuickReply(
        id: 'going-well',
        text: 'Going well!',
        emoji: '👍',
      ),
      const QuickReply(
        id: 'distracted',
        text: 'I got distracted',
        emoji: '😵‍💫',
      ),
      const QuickReply(
        id: 'motivation',
        text: 'Need motivation',
        emoji: '💪',
      ),
    ];
  }

  static List<QuickReply> getPostChallengeReplies() {
    return [
      const QuickReply(
        id: 'loved-it',
        text: 'Loved it!',
        emoji: '❤️',
      ),
      const QuickReply(
        id: 'challenging',
        text: 'It was challenging',
        emoji: '😤',
      ),
      const QuickReply(
        id: 'want-more',
        text: 'Want more like this',
        emoji: '🔥',
      ),
      const QuickReply(
        id: 'felt-good',
        text: 'Felt really good',
        emoji: '✨',
      ),
    ];
  }

  static List<QuickReply> getGeneralReplies() {
    return [
      const QuickReply(
        id: 'whats-challenge',
        text: 'What\'s my challenge?',
        emoji: '🎯',
      ),
      const QuickReply(
        id: 'how-streak',
        text: 'How\'s my streak?',
        emoji: '🔥',
      ),
      const QuickReply(
        id: 'need-encouragement',
        text: 'I need encouragement',
        emoji: '🤗',
      ),
      const QuickReply(
        id: 'share-progress',
        text: 'Share my progress',
        emoji: '📊',
      ),
    ];
  }
}