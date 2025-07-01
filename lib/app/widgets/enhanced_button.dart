import 'package:flutter/material.dart';
import 'package:mws/app/theme/app_theme.dart';

class EnhancedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Widget? icon;
  final bool isLoading;
  final bool isPrimary;

  const EnhancedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
    this.icon,
    this.isLoading = false,
    this.isPrimary = true,
  });

  @override
  State<EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<EnhancedButton>
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
      end: 1.05,
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
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (_isHovered)
                    BoxShadow(
                      color: widget.isPrimary
                          ? AppTheme.primaryAccent.withOpacity(0.4)
                          : AppTheme.neutralGray.withOpacity(0.3),
                      blurRadius: 20 * _glowAnimation.value,
                      spreadRadius: 2 * _glowAnimation.value,
                    ),
                ],
              ),
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onPressed,
                style: widget.style ??
                    (widget.isPrimary
                        ? AppTheme.primaryButtonStyle
                        : AppTheme.secondaryButtonStyle),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            widget.icon!,
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

