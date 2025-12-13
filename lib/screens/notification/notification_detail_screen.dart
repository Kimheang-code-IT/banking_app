import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/notification.dart' as model;

class NotificationDetailScreen extends StatelessWidget {
  final model.Notification notification;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  IconData _getNotificationIcon(model.NotificationType type) {
    switch (type) {
      case model.NotificationType.transaction:
        return Icons.payment;
      case model.NotificationType.security:
        return Icons.security;
      case model.NotificationType.promotion:
        return Icons.local_offer;
      case model.NotificationType.alert:
        return Icons.warning;
      case model.NotificationType.info:
        return Icons.info;
    }
  }

  Color _getNotificationColor(model.NotificationType type) {
    switch (type) {
      case model.NotificationType.transaction:
        return AppTheme.successGreen;
      case model.NotificationType.security:
        return AppTheme.errorRed;
      case model.NotificationType.promotion:
        return AppTheme.warningYellow;
      case model.NotificationType.alert:
        return AppTheme.warningYellow;
      case model.NotificationType.info:
        return AppTheme.infoBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.accentOrange,
        elevation: 0,
        toolbarHeight: 60,
        leadingWidth: 70,
        centerTitle: true,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.surfaceColor,
            size: 24,
          ),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: AppTheme.surfaceColor,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.account_balance,
              color: AppTheme.surfaceColor,
              size: 28,
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Title Section
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textOnLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMMM dd, yyyy • hh:mm a')
                            .format(notification.timestamp),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryOnLight,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingXL),
            // Content Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: AppTheme.lightBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                border: Border.all(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                notification.content,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textOnLight,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            // Type Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color: _getNotificationColor(notification.type)
                      .withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getNotificationIcon(notification.type),
                    size: 16,
                    color: _getNotificationColor(notification.type),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    notification.type.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getNotificationColor(notification.type),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

