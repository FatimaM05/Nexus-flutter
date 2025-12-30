import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/journal/journal_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Fixed: Firebase.initializeApp
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Fixed: removed extra parentheses

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Fixed: ModeBanner not ModetBanner
      title: 'Nexus',
      theme: ThemeData( // Fixed: ThemeData not ThemeDate
        appBarTheme: AppBarTheme( // Fixed: AppBarTheme not AnotherTheme
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
          side: WidgetStateProperty.resolveWith<BorderSide>((states) {
            if (states.contains(WidgetState.focused)) {
              return BorderSide(color: Color.fromARGB(255, 87, 67, 168), width: 1.0);
            } else {
              return BorderSide(color: Color(0xFFE5E7EB), width: 1.0);
            }
          }),
          hintStyle: WidgetStateProperty.all(
            TextStyle(color: Color.fromRGBO(10, 10, 10, 0.5)),
          ),
          elevation: WidgetStateProperty.all(0.0),
          backgroundColor: WidgetStateProperty.all(Color(0xFFF9FAFB)),
        ),
      ),
      // DIRECT TEST: Show Journal List Page
      home: const JournalListPage(), // ← Test your journal page directly
      // home: const SplashPage(), // ← Original (comment out for testing)
    );
  }
}