import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/splash_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final VoidCallback? onBack;

  const CustomAppBar({super.key, required this.selectedIndex, this.onBack});

  @override
  Widget build(BuildContext context) {
    String title = "";
    Widget? action;
    Widget? leading;

    switch (selectedIndex) {
      // Dashboard
      case 0:
        leading = Padding(
          padding: EdgeInsets.only(left: 20),
          child: Image.asset("assets/images/Logo.png"),
        );
        action = PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'logout') {
              await FirebaseAuth.instance.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashPage()),
                  (route) => false,
                );
              }
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
          ],
          child: const Padding(
            padding: EdgeInsets.only(right: 20),
            child: CircleAvatar(
              backgroundColor: Color(0xFFDADAE0),
              child: Text('S', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
        break;

      // To-Do
      case 1:
        title = "To-Do Hub";
        leading = IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        );
        action = const Padding(padding: EdgeInsets.only(right: 20));
        break;

      // Journal
      case 2:
        title = "Journal";
        leading = IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        );
        action = const Padding(padding: EdgeInsets.only(right: 20));
        break;

      // Highlights
      case 3:
        title = "Visual Highlights";
        leading = IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        );
        action = const Padding(
          padding: EdgeInsets.only(right: 20),
          // child: Icon(Icons.share),
        );
        break;
    }

    return AppBar(
      backgroundColor: const Color(0xFFA09CB0),
      elevation: 0,
      toolbarHeight: 80,
      centerTitle: false,
      leading: leading,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      actions: action != null ? [action] : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
