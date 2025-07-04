import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/theme/app_theme.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showRetry;
  final bool showDismiss;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? buttonColor;

  const ErrorDisplayWidget({
    Key? key,
    required this.title,
    required this.message,
    this.details,
    this.onRetry,
    this.onDismiss,
    this.showRetry = true,
    this.showDismiss = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.buttonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.warningRed.withOpacity(0.1),
        border: Border.all(
          color: AppTheme.warningRed.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warningRed.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error header with icon and title
          Row(
            children: [
              Icon(
                icon ?? Icons.error_outline,
                color: AppTheme.warningRed,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor ?? AppTheme.warningRed,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Error message
          Text(
            message,
            style: TextStyle(
              color: textColor ?? AppTheme.whiteText,
              fontSize: 14,
              fontFamily: 'Montserrat',
              height: 1.4,
            ),
          ),
          
          // Error details (if provided)
          if (details != null && details!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBackground.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.neutralGray.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Technical Details:',
                    style: TextStyle(
                      color: AppTheme.lightGrayText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    details!,
                    style: TextStyle(
                      color: AppTheme.lightGrayText,
                      fontSize: 11,
                      fontFamily: 'Courier',
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showDismiss) ...[
                TextButton(
                  onPressed: onDismiss ?? () => Get.back(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.lightGrayText,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Dismiss',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              if (showRetry && onRetry != null) ...[
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text(
                    'Retry',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor ?? AppTheme.warningRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Snackbar-style error display
class ErrorSnackbar {
  static void show({
    required String title,
    required String message,
    String? details,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 5),
    bool showRetry = false,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppTheme.warningRed.withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      duration: duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 300),
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
        size: 24,
      ),
      mainButton: showRetry && onRetry != null
          ? TextButton(
              onPressed: () {
                Get.back();
                onRetry();
              },
              child: const Text(
                'RETRY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
            )
          : null,
    );
  }
}

/// Dialog-style error display
class ErrorDialog {
  static void show({
    required String title,
    required String message,
    String? details,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    bool showRetry = true,
    bool barrierDismissible = true,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: ErrorDisplayWidget(
          title: title,
          message: message,
          details: details,
          onRetry: onRetry != null
              ? () {
                  Get.back();
                  onRetry();
                }
              : null,
          onDismiss: onDismiss ?? () => Get.back(),
          showRetry: showRetry,
          showDismiss: true,
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }
}

/// Inline error display for forms and widgets
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool showRetry;
  final EdgeInsets? padding;

  const InlineErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.showRetry = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warningRed.withOpacity(0.1),
        border: Border.all(
          color: AppTheme.warningRed.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.warningRed,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppTheme.warningRed,
                fontSize: 12,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          if (showRetry && onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: Icon(
                Icons.refresh,
                color: AppTheme.warningRed,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Connection status indicator with error handling
class ConnectionStatusWidget extends StatelessWidget {
  final bool isConnected;
  final bool isConnecting;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String? walletName;

  const ConnectionStatusWidget({
    Key? key,
    required this.isConnected,
    this.isConnecting = false,
    this.errorMessage,
    this.onRetry,
    this.walletName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (errorMessage != null) {
      statusColor = AppTheme.warningRed;
      statusIcon = Icons.error_outline;
      statusText = 'Connection Failed';
    } else if (isConnecting) {
      statusColor = AppTheme.blueAccent;
      statusIcon = Icons.sync;
      statusText = 'Connecting...';
    } else if (isConnected) {
      statusColor = AppTheme.successGreen;
      statusIcon = Icons.check_circle_outline;
      statusText = walletName != null ? 'Connected to $walletName' : 'Connected';
    } else {
      statusColor = AppTheme.lightGrayText;
      statusIcon = Icons.radio_button_unchecked;
      statusText = 'Not Connected';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isConnecting)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            )
          else
            Icon(
              statusIcon,
              color: statusColor,
              size: 16,
            ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          if (errorMessage != null && onRetry != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRetry,
              child: Icon(
                Icons.refresh,
                color: statusColor,
                size: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

