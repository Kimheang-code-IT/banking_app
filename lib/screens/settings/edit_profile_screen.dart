import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Edit Profile Screen
/// 
/// Placeholder screen for editing user profile
/// TODO: Implement full profile editing functionality
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.accentOrange,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppTheme.surfaceColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.surfaceColor),
      ),
      backgroundColor: AppTheme.lightBackground,
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: AppTheme.textSecondaryOnLight,
              ),
              SizedBox(height: 16),
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textOnLight,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Profile editing functionality will be implemented here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryOnLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

