import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_routes.dart';
import './services/auth_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final ApiService auth = ApiService();
  bool isTokenValid = await auth.verifyToken(); 
  runApp(
    ProviderScope(
      child: MyApp(initialRoute: isTokenValid ? AppRoutes.home : AppRoutes.login)
    )
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Craftz Admin',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xff292662),
          onPrimary: Colors.white,
          secondary: Color(0xFFC31349),
          onSecondary: Colors.white,
          surface: const Color.fromARGB(255, 206, 206, 206),
          onSurface: Color(0xff292662),
          error: Color(0xFFC31349),
          onError: Colors.white,
        ),
        fontFamily: 'Eras',
        textTheme: TextTheme(
          bodySmall: TextStyle(fontSize:12, color:Color(0xff292662), fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize:16, color:Color(0xff292662), fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize:16, color:Color(0xff292662), fontWeight: FontWeight.w600),
          headlineLarge: TextStyle(fontSize:25, color:Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w800),
          headlineMedium: TextStyle(fontSize:20, color:Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w700),
        ),
      ),
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
