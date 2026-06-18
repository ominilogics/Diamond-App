import 'package:daimond/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/gradient_scaffold.dart';
import '../widgets/custom_bottom_nav_bar.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Render the Home Screen at index 0, and dummy screens for the rest
  final List<Widget> _pages = const [
    HomeScreen(),
    Center(child: Text('Cards Screen')),
    Center(child: Text('Favorite Screen')),
    Center(child: Text('Settings Screen')),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
    );
  }
}
