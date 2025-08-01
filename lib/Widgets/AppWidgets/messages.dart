import 'package:flutter/material.dart';
import 'package:shakti/Screens/CommunityHome.dart';
import 'package:shakti/Screens/Mentors.dart';
import 'package:shakti/Screens/followers.dart';

class MessageBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const MessageBar({
    super.key,
    this.selectedIndex = 1,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Your color palette
    final Color primaryColor = const Color(0xFF1E3A8A); // Dark blue

    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: "Home",
                index: 0,
                onTap: () {
                  onItemSelected(0);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CommunityHomeScreen()),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.chat_bubble_outline,
                selectedIcon: Icons.chat_bubble,
                label: "Messages",
                index: 1,
                onTap: () {
                  onItemSelected(1);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FollowUsersScreen()),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.people_outline,
                selectedIcon: Icons.people,
                label: "Mentors",
                index: 2,
                onTap: () {
                  onItemSelected(2);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UsersListScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final bool isSelected = selectedIndex == index;
    final Color primaryColor = const Color(0xFF1E3A8A);
    final Color secondaryColor = const Color(0xFFFBBF24);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? secondaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? primaryColor : Colors.white,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
