import 'package:flutter/material.dart';
import 'package:ambulao_driver/screens/dashboard_screen.dart';
import 'package:ambulao_driver/screens/earnings_screen.dart';
import 'package:ambulao_driver/screens/profile_screen.dart';
import 'package:ambulao_driver/screens/menu_screen.dart';
import 'package:ambulao_driver/core/theme.dart';

final GlobalKey<MainLayoutState> mainLayoutKey = GlobalKey<MainLayoutState>();

class MainLayout extends StatefulWidget {
  final int initialIndex;
  MainLayout({Key? key, this.initialIndex = 0}) : super(key: key ?? mainLayoutKey);

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const EarningsScreen(),
    const ProfileScreen(),
    const MenuScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void switchToTab(int index) {
    if (mounted) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlue,
                  height: 1.5,
                );
              }
              return TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
                height: 1.5,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: AppTheme.primaryBlue, size: 26);
              }
              return IconThemeData(color: Colors.grey.shade500, size: 26);
            }),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            backgroundColor: Colors.white,
            elevation: 0,
            height: 64,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.currency_rupee_outlined),
                selectedIcon: Icon(Icons.currency_rupee),
                label: 'Earnings',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu),
                selectedIcon: Icon(Icons.menu),
                label: 'Menu',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
