import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

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
          'Report',
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
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.lightBackground,
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(AppTheme.spacingM),
          itemCount: 10,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.only(bottom: AppTheme.spacingM),
              color: AppTheme.cardGray,
              child: ListTile(
                leading: Icon(Icons.description, color: AppTheme.cardIconColor),
                title: Text('Report ${index + 1}'),
                subtitle: Text('Transaction report'),
                trailing: Icon(Icons.download),
                onTap: () {},
              ),
            );
          },
        ),
      ),
    );
  }
}

