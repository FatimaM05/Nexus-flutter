import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback goToTodo;
  const DashboardScreen({super.key, required this.goToTodo});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    );
  }
}