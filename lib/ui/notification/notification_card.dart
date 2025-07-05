import 'package:flutter/material.dart';
import '../../models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead
          ? null
          : Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con icona, titolo e timestamp
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: notification.color.withOpacity(0.1),
                    ),
                    child: Icon(
                      notification.icon,
                      color: notification.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.formattedTime,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (!notification.isRead)
                    IconButton(
                      icon: const Icon(Icons.mark_email_read_outlined),
                      tooltip: 'Segna come letta',
                      onPressed: onMarkAsRead,
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Elimina',
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notification.body,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (notification.typeLabel.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.label, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      notification.typeLabel,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
