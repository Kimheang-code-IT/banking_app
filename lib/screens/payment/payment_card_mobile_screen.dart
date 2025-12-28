import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';

enum PaymentCategory {
  simCard,
  school,
  electricity,
  water,
  internet,
  tvCable,
}

class PaymentCardMobileScreen extends StatefulWidget {
  const PaymentCardMobileScreen({super.key});

  @override
  State<PaymentCardMobileScreen> createState() =>
      _PaymentCardMobileScreenState();
}

class _PaymentCardMobileScreenState extends State<PaymentCardMobileScreen> {
  PaymentCategory _selectedCategory = PaymentCategory.simCard;
  bool _isLoading = false;
  String? _detectedProvider;
  String? _selectedSchool;
  String? _selectedInternetProvider;
  String? _selectedTvProvider;
  String? _selectedSemester;

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();

  // Cambodian mobile number prefixes
  final Map<String, List<String>> _providerPrefixes = {
    'Smart': [
      '010',
      '011',
      '012',
      '013',
      '014',
      '015',
      '016',
      '017',
      '018',
      '069',
      '070',
      '071',
      '081',
      '086',
      '087',
      '088',
      '089',
      '092',
      '093',
      '095',
      '096',
      '097',
      '098',
      '099'
    ],
    'Cellcard': [
      '011',
      '012',
      '013',
      '014',
      '015',
      '016',
      '017',
      '018',
      '061',
      '077',
      '078',
      '079',
      '085',
      '089',
      '092',
      '093',
      '095',
      '096',
      '097',
      '098',
      '099'
    ],
    'Metfone': [
      '031',
      '032',
      '033',
      '034',
      '035',
      '036',
      '037',
      '038',
      '039',
      '060',
      '066',
      '067',
      '068',
      '071',
      '088',
      '090',
      '097'
    ],
    'Seatel': ['038', '039', '078', '079', '088', '089'],
    'QB': [
      '013',
      '016',
      '017',
      '018',
      '042',
      '043',
      '044',
      '045',
      '046',
      '047',
      '048',
      '049',
      '050',
      '051',
      '052',
      '053',
      '054',
      '055',
      '056',
      '057',
      '058',
      '059',
      '060',
      '061',
      '062',
      '063',
      '064',
      '065',
      '066',
      '067',
      '068',
      '069',
      '070',
      '071',
      '072',
      '073',
      '074',
      '075',
      '076',
      '077',
      '078',
      '079',
      '080',
      '081',
      '082',
      '083',
      '084',
      '085',
      '086',
      '087',
      '088',
      '089',
      '090',
      '091',
      '092',
      '093',
      '094',
      '095',
      '096',
      '097',
      '098',
      '099'
    ],
  };

  // Category configuration
  final Map<PaymentCategory, Map<String, dynamic>> _categoryConfig = {
    PaymentCategory.simCard: {
      'name': 'SIM Card',
      'icon': Icons.sim_card,
      'color': Colors.blue,
    },
    PaymentCategory.school: {
      'name': 'School',
      'icon': Icons.school,
      'color': Colors.purple,
    },
    PaymentCategory.electricity: {
      'name': 'Electricity',
      'icon': Icons.flash_on,
      'color': Colors.orange,
    },
    PaymentCategory.water: {
      'name': 'Water',
      'icon': Icons.water_drop,
      'color': Colors.cyan,
    },
    PaymentCategory.internet: {
      'name': 'Internet',
      'icon': Icons.wifi,
      'color': Colors.green,
    },
    PaymentCategory.tvCable: {
      'name': 'TV/Cable',
      'icon': Icons.tv,
      'color': Colors.red,
    },
  };

  // Cambodian providers
  final List<String> _schools = [
    'Royal University of Phnom Penh',
    'Institute of Technology of Cambodia',
    'Royal University of Law and Economics',
    'University of Health Sciences',
    'National University of Management',
    'Other',
  ];

  final List<String> _internetProviders = [
    'Ezecom',
    'SINET',
    'Opennet',
    'Metfone',
    'Other',
  ];

  final List<String> _tvProviders = [
    'PPCTV',
    'CCTV',
    'Other',
  ];

  final List<String> _semesters = [
    'Semester 1',
    'Semester 2',
    'Summer',
    'Other',
  ];

