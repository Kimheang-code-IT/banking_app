import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/permission_service.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'pin_settings_screen.dart';
import 'help_support_screen.dart';
import 'two_factor_verification_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _permissionService = PermissionService();
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    // Initialize settings on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      if (!settingsProvider.isInitialized) {
        settingsProvider.initialize();
      }
    });
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      // Keep default version
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: AppTheme.textOnLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: AppTheme.textSecondaryOnLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textSecondaryOnLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: AppTheme.surfaceColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  Future<void> _handleBiometricToggle(bool enabled, SettingsProvider provider) async {
    await provider.toggleBiometric(enabled);

    if (!mounted) return;

    final error = provider.settings.lastError;
    if (error != null) {
      // Check if it's the special "permanently denied" flag
      if (error.contains('not available') || error.contains('not enrolled')) {
        // Show dialog with instructions
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Biometric Not Available',
              style: TextStyle(
                color: AppTheme.textOnLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              error,
              style: const TextStyle(
                color: AppTheme.textSecondaryOnLight,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: AppTheme.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
      provider.clearError();
    }
  }

  Future<void> _handleTwoFactorToggle(bool enabled, SettingsProvider provider) async {
    if (enabled) {
      // Start enrollment
      final challengeId = await provider.toggleTwoFactor(true);
      if (!mounted) return;

      final error = provider.settings.lastError;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        provider.clearError();
        return;
      }

      if (challengeId != null) {
        // Navigate to verification screen
        final verified = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => TwoFactorVerificationScreen(
              challengeId: challengeId,
            ),
          ),
        );

        if (verified != true && mounted) {
          // User cancelled or verification failed
          await provider.toggleTwoFactor(false);
        }
      }
    } else {
      // Disable 2FA - will require re-auth internally
      await provider.toggleTwoFactor(false);
      if (!mounted) return;

      final error = provider.settings.lastError;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        provider.clearError();
      }
    }
  }

  Future<void> _handlePushToggle(bool enabled, SettingsProvider provider) async {
    await provider.togglePushNotifications(enabled);

    if (!mounted) return;

    final error = provider.settings.lastError;
    if (error != null) {
      if (error == 'PERMANENTLY_DENIED') {
        // Show dialog with option to open settings
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Permission Required',
              style: TextStyle(
                color: AppTheme.textOnLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              'Push notification permission is permanently denied. Please enable it in your device settings.',
              style: TextStyle(
                color: AppTheme.textSecondaryOnLight,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppTheme.textSecondaryOnLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                ),
                child: const Text(
                  'Open Settings',
                  style: TextStyle(
                    color: AppTheme.surfaceColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

        if (openSettings == true) {
          await _permissionService.openAppSettings();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
      provider.clearError();
    }
  }

  Future<void> _handleEmailToggle(bool enabled, SettingsProvider provider) async {
    await provider.toggleEmailNotifications(enabled);

    if (!mounted) return;

    final error = provider.settings.lastError;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      provider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.accentOrange,
        elevation: 0,
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Icon(
            Icons.account_balance,
            color: AppTheme.surfaceColor,
            size: 28,
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppTheme.surfaceColor,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: AppTheme.lightBackground,
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          final settings = settingsProvider.settings;

          if (settings.isLoadingInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: [
              // Account Section
              _buildSectionHeader('Account'),
              _buildSettingsTile(
                context,
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                context,
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                context,
                icon: Icons.fingerprint,
                title: 'Biometric Authentication',
                trailing: _buildToggle(
                  value: settings.biometricEnabled,
                  isLoading: settingsProvider.isToggleLoading('biometric'),
                  onChanged: (value) => _handleBiometricToggle(value, settingsProvider),
                ),
              ),

              // Security Section
              _buildSectionHeader('Security'),
              _buildSettingsTile(
                context,
                icon: Icons.pin,
                title: 'PIN Settings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PinSettingsScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                context,
                icon: Icons.security,
                title: 'Two-Factor Authentication',
                trailing: _buildToggle(
                  value: settings.twoFactorEnabled,
                  isLoading: settingsProvider.isToggleLoading('twoFactor'),
                  onChanged: (value) => _handleTwoFactorToggle(value, settingsProvider),
                ),
              ),

              // Notifications Section
              _buildSectionHeader('Notifications'),
              _buildSettingsTile(
                context,
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                trailing: _buildToggle(
                  value: settings.pushEnabled,
                  isLoading: settingsProvider.isToggleLoading('push'),
                  onChanged: (value) => _handlePushToggle(value, settingsProvider),
                ),
              ),
              _buildDivider(),
              _buildSettingsTile(
                context,
                icon: Icons.email_outlined,
                title: 'Email Notifications',
                trailing: _buildToggle(
                  value: settings.emailEnabled,
                  isLoading: settingsProvider.isToggleLoading('email'),
                  onChanged: (value) => _handleEmailToggle(value, settingsProvider),
                ),
              ),

              // About Section
              _buildSectionHeader('About'),
              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: 'App Version',
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    _appVersion,
                    style: TextStyle(
                      color: AppTheme.textSecondaryOnLight,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              _buildDivider(),
              _buildSettingsTile(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),

              // Logout Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed,
                    foregroundColor: AppTheme.surfaceColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.accentOrange,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.dividerColor.withOpacity(0.5),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.accentOrange),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textOnLight,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.5),
                )
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildToggle({
    required bool value,
    required bool isLoading,
    required ValueChanged<bool> onChanged,
  }) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.accentOrange,
    );
  }
}
