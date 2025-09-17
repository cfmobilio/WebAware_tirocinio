import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance = FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  Function(List<NotificationModel>)? onNotificationsChanged;

  Future<void> initialize() async {
    await _requestPermissions();

    await _configureLocalNotifications();

    await _configureFirebaseMessaging();

    await _loadSavedNotifications();

    _schedulePeriodicNotifications();
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

  }

  Future<void> _configureLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _configureFirebaseMessaging() async {
    String? token = await _firebaseMessaging.getToken();

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {

    _showLocalNotification(message);

    _addNotificationToList(message);
  }

  void _handleNotificationOpened(RemoteMessage message) {
    _addNotificationToList(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'security_channel',
      'Sicurezza Digitale',
      channelDescription: 'Notifiche per la sicurezza digitale',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
    }
  }

  void _addNotificationToList(RemoteMessage message) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notifica',
      body: message.notification?.body ?? '',
      type: _getNotificationType(message.data),
      timestamp: DateTime.now(),
      isRead: false,
      data: message.data,
    );

    _notifications.insert(0, notification);

    if (_notifications.length > 50) {
      _notifications = _notifications.take(50).toList();
    }

    _saveNotifications();
    onNotificationsChanged?.call(_notifications);
  }

  NotificationType _getNotificationType(Map<String, dynamic> data) {
    final type = data['type'] ?? 'info';
    switch (type) {
      case 'security_warning':
        return NotificationType.securityWarning;
      case 'security_tip':
        return NotificationType.securityTip;
      case 'security_update':
        return NotificationType.securityUpdate;
      case 'reminder':
        return NotificationType.reminder;
      default:
        return NotificationType.info;
    }
  }

  Future<void> _loadSavedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications');

    if (notificationsJson != null) {
      final List<dynamic> notificationsList = jsonDecode(notificationsJson);
      _notifications = notificationsList
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    }
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = jsonEncode(
      _notifications.map((notification) => notification.toJson()).toList(),
    );
    await prefs.setString('notifications', notificationsJson);
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      onNotificationsChanged?.call(_notifications);
    }
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
    await _saveNotifications();
    onNotificationsChanged?.call(_notifications);
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    onNotificationsChanged?.call(_notifications);
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  void _schedulePeriodicNotifications() {
    Future.doWhile(() async {
        await Future.delayed(const Duration(hours: 2));
        _sendTestSecurityNotification();
        return true;
    });
  }

  void _sendTestSecurityNotification() {
    final securityTips = [
      {
        'title': 'Aggiorna le tue password',
        'body': 'È consigliabile cambiare le password ogni 3 mesi per mantenere la sicurezza dei tuoi account.',
        'type': 'security_tip'
      },
      {
        'title': 'Attenzione ai link sospetti',
        'body': 'Non cliccare mai su link in email o messaggi da mittenti sconosciuti.',
        'type': 'security_warning'
      },
      {
        'title': 'Backup dei dati',
        'body': 'Ricordati di effettuare un backup dei tuoi dati importanti.',
        'type': 'reminder'
      },
      {
        'title': 'Aggiornamento sicurezza',
        'body': 'Sono disponibili nuovi aggiornamenti di sicurezza per il tuo dispositivo.',
        'type': 'security_update'
      }
    ];

    final randomTip = securityTips[DateTime.now().millisecondsSinceEpoch % securityTips.length];

    final message = RemoteMessage(
      notification: RemoteNotification(
        title: randomTip['title'],
        body: randomTip['body'],
      ),
      data: {'type': randomTip['type']!},
    );

    _handleForegroundMessage(message);
  }
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
}