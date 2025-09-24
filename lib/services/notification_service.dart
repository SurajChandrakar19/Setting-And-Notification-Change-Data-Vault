import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationItem> _notifications = [];
  final ValueNotifier<List<NotificationItem>> notificationsNotifier =
      ValueNotifier<List<NotificationItem>>([]);

  List<NotificationItem> get notifications => _notifications;

  // using
  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? candidateName,
  }) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      candidateName: candidateName,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, notification);
    notificationsNotifier.value = List.from(_notifications);
  }

  // using
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notificationsNotifier.value = List.from(_notifications);
    }
  }

  // using
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notificationsNotifier.value = List.from(_notifications);
  }

  void clearAll() {
    _notifications.clear();
    notificationsNotifier.value = [];
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String? candidateName;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.candidateName,
    required this.timestamp,
    this.isRead = false,
  });
}

enum NotificationType { interview, reschedule, reached, general }

class TopNotificationService {
  static final TopNotificationService _instance =
      TopNotificationService._internal();
  factory TopNotificationService() => _instance;

  TopNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Future<void> init() async {
  //   // Android initialization
  //   const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

  //   // iOS initialization
  //   const iosInit = DarwinInitializationSettings();

  //   const initSettings = InitializationSettings(
  //     android: androidInit,
  //     iOS: iosInit,
  //   );

  //   await _flutterLocalNotificationsPlugin.initialize(
  //     initSettings,
  //     onDidReceiveNotificationResponse: (details) {
  //       // Handle tap on notification if needed
  //       print('Notification clicked: ${details.payload}');
  //     },
  //   );
  // }

  Future<void> init() async {
    // Android initialization
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    // Initialize plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification clicked: ${details.payload}');
      },
    );

    // ✅ Create notification channel (for Android 8+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'gfi_channel', // must match the id you use in showNotification
      'Interview Notifications',
      description: 'Notifications for interviews',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // Android-specific details
    final androidDetails = AndroidNotificationDetails(
      'gfi_channel', // Unique channel ID
      'Interview Notifications', // Channel name
      channelDescription: 'Notifications for interviews',
      importance: Importance.high, // Heads-up pop-up
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ticker: 'Interview Ticker',
      largeIcon: const DrawableResourceAndroidBitmap(
        '@mipmap/ic_launcher',
      ), // Your custom logo
      styleInformation: const DefaultStyleInformation(
        true,
        true,
      ), // Expandable text
    );

    // iOS-specific details
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Combined notification details
    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show notification
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: 'InterviewScheduled', // optional, for handling taps
    );
  }
}
