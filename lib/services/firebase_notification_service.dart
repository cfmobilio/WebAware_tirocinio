// services/firebase_notification_service.dart
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

  // Callback per aggiornare la UI
  Function(List<NotificationModel>)? onNotificationsChanged;

  /// Inizializza il servizio notifiche
  Future<void> initialize() async {
    print('Inizializzo FirebaseNotificationService');
    await _requestPermissions();
    await _configureLocalNotifications();
    await _configureFirebaseMessaging();
    await _loadSavedNotifications();
    _schedulePeriodicNotifications();
    print('FirebaseNotificationService inizializzato');
  }

  /// Richiedi permessi per le notifiche
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

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permessi notifiche concessi');
    } else {
      print('Permessi notifiche negati');
    }
  }

  /// Configura le notifiche locali
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

  /// Configura Firebase Messaging
  Future<void> _configureFirebaseMessaging() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Salva token nelle preferenze
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    }

    // Listener per messaggi in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listener per quando l'app viene aperta da una notifica
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);

    // Gestisci notifiche quando l'app è chiusa
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  /// Gestisce messaggi in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    print('Messaggio ricevuto in foreground: ${message.notification?.title}');

    // Crea notifica locale
    _showLocalNotification(message);

    // Aggiungi alla lista
    _addNotificationToList(message);
  }

  /// Gestisce apertura notifica
  void _handleNotificationOpened(RemoteMessage message) {
    print('Notifica aperta: ${message.notification?.title}');
    _addNotificationToList(message);
  }

  /// Mostra notifica locale
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

  /// Callback quando si tocca una notifica
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      print('Notifica toccata con payload: $data');
      // Naviga alla schermata appropriata
    }
  }

  /// Aggiunge notifica alla lista
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

    // Mantieni solo le ultime 50 notifiche
    if (_notifications.length > 50) {
      _notifications = _notifications.take(50).toList();
    }

    // Salva e notifica i listeners
    _saveNotifications();
    onNotificationsChanged?.call(_notifications);
  }

  /// Determina il tipo di notifica
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

  /// Carica notifiche salvate
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

  /// Salva notifiche
  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = jsonEncode(
      _notifications.map((notification) => notification.toJson()).toList(),
    );
    await prefs.setString('notifications', notificationsJson);
  }

  /// Segna notifica come letta
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      onNotificationsChanged?.call(_notifications);
    }
  }

  /// Segna tutte come lette
  Future<void> markAllAsRead() async {
    _notifications = _notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
    await _saveNotifications();
    onNotificationsChanged?.call(_notifications);
  }

  /// Elimina notifica
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    onNotificationsChanged?.call(_notifications);
  }

  /// Ottieni conteggio non lette
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Ottieni token FCM
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Programma notifiche periodiche di sicurezza
  void _schedulePeriodicNotifications() {
    // Simula notifiche di sicurezza ogni 30 secondi per testing
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      _sendTestSecurityNotification();
      return true;
    });
  }

  /// Invia notifica di test
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

    // Simula un RemoteMessage
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

/// Gestisce messaggi in background (deve essere funzione top-level)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('Messaggio ricevuto in background: ${message.notification?.title}');
}