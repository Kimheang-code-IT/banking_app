import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _pickedImage;
  bool _isPasswordVisible = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _pickedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
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
          'Profile',
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
      backgroundColor: AppTheme.accentOrange,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Column(
            children: [
              // Header Section with Blue Background
              Container(
                decoration: const BoxDecoration(
                  color: AppTheme.accentOrange,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingL,
                  vertical: AppTheme.spacingL,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar on the left (with upload functionality)
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.surfaceColor,
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : null,
                            child: _pickedImage == null
                                ? Text(
                                    authProvider.currentUser?.name.isNotEmpty ==
                                            true
                                        ? authProvider.currentUser!.name
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : 'J',
                                    style: const TextStyle(
                                      color: AppTheme.accentOrange,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.accentOrange,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.surfaceColor,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: AppTheme.surfaceColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Username and Phone on the right
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            authProvider.currentUser?.name ?? 'John Doe',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.surfaceColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                color: AppTheme.surfaceColor,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  authProvider.currentUser?.phone ??
                                      '+855 12 345 678',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.surfaceColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Profile Information List (Scrollable)
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.lightBackground,
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: 8,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      indent: 80,
                      color: AppTheme.textSecondaryOnLight.withOpacity(0.1),
                    ),
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return _buildInfoItem(
                            context,
                            icon: Icons.person,
                            label: 'Full Name',
                            value: authProvider.currentUser?.name ?? 'John Doe',
                          );
                        case 1:
                          return _buildInfoItem(
                            context,
                            icon: Icons.email,
                            label: 'Email Address',
                            value: authProvider.currentUser?.email ??
                                'john.doe@example.com',
                          );
                        case 2:
                          return _buildPasswordItem(context);
                        case 3:
                          return _buildInfoItem(
                            context,
                            icon: Icons.phone,
                            label: 'Phone Number',
                            value: authProvider.currentUser?.phone ??
                                '+855 12 345 678',
                          );
                        case 4:
                          return _buildInfoItem(
                            context,
                            icon: Icons.person_outline,
                            label: 'Gender',
                            value: authProvider.currentUser?.gender ?? 'Male',
                          );
                        case 5:
                          return _buildInfoItem(
                            context,
                            icon: Icons.cake,
                            label: 'Date of Birth',
                            value: authProvider.currentUser?.dateOfBirth != null
                                ? DateFormat('MMMM dd, yyyy')
                                    .format(authProvider.currentUser!.dateOfBirth!)
                                : 'May 15, 1990',
                          );
                        case 6:
                          return _buildInfoItem(
                            context,
                            icon: Icons.location_on,
                            label: 'Address',
                            value: authProvider.currentUser?.address ??
                                '123 Street 456, Phnom Penh, Cambodia',
                          );
                        case 7:
                          return _buildInfoItem(
                            context,
                            icon: Icons.calendar_today,
                            label: 'Member Since',
                            value: authProvider.currentUser?.createdAt != null
                                ? DateFormat('MMMM dd, yyyy')
                                    .format(authProvider.currentUser!.createdAt)
                                : DateFormat('MMMM dd, yyyy').format(
                                    DateTime.now()
                                        .subtract(const Duration(days: 365)),
                                  ),
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.accentOrange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Label and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryOnLight,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textOnLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordItem(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock,
              color: AppTheme.accentOrange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Label and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryOnLight,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isPasswordVisible ? 'password123' : '••••••••',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textOnLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Eye icon to toggle password visibility
          IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: AppTheme.accentOrange,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ],
      ),
    );
  }
}

