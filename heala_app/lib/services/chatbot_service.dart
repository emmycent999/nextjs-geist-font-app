import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/chat_message.dart';
import 'storage_service.dart';

class ChatbotService extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isTyping = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isTyping => _isTyping;

  // Predefined responses for common symptoms (for MVP)
  final Map<String, Map<String, dynamic>> _symptomDatabase = {
    'fever': {
      'condition': 'Fever',
      'confidence': 0.8,
      'recommendation': 'Monitor your temperature and stay hydrated. If fever persists above 38.5°C (101.3°F) for more than 3 days, consult a doctor.',
      'requires_urgent_care': false,
      'suggested_actions': [
        'Rest and drink plenty of fluids',
        'Take paracetamol or ibuprofen as directed',
        'Monitor temperature regularly',
        'Seek medical attention if fever exceeds 39°C (102.2°F)'
      ]
    },
    'headache': {
      'condition': 'Headache',
      'confidence': 0.7,
      'recommendation': 'Try rest in a quiet, dark room. Stay hydrated and consider over-the-counter pain relief.',
      'requires_urgent_care': false,
      'suggested_actions': [
        'Rest in a quiet, dark room',
        'Apply cold or warm compress',
        'Stay hydrated',
        'Take pain relief medication as needed'
      ]
    },
    'chest pain': {
      'condition': 'Chest Pain',
      'confidence': 0.9,
      'recommendation': 'Chest pain can be serious. Seek immediate medical attention, especially if accompanied by shortness of breath, nausea, or arm pain.',
      'requires_urgent_care': true,
      'suggested_actions': [
        'Seek immediate medical attention',
        'Call emergency services if severe',
        'Do not drive yourself to hospital',
        'Sit upright and try to stay calm'
      ]
    },
    'cough': {
      'condition': 'Cough',
      'confidence': 0.6,
      'recommendation': 'A persistent cough may indicate various conditions. Monitor for other symptoms and consider seeing a doctor if it persists.',
      'requires_urgent_care': false,
      'suggested_actions': [
        'Stay hydrated',
        'Use honey for soothing (if over 1 year old)',
        'Avoid irritants like smoke',
        'See a doctor if cough persists over 2 weeks'
      ]
    },
    'shortness of breath': {
      'condition': 'Shortness of Breath',
      'confidence': 0.85,
      'recommendation': 'Difficulty breathing can be serious. Seek medical attention promptly, especially if sudden or severe.',
      'requires_urgent_care': true,
      'suggested_actions': [
        'Seek immediate medical attention',
        'Sit upright',
        'Try to stay calm',
        'Call emergency services if severe'
      ]
    },
    'nausea': {
      'condition': 'Nausea',
      'confidence': 0.6,
      'recommendation': 'Nausea can have many causes. Try small sips of clear fluids and bland foods. Seek medical attention if persistent.',
      'requires_urgent_care': false,
      'suggested_actions': [
        'Sip clear fluids slowly',
        'Eat bland foods like crackers',
        'Rest and avoid strong odors',
        'See a doctor if vomiting persists'
      ]
    },
    'diarrhea': {
      'condition': 'Diarrhea',
      'confidence': 0.7,
      'recommendation': 'Stay hydrated and eat bland foods. Seek medical attention if severe or persistent, especially with fever or blood.',
      'requires_urgent_care': false,
      'suggested_actions': [
        'Drink plenty of fluids',
        'Eat bland foods (BRAT diet)',
        'Avoid dairy and fatty foods',
        'See a doctor if blood present or severe dehydration'
      ]
    }
  };

  ChatbotService() {
    _loadCachedMessages();
    _addWelcomeMessage();
  }

  Future<void> _loadCachedMessages() async {
    try {
      final cachedMessages = await StorageService.getChatMessages();
      _messages = cachedMessages;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cached messages: $e');
    }
  }

  void _addWelcomeMessage() {
    if (_messages.isEmpty) {
      final welcomeMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: "Hello! I'm Heala's AI health assistant. I can help you understand your symptoms and provide basic health guidance. Please describe your symptoms, and I'll do my best to help.\n\n⚠️ Important: This is not a substitute for professional medical advice. For emergencies, please call emergency services immediately.",
        isFromUser: false,
        timestamp: DateTime.now(),
        messageType: 'welcome',
      );
      _messages.add(welcomeMessage);
      _saveMessage(welcomeMessage);
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    try {
      _setLoading(true);
      _clearError();

      // Add user message
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: message.trim(),
        isFromUser: true,
        timestamp: DateTime.now(),
      );

      _messages.add(userMessage);
      await _saveMessage(userMessage);
      notifyListeners();

      // Show typing indicator
      _setTyping(true);

      // Process the message and get response
      final response = await _processMessage(message);

      // Remove typing indicator
      _setTyping(false);

      // Add bot response
      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: response['message'],
        isFromUser: false,
        timestamp: DateTime.now(),
        messageType: response['type'],
        metadata: response['metadata'],
      );

      _messages.add(botMessage);
      await _saveMessage(botMessage);
      notifyListeners();

    } catch (e) {
      _setError('Failed to send message: $e');
      _setTyping(false);
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> _processMessage(String message) async {
    final lowerMessage = message.toLowerCase();

    // Check for emergency keywords
    if (_containsEmergencyKeywords(lowerMessage)) {
      return _createEmergencyResponse();
    }

    // Check for symptom keywords
    final symptomResult = _analyzeSymptoms(lowerMessage);
    if (symptomResult != null) {
      return _createSymptomResponse(symptomResult);
    }

    // Check for general health questions
    if (_isGeneralHealthQuestion(lowerMessage)) {
      return _createGeneralHealthResponse(lowerMessage);
    }

    // Check for escalation request
    if (_isEscalationRequest(lowerMessage)) {
      return _createEscalationResponse();
    }

    // Default response
    return _createDefaultResponse();
  }

  bool _containsEmergencyKeywords(String message) {
    final emergencyKeywords = [
      'emergency', 'urgent', 'severe pain', 'can\'t breathe', 'chest pain',
      'heart attack', 'stroke', 'unconscious', 'bleeding heavily', 'overdose'
    ];
    
    return emergencyKeywords.any((keyword) => message.contains(keyword));
  }

  SymptomCheckResult? _analyzeSymptoms(String message) {
    for (final symptom in _symptomDatabase.keys) {
      if (message.contains(symptom)) {
        final data = _symptomDatabase[symptom]!;
        return SymptomCheckResult.fromJson(data);
      }
    }
    return null;
  }

  bool _isGeneralHealthQuestion(String message) {
    final healthKeywords = [
      'health', 'wellness', 'diet', 'exercise', 'sleep', 'stress',
      'prevention', 'nutrition', 'vitamins', 'medication'
    ];
    
    return healthKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isEscalationRequest(String message) {
    final escalationKeywords = [
      'doctor', 'speak to doctor', 'human', 'real person', 'medical professional',
      'appointment', 'consultation', 'help me book'
    ];
    
    return escalationKeywords.any((keyword) => message.contains(keyword));
  }

  Map<String, dynamic> _createEmergencyResponse() {
    return {
      'message': '🚨 EMERGENCY ALERT 🚨\n\nIf this is a medical emergency, please:\n\n• Call emergency services immediately (199 in Nigeria)\n• Go to the nearest emergency room\n• Do not delay seeking immediate medical attention\n\nI can help connect you to emergency services or find the nearest hospital. Would you like me to help with that?',
      'type': 'emergency',
      'metadata': {
        'requires_urgent_care': true,
        'emergency_numbers': ['199', '112'],
      }
    };
  }

  Map<String, dynamic> _createSymptomResponse(SymptomCheckResult result) {
    String urgencyIcon = result.requiresUrgentCare ? '🚨' : 'ℹ️';
    String urgencyText = result.requiresUrgentCare ? 
        '\n\n⚠️ This may require urgent medical attention.' : 
        '\n\n💡 This appears to be manageable with self-care.';

    String actionsText = '\n\nSuggested actions:\n';
    for (int i = 0; i < result.suggestedActions.length; i++) {
      actionsText += '${i + 1}. ${result.suggestedActions[i]}\n';
    }

    String escalationText = '\n\nWould you like me to help you book an appointment with a healthcare professional?';

    return {
      'message': '$urgencyIcon Based on your symptoms, this might be: **${result.condition}**\n\n${result.recommendation}$urgencyText$actionsText$escalationText',
      'type': 'symptom_check',
      'metadata': {
        'symptom_result': result.toJson(),
        'confidence': result.confidence,
        'requires_urgent_care': result.requiresUrgentCare,
      }
    };
  }

  Map<String, dynamic> _createGeneralHealthResponse(String message) {
    String response = '';
    
    if (message.contains('diet') || message.contains('nutrition')) {
      response = 'A balanced diet is crucial for good health. Focus on:\n\n• Plenty of fruits and vegetables\n• Whole grains\n• Lean proteins\n• Adequate hydration\n• Limit processed foods and sugar\n\nWould you like specific dietary advice from a nutritionist?';
    } else if (message.contains('exercise')) {
      response = 'Regular exercise is important for overall health:\n\n• Aim for 150 minutes of moderate activity per week\n• Include both cardio and strength training\n• Start slowly if you\'re new to exercise\n• Listen to your body\n\nConsult a doctor before starting any new exercise program.';
    } else if (message.contains('sleep')) {
      response = 'Good sleep is essential for health:\n\n• Aim for 7-9 hours per night\n• Maintain a consistent sleep schedule\n• Create a relaxing bedtime routine\n• Avoid screens before bed\n• Keep your bedroom cool and dark';
    } else {
      response = 'I can provide general health information, but for personalized advice, it\'s best to consult with a healthcare professional. Would you like me to help you book an appointment?';
    }

    return {
      'message': response,
      'type': 'general_health',
      'metadata': {}
    };
  }

  Map<String, dynamic> _createEscalationResponse() {
    return {
      'message': 'I\'d be happy to help you connect with a healthcare professional! 👨‍⚕️👩‍⚕️\n\nI can help you:\n\n• Find doctors by specialty\n• Book an appointment\n• Schedule a teleconsultation\n• Find nearby hospitals\n\nWhat type of healthcare professional would you like to see?',
      'type': 'escalation',
      'metadata': {
        'escalation_requested': true,
        'available_actions': ['book_appointment', 'find_doctor', 'teleconsultation']
      }
    };
  }

  Map<String, dynamic> _createDefaultResponse() {
    final responses = [
      'I understand you\'re looking for health information. Could you please describe your symptoms more specifically? For example, are you experiencing pain, discomfort, or other symptoms?',
      'I\'m here to help with health-related questions. Could you tell me more about what you\'re experiencing?',
      'To better assist you, could you provide more details about your symptoms or health concerns?',
      'I can help with symptom checking and health guidance. What specific symptoms or health questions do you have?'
    ];
    
    final randomResponse = responses[DateTime.now().millisecond % responses.length];
    
    return {
      'message': randomResponse,
      'type': 'clarification',
      'metadata': {}
    };
  }

  Future<void> _saveMessage(ChatMessage message) async {
    try {
      await StorageService.saveChatMessage(message);
    } catch (e) {
      debugPrint('Error saving message: $e');
    }
  }

  Future<void> clearChat() async {
    try {
      _messages.clear();
      await StorageService.clearChatMessages();
      _addWelcomeMessage();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear chat: $e');
    }
  }

  Future<void> escalateToDoctor() async {
    final escalationMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: 'I\'m connecting you with our appointment booking system. You can find and book appointments with healthcare professionals in the Appointments section of the app.',
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: 'escalation',
      metadata: {
        'action': 'redirect_to_appointments'
      }
    );

    _messages.add(escalationMessage);
    await _saveMessage(escalationMessage);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
