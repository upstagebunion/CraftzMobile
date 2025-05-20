import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_routes.dart';
import './services/auth_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    LoadingApp()
  );

  final ApiService auth = ApiService();
  bool isTokenValid = await auth.verifyToken();

  runApp(
    ProviderScope(
      child: MyApp(initialRoute: isTokenValid ? AppRoutes.home : AppRoutes.login)
    )
  );
}

class LoadingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xff292662),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 4.0,
              ),
              SizedBox(height: 20),
              Text(
                'Verificando sesión...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Eras',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
        progressIndicatorTheme: ProgressIndicatorThemeData(
          circularTrackColor: Color.fromARGB(255, 173, 170, 243),
          strokeCap: StrokeCap.round, 
          strokeWidth: 4.0
        ),
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
          bodySmall: TextStyle(fontSize:12, color:Color(0xff292662), fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(fontSize:16, color:Color(0xff292662), fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontSize:16, color:Color(0xff292662), fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontSize:18, color:Color(0xff292662), fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize:19, color:Color(0xff292662), fontWeight: FontWeight.w900),
          titleLarge: TextStyle(fontSize:20, color:Color(0xff292662), fontWeight: FontWeight.w900),
          headlineLarge: TextStyle(fontSize:25, color:Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w900),
          headlineMedium: TextStyle(fontSize:25, color:Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w800),
          headlineSmall: TextStyle(fontSize:20, color:Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w700),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Color(0xff292662),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            textStyle: TextStyle(fontFamily: 'Eras', fontSize: 12, fontWeight: FontWeight.w600)
          )
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff292662),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            textStyle: TextStyle(fontFamily: 'Eras', fontWeight: FontWeight.w600)
          )
        ),
      ),
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
