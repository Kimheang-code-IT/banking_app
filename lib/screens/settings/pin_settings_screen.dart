import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/secure_storage_service.dart';

/// PIN Settings Screen
/// 
/// Allows users to set, change, or disable PIN
class PinSettingsScreen extends StatefulWidget {
  const PinSettingsScreen({super.key});

  @override
  State<PinSettingsScreen> createState() => _PinSettingsScreenState();
}

class _PinSettingsScreenState extends State<PinSettingsScreen> {
  final _secureStorage = SecureStorageService();
  bool _hasPin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final hasPin = await _secureStorage.hasPin();
    setState(() {
      _hasPin = hasPin;
      _isLoading = false;
    });
  }

  Future<void> _setPin() async {
    // TODO: Navigate to PIN entry screen
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Set PIN functionality will be implemented'),
          backgroundColor: AppTheme.accentOrange,
        ),
      );
    }
  }

  Future<void> _changePin() async {
    // TODO: Navigate to PIN change flow (verify old, then set new)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Change PIN functionality will be implemented'),
          backgroundColor: AppTheme.accentOrange,
        ),
      );
    }
  }

  Future<void> _disablePin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable PIN'),
        content: const Text('Are you sure you want to disable PIN?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _secureStorage.clearPin();
      await _checkPinStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN disabled successfully'),
            backgroundColor: AppTheme.accentOrange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.accentOrange,
          elevation: 0,
          title: const Text(
            'PIN Settings',
            style: TextStyle(
              color: AppTheme.surfaceColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: const IconThemeData(color: AppTheme.surfaceColor),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.accentOrange,
        elevation: 0,
        title: const Text(
          'PIN Settings',
          style: TextStyle(
            color: AppTheme.surfaceColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.surfaceColor),
      ),
      backgroundColor: AppTheme.lightBackground,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_hasPin) ...[
            ListTile(
              leading: const Icon(Icons.pin, color: AppTheme.accentOrange),
              title: const Text('Set PIN'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _setPin,
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.pin, color: AppTheme.accentOrange),
              title: const Text('Change PIN'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _changePin,
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
              title: const Text(
                'Disable PIN',
                style: TextStyle(color: AppTheme.errorRed),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _disablePin,
            ),
          ],
        ],
      ),
    );
  }
}

