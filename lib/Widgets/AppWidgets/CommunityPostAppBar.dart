import 'package:flutter/material.dart';
import 'package:shakti/Screens/CommunityHome.dart';
import 'package:shakti/Screens/CreatePost.dart';
import 'package:shakti/Screens/Mentors.dart';
import 'package:shakti/Utils/constants/colors.dart';

class CustomTopBar3 extends StatelessWidget {
  const CustomTopBar3({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Scolor.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommunityHomeScreen()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.group, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FollowUsersScreen()));
                },
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Scolor.secondry,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreatePostScreen()));
                },
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text(
                  "Add Post",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
