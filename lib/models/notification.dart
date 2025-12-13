class Notification {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final String? icon;

  Notification({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.icon,
  });

  String getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String getPreview() {
    if (content.length <= 50) {
      return content;
    }
    return '${content.substring(0, 50)}...';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.name,
      'icon': icon,
    };
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.info,
      ),
      icon: json['icon'] as String?,
    );
  }
}

enum NotificationType {
  transaction,
  security,
  promotion,
  info,
  alert,
}

