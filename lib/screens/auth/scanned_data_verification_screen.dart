import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../services/storage_service.dart';
import 'id_card_scanner_screen.dart';
import 'additional_info_screen.dart';

class ScannedDataVerificationScreen extends StatefulWidget {
  const ScannedDataVerificationScreen({super.key});

  @override
  State<ScannedDataVerificationScreen> createState() =>
      _ScannedDataVerificationScreenState();
}

class _ScannedDataVerificationScreenState
    extends State<ScannedDataVerificationScreen> {
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScannedData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idNumberController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _loadScannedData() async {
    final data = await _storageService.getScannedIdData();
    setState(() {
      _nameController.text = data?['name'] ?? '';
      _idNumberController.text = data?['idNumber'] ?? '';
      _dateOfBirthController.text = data?['dateOfBirth'] ?? '';
      _isLoading = false;
    });
  }

  void _handleEdit() {
    // Go back to ID scanner to re-scan
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const IdCardScannerScreen(),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      // Save edited data to storage
      final updatedData = {
        'name': _nameController.text.trim(),
        'idNumber': _idNumberController.text.trim(),
        'dateOfBirth': _dateOfBirthController.text.trim(),
      };
      await _storageService.saveScannedIdData(updatedData);

      // Navigate to Additional Info screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdditionalInfoScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
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
          'Verify Your Information',
          style: TextStyle(
            color: AppTheme.surfaceColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _handleEdit,
            child: const Text(
              'Edit',
              style: TextStyle(
                color: AppTheme.surfaceColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(AppTheme.spacingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info card
                    Container(
                      padding: EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        border: Border.all(
                          color: AppTheme.accentOrange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.accentOrange,
                            size: 24,
                          ),
                          SizedBox(width: AppTheme.spacingM),
                          Expanded(
                            child: Text(
                              'Please verify or enter your information manually. You can edit all fields below.',
                              style: TextStyle(
                                color: AppTheme.textOnLight,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingXL),
                    // Scanned Data Section
                    Text(
                      'ID Card Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textOnLight,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    // Name Field
                    _buildEditableField(
                      icon: Icons.person_outlined,
                      label: 'Full Name',
                      controller: _nameController,
                      hintText: 'Enter your full name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    // ID Number Field
                    _buildEditableField(
                      icon: Icons.badge_outlined,
                      label: 'ID Number',
                      controller: _idNumberController,
                      hintText: 'Enter your ID number',
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your ID number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    // Date of Birth Field
                    _buildEditableField(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date of Birth',
                      controller: _dateOfBirthController,
                      hintText: 'YYYY-MM-DD (e.g., 1990-05-15)',
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your date of birth';
                        }
                        // Basic date format validation
                        final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                        if (!dateRegex.hasMatch(value.trim())) {
                          return 'Please use format YYYY-MM-DD';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppTheme.spacingXL),
                    // Continue Button
                    CustomButton(
                      text: 'Continue',
                      onPressed: _handleContinue,
                      isLoading: false,
                    ),
                    SizedBox(height: AppTheme.spacingL),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: AppTheme.accentOrange.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.accentOrange,
              size: 24,
            ),
          ),
          SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                hintText: hintText,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryOnLight,
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.6),
                ),
              ),
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textOnLight,
                fontWeight: FontWeight.w600,
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}
