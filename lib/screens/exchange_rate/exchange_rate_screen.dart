import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class Currency {
  final String code;
  final String name;
  final String country;
  final String flag;
  final double buyRate; // Rate to buy (USD to currency)
  final double sellRate; // Rate to sell (currency to USD)
  final double changePercent; // Change percentage

  Currency({
    required this.code,
    required this.name,
    required this.country,
    required this.flag,
    required this.buyRate,
    required this.sellRate,
    required this.changePercent,
  });
}

class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({super.key});

  @override
  State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Currency> _currencies = [];
  List<Currency> _filteredCurrencies = [];
  bool _showBuyRate = true;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
    _searchController.addListener(_filterCurrencies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCurrencies() {
    // Major currencies with exchange rates (1 USD = X currency)
    // Rates are approximate and for demonstration
    _currencies = [
      Currency(
        code: 'KHR',
        name: 'Riel',
        country: 'Cambodia',
        flag: '🇰🇭',
        buyRate: 4100.00,
        sellRate: 4080.00,
        changePercent: 0.15,
      ),
      Currency(
        code: 'THB',
        name: 'Baht',
        country: 'Thailand',
        flag: '🇹🇭',
        buyRate: 35.50,
        sellRate: 35.30,
        changePercent: -0.25,
      ),
      Currency(
        code: 'EUR',
        name: 'Euro',
        country: 'European Union',
        flag: '🇪🇺',
        buyRate: 0.92,
        sellRate: 0.90,
        changePercent: 0.35,
      ),
      Currency(
        code: 'GBP',
        name: 'Pound Sterling',
        country: 'United Kingdom',
        flag: '🇬🇧',
        buyRate: 0.79,
        sellRate: 0.77,
        changePercent: 0.42,
      ),
      Currency(
        code: 'JPY',
        name: 'Yen',
        country: 'Japan',
        flag: '🇯🇵',
        buyRate: 149.50,
        sellRate: 149.00,
        changePercent: -0.18,
      ),
      Currency(
        code: 'CNY',
        name: 'Yuan',
        country: 'China',
        flag: '🇨🇳',
        buyRate: 7.25,
        sellRate: 7.20,
        changePercent: 0.12,
      ),
      Currency(
        code: 'SGD',
        name: 'Singapore Dollar',
        country: 'Singapore',
        flag: '🇸🇬',
        buyRate: 1.34,
        sellRate: 1.32,
        changePercent: 0.08,
      ),
      Currency(
        code: 'MYR',
        name: 'Ringgit',
        country: 'Malaysia',
        flag: '🇲🇾',
        buyRate: 4.68,
        sellRate: 4.65,
        changePercent: -0.15,
      ),
      Currency(
        code: 'IDR',
        name: 'Rupiah',
        country: 'Indonesia',
        flag: '🇮🇩',
        buyRate: 15650.00,
        sellRate: 15600.00,
        changePercent: 0.22,
      ),
      Currency(
        code: 'VND',
        name: 'Dong',
        country: 'Vietnam',
        flag: '🇻🇳',
        buyRate: 24500.00,
        sellRate: 24450.00,
        changePercent: 0.05,
      ),
      Currency(
        code: 'PHP',
        name: 'Peso',
        country: 'Philippines',
        flag: '🇵🇭',
        buyRate: 55.80,
        sellRate: 55.50,
        changePercent: -0.10,
      ),
      Currency(
        code: 'AUD',
        name: 'Australian Dollar',
        country: 'Australia',
        flag: '🇦🇺',
        buyRate: 1.52,
        sellRate: 1.50,
        changePercent: 0.28,
      ),
      Currency(
        code: 'CAD',
        name: 'Canadian Dollar',
        country: 'Canada',
        flag: '🇨🇦',
        buyRate: 1.36,
        sellRate: 1.34,
        changePercent: 0.15,
      ),
      Currency(
        code: 'CHF',
        name: 'Swiss Franc',
        country: 'Switzerland',
        flag: '🇨🇭',
        buyRate: 0.88,
        sellRate: 0.86,
        changePercent: 0.30,
      ),
      Currency(
        code: 'HKD',
        name: 'Hong Kong Dollar',
        country: 'Hong Kong',
        flag: '🇭🇰',
        buyRate: 7.82,
        sellRate: 7.80,
        changePercent: 0.05,
      ),
      Currency(
        code: 'KRW',
        name: 'Won',
        country: 'South Korea',
        flag: '🇰🇷',
        buyRate: 1320.00,
        sellRate: 1315.00,
        changePercent: -0.20,
      ),
      Currency(
        code: 'INR',
        name: 'Rupee',
        country: 'India',
        flag: '🇮🇳',
        buyRate: 83.25,
        sellRate: 83.00,
        changePercent: 0.18,
      ),
      Currency(
        code: 'NZD',
        name: 'New Zealand Dollar',
        country: 'New Zealand',
        flag: '🇳🇿',
        buyRate: 1.68,
        sellRate: 1.66,
        changePercent: 0.32,
      ),
      Currency(
        code: 'BRL',
        name: 'Real',
        country: 'Brazil',
        flag: '🇧🇷',
        buyRate: 4.95,
        sellRate: 4.92,
        changePercent: -0.25,
      ),
      Currency(
        code: 'RUB',
        name: 'Ruble',
        country: 'Russia',
        flag: '🇷🇺',
        buyRate: 92.50,
        sellRate: 92.00,
        changePercent: 0.40,
      ),
    ];

    _filteredCurrencies = _currencies;
  }

  void _filterCurrencies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = _currencies;
      } else {
        _filteredCurrencies = _currencies.where((currency) {
          return currency.code.toLowerCase().contains(query) ||
              currency.name.toLowerCase().contains(query) ||
              currency.country.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  String _formatRate(double rate) {
    if (rate >= 1000) {
      return rate.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return rate.toStringAsFixed(rate < 1 ? 4 : 2);
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
          'Exchange Rate',
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
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.lightBackground,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search currency...',
                    prefixIcon: const Icon(Icons.search),
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
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Buy Rate'),
                        selected: _showBuyRate,
                        onSelected: (selected) {
                          setState(() {
                            _showBuyRate = true;
                          });
                        },
                        selectedColor: AppTheme.accentOrange,
                        labelStyle: TextStyle(
                          color: _showBuyRate
                              ? AppTheme.surfaceColor
                              : AppTheme.textOnLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Sell Rate'),
                        selected: !_showBuyRate,
                        onSelected: (selected) {
                          setState(() {
                            _showBuyRate = false;
                          });
                        },
                        selectedColor: AppTheme.accentOrange,
                        labelStyle: TextStyle(
                          color: !_showBuyRate
                              ? AppTheme.surfaceColor
                              : AppTheme.textOnLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Currency List
          Expanded(
            child: _filteredCurrencies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textSecondaryOnLight.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No currencies found',
                          style: TextStyle(
                            color: AppTheme.textSecondaryOnLight,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = _filteredCurrencies[index];
                      final rate = _showBuyRate ? currency.buyRate : currency.sellRate;
                      final isPositive = currency.changePercent >= 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.textSecondaryOnLight.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Flag and Currency Info
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    currency.flag,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          currency.code,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textOnLight,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            currency.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.textSecondaryOnLight,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currency.country,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondaryOnLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Rate and Change
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '1 USD = ${_formatRate(rate)} ${currency.code}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textOnLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isPositive
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                        size: 14,
                                        color: isPositive
                                            ? AppTheme.successGreen
                                            : AppTheme.errorRed,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${isPositive ? '+' : ''}${currency.changePercent.toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isPositive
                                              ? AppTheme.successGreen
                                              : AppTheme.errorRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
