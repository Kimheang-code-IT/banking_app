import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/account.dart';
import '../../models/transaction.dart';
import '../../theme/app_theme.dart';
import '../qr_scanner/qr_scanner_screen.dart';

class TransferScreen extends StatefulWidget {
  final String? prefillAccountNumber;
  final String? prefillAmount;

  const TransferScreen({
    super.key,
    this.prefillAccountNumber,
    this.prefillAmount,
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  Account? _selectedAccount;
  bool _isLoading = false;
  String? _recipientName;

  @override
  void initState() {
    super.initState();
    // Prefill data from QR scanner if available
    if (widget.prefillAccountNumber != null) {
      _recipientController.text = widget.prefillAccountNumber!;
    }
    if (widget.prefillAmount != null) {
      _amountController.text = widget.prefillAmount!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).loadAccounts();
    });
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _simulateRecipientLookup(String accountNumber) {
    // Simulate looking up recipient name
    if (accountNumber.length >= 8) {
      setState(() {
        _recipientName = 'Account Holder'; // In real app, fetch from API
      });
    } else {
      setState(() {
        _recipientName = null;
      });
    }
  }

  Future<void> _handleTransfer() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an account'),
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

      if (amount > _selectedAccount!.balance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Insufficient balance. Please check your account balance.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Confirm Transfer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recipient: ${_recipientController.text}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'Amount: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentOrange,
                ),
              ),
              if (_descriptionController.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Description: ${_descriptionController.text}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentOrange,
                foregroundColor: AppTheme.surfaceColor,
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() {
        _isLoading = true;
      });

      // Simulate transfer processing
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final accountProvider =
          Provider.of<AccountProvider>(context, listen: false);
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);

      // Update account balance
      await accountProvider.updateAccountBalance(
        _selectedAccount!.accountNumber,
        _selectedAccount!.balance - amount,
      );

      // Add transaction
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: -amount,
        type: TransactionType.transfer,
        description: _descriptionController.text.isEmpty
            ? 'Transfer to ${_recipientController.text}'
            : _descriptionController.text,
        date: DateTime.now(),
        recipient: _recipientController.text,
        status: TransactionStatus.completed,
        accountNumber: _selectedAccount!.accountNumber,
      );

      await transactionProvider.addTransaction(transaction);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfer completed successfully!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );

        // Clear form
        _recipientController.clear();
        _amountController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedAccount = null;
          _recipientName = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

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
          'Transfer Money',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Selection
              Consumer<AccountProvider>(
                builder: (context, accountProvider, _) {
                  if (accountProvider.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (accountProvider.accounts.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppTheme.textSecondaryOnLight),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No accounts available',
                              style: TextStyle(
                                  color: AppTheme.textSecondaryOnLight),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'From Account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textOnLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...accountProvider.accounts.map((account) {
                        final isSelected = _selectedAccount?.accountNumber ==
                            account.accountNumber;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedAccount = account;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.accentOrange.withOpacity(0.1)
                                    : AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.accentOrange
                                      : AppTheme.textSecondaryOnLight
                                          .withOpacity(0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.accentOrange
                                          : AppTheme.accentOrange
                                              .withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.account_balance_wallet,
                                      color: isSelected
                                          ? AppTheme.surfaceColor
                                          : AppTheme.accentOrange,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          account.accountName ??
                                              account.type.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textOnLight,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          account.accountNumber,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                AppTheme.textSecondaryOnLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        currencyFormat.format(account.balance),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? AppTheme.accentOrange
                                              : AppTheme.textOnLight,
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppTheme.accentOrange,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Recipient Account Number
              const Text(
                'To Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textOnLight,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _recipientController,
                      textInputAction: TextInputAction.next,
                      onChanged: _simulateRecipientLookup,
                      decoration: InputDecoration(
                        hintText: 'Enter account number',
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: AppTheme.surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                AppTheme.textSecondaryOnLight.withOpacity(0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                AppTheme.textSecondaryOnLight.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
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
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter recipient account number';
                        }
                        if (value.length < 8) {
                          return 'Account number must be at least 8 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.qr_code_scanner,
                          color: AppTheme.surfaceColor),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QRScannerScreen(),
                          ),
                        );
                        // QR scanner will navigate to transfer screen with prefill
                      },
                    ),
                  ),
                ],
              ),
              if (_recipientName != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: AppTheme.successGreen, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _recipientName!,
                        style: TextStyle(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Amount
              const Text(
                'Amount (USD)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textOnLight,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  prefixIcon: const Icon(Icons.attach_money),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (_selectedAccount != null &&
                      amount > _selectedAccount!.balance) {
                    return 'Amount exceeds available balance';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

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
                  Expanded(
                    child: _buildQuickAmountButton('10'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAmountButton('50'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAmountButton('100'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAmountButton('500'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Description
              TextFormField(
                controller: _descriptionController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add a note for this transfer',
                  prefixIcon: const Icon(Icons.description_outlined),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                maxLines: 2,
              ),

              const SizedBox(height: 40),

              // Transfer Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: AppTheme.surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Transfer Money',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    return InkWell(
      onTap: () {
        setState(() {
          _amountController.text = amount;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
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
