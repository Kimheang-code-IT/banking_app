import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (context.mounted) {
        // Navigation will be handled by the router
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
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
      backgroundColor: AppTheme.accentOrange,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Container(
            decoration: const BoxDecoration(
              color: AppTheme.lightBackground,
            ),
            child: ListView(
              children: [
                // Account Settings
                _buildSectionHeader(context, 'Account'),
                _buildSettingsTile(
                  context,
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Edit profile feature coming soon')),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Change password feature coming soon')),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.fingerprint,
                  title: 'Biometric Authentication',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Biometric authentication coming soon')),
                      );
                    },
                  ),
                ),

                // Security Settings
                _buildSectionHeader(context, 'Security'),
                _buildSettingsTile(
                  context,
                  icon: Icons.pin,
                  title: 'PIN Settings',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('PIN settings feature coming soon')),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.security,
                  title: 'Two-Factor Authentication',
                  trailing: Switch(
                    value: false, // TODO: Implement 2FA toggle
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('2FA feature coming soon')),
                      );
                    },
                  ),
                ),

                // Notifications
                _buildSectionHeader(context, 'Notifications'),
                _buildSettingsTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // Notification toggle functionality
                    },
                  ),
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Email Notifications',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // Email notification toggle functionality
                    },
                  ),
                ),

                // About
                _buildSectionHeader(context, 'About'),
                _buildSettingsTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'App Version',
                  trailing: Text(
                    '1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Help & Support coming soon')),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Privacy Policy coming soon')),
                    );
                  },
                ),

                // Logout
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textSecondary,
                      foregroundColor: AppTheme.surfaceColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
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
      title: Text(title),
      trailing: trailing ??
          Icon(Icons.chevron_right, color: AppTheme.textSecondaryOnLight),
      onTap: onTap,
    );
  }
}
