import 'package:assignment_2/screens/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:assignment_2/screens/login_page.dart';
import 'package:assignment_2/screens/main_screen.dart';

class AppRoutes {
  static const String onboarding = "/onboarding";
  static const String login = "/login";
  static const String main = "/main";

  static Map<String, WidgetBuilder> routes = {
    onboarding: (context) => const OnboardingPage(),
    login: (context) => const LoginPage(),
    main: (context) => const MainScreen(),
  };
}
