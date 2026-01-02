import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/auth/login.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final VoidCallback? onBack;
  final String username;

  const CustomAppBar({
    super.key,
    required this.selectedIndex,
    this.onBack,
     required this.username,
  });

  @override
  Widget build(BuildContext context) {
    String title = "";
    Widget? action;
    Widget? leading;

    switch (selectedIndex) {

      // Dashboard
      case 0:
        leading = Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Image.asset("assets/images/Logo.png"),
        );

        action = Padding(
          padding: const EdgeInsets.only(right: 20),
          child: PopupMenuButton<String>(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            offset: const Offset(0, 50),
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Color(0xFFA09CB0)),
                    SizedBox(width: 3),
                    Text("Sign Out", style: TextStyle(color: Color(0xFFA09CB0)),),
                  ],
                ),
              ),
            ],
            child: CircleAvatar(
              backgroundColor: const Color(0xFFDADAE0),
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : "?",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        action = const Padding(
          padding: EdgeInsets.only(right: 20),
        );
        break;

      // Journal
      case 2: 
        title = "Journal";
        leading = IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        );
        action = const Padding(
          padding: EdgeInsets.only(right: 20),
        );
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
