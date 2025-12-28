import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).loadAccounts();
      Provider.of<TransactionProvider>(context, listen: false)
          .loadTransactions();
    });
  }

  List<Transaction> get _withdrawHistory {
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    return transactionProvider.transactions
        .where((t) => t.type == TransactionType.expense)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double get _totalWithdrawals {
    return _withdrawHistory.fold(0.0, (sum, t) => sum + t.amount);
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

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
          'Withdraw',
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
      body: Column(
        children: [
          // Summary Section (200 height)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accentOrange,
                  AppTheme.accentOrange.withOpacity(0.8),
                ],
              ),
            ),
            child: Consumer<AccountProvider>(
              builder: (context, accountProvider, child) {
                final primaryAccount = accountProvider.primaryAccount;
                final balance = primaryAccount?.balance ?? 0.0;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Current Balance',
                                    style: TextStyle(
                                      color: AppTheme.surfaceColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      currencyFormat.format(balance),
                                      style: const TextStyle(
                                        color: AppTheme.surfaceColor,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.savings,
                                color: AppTheme.surfaceColor,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: _buildSummaryItem(
                                'Total Withdrawals',
                                currencyFormat.format(_totalWithdrawals),
                                Icons.arrow_upward,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: AppTheme.surfaceColor.withOpacity(0.3),
                            ),
                            Expanded(
                              child: _buildSummaryItem(
                                'Withdrawal Count',
                                '${_withdrawHistory.length}',
                                Icons.receipt,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // History List
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.lightBackground,
              ),
              child: Consumer<TransactionProvider>(
                builder: (context, transactionProvider, _) {
                  final history = _withdrawHistory;

                  return RefreshIndicator(
                    onRefresh: () async {
                      await transactionProvider.loadTransactions();
                    },
                    child: history.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.savings_outlined,
                                  size: 64,
                                  color: AppTheme.textSecondaryOnLight
                                      .withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No withdrawal history',
                                  style: TextStyle(
                                    color: AppTheme.textSecondaryOnLight,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(top: 8),
                            itemCount: history.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              thickness: 1,
                              indent: 80,
                              color: AppTheme.textSecondaryOnLight
                                  .withOpacity(0.1),
                            ),
                            itemBuilder: (context, index) {
                              final transaction = history[index];
                              return _buildWithdrawItem(
                                  transaction, currencyFormat);
                            },
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawItem(
      Transaction transaction, NumberFormat currencyFormat) {
    return InkWell(
      onTap: () {
        // Could navigate to transaction detail if needed
      },
      child: Container(
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
                color: AppTheme.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward,
                color: AppTheme.errorRed,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Description, Amount, and Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textOnLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(transaction.amount),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.errorRed,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getRelativeTime(transaction.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryOnLight,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    transaction.status.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentOrange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppTheme.surfaceColor,
          size: 20,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.surfaceColor.withOpacity(0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.surfaceColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
