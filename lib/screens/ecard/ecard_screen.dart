import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/card_provider.dart';
import '../../widgets/card_widget.dart';

class ECardScreen extends StatefulWidget {
  const ECardScreen({super.key});

  @override
  State<ECardScreen> createState() => _ECardScreenState();
}

class _ECardScreenState extends State<ECardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CardProvider>(context, listen: false).loadCards();
    });
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
          'E-Card',
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
      body: Consumer<CardProvider>(
        builder: (context, cardProvider, _) {
          if (cardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeCards = cardProvider.activeCards;

          return RefreshIndicator(
            onRefresh: () async {
              await cardProvider.loadCards();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.accentOrange,
                          AppTheme.accentOrange.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.credit_card,
                            color: AppTheme.surfaceColor,
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'E-Card Management',
                                style: TextStyle(
                                  color: AppTheme.surfaceColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${activeCards.length} active card${activeCards.length != 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: AppTheme.surfaceColor.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      border: Border.all(
                        color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: AppTheme.accentOrange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'About E-Cards',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textOnLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage your digital cards for online and contactless payments',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondaryOnLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Active Cards Section
                  if (activeCards.isNotEmpty) ...[
                    const Text(
                      'Your E-Cards',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textOnLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...activeCards.map((card) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CardWidget(
                            card: card,
                            onTap: () {
                              // Show card details or actions
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${card.type.name} card details'),
                                  backgroundColor: AppTheme.accentOrange,
                                ),
                              );
                            },
                          ),
                        )),
                  ],

                  const SizedBox(height: 24),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textOnLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.add_card,
                          label: 'Add Card',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Add card feature coming soon'),
                                backgroundColor: AppTheme.accentOrange,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.history,
                          label: 'Card History',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Card history feature coming soon'),
                                backgroundColor: AppTheme.accentOrange,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  if (activeCards.isEmpty) ...[
                    const SizedBox(height: 32),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.credit_card_off,
                            size: 64,
                            color:
                                AppTheme.textSecondaryOnLight.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No E-Cards Available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textOnLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a new E-Card to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryOnLight,
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
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.accentOrange,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textOnLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
