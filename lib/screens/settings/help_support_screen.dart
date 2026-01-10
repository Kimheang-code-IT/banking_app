import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Help & Support Screen
/// 
/// Provides FAQ and contact support options
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.accentOrange,
        elevation: 0,
        title: const Text(
          'Help & Support',
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
          _buildSectionHeader('Frequently Asked Questions'),
          _buildFAQItem(
            'How do I transfer money?',
            'You can transfer money by going to the Transfer section and following the steps.',
          ),
          _buildFAQItem(
            'How do I change my password?',
            'Go to Settings > Account > Change Password to update your password.',
          ),
          _buildFAQItem(
            'How do I enable biometric authentication?',
            'Go to Settings > Account > Biometric Authentication and toggle it on.',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Contact Support'),
          ListTile(
            leading: const Icon(Icons.email, color: AppTheme.accentOrange),
            title: const Text('Email Support'),
            subtitle: const Text('support@bankingapp.com'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open email client
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email support: support@bankingapp.com'),
                  backgroundColor: AppTheme.accentOrange,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: AppTheme.accentOrange),
            title: const Text('Call Support'),
            subtitle: const Text('+855 123 456 789'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Make phone call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Call support: +855 123 456 789'),
                  backgroundColor: AppTheme.accentOrange,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: AppTheme.accentOrange),
            title: const Text('Live Chat'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open live chat
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Live chat will be available soon'),
                  backgroundColor: AppTheme.accentOrange,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.accentOrange,
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            answer,
            style: const TextStyle(
              color: AppTheme.textSecondaryOnLight,
            ),
          ),
        ),
      ],
    );
  }
}