  Map<String, dynamic> _getProviderInfo(String providerName) {
    switch (providerName) {
      case 'Smart':
        return {
          'name': 'Smart',
          'icon': Icons.phone_iphone,
          'color': Colors.red
        };
      case 'Cellcard':
        return {
          'name': 'Cellcard',
          'icon': Icons.phone_android,
          'color': Colors.blue
        };
      case 'Metfone':
        return {'name': 'Metfone', 'icon': Icons.phone, 'color': Colors.orange};
      case 'Seatel':
        return {
          'name': 'Seatel',
          'icon': Icons.sim_card,
          'color': Colors.green
        };
      case 'QB':
        return {
          'name': 'QB',
          'icon': Icons.phone_android,
          'color': Colors.purple
        };
      default:
        return {'name': 'Unknown', 'icon': Icons.phone, 'color': Colors.grey};
    }
  }

  void _detectProvider(String phoneNumber) {
    if (_selectedCategory != PaymentCategory.simCard) return;

    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.isEmpty || cleaned.length < 2) {
      setState(() {
        _detectedProvider = null;
      });
      return;
    }

    String numberToCheck = cleaned;
    if (cleaned.startsWith('855') && cleaned.length > 3) {
      numberToCheck = cleaned.substring(3);
    } else if (!cleaned.startsWith('0') && cleaned.length >= 9) {
      numberToCheck = '0$cleaned';
    }

    if (!numberToCheck.startsWith('0') && numberToCheck.length >= 2) {
      numberToCheck = '0$numberToCheck';
    }

    String? detected;

    if (numberToCheck.length >= 3) {
      final prefix3 = numberToCheck.substring(0, 3);
      final priorityOrder = ['Smart', 'Cellcard', 'Metfone', 'Seatel', 'QB'];
      for (var providerName in priorityOrder) {
        if (_providerPrefixes[providerName]?.contains(prefix3) ?? false) {
          detected = providerName;
          break;
        }
      }
    }

    if (detected == null && numberToCheck.length >= 2) {
      final prefix2 = numberToCheck.substring(0, 2);
      final priorityOrder = ['Smart', 'Cellcard', 'Metfone', 'Seatel', 'QB'];
      for (var providerName in priorityOrder) {
        final prefixes = _providerPrefixes[providerName] ?? [];
        if (prefixes.any((p) => p.startsWith(prefix2))) {
          detected = providerName;
          break;
        }
      }
    }

