import 'package:flutter/material.dart';

enum NotificationType {
  securityWarning,
  securityTip,
  securityUpdate,
  reminder,
  info,
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic> data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    required this.isRead,
    required this.data,
  });

  /// Crea copia con modifiche
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  /// Converte da JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values[json['type']],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'],
      data: Map<String, dynamic>.from(json['data']),
    );
  }

  /// Converte in JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  /// Ottiene l'icona per il tipo di notifica
  IconData get icon {
    switch (type) {
      case NotificationType.securityWarning:
        return Icons.warning;
      case NotificationType.securityTip:
        return Icons.security;
      case NotificationType.securityUpdate:
        return Icons.system_update;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.info:
        return Icons.info;
    }
  }

  /// Ottiene il colore per il tipo di notifica
  Color get color {
    switch (type) {
      case NotificationType.securityWarning:
        return Colors.red;
      case NotificationType.securityTip:
        return Colors.blue;
      case NotificationType.securityUpdate:
        return Colors.green;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.info:
        return Colors.grey;
    }
  }

  /// Ottiene l'etichetta per il tipo di notifica
  String get typeLabel {
    switch (type) {
      case NotificationType.securityWarning:
        return 'Avviso di Sicurezza';
      case NotificationType.securityTip:
        return 'Consiglio di Sicurezza';
      case NotificationType.securityUpdate:
        return 'Aggiornamento Sicurezza';
      case NotificationType.reminder:
        return 'Promemoria';
      case NotificationType.info:
        return 'Informazione';
    }
  }

  /// Formatta il timestamp
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m fa';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h fa';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}g fa';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}