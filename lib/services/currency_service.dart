class CurrencyService {
  // Exchange rate: 1 USD = 4100 KHR (Riel) - approximate rate
  static const double usdToRielRate = 4100.0;
  static const double rielToUsdRate = 1 / usdToRielRate;

  static double convertUsdToRiel(double usdAmount) {
    return usdAmount * usdToRielRate;
  }

  static double convertRielToUsd(double rielAmount) {
    return rielAmount * rielToUsdRate;
  }

  static String formatRiel(double amount) {
    final formatted = _formatNumber(amount, decimals: 2);
    return '$formatted ៛';
  }

  static String formatUsd(double amount) {
    final formatted = _formatNumber(amount, decimals: 2);
    return '$formatted \$';
  }

  static String _formatNumber(double number, {int decimals = 2}) {
    final parts = number.toStringAsFixed(decimals).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';
    
    // Add commas for thousands
    String formattedInteger = '';
    for (int i = integerPart.length - 1; i >= 0; i--) {
      formattedInteger = integerPart[i] + formattedInteger;
      if ((integerPart.length - i) % 3 == 0 && i != 0) {
        formattedInteger = ',' + formattedInteger;
      }
    }
    
    return decimalPart.isNotEmpty 
        ? '$formattedInteger.$decimalPart'
        : formattedInteger;
  }
}

