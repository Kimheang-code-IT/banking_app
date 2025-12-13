import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/account.dart';
import '../../models/transaction.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_theme.dart';

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

  Future<void> _handleTransfer() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: AppTheme.surfaceColor),
                SizedBox(width: AppTheme.spacingS),
                Text('Please select an account'),
              ],
            ),
            backgroundColor: AppTheme.textSecondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusM)),
            ),
            margin: EdgeInsets.all(AppTheme.spacingM),
          ),
        );
        return;
      }

      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: AppTheme.surfaceColor),
                SizedBox(width: AppTheme.spacingS),
                Text('Please enter a valid amount'),
              ],
            ),
            backgroundColor: AppTheme.textSecondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusM)),
            ),
            margin: EdgeInsets.all(AppTheme.spacingM),
          ),
        );
        return;
      }

      if (amount > _selectedAccount!.balance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: AppTheme.surfaceColor),
                SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text('Insufficient balance. Please check your account balance.'),
                ),
              ],
            ),
            backgroundColor: AppTheme.textSecondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusM)),
            ),
            margin: EdgeInsets.all(AppTheme.spacingM),
          ),
        );
        return;
      }

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          title: const Text('Confirm Transfer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recipient: ${_recipientController.text}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: AppTheme.spacingS),
              Text(
                'Amount: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentOrange,
                    ),
              ),
              if (_descriptionController.text.isNotEmpty) ...[
                SizedBox(height: AppTheme.spacingS),
                Text(
                  'Description: ${_descriptionController.text}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondaryOnLight),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentOrange,
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

      final accountProvider = Provider.of<AccountProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

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
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: AppTheme.surfaceColor),
                SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text('Transfer completed successfully!'),
                ),
              ],
            ),
            backgroundColor: AppTheme.accentOrange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusM)),
            ),
            margin: EdgeInsets.all(AppTheme.spacingM),
          ),
        );

        // Clear form
        _recipientController.clear();
        _amountController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedAccount = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

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
        padding: EdgeInsets.all(AppTheme.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Account Selection Card
              Consumer<AccountProvider>(
                builder: (context, accountProvider, _) {
                  if (accountProvider.isLoading) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.spacingL),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  if (accountProvider.accounts.isEmpty) {
                    return Card(
                      elevation: AppTheme.elevationLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.spacingL),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: AppTheme.surfaceColor),
                            SizedBox(width: AppTheme.spacingM),
                            Expanded(
                              child: Text(
                                'No accounts available',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondaryOnLight,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Card(
                    elevation: AppTheme.elevationLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance, color: AppTheme.cardIconColor),
                              SizedBox(width: AppTheme.spacingS),
                              Text(
                                'From Account',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppTheme.spacingM),
                          DropdownButtonFormField<Account>(
                            value: _selectedAccount,
                            decoration: const InputDecoration(
                              labelText: 'Select Account',
                              hintText: 'Choose an account',
                              border: OutlineInputBorder(),
                            ),
                            items: accountProvider.accounts.map((account) {
                              return DropdownMenuItem<Account>(
                                value: account,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      account.accountName ?? account.type.toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: AppTheme.spacingXS),
                                    Text(
                                      '${account.accountNumber} • ${currencyFormat.format(account.balance)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondaryOnLight,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (account) {
                              setState(() {
                                _selectedAccount = account;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select an account';
                              }
                              return null;
                            },
                          ),
                          if (_selectedAccount != null) ...[
                            SizedBox(height: AppTheme.spacingM),
                            Container(
                              padding: EdgeInsets.all(AppTheme.spacingM),
                              decoration: BoxDecoration(
                                color: AppTheme.lightBackground,
                                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Available Balance:',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    currencyFormat.format(_selectedAccount!.balance),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.accentOrange,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: AppTheme.spacingL),

              // Recipient Field
              TextFormField(
                controller: _recipientController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Recipient Account Number',
                  hintText: 'Enter account number',
                  prefixIcon: Icon(Icons.person_outlined),
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

              SizedBox(height: AppTheme.spacingM),

              // Amount Field
              TextFormField(
                controller: _amountController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (_selectedAccount != null && amount > _selectedAccount!.balance) {
                    return 'Amount exceeds available balance';
                  }
                  return null;
                },
              ),

              SizedBox(height: AppTheme.spacingM),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add a note for this transfer',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 2,
              ),

              SizedBox(height: AppTheme.spacingXL),

              // Transfer Button
              CustomButton(
                text: 'Transfer Money',
                onPressed: _handleTransfer,
                isLoading: _isLoading,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
