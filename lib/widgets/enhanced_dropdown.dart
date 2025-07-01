import 'package:flutter/material.dart';

class EnhancedDropdown<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? hoverColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const EnhancedDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.hint,
    this.icon,
    this.backgroundColor,
    this.borderColor,
    this.hoverColor,
    this.borderRadius,
    this.padding,
  });

  @override
  State<EnhancedDropdown<T>> createState() => _EnhancedDropdownState<T>();
}

class _EnhancedDropdownState<T> extends State<EnhancedDropdown<T>>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

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
    _colorAnimation = ColorTween(
      begin: widget.backgroundColor ?? Colors.grey[900],
      end: widget.hoverColor ?? Colors.grey[800],
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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _animationController.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                border: Border.all(
                  color: widget.borderColor ?? Colors.purple.withOpacity(0.3),
                  width: _isHovered ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.borderColor ?? Colors.purple).withOpacity(_isHovered ? 0.3 : 0.1),
                    blurRadius: _isHovered ? 12 : 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: widget.value,
                  items: widget.items,
                  onChanged: widget.onChanged,
                  isExpanded: true,
                  dropdownColor: widget.backgroundColor ?? Colors.grey[900],
                  icon: widget.icon ?? Icon(
                    Icons.keyboard_arrow_down,
                    color: widget.borderColor ?? Colors.purple,
                  ),
                  hint: widget.hint != null ? Text(widget.hint!) : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

