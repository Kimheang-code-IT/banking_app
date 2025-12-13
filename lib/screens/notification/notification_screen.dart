import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/notification.dart' as model;
import '../../services/mock_data_service.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final MockDataService _mockDataService = MockDataService();
  final TextEditingController _searchController = TextEditingController();
  List<model.Notification> _notifications = [];
  List<model.Notification> _filteredNotifications = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = _mockDataService.getMockNotifications();
      _filteredNotifications = _notifications;
    });
  }

  void _filterNotifications(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredNotifications = _notifications;
      } else {
        _filteredNotifications = _notifications
            .where((notif) =>
                notif.title.toLowerCase().contains(query.toLowerCase()) ||
                notif.content.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          'Notifications',
          style: TextStyle(
            color: AppTheme.surfaceColor,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: AppTheme.surfaceColor,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _filteredNotifications = _notifications;
                  }
                });
              },
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.accentOrange,
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.lightBackground,
        ),
        child: Column(
          children: [
            // Search bar
            if (_isSearching)
              Container(
                color: AppTheme.lightBackground,
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search notifications...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterNotifications('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.textSecondaryOnLight.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onChanged: _filterNotifications,
                ),
              ),
            // Notifications list
            Expanded(
              child: _filteredNotifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: AppTheme.textSecondaryOnLight.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isSearching
                                ? 'No notifications found'
                                : 'No notifications yet',
                            style: TextStyle(
                              color: AppTheme.textSecondaryOnLight,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await Future.delayed(const Duration(seconds: 1));
                        _loadNotifications();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: _filteredNotifications.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          indent: 80,
                          color: AppTheme.textSecondaryOnLight.withOpacity(0.1),
                        ),
                        itemBuilder: (context, index) {
                          final notification = _filteredNotifications[index];
                          return _buildNotificationItem(notification);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(model.Notification notification) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailScreen(
              notification: notification,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            // Icon
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 24,
                  ),
                ),
                if (!notification.isRead)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppTheme.errorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Title, Preview, and Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                      color: AppTheme.textOnLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.getPreview(),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryOnLight,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  notification.getRelativeTime(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryOnLight,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (!notification.isRead)
                  const SizedBox(height: 4),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.errorRed,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

