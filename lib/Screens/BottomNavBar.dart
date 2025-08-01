import 'package:flutter/material.dart';
import 'package:shakti/Screens/CommunityHome.dart';
import 'package:shakti/Screens/Finance.dart';
import 'package:shakti/Screens/Invest.dart';
import 'package:shakti/Screens/avatar.dart';
import 'package:shakti/Utils/constants/colors.dart';

class BottomNavBarExample extends StatefulWidget {
  @override
  _BottomNavBarExampleState createState() => _BottomNavBarExampleState();
}

class _BottomNavBarExampleState extends State<BottomNavBarExample> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    AvatarScreen(),
    Finance(),
    Invest(),
    CommunityHomeScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.white,
        selectedItemColor: Scolor.secondry,
        backgroundColor: Scolor.primary,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 0
                  ? 'assets/images/Vector (3).png' // Image when selected
                  : 'assets/images/dishawhite.png', // Image when not selected
              width: 24,
              height: 24,
            ),
            label: "Disha",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 1
                  ? 'assets/images/raphael_piechart.png'
                  : 'assets/images/Vector (4).png',
              width: 24,
              height: 24,
            ),
            label: "Finance",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 2
                  ? 'assets/images/Vector (6).png'
                  : 'assets/images/Vector (5).png',
              width: 24,
              height: 24,
            ),
            label: "Invest",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 3
                  ? 'assets/images/yellowcommunity.png'
                  : 'assets/images/fluent_people-community-16-regular.png',
              width: 24,
              height: 24,
            ),
            label: "Community",
          ),
        ],
      ),
    );
  }
}

class Community {}
