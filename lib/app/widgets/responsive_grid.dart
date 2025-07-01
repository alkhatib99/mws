import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double mobileBreakpoint;
  final double tabletBreakpoint;
  final double? childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 1024,
    this.childAspectRatio,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;
        if (constraints.maxWidth >= tabletBreakpoint) {
          columns = desktopColumns;
        } else if (constraints.maxWidth >= mobileBreakpoint) {
          columns = tabletColumns;
        } else {
          columns = mobileColumns;
        }

        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: childAspectRatio ?? _getDefaultAspectRatio(constraints.maxWidth),
              crossAxisSpacing: spacing,
              mainAxisSpacing: runSpacing,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          ),
        );
      },
    );
  }

  double _getDefaultAspectRatio(double width) {
    if (width >= tabletBreakpoint) {
      return 3.5; // Desktop
    } else if (width >= mobileBreakpoint) {
      return 3.0; // Tablet
    } else {
      return 2.7; // Mobile
    }
  }
}

class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;
  final EdgeInsetsGeometry? padding;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        alignment: alignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }
}

