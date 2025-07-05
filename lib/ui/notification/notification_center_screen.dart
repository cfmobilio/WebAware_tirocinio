// screens/notification_center_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../services/notification_provider.dart';
import 'notification_card.dart';



class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro Notifiche'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              return provider.unreadCount > 0
                  ? TextButton(
                onPressed: () => provider.markAllAsRead(),
                child: const Text('Segna tutte lette'),
              )
                  : const SizedBox.shrink();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.all_inbox),
              text: 'Tutte',
            ),
            Tab(
              icon: const Icon(Icons.circle_notifications),
              text: 'Non lette',
            ),
            Tab(
              icon: const Icon(Icons.security),
              text: 'Sicurezza',
            ),
          ],
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Tutte le notifiche
              _buildNotificationList(provider.notifications, provider),

              // Notifiche non lette
              _buildNotificationList(provider.unreadNotifications, provider),

              // Notifiche di sicurezza
              _buildNotificationList(
                provider.notifications.where((n) =>
                n.type == NotificationType.securityWarning ||
                    n.type == NotificationType.securityTip ||
                    n.type == NotificationType.securityUpdate
                ).toList(),
                provider,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications, NotificationProvider provider) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nessuna notifica',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Ricarica le notifiche
        await provider.initialize();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationCard(
            notification: notification,
            onTap: () => _handleNotificationTap(notification, provider),
            onMarkAsRead: () => provider.markAsRead(notification.id),
            onDelete: () => _showDeleteDialog(notification, provider),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification, NotificationProvider provider) {
    // Segna come letta se non lo è già
    if (!notification.isRead) {
      provider.markAsRead(notification.id);
    }

    // Mostra dettagli notifica
    _showNotificationDetails(notification);
  }

  void _showNotificationDetails(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(notification.icon, color: notification.color),
            const SizedBox(width: 8),
            Expanded(child: Text(notification.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.label, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  notification.typeLabel,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  notification.formattedTime,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(NotificationModel notification, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina notifica'),
        content: const Text('Sei sicuro di voler eliminare questa notifica?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteNotification(notification.id);
              Navigator.pop(context);
            },
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}