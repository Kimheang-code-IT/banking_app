import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/bill_provider.dart';
import '../../providers/account_provider.dart';
import '../../models/bill.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_theme.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BillProvider>(context, listen: false).loadBills();
      Provider.of<AccountProvider>(context, listen: false).loadAccounts();
    });
  }

  Future<void> _payBill(Bill bill) async {
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    final primaryAccount = accountProvider.primaryAccount;

    if (primaryAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: AppTheme.surfaceColor),
              SizedBox(width: AppTheme.spacingS),
              Text('No account available for payment'),
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

    if (primaryAccount.balance < bill.amount) {
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: const Text('Confirm Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider: ${bill.provider}'),
            SizedBox(height: AppTheme.spacingS),
            Text(
              'Amount: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(bill.amount)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentOrange,
                  ),
            ),
            SizedBox(height: AppTheme.spacingS),
            Text('Due Date: ${DateFormat('MMM dd, yyyy').format(bill.dueDate)}'),
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
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final billProvider = Provider.of<BillProvider>(context, listen: false);

      // Update account balance
      await accountProvider.updateAccountBalance(
        primaryAccount.accountNumber,
        primaryAccount.balance - bill.amount,
      );

      // Mark bill as paid
      await billProvider.payBill(bill.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: AppTheme.surfaceColor),
                SizedBox(width: AppTheme.spacingS),
                Text('Bill paid successfully!'),
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

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
          'Bills',
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
      body: Consumer<BillProvider>(
        builder: (context, billProvider, _) {
          if (billProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final bills = billProvider.bills;
          final pendingBills = billProvider.pendingBills;
          final overdueBills = billProvider.overdueBills;

          if (bills.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await billProvider.loadBills();
            },
            child: ListView(
              padding: EdgeInsets.all(AppTheme.spacingM),
              children: [
                // Summary Card
                if (pendingBills.isNotEmpty)
                  Card(
                    elevation: AppTheme.elevationLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    ),
                    color: AppTheme.cardGray,
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.receipt_long, color: AppTheme.cardIconColor),
                              SizedBox(width: AppTheme.spacingS),
                              Text(
                                'Pending Bills',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppTheme.spacingM),
                          Text(
                            currencyFormat.format(billProvider.totalPendingAmount),
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppTheme.accentOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (overdueBills.isNotEmpty) ...[
                            SizedBox(height: AppTheme.spacingM),
                            Container(
                              padding: EdgeInsets.all(AppTheme.spacingM),
                              decoration: BoxDecoration(
                                color: AppTheme.cardGray,
                                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning, color: AppTheme.surfaceColor, size: 20),
                                  SizedBox(width: AppTheme.spacingS),
                                  Text(
                                    '${overdueBills.length} overdue bill(s)',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondaryOnLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: AppTheme.spacingL),

                // Bills List
                ...bills.map((bill) => _buildBillCard(
                      context,
                      bill: bill,
                      currencyFormat: currencyFormat,
                      dateFormat: dateFormat,
                      onPay: () => _payBill(bill),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBillCard(
    BuildContext context, {
    required Bill bill,
    required NumberFormat currencyFormat,
    required DateFormat dateFormat,
    required VoidCallback onPay,
  }) {
    final isOverdue = bill.isOverdue;
    final isPaid = bill.status == BillStatus.paid;
    final statusColor = _getStatusColor(bill.status);

    return Card(
      elevation: AppTheme.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      margin: EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.provider,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textOnLight,
                            ),
                      ),
                      SizedBox(height: AppTheme.spacingXS),
                      Row(
                        children: [
                          Icon(
                            _getCategoryIcon(bill.category),
                            size: 16,
                            color: AppTheme.textSecondaryOnLight,
                          ),
                          SizedBox(width: AppTheme.spacingXS),
                          Text(
                            _getCategoryName(bill.category),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondaryOnLight,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Text(
                    bill.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryOnLight,
                          ),
                    ),
                    SizedBox(height: AppTheme.spacingXS),
                    Text(
                      currencyFormat.format(bill.amount),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isOverdue ? AppTheme.textSecondaryOnLight : AppTheme.textOnLight,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Due Date',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryOnLight,
                          ),
                    ),
                    SizedBox(height: AppTheme.spacingXS),
                    Text(
                      dateFormat.format(bill.dueDate),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isOverdue ? AppTheme.textSecondaryOnLight : AppTheme.textOnLight,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            if (bill.description != null) ...[
              SizedBox(height: AppTheme.spacingM),
              Container(
                padding: EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.lightBackground,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Text(
                  bill.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryOnLight,
                      ),
                ),
              ),
            ],
            if (!isPaid) ...[
              SizedBox(height: AppTheme.spacingL),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: isOverdue ? 'Pay Overdue Bill' : 'Pay Bill',
                  onPressed: onPay,
                  backgroundColor: isOverdue ? AppTheme.textSecondary : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spacingXL),
            decoration: BoxDecoration(
              color: AppTheme.lightBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppTheme.accentOrange.withOpacity(0.6),
            ),
          ),
          SizedBox(height: AppTheme.spacingL),
          Text(
            'No bills found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textOnLight,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: AppTheme.spacingS),
          Text(
            'Your bills will appear here when available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryOnLight,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(BillCategory category) {
    switch (category) {
      case BillCategory.utilities:
        return Icons.bolt;
      case BillCategory.subscription:
        return Icons.subscriptions;
      case BillCategory.insurance:
        return Icons.shield;
      case BillCategory.loan:
        return Icons.account_balance;
      case BillCategory.other:
        return Icons.receipt;
    }
  }

  String _getCategoryName(BillCategory category) {
    switch (category) {
      case BillCategory.utilities:
        return 'Utilities';
      case BillCategory.subscription:
        return 'Subscription';
      case BillCategory.insurance:
        return 'Insurance';
      case BillCategory.loan:
        return 'Loan';
      case BillCategory.other:
        return 'Other';
    }
  }

  Color _getStatusColor(BillStatus status) {
    switch (status) {
      case BillStatus.paid:
        return AppTheme.accentOrange;
      case BillStatus.pending:
        return AppTheme.accentOrange;
      case BillStatus.overdue:
        return AppTheme.textSecondary;
    }
  }
}

