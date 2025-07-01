import 'package:flutter/material.dart';

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final String? fontFamily;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;
  final double mobileBreakpoint;
  final double tabletBreakpoint;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.fontWeight,
    this.color,
    this.fontFamily,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = _getFontSize(constraints.maxWidth);
        
        return Text(
          text,
          style: (style ?? const TextStyle()).copyWith(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            fontFamily: fontFamily,
            height: height,
          ),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }

  double _getFontSize(double width) {
    if (width >= tabletBreakpoint && desktopFontSize != null) {
      return desktopFontSize!;
    } else if (width >= mobileBreakpoint && tabletFontSize != null) {
      return tabletFontSize!;
    } else if (mobileFontSize != null) {
      return mobileFontSize!;
    }
    
    // Fallback to default sizes based on screen width
    if (width >= tabletBreakpoint) {
      return 16.0; // Desktop default
    } else if (width >= mobileBreakpoint) {
      return 15.0; // Tablet default
    } else {
      return 14.0; // Mobile default
    }
  }
}

class ResponsiveTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final FontWeight? fontWeight;
  final String? fontFamily;

  const ResponsiveTitle(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontWeight,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveText(
      text,
      style: style,
      mobileFontSize: 28.0,
      tabletFontSize: 36.0,
      desktopFontSize: 42.0,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color,
      fontFamily: fontFamily ?? 'Montserrat',
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ResponsiveSubtitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final FontWeight? fontWeight;
  final String? fontFamily;

  const ResponsiveSubtitle(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontWeight,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveText(
      text,
      style: style,
      mobileFontSize: 14.0,
      tabletFontSize: 16.0,
      desktopFontSize: 18.0,
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily ?? 'Montserrat',
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      height: 1.5,
    );
  }
}

