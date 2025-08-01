import 'package:flutter/material.dart';
import 'package:shakti/Screens/CommunityHome.dart';
import 'package:shakti/Screens/CreatePost.dart';
import 'package:shakti/Screens/Mentors.dart';
import 'package:shakti/Screens/followers.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/helpers/helper_functions.dart';

class CustomTopBar1 extends StatelessWidget {
  const CustomTopBar1({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = THelperFunctions.screenHeight(context);
    return Column(
      children: [
        SizedBox(
          height: screenHeight * 0.05,
        ),
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
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Scolor.secondry,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              //   onPressed: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => CommunityHomeScreen()));
              //   },
              //   icon: const Icon(Icons.home, color: Colors.black),
              //   label: null,
              //   //const Text(
              //   //   "Home",
              //   //   style: TextStyle(color: Colors.black),
              //   // ),
              // ),
              IconButton(
                icon: const Icon(Icons.group, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FollowUsersScreen()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreatePostScreen()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.message, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UsersListScreen()));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
