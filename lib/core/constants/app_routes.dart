import 'package:flutter/material.dart';
import '../../presentation/screens/home/home_screen.dart';

class AppRoutes {
  static const String home = '/';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeScreen(),
    };
  }
}