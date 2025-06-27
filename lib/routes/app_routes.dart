import 'package:get/get.dart';
import '../views/splash_screen.dart';
import '../views/home_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];

  // static String getInitialRoute() => splash;
}

