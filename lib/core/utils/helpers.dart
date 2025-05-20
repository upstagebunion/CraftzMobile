import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:craftz_app/core/constants/app_routes.dart'; 

class AuthHelper {
  static Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }
}