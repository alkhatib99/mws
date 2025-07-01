import 'package:flutter/material.dart';
import 'package:mws/app/theme/app_theme.dart';

class WalletCard extends StatefulWidget {
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
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

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

  void _onHover(bool isHovered) {
    if (!widget.isAvailable || widget.isLoading) return;
    
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
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: _isHovered 
                    ? AppTheme.secondaryBackground.withOpacity(0.6)
                    : AppTheme.secondaryBackground.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered 
                      ? AppTheme.primaryAccent.withOpacity(0.6)
                      : AppTheme.primaryAccent.withOpacity(0.2),
                  width: _isHovered ? 2 : 1,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryAccent.withOpacity(0.2),
                          blurRadius: 15 * _glowAnimation.value,
                          spreadRadius: 2 * _glowAnimation.value,
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: widget.isAvailable && !widget.isLoading ? widget.onTap : null,
                  child: Padding(
                    padding: EdgeInsets.all(widget.isDesktop
                        ? 18
                        : widget.isTablet
                            ? 14
                            : 12),
                    child: Row(
                      children: [
                        Container(
                          width: widget.isDesktop
                              ? 48
                              : widget.isTablet
                                  ? 44
                                  : 40,
                          height: widget.isDesktop
                              ? 48
                              : widget.isTablet
                                  ? 44
                                  : 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.primaryAccent.withOpacity(0.1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              widget.iconPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.account_balance_wallet,
                                color: AppTheme.primaryAccent,
                                size: widget.isDesktop
                                    ? 28
                                    : widget.isTablet
                                        ? 26
                                        : 24,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            width: widget.isDesktop
                                ? 16
                                : widget.isTablet
                                    ? 14
                                    : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.name,
                                style: TextStyle(
                                  fontSize: widget.isDesktop
                                      ? 16
                                      : widget.isTablet
                                          ? 14
                                          : 13,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isAvailable 
                                      ? AppTheme.whiteText 
                                      : AppTheme.lightGrayText,
                                  fontFamily: 'Montserrat',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.description,
                                style: TextStyle(
                                  fontSize: widget.isDesktop
                                      ? 12
                                      : widget.isTablet
                                          ? 11
                                          : 10,
                                  color: AppTheme.lightGrayText,
                                  fontFamily: 'Montserrat',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        if (widget.isLoading)
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
                            color: _isHovered 
                                ? AppTheme.primaryAccent 
                                : AppTheme.lightGrayText,
                            size: widget.isDesktop
                                ? 20
                                : widget.isTablet
                                    ? 18
                                    : 16,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
