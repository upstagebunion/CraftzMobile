import 'package:flutter/material.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/productos/productos_screen.dart';
import '../../presentation/screens/login/login_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String productos = '/productos';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => LoginScreen(),
      home: (context) => const HomeScreen(),
      productos: (context) => ProductsPage(),
    };
  }
}