import 'package:permission_handler/permission_handler.dart' as ph;

/// Permission Service
/// 
/// Handles app permissions, especially for push notifications
class PermissionService {
  /// Check if notification permission is granted
  Future<bool> isNotificationPermissionGranted() async {
    final status = await ph.Permission.notification.status;
    return status.isGranted;
  }

  /// Request notification permission
  /// Returns true if granted, false otherwise
  Future<bool> requestNotificationPermission() async {
    final status = await ph.Permission.notification.request();
    return status.isGranted;
  }

  /// Check if notification permission is permanently denied
  Future<bool> isNotificationPermissionPermanentlyDenied() async {
    final status = await ph.Permission.notification.status;
    return status.isPermanentlyDenied;
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    try {
      return await ph.openAppSettings();
    } catch (e) {
      return false;
    }
  }

  /// Get human-readable permission status message
  Future<String> getNotificationPermissionStatusMessage() async {
    final status = await ph.Permission.notification.status;
    switch (status) {
      case ph.PermissionStatus.granted:
        return 'Notifications are enabled';
      case ph.PermissionStatus.denied:
        return 'Notifications are disabled. Please enable in Settings.';
      case ph.PermissionStatus.permanentlyDenied:
        return 'Notifications are permanently disabled. Please enable in Settings.';
      case ph.PermissionStatus.restricted:
        return 'Notification access is restricted';
      case ph.PermissionStatus.limited:
        return 'Notification access is limited';
      default:
        return 'Notification status unknown';
    }
  }
}

