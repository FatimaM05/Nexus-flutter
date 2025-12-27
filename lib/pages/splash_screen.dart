import 'dart:async';
import 'dart:math' as math; 
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import "./auth/login.dart";

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Rotation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); 

    // Navigate Home
    Timer(const Duration(seconds: 6), () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false; 
    if (!mounted) return;


    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  });
  }

  @override
  void dispose() {
    // Dispose controller
    _controller.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(160, 156, 176, 100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rotating Logo
            RotationTransition(
              turns: _controller,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circle Painter
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: NexusLogoPainter(),
                  ),
                  // Center N
                  RotationTransition(
                    turns: ReverseAnimation(_controller),
                    child: const Text(
                      "N",
                      style: TextStyle(
                        fontSize: 60,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Chicle', 
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // App Title
            const Text(
              "NEXUS",
              style: TextStyle(
                fontSize: 48,
                letterSpacing: 2,
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontFamily: 'Chicle', 
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Logo Painter
class NexusLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = size.width / 2;

    // main circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // 3 dots
    for (int i = 0; i < 3; i++) {
      double angle = (i * 120) * math.pi / 180;
      double x = centerX + radius * math.cos(angle);
      double y = centerY + radius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 10, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
