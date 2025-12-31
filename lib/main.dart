import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexus',
      //home: const HomePage(),
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFA09CB0),
        appBarTheme: AppBarThemeData(
          backgroundColor: Color.fromRGBO(160, 156, 176, 1),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(160, 156, 176, 1),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: CircleBorder(),
        ),
        searchBarTheme: SearchBarThemeData(
          constraints: BoxConstraints.tightFor(height: 50),
          side: WidgetStateProperty.resolveWith<BorderSide>((states) {
            if (states.contains(WidgetState.focused)) {
              return BorderSide(
                color: Color.fromARGB(255, 87, 67, 168),
                width: 1.0,
              );
            }
            // else if (states.contains(
            //   WidgetState.pressed | WidgetState.hovered,
            // )) {
            //   return BorderSide(color: Color(0xFF413476), width: 1.0);
            // }
            else {
              return BorderSide(color: Color(0xFFE5E7EB), width: 1.0);
            }
          }),
          hintStyle: WidgetStateProperty.all(
            TextStyle(color: Color.fromRGBO(10, 10, 10, 0.5)),
          ),
          elevation: WidgetStateProperty.all(0.0),
          backgroundColor: WidgetStateProperty.all(Color(0xFFF9FAFB)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          ),
          padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0))
        ),
      ),
      home: const SplashPage(), 
    );
  }
}

