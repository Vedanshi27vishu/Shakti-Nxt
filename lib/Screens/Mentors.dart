import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shakti/Screens/BottomNavBar.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/Widgets/AppWidgets/CommunityMentorAppBar.dart';
import 'package:shakti/Widgets/AppWidgets/ScreenHeadings.dart';
import 'package:shakti/helpers/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FollowUsersScreen extends StatefulWidget {
  const FollowUsersScreen({super.key});

  @override
  State<FollowUsersScreen> createState() => _FollowUsersScreenState();
}

class _FollowUsersScreenState extends State<FollowUsersScreen> {
  List<UserModel> allUsers = [];
  List<UserModel> filteredUsers = [];
  Set<String> followingIds = {};
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchFollowingUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) throw Exception('No auth token found');
      final response = await http.get(
        Uri.parse('http://65.2.82.85:5000/user/all-users'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          allUsers = (data['users'] as List)
              .map((user) => UserModel.fromJson(user))
              .toList();
          filteredUsers = allUsers;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Failed to fetch users: $e');
    }
  }

  Future<void> fetchFollowingUsers() async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) throw Exception('No auth token found');
      final response = await http.get(
        Uri.parse('http://65.2.82.85:5000/api/follow/followers-following'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          followingIds = (data['following'] as List)
              .map((user) => user['userId'].toString())
              .toSet();
        });
      }
    } catch (e) {
      print('Error fetching following users: $e');
    }
  }

  Future<void> followUser(String userId) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) throw Exception('No auth token found');
      final response = await http.put(
        Uri.parse('http://65.2.82.85:5000/api/follow/F/$userId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          followingIds.add(userId);
          final userIndex = allUsers.indexWhere((user) => user.id == userId);
          if (userIndex != -1) {
            allUsers[userIndex] = allUsers[userIndex].copyWith(
              followersCount: allUsers[userIndex].followersCount + 1,
            );
            final filteredIndex =
                filteredUsers.indexWhere((user) => user.id == userId);
            if (filteredIndex != -1) {
              filteredUsers[filteredIndex] =
                  filteredUsers[filteredIndex].copyWith(
                followersCount: filteredUsers[filteredIndex].followersCount + 1,
              );
            }
          }
        });
        _showSuccessSnackBar('User followed successfully');
      } else {
        throw Exception('Failed to follow user');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to follow user: $e');
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) throw Exception('No auth token found');
      final response = await http.put(
        Uri.parse('http://65.2.82.85:5000/api/follow/U/$userId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          followingIds.remove(userId);
          final userIndex = allUsers.indexWhere((user) => user.id == userId);
          if (userIndex != -1) {
            allUsers[userIndex] = allUsers[userIndex].copyWith(
              followersCount: allUsers[userIndex].followersCount - 1,
            );
            final filteredIndex =
                filteredUsers.indexWhere((user) => user.id == userId);
            if (filteredIndex != -1) {
              filteredUsers[filteredIndex] =
                  filteredUsers[filteredIndex].copyWith(
                followersCount: filteredUsers[filteredIndex].followersCount - 1,
              );
            }
          }
        });
        _showSuccessSnackBar('User unfollowed successfully');
      } else {
        throw Exception('Failed to unfollow user');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to unfollow user: $e');
    }
  }

  void filterUsers(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredUsers = allUsers;
      } else {
        filteredUsers = allUsers.where((user) {
          return user.email.toLowerCase().contains(query.toLowerCase()) ||
              user.fullName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = THelperFunctions.screenWidth(context);
    double screenHeight = THelperFunctions.screenHeight(context);

    // Responsive padding and card width
    double contentMaxWidth;
    if (screenWidth < 600) {
      contentMaxWidth = screenWidth;
    } else if (screenWidth < 1000) {
      contentMaxWidth = 700;
    } else {
      contentMaxWidth = 900;
    }
    // Card width -- always centered and maxes out for large screens
    double cardWidth = contentMaxWidth < 420
        ? contentMaxWidth
        : (contentMaxWidth > 520 ? 520 : contentMaxWidth);

    return Scaffold(
      backgroundColor: Scolor.primary,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Center(
          child: Container(
            width: contentMaxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.015),
                Center(child: ScreenHeadings(text: "Connect with Users")),
                SizedBox(height: screenHeight * 0.02),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Scolor.primary,
                    borderRadius: BorderRadius.circular(cardWidth * 0.07),
                    border: Border.all(color: Scolor.secondry, width: 1),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterUsers,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by name or email...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, color: Scolor.secondry),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Scolor.secondry),
                              onPressed: () {
                                searchController.clear();
                                filterUsers('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: cardWidth * 0.06,
                        vertical: screenHeight * 0.018,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // Users Count
                Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.008),
                  child: Text(
                    '${filteredUsers.length} users found',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: cardWidth * 0.038,
                    ),
                  ),
                ),
                // Users List
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Scolor.secondry),
                          ),
                        )
                      : filteredUsers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: cardWidth * 0.4,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(height: screenHeight * 0.03),
                                  Text(
                                    searchQuery.isEmpty
                                        ? 'No users available'
                                        : 'No users match your search',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: cardWidth * 0.045,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                await fetchUsers();
                                await fetchFollowingUsers();
                              },
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.012),
                                itemCount: filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = filteredUsers[index];
                                  final isFollowing =
                                      followingIds.contains(user.id);
                                  return Center(
                                    child: UserCard(
                                      user: user,
                                      isFollowing: isFollowing,
                                      onFollowToggle: () {
                                        if (isFollowing) {
                                          unfollowUser(user.id);
                                        } else {
                                          followUser(user.id);
                                        }
                                      },
                                      cardWidth: cardWidth,
                                      screenHeight: screenHeight,
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final UserModel user;
  final bool isFollowing;
  final VoidCallback onFollowToggle;
  final double cardWidth; // Responsive card width, not whole screen
  final double screenHeight;

  const UserCard({
    super.key,
    required this.user,
    required this.isFollowing,
    required this.onFollowToggle,
    required this.cardWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive sizes
    final double avatarRadius = cardWidth * 0.13 > 36 ? 36 : cardWidth * 0.13; // up to 36px
    final double verPad = cardWidth * 0.06;
    final double horPad = cardWidth * 0.07;
    final double nameFont = cardWidth * 0.077 > 19 ? 19 : cardWidth * 0.077;
    final double subFont = cardWidth * 0.055 > 16 ? 16 : cardWidth * 0.055;
    final double statNumberFont = cardWidth * 0.06;
    final double statLabelFont = cardWidth * 0.036;
    final double buttonFont = cardWidth * 0.048;
    final double buttonHeight = screenHeight * 0.055 > 46 ? 46 : screenHeight * 0.055;

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(bottom: screenHeight * 0.017),
      padding: EdgeInsets.symmetric(horizontal: horPad, vertical: verPad * 0.5),
      decoration: BoxDecoration(
        color: Scolor.primary,
        borderRadius: BorderRadius.circular(cardWidth * 0.07),
        border: Border.all(color: Scolor.secondry, width: 1),
        boxShadow: [
          BoxShadow(
            color: Scolor.secondry.withOpacity(0.07),
            spreadRadius: 1,
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Scolor.secondry,
                radius: avatarRadius,
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: avatarRadius * 0.95,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: horPad * 0.55),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: nameFont,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: verPad * 0.15),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: subFont,
                        color: Colors.grey[400],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: horPad * 0.6,
                  vertical: verPad * 0.18,
                ),
                decoration: BoxDecoration(
                  color: isFollowing ? Colors.grey[700] : Scolor.secondry,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: TextStyle(
                    fontSize: cardWidth * 0.038,
                    fontWeight: FontWeight.w600,
                    color: isFollowing ? Colors.white : Colors.black,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: verPad * 0.18),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.people,
                count: user.followersCount,
                label: 'Followers',
                numberFont: statNumberFont,
                labelFont: statLabelFont,
              ),
              SizedBox(width: cardWidth * 0.15),
              _buildStatItem(
                icon: Icons.person_add,
                count: user.followingCount,
                label: 'Following',
                numberFont: statNumberFont,
                labelFont: statLabelFont,
              ),
            ],
          ),
          SizedBox(height: verPad * 0.35),
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey[700] : Scolor.secondry,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(cardWidth * 0.045),
                ),
                padding: EdgeInsets.symmetric(vertical: verPad * 0.27),
              ),
              onPressed: onFollowToggle,
              icon: Icon(
                isFollowing ? Icons.person_remove : Icons.person_add,
                color: isFollowing ? Colors.white : Colors.black,
                size: cardWidth * 0.08,
              ),
              label: Text(
                isFollowing ? "Unfollow" : "Follow",
                style: TextStyle(
                  color: isFollowing ? Colors.white : Colors.black,
                  fontSize: buttonFont,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
    required double numberFont,
    required double labelFont,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Scolor.secondry,
          size: numberFont,
        ),
        SizedBox(width: numberFont * 0.37),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: numberFont,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: labelFont,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final int followersCount;
  final int followingCount;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.followersCount,
    required this.followingCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    int? followersCount,
    int? followingCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}
