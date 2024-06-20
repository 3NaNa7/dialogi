import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
// import '../screens/phone/phone_screen.dart';
import '../screens/phone/register_screen.dart';
import '../screens/phone/login_screen.dart';
import '../screens/profile/profile_screen.dart';

/// Generator callback allowing the app to be navigated to a named route.

/// Static class contains Strings of all named routes
class Routers {
  static const String home = '/home';
  static const String sms = '/sms';
  static const String profile = '/profile';
  static const String register = '/register';
  static const String login = '/login';
}

///Return MaterialPageRoute depends of route name

// ignore: missing_return
Route<dynamic> router(routeSetting) {
  switch (routeSetting.name) {
    case Routers.register:
      return MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
        settings: routeSetting,
      );
      break;
    case Routers.login:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
        settings: routeSetting,
      );
      break;
    case Routers.home:
      return MaterialPageRoute(
        builder: (context) => HomeScreen(),
        settings: routeSetting,
      );
      break;
    case Routers.profile:
      return MaterialPageRoute(
          builder: (context) => ProfileScreen(
                profile: routeSetting.arguments,
              ),
          settings: routeSetting);
      break;
  }
}
