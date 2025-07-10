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

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _notificationService.initialize();

      _notificationService.onNotificationsChanged = (notifications) {
        _notifications = notifications;
        notifyListeners();
      };

      _notifications = _notificationService.notifications;

    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
    _notifications = _notificationService.notifications;
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
    _notifications = _notificationService.notifications;
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
    _notifications = _notificationService.notifications;
    notifyListeners();
  }

  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  List<NotificationModel> getRecentNotifications() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _notifications.where((n) => n.timestamp.isAfter(weekAgo)).toList();
  }

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

  Future<String?> getFCMToken() async {
    return await _notificationService.getFCMToken();
  }
}