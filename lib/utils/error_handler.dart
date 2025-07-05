import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mws/app/theme/app_theme.dart';

enum ErrorType {
  network,
  validation,
  security,
  wallet,
  transaction,
  rpc,
  unknown,
}

enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

class AppError {
  final String code;
  final String message;
  final String? details;
  final ErrorType type;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final String? stackTrace;
  final Map<String, dynamic>? metadata;

  AppError({
    required this.code,
    required this.message,
    this.details,
    required this.type,
    required this.severity,
    DateTime? timestamp,
    this.stackTrace,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'details': details,
      'type': type.toString(),
      'severity': severity.toString(),
      'timestamp': timestamp.toIso8601String(),
      'stackTrace': stackTrace,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'AppError(code: $code, message: $message, type: $type, severity: $severity)';
  }
}

class ErrorHandler {
  static final List<AppError> _errorHistory = [];
  static const int _maxHistorySize = 100;
  
  // Error callbacks
  static void Function(AppError)? _onError;
  static void Function(AppError)? _onCriticalError;

  /// Set error callbacks
  static void setErrorCallbacks({
    void Function(AppError)? onError,
    void Function(AppError)? onCriticalError,
  }) {
    _onError = onError;
    _onCriticalError = onCriticalError;
  }

  /// Handle an error
  static void handleError(
    dynamic error, {
    String? code,
    String? message,
    String? details,
    ErrorType? type,
    ErrorSeverity? severity,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final appError = _createAppError(
      error,
      code: code,
      message: message,
      details: details,
      type: type,
      severity: severity,
      stackTrace: stackTrace,
      metadata: metadata,
    );

    _logError(appError);
    _storeError(appError);
    _notifyCallbacks(appError);
  }

  /// Create AppError from various error types
  static AppError _createAppError(
    dynamic error, {
    String? code,
    String? message,
    String? details,
    ErrorType? type,
    ErrorSeverity? severity,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    String errorCode = code ?? 'UNKNOWN_ERROR';
    String errorMessage = message ?? 'An unknown error occurred';
    String? errorDetails = details;
    ErrorType errorType = type ?? ErrorType.unknown;
    ErrorSeverity errorSeverity = severity ?? ErrorSeverity.medium;
    String? errorStackTrace = stackTrace?.toString();

    if (error != null) {
      // Handle different error types
      if (error is AppError) {
        return error;
      } else if (error is Exception) {
        errorMessage = message ?? error.toString();
        errorDetails = details ?? error.runtimeType.toString();
        
        // Classify common exceptions
        if (error.toString().contains('SocketException') || 
            error.toString().contains('TimeoutException')) {
          errorType = ErrorType.network;
          errorCode = 'NETWORK_ERROR';
        } else if (error.toString().contains('FormatException')) {
          errorType = ErrorType.validation;
          errorCode = 'VALIDATION_ERROR';
        }
      } else if (error is String) {
        errorMessage = message ?? error;
        
        // Classify based on error message content
        if (error.toLowerCase().contains('network') || 
            error.toLowerCase().contains('connection')) {
          errorType = ErrorType.network;
          errorCode = 'NETWORK_ERROR';
        } else if (error.toLowerCase().contains('invalid') || 
                   error.toLowerCase().contains('validation')) {
          errorType = ErrorType.validation;
          errorCode = 'VALIDATION_ERROR';
        } else if (error.toLowerCase().contains('wallet') || 
                   error.toLowerCase().contains('metamask')) {
          errorType = ErrorType.wallet;
          errorCode = 'WALLET_ERROR';
        } else if (error.toLowerCase().contains('transaction') || 
                   error.toLowerCase().contains('gas')) {
          errorType = ErrorType.transaction;
          errorCode = 'TRANSACTION_ERROR';
        } else if (error.toLowerCase().contains('rpc') || 
                   error.toLowerCase().contains('provider')) {
          errorType = ErrorType.rpc;
          errorCode = 'RPC_ERROR';
        }
      }
    }

    return AppError(
      code: errorCode,
      message: errorMessage,
      details: errorDetails,
      type: errorType,
      severity: errorSeverity,
      stackTrace: errorStackTrace,
      metadata: metadata,
    );
  }

  /// Log error to console
  static void _logError(AppError error) {
    if (kDebugMode) {
      print('🚨 ${error.severity.name.toUpperCase()} ERROR [${error.code}]: ${error.message}');
      if (error.details != null) {
        print('   Details: ${error.details}');
      }
      if (error.metadata != null) {
        print('   Metadata: ${error.metadata}');
      }
      if (error.stackTrace != null) {
        print('   Stack Trace: ${error.stackTrace}');
      }
    }
  }

  /// Store error in history
  static void _storeError(AppError error) {
    _errorHistory.add(error);
    
    // Keep history size manageable
    if (_errorHistory.length > _maxHistorySize) {
      _errorHistory.removeRange(0, _errorHistory.length - _maxHistorySize);
    }
  }

  /// Notify error callbacks
  static void _notifyCallbacks(AppError error) {
    try {
      _onError?.call(error);
      
      if (error.severity == ErrorSeverity.critical) {
        _onCriticalError?.call(error);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in error callback: $e');
      }
    }
  }

  /// Get error history
  static List<AppError> getErrorHistory() {
    return List.from(_errorHistory);
  }

  /// Clear error history
  static void clearErrorHistory() {
    _errorHistory.clear();
  }

  /// Get errors by type
  static List<AppError> getErrorsByType(ErrorType type) {
    return _errorHistory.where((error) => error.type == type).toList();
  }

  /// Get errors by severity
  static List<AppError> getErrorsBySeverity(ErrorSeverity severity) {
    return _errorHistory.where((error) => error.severity == severity).toList();
  }

  /// Get recent errors
  static List<AppError> getRecentErrors({Duration? since}) {
    final cutoff = since != null 
        ? DateTime.now().subtract(since)
        : DateTime.now().subtract(const Duration(hours: 1));
    
    return _errorHistory.where((error) => error.timestamp.isAfter(cutoff)).toList();
  }

  /// Show error dialog
  static void showErrorDialog(
    BuildContext context,
    AppError error, {
    String? title,
    List<Widget>? actions,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryBackground,
        title: Text(
          title ?? _getErrorTitle(error),
          style: const TextStyle(
            color: AppTheme.whiteText,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error.message,
              style: const TextStyle(
                color: AppTheme.whiteText,
                fontFamily: 'Montserrat',
              ),
            ),
            if (error.details != null) ...[
              const SizedBox(height: 12),
              Text(
                'Details:',
                style: const TextStyle(
                  color: AppTheme.lightGrayText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                error.details!,
                style: const TextStyle(
                  color: AppTheme.lightGrayText,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ],
        ),
        actions: actions ?? [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppTheme.primaryAccent,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    AppError error, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    final backgroundColor = _getErrorColor(error.severity);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error.message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            if (error.details != null)
              Text(
                error.details!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                ),
              ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 4),
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Get error title based on type
  static String _getErrorTitle(AppError error) {
    switch (error.type) {
      case ErrorType.network:
        return 'Network Error';
      case ErrorType.validation:
        return 'Validation Error';
      case ErrorType.security:
        return 'Security Error';
      case ErrorType.wallet:
        return 'Wallet Error';
      case ErrorType.transaction:
        return 'Transaction Error';
      case ErrorType.rpc:
        return 'RPC Error';
      case ErrorType.unknown:
        return 'Error';
    }
  }

  /// Get error color based on severity
  static Color _getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return AppTheme.blueAccent;
      case ErrorSeverity.medium:
        return AppTheme.goldAccent;
      case ErrorSeverity.high:
        return AppTheme.warningRed;
      case ErrorSeverity.critical:
        return const Color(0xFF8B0000); // Dark red
    }
  }

  /// Handle wallet connection errors
  static AppError handleWalletError(dynamic error) {
    String message = 'Failed to connect wallet';
    String? details;
    ErrorSeverity severity = ErrorSeverity.medium;

    if (error.toString().contains('User rejected')) {
      message = 'Connection cancelled by user';
      severity = ErrorSeverity.low;
    } else if (error.toString().contains('No provider')) {
      message = 'Wallet not found. Please install MetaMask or use WalletConnect';
      details = 'Make sure you have a compatible wallet installed';
    } else if (error.toString().contains('Unauthorized')) {
      message = 'Wallet connection unauthorized';
      details = 'Please check your wallet settings and try again';
    } else if (error.toString().contains('Network')) {
      message = 'Network connection failed';
      details = 'Please check your internet connection and try again';
    }

    return AppError(
      code: 'WALLET_CONNECTION_ERROR',
      message: message,
      details: details,
      type: ErrorType.wallet,
      severity: severity,
      metadata: {'originalError': error.toString()},
    );
  }

  /// Handle transaction errors
  static AppError handleTransactionError(dynamic error) {
    String message = 'Transaction failed';
    String? details;
    ErrorSeverity severity = ErrorSeverity.high;

    if (error.toString().contains('insufficient funds')) {
      message = 'Insufficient funds for transaction';
      details = 'Please check your balance and gas fees';
    } else if (error.toString().contains('gas')) {
      message = 'Gas estimation failed';
      details = 'Try adjusting gas price or limit';
    } else if (error.toString().contains('nonce')) {
      message = 'Transaction nonce error';
      details = 'Please try again or reset your wallet';
    } else if (error.toString().contains('rejected')) {
      message = 'Transaction rejected by user';
      severity = ErrorSeverity.low;
    } else if (error.toString().contains('timeout')) {
      message = 'Transaction timeout';
      details = 'Network congestion may be causing delays';
    }

    return AppError(
      code: 'TRANSACTION_ERROR',
      message: message,
      details: details,
      type: ErrorType.transaction,
      severity: severity,
      metadata: {'originalError': error.toString()},
    );
  }

  /// Handle RPC errors
  static AppError handleRpcError(dynamic error) {
    String message = 'RPC connection failed';
    String? details;
    ErrorSeverity severity = ErrorSeverity.medium;

    if (error.toString().contains('timeout')) {
      message = 'RPC request timeout';
      details = 'The RPC endpoint is not responding';
    } else if (error.toString().contains('rate limit')) {
      message = 'Rate limit exceeded';
      details = 'Too many requests. Please wait and try again';
    } else if (error.toString().contains('invalid response')) {
      message = 'Invalid RPC response';
      details = 'The RPC endpoint returned an invalid response';
    } else if (error.toString().contains('not found')) {
      message = 'RPC endpoint not found';
      details = 'Please check the RPC URL and try again';
      severity = ErrorSeverity.high;
    }

    return AppError(
      code: 'RPC_ERROR',
      message: message,
      details: details,
      type: ErrorType.rpc,
      severity: severity,
      metadata: {'originalError': error.toString()},
    );
  }

  /// Handle validation errors
  static AppError handleValidationError(String field, String message) {
    return AppError(
      code: 'VALIDATION_ERROR',
      message: 'Validation failed: $message',
      details: 'Field: $field',
      type: ErrorType.validation,
      severity: ErrorSeverity.low,
      metadata: {'field': field},
    );
  }

  /// Handle security errors
  static AppError handleSecurityError(String message, {String? details}) {
    return AppError(
      code: 'SECURITY_ERROR',
      message: message,
      details: details,
      type: ErrorType.security,
      severity: ErrorSeverity.critical,
    );
  }

  /// Get error statistics
  static Map<String, dynamic> getErrorStatistics() {
    final total = _errorHistory.length;
    final byType = <String, int>{};
    final bySeverity = <String, int>{};
    
    for (final error in _errorHistory) {
      byType[error.type.toString()] = (byType[error.type.toString()] ?? 0) + 1;
      bySeverity[error.severity.toString()] = (bySeverity[error.severity.toString()] ?? 0) + 1;
    }
    
    return {
      'total': total,
      'byType': byType,
      'bySeverity': bySeverity,
      'recent': getRecentErrors().length,
    };
  }
}

