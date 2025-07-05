// providers/notification_provider.dart
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/firebase_notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final FirebaseNotificationService _notificationService = FirebaseNotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  /// Inizializza il provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Inizializza il servizio
      await _notificationService.initialize();

      // Configura il callback per aggiornamenti
      _notificationService.onNotificationsChanged = (notifications) {
        _notifications = notifications;
        notifyListeners();
      };

      // Carica notifiche iniziali
      _notifications = _notificationService.notifications;

    } catch (e) {
      print('Errore nell\'inizializzazione delle notifiche: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Segna notifica come letta
  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
    _notifications = _notificationService.notifications;
    notifyListeners();
  }

  /// Segna tutte come lette
  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
    _notifications = _notificationService.notifications;
    notifyListeners();
  }

  /// Elimina notifica
  Future<void> deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
    _notifications = _notificationService.notifications;
    notifyListeners();
  }

  /// Ottieni notifiche per tipo
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Ottieni notifiche dell'ultima settimana
  List<NotificationModel> getRecentNotifications() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _notifications.where((n) => n.timestamp.isAfter(weekAgo)).toList();
  }

  /// Ottieni statistiche notifiche
  Map<String, int> getNotificationStats() {
    final stats = <String, int>{
      'total': _notifications.length,
      'unread': unreadCount,
      'securityWarnings': getNotificationsByType(NotificationType.securityWarning).length,
      'securityTips': getNotificationsByType(NotificationType.securityTip).length,
      'reminders': getNotificationsByType(NotificationType.reminder).length,
    };

    return stats;
  }

  /// Ottieni token FCM
  Future<String?> getFCMToken() async {
    return await _notificationService.getFCMToken();
  }
}