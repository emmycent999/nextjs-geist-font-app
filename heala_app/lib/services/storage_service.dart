import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/appointment.dart';
import '../models/chat_message.dart';

class StorageService {
  static const String _userBoxName = 'user_box';
  static const String _appointmentsBoxName = 'appointments_box';
  static const String _chatBoxName = 'chat_box';
  static const String _settingsBoxName = 'settings_box';

  static late Box<Map> _userBox;
  static late Box<Map> _appointmentsBox;
  static late Box<Map> _chatBox;
  static late Box<Map> _settingsBox;

  static Future<void> init() async {
    try {
      _userBox = await Hive.openBox<Map>(_userBoxName);
      _appointmentsBox = await Hive.openBox<Map>(_appointmentsBoxName);
      _chatBox = await Hive.openBox<Map>(_chatBoxName);
      _settingsBox = await Hive.openBox<Map>(_settingsBoxName);
    } catch (e) {
      throw Exception('Failed to initialize storage: $e');
    }
  }

  // User Data Management
  static Future<void> saveUserData(User user) async {
    try {
      await _userBox.put('current_user', user.toJson());
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  static Future<User?> getUserData() async {
    try {
      final userData = _userBox.get('current_user');
      if (userData != null) {
        return User.fromJson(Map<String, dynamic>.from(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearUserData() async {
    try {
      await _userBox.delete('current_user');
    } catch (e) {
      throw Exception('Failed to clear user data: $e');
    }
  }

  // Appointments Management
  static Future<void> saveAppointments(List<Appointment> appointments) async {
    try {
      final appointmentsMap = <String, Map<String, dynamic>>{};
      for (final appointment in appointments) {
        appointmentsMap[appointment.id] = appointment.toJson();
      }
      await _appointmentsBox.put('appointments', appointmentsMap);
    } catch (e) {
      throw Exception('Failed to save appointments: $e');
    }
  }

  static Future<List<Appointment>> getAppointments() async {
    try {
      final appointmentsData = _appointmentsBox.get('appointments');
      if (appointmentsData != null) {
        final appointmentsMap = Map<String, dynamic>.from(appointmentsData);
        return appointmentsMap.values
            .map((data) => Appointment.fromJson(Map<String, dynamic>.from(data)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveAppointment(Appointment appointment) async {
    try {
      final appointments = await getAppointments();
      final index = appointments.indexWhere((a) => a.id == appointment.id);
      
      if (index != -1) {
        appointments[index] = appointment;
      } else {
        appointments.add(appointment);
      }
      
      await saveAppointments(appointments);
    } catch (e) {
      throw Exception('Failed to save appointment: $e');
    }
  }

  static Future<void> deleteAppointment(String appointmentId) async {
    try {
      final appointments = await getAppointments();
      appointments.removeWhere((a) => a.id == appointmentId);
      await saveAppointments(appointments);
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  // Chat Messages Management
  static Future<void> saveChatMessages(List<ChatMessage> messages) async {
    try {
      final messagesMap = <String, Map<String, dynamic>>{};
      for (final message in messages) {
        messagesMap[message.id] = message.toJson();
      }
      await _chatBox.put('chat_messages', messagesMap);
    } catch (e) {
      throw Exception('Failed to save chat messages: $e');
    }
  }

  static Future<List<ChatMessage>> getChatMessages() async {
    try {
      final messagesData = _chatBox.get('chat_messages');
      if (messagesData != null) {
        final messagesMap = Map<String, dynamic>.from(messagesData);
        return messagesMap.values
            .map((data) => ChatMessage.fromJson(Map<String, dynamic>.from(data)))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveChatMessage(ChatMessage message) async {
    try {
      final messages = await getChatMessages();
      messages.add(message);
      await saveChatMessages(messages);
    } catch (e) {
      throw Exception('Failed to save chat message: $e');
    }
  }

  static Future<void> clearChatMessages() async {
    try {
      await _chatBox.delete('chat_messages');
    } catch (e) {
      throw Exception('Failed to clear chat messages: $e');
    }
  }

  // Settings Management
  static Future<void> saveSetting(String key, dynamic value) async {
    try {
      await _settingsBox.put(key, {'value': value});
    } catch (e) {
      throw Exception('Failed to save setting: $e');
    }
  }

  static Future<T?> getSetting<T>(String key) async {
    try {
      final settingData = _settingsBox.get(key);
      if (settingData != null) {
        return settingData['value'] as T?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteSetting(String key) async {
    try {
      await _settingsBox.delete(key);
    } catch (e) {
      throw Exception('Failed to delete setting: $e');
    }
  }

  // Notification Settings
  static Future<void> saveNotificationToken(String token) async {
    await saveSetting('fcm_token', token);
  }

  static Future<String?> getNotificationToken() async {
    return await getSetting<String>('fcm_token');
  }

  // App Preferences
  static Future<void> saveThemeMode(String themeMode) async {
    await saveSetting('theme_mode', themeMode);
  }

  static Future<String?> getThemeMode() async {
    return await getSetting<String>('theme_mode');
  }

  static Future<void> saveLanguage(String language) async {
    await saveSetting('language', language);
  }

  static Future<String?> getLanguage() async {
    return await getSetting<String>('language');
  }

  // Emergency Contacts
  static Future<void> saveEmergencyContacts(List<Map<String, String>> contacts) async {
    await saveSetting('emergency_contacts', contacts);
  }

  static Future<List<Map<String, String>>> getEmergencyContacts() async {
    final contacts = await getSetting<List>('emergency_contacts');
    if (contacts != null) {
      return contacts.cast<Map<String, String>>();
    }
    return [];
  }

  // Clear all data (for logout or app reset)
  static Future<void> clearAllData() async {
    try {
      await _userBox.clear();
      await _appointmentsBox.clear();
      await _chatBox.clear();
      await _settingsBox.clear();
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  // Check storage health
  static Future<bool> isStorageHealthy() async {
    try {
      await _userBox.put('health_check', {'timestamp': DateTime.now().toIso8601String()});
      final healthCheck = _userBox.get('health_check');
      await _userBox.delete('health_check');
      return healthCheck != null;
    } catch (e) {
      return false;
    }
  }
}
