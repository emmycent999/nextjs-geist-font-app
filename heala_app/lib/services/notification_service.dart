import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'storage_service.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  static String? get fcmToken => _fcmToken;

  static Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission for notifications');
        
        // Get FCM token
        _fcmToken = await _firebaseMessaging.getToken();
        if (_fcmToken != null) {
          await StorageService.saveNotificationToken(_fcmToken!);
          debugPrint('FCM Token: $_fcmToken');
        }

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          StorageService.saveNotificationToken(newToken);
          debugPrint('FCM Token refreshed: $newToken');
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

        // Handle notification taps when app is in background
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Handle notification tap when app is terminated
        final initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }

      } else {
        debugPrint('User declined or has not accepted permission for notifications');
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Received foreground message: ${message.messageId}');
    
    // Show in-app notification or update UI
    if (message.notification != null) {
      _showInAppNotification(
        title: message.notification!.title ?? 'Heala',
        body: message.notification!.body ?? '',
        data: message.data,
      );
    }
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Received background message: ${message.messageId}');
    
    // Handle background message processing
    // This could include updating local storage, etc.
    if (message.data.isNotEmpty) {
      await _processNotificationData(message.data);
    }
  }

  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    
    // Navigate to appropriate screen based on notification data
    final data = message.data;
    if (data.containsKey('type')) {
      _navigateBasedOnNotificationType(data);
    }
  }

  static void _showInAppNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    // This would typically show a snackbar or custom notification widget
    // For now, we'll just print to debug console
    debugPrint('In-app notification: $title - $body');
  }

  static Future<void> _processNotificationData(Map<String, dynamic> data) async {
    try {
      final type = data['type'];
      
      switch (type) {
        case 'appointment_reminder':
          await _handleAppointmentReminder(data);
          break;
        case 'appointment_update':
          await _handleAppointmentUpdate(data);
          break;
        case 'medication_reminder':
          await _handleMedicationReminder(data);
          break;
        case 'emergency_alert':
          await _handleEmergencyAlert(data);
          break;
        case 'chat_message':
          await _handleChatMessage(data);
          break;
        default:
          debugPrint('Unknown notification type: $type');
      }
    } catch (e) {
      debugPrint('Error processing notification data: $e');
    }
  }

  static void _navigateBasedOnNotificationType(Map<String, dynamic> data) {
    final type = data['type'];
    
    // This would use Navigator to navigate to appropriate screens
    // For now, we'll just log the navigation intent
    switch (type) {
      case 'appointment_reminder':
      case 'appointment_update':
        debugPrint('Navigate to appointments screen');
        break;
      case 'chat_message':
        debugPrint('Navigate to chat screen');
        break;
      case 'emergency_alert':
        debugPrint('Navigate to emergency screen');
        break;
      default:
        debugPrint('Navigate to home screen');
    }
  }

  static Future<void> _handleAppointmentReminder(Map<String, dynamic> data) async {
    final appointmentId = data['appointment_id'];
    debugPrint('Processing appointment reminder for: $appointmentId');
    
    // Update local appointment data if needed
    // This could trigger UI updates or local notifications
  }

  static Future<void> _handleAppointmentUpdate(Map<String, dynamic> data) async {
    final appointmentId = data['appointment_id'];
    final status = data['status'];
    debugPrint('Processing appointment update: $appointmentId - $status');
    
    // Update local appointment status
    // Refresh appointment data from server
  }

  static Future<void> _handleMedicationReminder(Map<String, dynamic> data) async {
    final medicationName = data['medication_name'];
    final dosage = data['dosage'];
    debugPrint('Processing medication reminder: $medicationName - $dosage');
    
    // Show medication reminder notification
    // Update medication tracking data
  }

  static Future<void> _handleEmergencyAlert(Map<String, dynamic> data) async {
    final alertType = data['alert_type'];
    final message = data['message'];
    debugPrint('Processing emergency alert: $alertType - $message');
    
    // Handle emergency notifications with high priority
    // This might trigger immediate UI updates or sounds
  }

  static Future<void> _handleChatMessage(Map<String, dynamic> data) async {
    final senderId = data['sender_id'];
    final message = data['message'];
    debugPrint('Processing chat message from: $senderId - $message');
    
    // Update chat data
    // Show chat notification if app is in background
  }

  // Subscribe to topics for targeted notifications
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  // Send notification data to server for user targeting
  static Future<void> updateNotificationPreferences({
    required bool appointmentReminders,
    required bool medicationReminders,
    required bool emergencyAlerts,
    required bool chatNotifications,
  }) async {
    try {
      // This would typically send preferences to your backend
      await StorageService.saveSetting('notification_preferences', {
        'appointment_reminders': appointmentReminders,
        'medication_reminders': medicationReminders,
        'emergency_alerts': emergencyAlerts,
        'chat_notifications': chatNotifications,
      });
      
      debugPrint('Notification preferences updated');
    } catch (e) {
      debugPrint('Error updating notification preferences: $e');
    }
  }

  static Future<Map<String, bool>> getNotificationPreferences() async {
    try {
      final preferences = await StorageService.getSetting<Map>('notification_preferences');
      if (preferences != null) {
        return {
          'appointment_reminders': preferences['appointment_reminders'] ?? true,
          'medication_reminders': preferences['medication_reminders'] ?? true,
          'emergency_alerts': preferences['emergency_alerts'] ?? true,
          'chat_notifications': preferences['chat_notifications'] ?? true,
        };
      }
    } catch (e) {
      debugPrint('Error getting notification preferences: $e');
    }
    
    // Return default preferences
    return {
      'appointment_reminders': true,
      'medication_reminders': true,
      'emergency_alerts': true,
      'chat_notifications': true,
    };
  }

  // Clear notification data (for logout)
  static Future<void> clearNotificationData() async {
    try {
      await StorageService.deleteSetting('notification_preferences');
      await StorageService.deleteSetting('fcm_token');
      _fcmToken = null;
      debugPrint('Notification data cleared');
    } catch (e) {
      debugPrint('Error clearing notification data: $e');
    }
  }
}

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await NotificationService._handleBackgroundMessage(message);
}
