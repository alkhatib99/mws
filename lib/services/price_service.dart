import 'dart:convert';
import 'package:http/http.dart' as http;

class PriceService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';
  
  // Token symbol to CoinGecko ID mapping
  static const Map<String, String> _tokenIds = {
    'ETH': 'ethereum',
    'BNB': 'binancecoin',
    'USDC': 'usd-coin',
    'USDT': 'tether',
    'DAI': 'dai',
    'CAKE': 'pancakeswap-token',
  };

  // Cache for prices to avoid excessive API calls
  static final Map<String, double> _priceCache = {};
  static DateTime? _lastFetchTime;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Get USD price for a token symbol
  static Future<double> getTokenPrice(String symbol) async {
    // Check cache first
    if (_priceCache.containsKey(symbol) && 
        _lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _cacheExpiry) {
      return _priceCache[symbol] ?? 0.0;
    }

    try {
      final tokenId = _tokenIds[symbol.toUpperCase()];
      if (tokenId == null) {
        // For unknown tokens, return 0
        return 0.0;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/simple/price?ids=$tokenId&vs_currencies=usd'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final price = data[tokenId]?['usd']?.toDouble() ?? 0.0;
        
        // Update cache
        _priceCache[symbol] = price;
        _lastFetchTime = DateTime.now();
        
        return price;
      } else {
        throw Exception('Failed to fetch price: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching price for $symbol: $e');
      // Return cached price if available, otherwise 0
      return _priceCache[symbol] ?? 0.0;
    }
  }

  /// Get USD value for a token amount
  static Future<double> getTokenValueInUSD(String symbol, double amount) async {
    final price = await getTokenPrice(symbol);
    return price * amount;
  }

  /// Get multiple token prices at once
  static Future<Map<String, double>> getMultipleTokenPrices(List<String> symbols) async {
    final Map<String, double> prices = {};
    
    // Filter symbols that have CoinGecko IDs
    final validSymbols = symbols.where((symbol) => _tokenIds.containsKey(symbol.toUpperCase())).toList();
    
    if (validSymbols.isEmpty) {
      return prices;
    }

    try {
      final tokenIds = validSymbols.map((symbol) => _tokenIds[symbol.toUpperCase()]!).join(',');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/simple/price?ids=$tokenIds&vs_currencies=usd'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        for (final symbol in validSymbols) {
          final tokenId = _tokenIds[symbol.toUpperCase()]!;
          final price = data[tokenId]?['usd']?.toDouble() ?? 0.0;
          prices[symbol] = price;
          _priceCache[symbol] = price;
        }
        
        _lastFetchTime = DateTime.now();
      }
    } catch (e) {
      print('Error fetching multiple prices: $e');
      // Return cached prices for requested symbols
      for (final symbol in validSymbols) {
        prices[symbol] = _priceCache[symbol] ?? 0.0;
      }
    }

    return prices;
  }

  /// Clear price cache
  static void clearCache() {
    _priceCache.clear();
    _lastFetchTime = null;
  }

  /// Format USD value for display
  static String formatUSDValue(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(2)}K';
    } else if (value >= 1) {
      return '\$${value.toStringAsFixed(2)}';
    } else if (value >= 0.01) {
      return '\$${value.toStringAsFixed(4)}';
    } else if (value > 0) {
      return '\$${value.toStringAsFixed(6)}';
    } else {
      return '\$0.00';
    }
  }
}

