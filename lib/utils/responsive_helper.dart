import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Screen type detection
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  // Screen size getters
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Responsive values
  static T getValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop(context) && largeDesktop != null) {
      return largeDesktop;
    } else if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  // Responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return getValue(
      context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
      largeDesktop: const EdgeInsets.all(40),
    );
  }

  // Responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    return getValue(
      context,
      mobile: const EdgeInsets.all(8),
      tablet: const EdgeInsets.all(12),
      desktop: const EdgeInsets.all(16),
      largeDesktop: const EdgeInsets.all(20),
    );
  }

  // Responsive font sizes
  static double getHeadlineFontSize(BuildContext context) {
    return getValue(
      context,
      mobile: 24,
      tablet: 28,
      desktop: 32,
      largeDesktop: 36,
    );
  }

  static double getTitleFontSize(BuildContext context) {
    return getValue(
      context,
      mobile: 18,
      tablet: 20,
      desktop: 22,
      largeDesktop: 24,
    );
  }

  static double getBodyFontSize(BuildContext context) {
    return getValue(
      context,
      mobile: 14,
      tablet: 15,
      desktop: 16,
      largeDesktop: 16,
    );
  }

  static double getCaptionFontSize(BuildContext context) {
    return getValue(
      context,
      mobile: 12,
      tablet: 13,
      desktop: 14,
      largeDesktop: 14,
    );
  }

  // Responsive spacing
  static double getSpacing(BuildContext context, {double multiplier = 1.0}) {
    final baseSpacing = getValue(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
      largeDesktop: 20.0,
    );
    return baseSpacing * multiplier;
  }

  // Responsive icon sizes
  static double getIconSize(BuildContext context) {
    return getValue(
      context,
      mobile: 20,
      tablet: 22,
      desktop: 24,
      largeDesktop: 26,
    );
  }

  static double getLargeIconSize(BuildContext context) {
    return getValue(
      context,
      mobile: 32,
      tablet: 36,
      desktop: 40,
      largeDesktop: 44,
    );
  }

  // Responsive button sizes
  static Size getButtonSize(BuildContext context) {
    return getValue(
      context,
      mobile: const Size(double.infinity, 48),
      tablet: const Size(double.infinity, 52),
      desktop: const Size(double.infinity, 56),
      largeDesktop: const Size(double.infinity, 60),
    );
  }

  // Responsive card dimensions
  static double getCardElevation(BuildContext context) {
    return getValue(
      context,
      mobile: 2,
      tablet: 4,
      desktop: 6,
      largeDesktop: 8,
    );
  }

  static BorderRadius getCardBorderRadius(BuildContext context) {
    final radius = getValue(
      context,
      mobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
      largeDesktop: 18.0,
    );
    return BorderRadius.circular(radius);
  }

  // Responsive grid columns
  static int getGridColumns(BuildContext context) {
    return getValue(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      largeDesktop: 4,
    );
  }

  // Responsive max width for content
  static double getMaxContentWidth(BuildContext context) {
    return getValue(
      context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1200,
      largeDesktop: 1400,
    );
  }

  // Responsive sidebar width
  static double getSidebarWidth(BuildContext context) {
    return getValue(
      context,
      mobile: 280,
      tablet: 320,
      desktop: 360,
      largeDesktop: 400,
    );
  }

  // Responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    return getValue(
      context,
      mobile: 56,
      tablet: 64,
      desktop: 72,
      largeDesktop: 80,
    );
  }

  // Responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    return getValue(
      context,
      mobile: screenWidth * 0.9,
      tablet: screenWidth * 0.7,
      desktop: screenWidth * 0.5,
      largeDesktop: screenWidth * 0.4,
    );
  }

  // Responsive layout helpers
  static Widget buildResponsiveRow({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    bool forceColumn = false,
  }) {
    if (isMobile(context) || forceColumn) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    }
  }

  static Widget buildResponsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    double? childAspectRatio,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
  }) {
    final columns = getGridColumns(context);
    final spacing = getSpacing(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: childAspectRatio ?? 1.0,
        mainAxisSpacing: mainAxisSpacing ?? spacing,
        crossAxisSpacing: crossAxisSpacing ?? spacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  // Responsive container with max width
  static Widget buildConstrainedContainer({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return Container(
      width: double.infinity,
      margin: margin ?? getResponsiveMargin(context),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? getMaxContentWidth(context),
          ),
          child: Container(
            padding: padding ?? getResponsivePadding(context),
            child: child,
          ),
        ),
      ),
    );
  }

  // Responsive safe area
  static Widget buildResponsiveSafeArea({
    required BuildContext context,
    required Widget child,
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left && !isDesktop(context),
      right: right && !isDesktop(context),
      child: child,
    );
  }

  // Responsive app bar
  static PreferredSizeWidget buildResponsiveAppBar({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    Color? backgroundColor,
  }) {
    final height = getAppBarHeight(context);
    final titleFontSize = getTitleFontSize(context);

    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: centerTitle,
        backgroundColor: backgroundColor,
        actions: actions,
        leading: leading,
        toolbarHeight: height,
      ),
    );
  }

  // Responsive bottom sheet
  static void showResponsiveBottomSheet({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    if (isDesktop(context)) {
      // Show as dialog on desktop
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            width: getDialogWidth(context),
            constraints: BoxConstraints(
              maxHeight: getScreenHeight(context) * 0.8,
            ),
            child: child,
          ),
        ),
      );
    } else {
      // Show as bottom sheet on mobile/tablet
      showModalBottomSheet(
        context: context,
        isScrollControlled: isScrollControlled,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => child,
      );
    }
  }

  // Responsive snackbar
  static void showResponsiveSnackBar({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          fontSize: getBodyFontSize(context),
          fontFamily: 'Montserrat',
        ),
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      action: action,
      behavior: SnackBarBehavior.floating,
      margin: getResponsiveMargin(context),
      shape: RoundedRectangleBorder(
        borderRadius: getCardBorderRadius(context),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

