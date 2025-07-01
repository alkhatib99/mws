import 'package:flutter/material.dart';
import 'package:mws/app/theme/app_theme.dart';

class WalletCard extends StatelessWidget {
  final String name;
  final String iconPath;
  final String description;
  final bool isAvailable;
  final bool isLoading;
  final VoidCallback? onTap;
  final bool isDesktop;
  final bool isTablet;

  const WalletCard({
    super.key,
    required this.name,
    required this.iconPath,
    required this.description,
    this.isAvailable = true,
    this.isLoading = false,
    this.onTap,
    this.isDesktop = false,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isAvailable && !isLoading ? onTap : null,
          child: Padding(
            padding: EdgeInsets.all(isDesktop
                ? 18
                : isTablet
                    ? 14
                    : 12),
            child: Row(
              children: [
                Container(
                  width: isDesktop
                      ? 48
                      : isTablet
                          ? 44
                          : 40,
                  height: isDesktop
                      ? 48
                      : isTablet
                          ? 44
                          : 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.primaryAccent.withOpacity(0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      iconPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.account_balance_wallet,
                        color: AppTheme.primaryAccent,
                        size: isDesktop
                            ? 28
                            : isTablet
                                ? 26
                                : 24,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    width: isDesktop
                        ? 16
                        : isTablet
                            ? 14
                            : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: isDesktop
                                ? 16
                                : isTablet
                                    ? 14
                                    : 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.whiteText,
                            fontFamily: 'Montserrat',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 2),
                      Expanded(
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: isDesktop
                                ? 12
                                : isTablet
                                    ? 11
                                    : 10,
                            color: AppTheme.lightGrayText,
                            fontFamily: 'Montserrat',
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryAccent,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.lightGrayText,
                    size: isDesktop
                        ? 20
                        : isTablet
                            ? 18
                            : 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
