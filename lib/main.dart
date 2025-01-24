import 'package:flutter/material.dart';
import 'core/constants/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Craftz Admin',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: buildMaterialColor(Color(0xff292662)),
          accentColor: Color.fromARGB(255, 195, 19, 73)
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Eras',
        textTheme: TextTheme(
          bodySmall: TextStyle(fontSize:12, color:Color(0xff292662), fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize:16, color:Color(0xff292662), fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize:16, color:Color(0xff292662), fontWeight: FontWeight.w600),
          headlineLarge: TextStyle(fontSize:25, color:Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w800),
          headlineMedium: TextStyle(fontSize:20, color:Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w700),
        ),
      ),
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}

MaterialColor buildMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}