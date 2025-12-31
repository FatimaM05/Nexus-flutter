import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../pages/dashboard/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<int> _history = [0];

  late final List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardScreen(goToTodo: _goToTodo), 
      const Center(child: Text("To-Do Page")),
      const Center(child: Text("Journal Page")),
      const Center(child: Text("Highlights Page")),
    ];
  }

    void _goToTodo() {
    _onTabSelected(1);
  }

  void _onTabSelected(int index) {
    if (_history.isEmpty || _history.last != index) {
      _history.add(index);
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onBackPressed() {
    if (_history.length > 1) {
      _history.removeLast();
      int previous = _history.last;
      setState(() {
        _selectedIndex = previous;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // icons for bottom navbar
    final dashboardIcon =
        _selectedIndex == 0 ? Icons.home_filled : Icons.home_outlined;
    final todoIcon =
        _selectedIndex == 1 ? Icons.check_box : Icons.check_box_outlined;
    final journalIcon =
        _selectedIndex == 2 ? Icons.book : Icons.book_outlined;
    final highlightsIcon =
        _selectedIndex == 3 ? Icons.image : Icons.image_outlined;

    return Scaffold(
      backgroundColor: const Color(0xFFA09CB0),

      // main appbar of our page
      appBar: CustomAppBar(
        selectedIndex: _selectedIndex,
        onBack: _selectedIndex == 0 ? null : _onBackPressed,
      ),

      // body gotta have pages and stuff
      body: _pages[_selectedIndex],

      // the bottom navabr of our app
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
          color: Colors.white,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFA09CB0),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(icon: Icon(dashboardIcon), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(todoIcon), label: 'To-Do'),
            BottomNavigationBarItem(icon: Icon(journalIcon), label: 'Journal'),
            BottomNavigationBarItem(icon: Icon(highlightsIcon), label: 'Highlights'),
          ],
        ),
      ),
    );
  }
}
