import 'package:flutter/material.dart';
import 'package:mws/app/theme/app_theme.dart';

class  WalletCard extends StatefulWidget {
  final String name;
  final String iconPath;
  final String description;
  final bool isAvailable;
  final bool isConnecting;
  final VoidCallback onTap;
  final bool isDesktop;
  final bool isTablet;
  final bool isSelected;

  const  WalletCard({
    Key? key,
    required this.name,
    required this.iconPath,
    required this.description,
    required this.isAvailable,
    required this.onTap,
    this.isConnecting = false,
    this.isDesktop = false,
    this.isTablet = false,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State< WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State< WalletCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight = widget.isDesktop ? 120.0 : widget.isTablet ? 110.0 : 100.0;
    final iconSize = widget.isDesktop ? 48.0 : widget.isTablet ? 44.0 : 40.0;
    final titleFontSize = widget.isDesktop ? 16.0 : widget.isTablet ? 15.0 : 14.0;
    final descriptionFontSize = widget.isDesktop ? 13.0 : widget.isTablet ? 12.0 : 11.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHoverChanged(true),
            onExit: (_) => _onHoverChanged(false),
            child: GestureDetector(
              onTap: widget.isAvailable && !widget.isConnecting ? widget.onTap : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: cardHeight,
                decoration: _getCardDecoration(),
                child: Stack(
                  children: [
                    // Glow effect
                    if (_isHovered || widget.isSelected)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryAccent.withOpacity(0.3 * _glowAnimation.value),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Card content
                    Padding(
                      padding: EdgeInsets.all(widget.isDesktop ? 20.0 : 16.0),
                      child: Row(
                        children: [
                          // Wallet icon
                          _buildWalletIcon(iconSize),
                          
                          SizedBox(width: widget.isDesktop ? 16.0 : 12.0),
                          
                          // Wallet info
                          Expanded(
                            child: _buildWalletInfo(titleFontSize, descriptionFontSize),
                          ),
                          
                          // Status indicator
                          _buildStatusIndicator(),
                        ],
                      ),
                    ),
                    
                    // Loading overlay
                    if (widget.isConnecting)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryAccent),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _getCardDecoration() {
    if (widget.isSelected) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryAccent.withOpacity(0.1),
            AppTheme.primaryAccent.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryAccent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryAccent.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    if (_isHovered && widget.isAvailable) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryBackground,
            AppTheme.secondaryBackground.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryAccent.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryAccent.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: widget.isAvailable 
          ? AppTheme.secondaryBackground 
          : AppTheme.secondaryBackground.withOpacity(0.5),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: widget.isAvailable 
            ? AppTheme.neutralGray.withOpacity(0.3)
            : AppTheme.neutralGray.withOpacity(0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildWalletIcon(double iconSize) {
    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: widget.isAvailable 
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          widget.iconPath,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: widget.isAvailable 
                    ? AppTheme.primaryAccent 
                    : AppTheme.lightGrayText,
                size: iconSize * 0.6,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWalletInfo(double titleFontSize, double descriptionFontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.name,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: widget.isAvailable 
                ? AppTheme.whiteText 
                : AppTheme.lightGrayText,
            fontFamily: 'Montserrat',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          widget.description,
          style: TextStyle(
            fontSize: descriptionFontSize,
            color: widget.isAvailable 
                ? AppTheme.lightGrayText 
                : AppTheme.lightGrayText.withOpacity(0.5),
            fontFamily: 'Montserrat',
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    if (widget.isConnecting) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryAccent),
        ),
      );
    }

    if (widget.isSelected) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppTheme.primaryAccent,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 16,
        ),
      );
    }

    if (!widget.isAvailable) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppTheme.lightGrayText.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.lock,
          color: AppTheme.lightGrayText,
          size: 16,
        ),
      );
    }

    return AnimatedOpacity(
      opacity: _isHovered ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: const Icon(
        Icons.arrow_forward_ios,
        color: AppTheme.primaryAccent,
        size: 16,
      ),
    );
  }
}

