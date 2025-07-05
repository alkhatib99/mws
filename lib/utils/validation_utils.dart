import 'package:mws/utils/security_utils.dart';

class ValidationUtils {
  // Ethereum address validation
  static String? validateEthereumAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Address cannot be empty';
    }
    
    if (!SecurityUtils.isValidEthereumAddress(trimmed)) {
      return 'Invalid Ethereum address format';
    }
    
    return null;
  }

  // Private key validation
  static String? validatePrivateKey(String? value) {
    if (value == null || value.isEmpty) {
      return 'Private key is required';
    }
    
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Private key cannot be empty';
    }
    
    if (!SecurityUtils.isValidPrivateKey(trimmed)) {
      return 'Invalid private key format';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value, {bool requireStrong = false}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (requireStrong) {
      final strength = SecurityUtils.validatePasswordStrength(value);
      if (strength == PasswordStrength.weak || strength == PasswordStrength.empty) {
        return 'Password is too weak. Use uppercase, lowercase, numbers, and symbols';
      }
    }
    
    return null;
  }

  // Amount validation
  static String? validateAmount(String? value, {double? maxAmount, double? balance}) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Amount cannot be empty';
    }
    
    double amount;
    try {
      amount = double.parse(trimmed);
    } catch (e) {
      return 'Invalid amount format';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    if (!amount.isFinite) {
      return 'Invalid amount';
    }
    
    if (maxAmount != null && amount > maxAmount) {
      return 'Amount exceeds maximum allowed (${maxAmount.toStringAsFixed(6)})';
    }
    
    if (balance != null && amount > balance) {
      return 'Insufficient balance (${balance.toStringAsFixed(6)} available)';
    }
    
    return null;
  }

  // Recipients list validation
  static String? validateRecipientsList(String? value) {
    if (value == null || value.isEmpty) {
      return 'Recipients list is required';
    }
    
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Recipients list cannot be empty';
    }
    
    final lines = trimmed.split('\n');
    final addresses = lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    
    if (addresses.isEmpty) {
      return 'At least one recipient address is required';
    }
    
    if (addresses.length > 100) {
      return 'Maximum 100 recipients allowed';
    }
    
    // Validate each address
    for (int i = 0; i < addresses.length; i++) {
      final address = addresses[i];
      if (!SecurityUtils.isValidEthereumAddress(address)) {
        return 'Invalid address on line ${i + 1}: $address';
      }
    }
    
    // Check for duplicates
    final uniqueAddresses = addresses.toSet();
    if (uniqueAddresses.length != addresses.length) {
      return 'Duplicate addresses found';
    }
    
    return null;
  }

  // Network/Chain ID validation
  static String? validateChainId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Network is required';
    }
    
    final supportedChains = ['1', '56', '137', '8453', '42161', '10'];
    if (!supportedChains.contains(value)) {
      return 'Unsupported network';
    }
    
    return null;
  }

  // Gas price validation
  static String? validateGasPrice(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Gas price is optional
    }
    
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    
    double gasPrice;
    try {
      gasPrice = double.parse(trimmed);
    } catch (e) {
      return 'Invalid gas price format';
    }
    
    if (gasPrice <= 0) {
      return 'Gas price must be greater than 0';
    }
    
    if (gasPrice > 1000) {
      return 'Gas price seems too high (>1000 Gwei)';
    }
    
    return null;
  }

  // Gas limit validation
  static String? validateGasLimit(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Gas limit is optional
    }
    
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    
    int gasLimit;
    try {
      gasLimit = int.parse(trimmed);
    } catch (e) {
      return 'Invalid gas limit format';
    }
    
    if (gasLimit <= 0) {
      return 'Gas limit must be greater than 0';
    }
    
    if (gasLimit < 21000) {
      return 'Gas limit too low (minimum 21,000)';
    }
    
    if (gasLimit > 10000000) {
      return 'Gas limit too high (maximum 10,000,000)';
    }
    
    return null;
  }

  // URL validation
  static String? validateUrl(String? value, {bool requireHttps = false}) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'URL cannot be empty';
    }
    
    Uri uri;
    try {
      uri = Uri.parse(trimmed);
    } catch (e) {
      return 'Invalid URL format';
    }
    
    if (!uri.hasScheme) {
      return 'URL must include protocol (http:// or https://)';
    }
    
    if (requireHttps && uri.scheme != 'https') {
      return 'HTTPS is required';
    }
    
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'Only HTTP and HTTPS protocols are allowed';
    }
    
    if (!uri.hasAuthority) {
      return 'URL must include a domain';
    }
    
    return null;
  }

  // RPC endpoint validation
  static String? validateRpcEndpoint(String? value) {
    final urlValidation = validateUrl(value);
    if (urlValidation != null) {
      return urlValidation;
    }
    
    final uri = Uri.parse(value!.trim());
    
    // Check for common RPC endpoint patterns
    final path = uri.path.toLowerCase();
    if (path.isNotEmpty && 
        !path.contains('rpc') && 
        !path.contains('api') && 
        !path.contains('v1') && 
        !path.contains('v2') &&
        path != '/') {
      return 'URL does not appear to be an RPC endpoint';
    }
    
    return null;
  }

  // File content validation for CSV/TXT uploads
  static String? validateFileContent(String content, {int maxLines = 1000}) {
    if (content.isEmpty) {
      return 'File is empty';
    }
    
    final lines = content.split('\n');
    if (lines.length > maxLines) {
      return 'File has too many lines (maximum $maxLines)';
    }
    
    // Check for valid addresses in the file
    int validAddresses = 0;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty) {
        if (SecurityUtils.isValidEthereumAddress(trimmed)) {
          validAddresses++;
        }
      }
    }
    
    if (validAddresses == 0) {
      return 'No valid Ethereum addresses found in file';
    }
    
    return null;
  }

  // Transaction hash validation
  static String? validateTransactionHash(String? value) {
    if (value == null || value.isEmpty) {
      return 'Transaction hash is required';
    }
    
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Transaction hash cannot be empty';
    }
    
    // Remove 0x prefix if present
    String cleanHash = trimmed.toLowerCase();
    if (cleanHash.startsWith('0x')) {
      cleanHash = cleanHash.substring(2);
    }
    
    // Check length (64 hex characters = 32 bytes)
    if (cleanHash.length != 64) {
      return 'Invalid transaction hash length';
    }
    
    // Check if all characters are valid hex
    final hexRegex = RegExp(r'^[0-9a-f]+$');
    if (!hexRegex.hasMatch(cleanHash)) {
      return 'Invalid transaction hash format';
    }
    
    return null;
  }

  // Wallet name validation
  static String? validateWalletName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Wallet name is required';
    }
    
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Wallet name cannot be empty';
    }
    
    if (trimmed.length < 2) {
      return 'Wallet name must be at least 2 characters';
    }
    
    if (trimmed.length > 50) {
      return 'Wallet name must be less than 50 characters';
    }
    
    // Check for valid characters (alphanumeric, spaces, hyphens, underscores)
    final validNameRegex = RegExp(r'^[a-zA-Z0-9\s\-_]+$');
    if (!validNameRegex.hasMatch(trimmed)) {
      return 'Wallet name contains invalid characters';
    }
    
    return null;
  }

  // Batch validation for multiple addresses
  static Map<String, String> validateAddressBatch(List<String> addresses) {
    final errors = <String, String>{};
    
    for (int i = 0; i < addresses.length; i++) {
      final address = addresses[i];
      final validation = validateEthereumAddress(address);
      if (validation != null) {
        errors['address_$i'] = validation;
      }
    }
    
    return errors;
  }

  // Comprehensive transaction validation
  static Map<String, String> validateTransaction({
    required String? recipient,
    required String? amount,
    required String? chainId,
    double? balance,
    double? gasEstimate,
  }) {
    final errors = <String, String>{};
    
    final recipientError = validateEthereumAddress(recipient);
    if (recipientError != null) {
      errors['recipient'] = recipientError;
    }
    
    final amountError = validateAmount(amount, balance: balance);
    if (amountError != null) {
      errors['amount'] = amountError;
    }
    
    final chainError = validateChainId(chainId);
    if (chainError != null) {
      errors['chainId'] = chainError;
    }
    
    // Check if user has enough balance for gas
    if (balance != null && gasEstimate != null && amount != null) {
      try {
        final amountValue = double.parse(amount);
        final totalRequired = amountValue + gasEstimate;
        if (totalRequired > balance) {
          errors['balance'] = 'Insufficient balance for transaction and gas fees';
        }
      } catch (e) {
        // Amount validation will catch this
      }
    }
    
    return errors;
  }

  // Multi-send transaction validation
  static Map<String, String> validateMultiSendTransaction({
    required String? recipients,
    required String? amount,
    required String? chainId,
    double? balance,
    double? gasEstimatePerTx,
  }) {
    final errors = <String, String>{};
    
    final recipientsError = validateRecipientsList(recipients);
    if (recipientsError != null) {
      errors['recipients'] = recipientsError;
      return errors; // Don't continue if recipients are invalid
    }
    
    final amountError = validateAmount(amount);
    if (amountError != null) {
      errors['amount'] = amountError;
    }
    
    final chainError = validateChainId(chainId);
    if (chainError != null) {
      errors['chainId'] = chainError;
    }
    
    // Calculate total cost
    if (recipients != null && amount != null && balance != null) {
      try {
        final addresses = recipients
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();
        
        final amountValue = double.parse(amount);
        final totalAmount = amountValue * addresses.length;
        final totalGas = (gasEstimatePerTx ?? 0.001) * addresses.length;
        final totalRequired = totalAmount + totalGas;
        
        if (totalRequired > balance) {
          errors['balance'] = 'Insufficient balance. Required: ${totalRequired.toStringAsFixed(6)}, Available: ${balance.toStringAsFixed(6)}';
        }
      } catch (e) {
        // Amount validation will catch parsing errors
      }
    }
    
    return errors;
  }

  // Sanitize and format address
  static String formatAddress(String address) {
    String cleaned = address.trim().toLowerCase();
    if (!cleaned.startsWith('0x')) {
      cleaned = '0x$cleaned';
    }
    return cleaned;
  }

  // Parse and validate recipients list
  static List<String> parseRecipientsList(String recipients) {
    return recipients
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((address) => formatAddress(address))
        .toList();
  }

  // Check for common security issues
  static List<String> checkSecurityIssues({
    required String? privateKey,
    required String? password,
    required bool isSecureContext,
  }) {
    final issues = <String>[];
    
    if (!isSecureContext) {
      issues.add('Not using HTTPS - your data may not be secure');
    }
    
    if (privateKey != null && privateKey.isNotEmpty) {
      issues.add('Private key usage in browser is not recommended for large amounts');
      
      if (password == null || password.isEmpty) {
        issues.add('Private key should be encrypted with a strong password');
      } else {
        final strength = SecurityUtils.validatePasswordStrength(password);
        if (strength == PasswordStrength.weak) {
          issues.add('Password is too weak for private key encryption');
        }
      }
    }
    
    return issues;
  }
}