    setState(() {
      _detectedProvider = detected;
    });
  }

  void _onCategorySelected(PaymentCategory category) {
    setState(() {
      _selectedCategory = category;
      _detectedProvider = null;
      _selectedSchool = null;
      _selectedInternetProvider = null;
      _selectedTvProvider = null;
      _selectedSemester = null;
      // Clear all controllers
      _phoneController.clear();
      _amountController.clear();
      _studentIdController.clear();
      _accountNumberController.clear();
      _customerNameController.clear();
    });
  }

  bool _validateForm() {
    switch (_selectedCategory) {
      case PaymentCategory.simCard:
        if (_phoneController.text.isEmpty || _amountController.text.isEmpty) {
          return false;
        }
        if (_detectedProvider == null) {
          return false;
        }
        break;
      case PaymentCategory.school:
        if (_studentIdController.text.isEmpty ||
            _selectedSchool == null ||
            _selectedSemester == null ||
            _amountController.text.isEmpty) {
          return false;
        }
        break;
      case PaymentCategory.electricity:
      case PaymentCategory.water:
        if (_accountNumberController.text.isEmpty ||
            _customerNameController.text.isEmpty ||
            _amountController.text.isEmpty) {
          return false;
        }
        break;
      case PaymentCategory.internet:
      case PaymentCategory.tvCable:
        if (_accountNumberController.text.isEmpty ||
            (_selectedCategory == PaymentCategory.internet &&
                _selectedInternetProvider == null) ||
            (_selectedCategory == PaymentCategory.tvCable &&
                _selectedTvProvider == null) ||
            _amountController.text.isEmpty) {
          return false;
        }
        break;
    }
    return true;
  }

  String _getValidationErrorMessage() {
    switch (_selectedCategory) {
      case PaymentCategory.simCard:
        if (_phoneController.text.isEmpty || _amountController.text.isEmpty) {
          return 'Please fill in all fields';
        }
        if (_detectedProvider == null) {
          return 'Please enter a valid Cambodian phone number';
        }
        break;
      case PaymentCategory.school:
        if (_studentIdController.text.isEmpty) {
          return 'Please enter student ID';
        }
        if (_selectedSchool == null) {
          return 'Please select a school';
        }
        if (_selectedSemester == null) {
          return 'Please select a semester';
        }
        if (_amountController.text.isEmpty) {
          return 'Please enter amount';
        }
        break;
      case PaymentCategory.electricity:
      case PaymentCategory.water:
        if (_accountNumberController.text.isEmpty) {
          return 'Please enter account number';
        }
        if (_customerNameController.text.isEmpty) {
          return 'Please enter customer name';
        }
        if (_amountController.text.isEmpty) {
          return 'Please enter amount';
        }
        break;
      case PaymentCategory.internet:
        if (_accountNumberController.text.isEmpty) {
          return 'Please enter account number';
        }
        if (_selectedInternetProvider == null) {
          return 'Please select internet provider';
        }
        if (_amountController.text.isEmpty) {
          return 'Please enter amount';
        }
        break;
      case PaymentCategory.tvCable:
        if (_accountNumberController.text.isEmpty) {
          return 'Please enter account number';
        }
        if (_selectedTvProvider == null) {
          return 'Please select TV/Cable provider';
        }
        if (_amountController.text.isEmpty) {
          return 'Please enter amount';
        }
        break;
    }
    return 'Please fill in all required fields';
  }

  Future<void> _handlePayment() async {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getValidationErrorMessage()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    final primaryAccount = accountProvider.primaryAccount;

    if (primaryAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No account available for payment'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (primaryAccount.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Create transaction description
    String description = _getPaymentDescription();
    String recipient = _getRecipient();

    // Create transaction
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: TransactionType.expense,
      description: description,
      date: DateTime.now(),
      recipient: recipient,
      status: TransactionStatus.completed,
      category: _categoryConfig[_selectedCategory]!['name'] as String,
      accountNumber: primaryAccount.accountNumber,
    );

    // Update account balance
    await accountProvider.updateAccountBalance(
      primaryAccount.accountNumber,
      primaryAccount.balance - amount,
    );

    // Add transaction
    await transactionProvider.addTransaction(transaction);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Payment of \$${amount.toStringAsFixed(2)} successful!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      // Clear form
      _phoneController.clear();
      _amountController.clear();
      _studentIdController.clear();
      _accountNumberController.clear();
      _customerNameController.clear();
      setState(() {
        _detectedProvider = null;
        _selectedSchool = null;
        _selectedInternetProvider = null;
        _selectedTvProvider = null;
        _selectedSemester = null;
      });
    }
  }

  String _getPaymentDescription() {
    switch (_selectedCategory) {
      case PaymentCategory.simCard:
        return 'SIM Card Top-up - ${_phoneController.text}';
      case PaymentCategory.school:
        return 'School Payment - $_selectedSchool';
      case PaymentCategory.electricity:
        return 'Electricity Payment - EDC';
      case PaymentCategory.water:
        return 'Water Payment - Phnom Penh Water Supply';
      case PaymentCategory.internet:
        return 'Internet Payment - $_selectedInternetProvider';
      case PaymentCategory.tvCable:
        return 'TV/Cable Payment - $_selectedTvProvider';
    }
  }

  String _getRecipient() {
    switch (_selectedCategory) {
      case PaymentCategory.simCard:
        return _phoneController.text;
      case PaymentCategory.school:
        return _studentIdController.text;
      case PaymentCategory.electricity:
      case PaymentCategory.water:
      case PaymentCategory.internet:
      case PaymentCategory.tvCable:
        return _accountNumberController.text;
    }
  }

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      _detectProvider(_phoneController.text);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _studentIdController.dispose();
    _accountNumberController.dispose();
    _customerNameController.dispose();
    super.dispose();
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
          'Payment',
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
      body: Column(
        children: [
          // Category Chips
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: PaymentCategory.values.length,
              itemBuilder: (context, index) {
                final category = PaymentCategory.values[index];
                final config = _categoryConfig[category]!;
                final isSelected = _selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => _onCategorySelected(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.accentOrange
                            : AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.accentOrange
                              : AppTheme.textSecondaryOnLight.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentOrange.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            config['icon'] as IconData,
                            color: isSelected
                                ? AppTheme.surfaceColor
                                : AppTheme.textSecondaryOnLight,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            config['name'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppTheme.surfaceColor
                                  : AppTheme.textSecondaryOnLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Dynamic Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider Detection Card (for SIM Card)
                  if (_selectedCategory == PaymentCategory.simCard &&
                      _detectedProvider != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getProviderInfo(_detectedProvider!)['color']
                            as Color,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_getProviderInfo(_detectedProvider!)['color']
                                        as Color)
                                    .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getProviderInfo(_detectedProvider!)['icon']
                                as IconData,
                            color: AppTheme.surfaceColor,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Detected Provider',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        AppTheme.surfaceColor.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _detectedProvider!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.surfaceColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_selectedCategory == PaymentCategory.simCard &&
                      _detectedProvider != null)
                    const SizedBox(height: 24),

                  // Dynamic Form Fields
                  ..._buildCategoryFields(),

                  const SizedBox(height: 32),

                  // Quick Amount Buttons
                  const Text(
                    'Quick Amount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textOnLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildQuickAmountButton('5')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickAmountButton('10')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickAmountButton('20')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickAmountButton('50')),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handlePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        foregroundColor: AppTheme.surfaceColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.surfaceColor,
                                ),
                              ),
                            )
                          : const Text(
                              'Pay Now',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryFields() {
    switch (_selectedCategory) {
      case PaymentCategory.simCard:
        return [
          const Text(
            'Phone Number',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Enter phone number (e.g., 0151234567)',
              prefixIcon: const Icon(Icons.phone),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: const BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Amount (USD)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter amount',
              prefixIcon: const Icon(Icons.attach_money),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: const BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ];

      case PaymentCategory.school:
        return [
          const Text(
            'Student ID',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _studentIdController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Enter student ID',
              prefixIcon: const Icon(Icons.badge),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: const BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'School Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
              ),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedSchool,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Select school',
                prefixIcon: const Icon(Icons.school),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              items: _schools.map((school) {
                return DropdownMenuItem(
                  value: school,
                  child: Text(
                    school,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSchool = value;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Semester',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
              ),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedSemester,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Select semester',
                prefixIcon: const Icon(Icons.calendar_today),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              items: _semesters.map((semester) {
                return DropdownMenuItem(
                  value: semester,
                  child: Text(
                    semester,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSemester = value;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Amount (USD)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter amount',
              prefixIcon: const Icon(Icons.attach_money),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: const BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ];

      case PaymentCategory.electricity:
      case PaymentCategory.water:
        return [
          const Text(
            'Account Number',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _accountNumberController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Enter account number',
              prefixIcon: const Icon(Icons.account_circle),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: const BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Customer Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customerNameController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              hintText: 'Enter customer name',
              prefixIcon: const Icon(Icons.person),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: const BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Amount (USD)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter amount',
              prefixIcon: const Icon(Icons.attach_money),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: const BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ];

      case PaymentCategory.internet:
        return [
          const Text(
            'Account Number',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _accountNumberController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Enter account number',
              prefixIcon: const Icon(Icons.account_circle),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: const BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Internet Provider',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
              ),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedInternetProvider,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Select internet provider',
                prefixIcon: const Icon(Icons.wifi),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              items: _internetProviders.map((provider) {
                return DropdownMenuItem(
                  value: provider,
                  child: Text(
                    provider,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedInternetProvider = value;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Amount (USD)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter amount',
              prefixIcon: const Icon(Icons.attach_money),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: const BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ];

      case PaymentCategory.tvCable:
        return [
          const Text(
            'Account Number',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _accountNumberController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Enter account number',
              prefixIcon: const Icon(Icons.account_circle),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: const BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'TV/Cable Provider',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
              ),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedTvProvider,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Select TV/Cable provider',
                prefixIcon: const Icon(Icons.tv),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              items: _tvProviders.map((provider) {
                return DropdownMenuItem(
                  value: provider,
                  child: Text(
                    provider,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTvProvider = value;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Amount (USD)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter amount',
              prefixIcon: const Icon(Icons.attach_money),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                borderSide: const BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ];
    }
  }

  Widget _buildQuickAmountButton(String amount) {
    return InkWell(
      onTap: () {
        setState(() {
          _amountController.text = amount;
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusS),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
          border: Border.all(
            color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Text(
            '\$$amount',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOnLight,
            ),
          ),
        ),
      ),
    );
  }
}
