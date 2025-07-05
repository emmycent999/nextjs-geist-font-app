class ChatMessage {
  final String id;
  final String message;
  final bool isFromUser;
  final DateTime timestamp;
  final String? messageType; // 'text', 'symptom_check', 'escalation'
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isFromUser,
    required this.timestamp,
    this.messageType = 'text',
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      message: json['message'],
      isFromUser: json['is_from_user'],
      timestamp: DateTime.parse(json['timestamp']),
      messageType: json['message_type'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'is_from_user': isFromUser,
      'timestamp': timestamp.toIso8601String(),
      'message_type': messageType,
      'metadata': metadata,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? message,
    bool? isFromUser,
    DateTime? timestamp,
    String? messageType,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      message: message ?? this.message,
      isFromUser: isFromUser ?? this.isFromUser,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      metadata: metadata ?? this.metadata,
    );
  }
}

class SymptomCheckResult {
  final String condition;
  final double confidence;
  final String recommendation;
  final bool requiresUrgentCare;
  final List<String> suggestedActions;

  SymptomCheckResult({
    required this.condition,
    required this.confidence,
    required this.recommendation,
    required this.requiresUrgentCare,
    required this.suggestedActions,
  });

  factory SymptomCheckResult.fromJson(Map<String, dynamic> json) {
    return SymptomCheckResult(
      condition: json['condition'],
      confidence: json['confidence'].toDouble(),
      recommendation: json['recommendation'],
      requiresUrgentCare: json['requires_urgent_care'],
      suggestedActions: List<String>.from(json['suggested_actions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'confidence': confidence,
      'recommendation': recommendation,
      'requires_urgent_care': requiresUrgentCare,
      'suggested_actions': suggestedActions,
    };
  }
}
