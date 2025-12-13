import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/card_provider.dart';
import '../../widgets/card_widget.dart';
import '../../theme/app_theme.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CardProvider>(context, listen: false).loadCards();
    });
  }

  Future<void> _toggleCardStatus(String cardId, bool currentStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentStatus ? 'Freeze Card?' : 'Unfreeze Card?'),
        content: Text(
          currentStatus
              ? 'This card will be temporarily frozen and cannot be used for transactions.'
              : 'This card will be unfrozen and can be used for transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(currentStatus ? 'Freeze' : 'Unfreeze'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      await cardProvider.toggleCardStatus(cardId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentStatus
                  ? 'Card frozen successfully'
                  : 'Card unfrozen successfully',
            ),
            backgroundColor: AppTheme.accentOrange,
          ),
        );
      }
    }
  }

  void _showCardDetails(BuildContext context, card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Card Details',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 24),
                _buildDetailRow(
                    context, 'Card Type', card.type.name.toUpperCase()),
                const SizedBox(height: 16),
                _buildDetailRow(context, 'Card Number', card.maskedCardNumber),
                const SizedBox(height: 16),
                _buildDetailRow(context, 'Card Holder', card.holderName),
                const SizedBox(height: 16),
                _buildDetailRow(context, 'Expiry Date', card.expiryDate),
                const SizedBox(height: 16),
                _buildDetailRow(
                    context, 'Status', card.isActive ? 'Active' : 'Frozen'),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleCardStatus(card.id, card.isActive);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          card.isActive ? AppTheme.textSecondary : AppTheme.accentOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      card.isActive ? 'Freeze Card' : 'Unfreeze Card',
                      style: const TextStyle(color: AppTheme.surfaceColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
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
          'Cards',
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

          final cards = cardProvider.cards;

          if (cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.credit_card_off_outlined,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No cards found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                  ),
                ],
              ),
            );
          }

          final frozenCards = cards.where((card) => !card.isActive).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await cardProvider.loadCards();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Active Cards
                if (cardProvider.activeCards.isNotEmpty) ...[
                  Text(
                    'Active Cards',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...cardProvider.activeCards.map((card) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CardWidget(
                          card: card,
                          onTap: () => _showCardDetails(context, card),
                        ),
                      )),
                  const SizedBox(height: 24),
                ],

                // Frozen Cards
                if (frozenCards.isNotEmpty) ...[
                  Text(
                    'Frozen Cards',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...frozenCards.map((card) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Opacity(
                          opacity: 0.6,
                          child: CardWidget(
                            card: card,
                            onTap: () => _showCardDetails(context, card),
                          ),
                        ),
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
