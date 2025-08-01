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

    // Responsive max width
    double contentMaxWidth;
    if (screenWidth < 600) {
      contentMaxWidth = screenWidth;
    } else if (screenWidth < 1000) {
      contentMaxWidth = 700;
    } else {
      contentMaxWidth = 900;
    }

    return Scaffold(
      backgroundColor: Scolor.primary,
      appBar: AppBar(
        backgroundColor: Scolor.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Scolor.secondry),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BottomNavBarExample()),
            );
          },
        ),
      ),
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
                const CustomTopBar2(),
                SizedBox(height: screenHeight * 0.015),
                Center(child: ScreenHeadings(text: "Connect with Users")),
                SizedBox(height: screenHeight * 0.02),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Scolor.primary,
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
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
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.02,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // Users Count
                Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                  child: Text(
                    '${filteredUsers.length} users found',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: screenWidth * 0.035,
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
                                    size: screenWidth * 0.2,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Text(
                                    searchQuery.isEmpty
                                        ? 'No users available'
                                        : 'No users match your search',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: screenWidth * 0.04,
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
                              // The ListView is now sized by contentMaxWidth so cards are always balanced.
                              child: ListView.builder(
                                itemCount: filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = filteredUsers[index];
                                  final isFollowing = followingIds.contains(user.id);
                                  return UserCard(
                                    user: user,
                                    isFollowing: isFollowing,
                                    onFollowToggle: () {
                                      if (isFollowing) {
                                        unfollowUser(user.id);
                                      } else {
                                        followUser(user.id);
                                      }
                                    },
                                    screenWidth: contentMaxWidth,   // Use responsive width here to balance
                                    screenHeight: screenHeight,
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
  final double screenWidth;
  final double screenHeight;

  const UserCard({
    super.key,
    required this.user,
    required this.isFollowing,
    required this.onFollowToggle,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Card and content all scale off passed-in screenWidth for true responsivity!
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Scolor.primary,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(color: Scolor.secondry, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Scolor.secondry,
                radius: screenWidth * 0.06,
                child: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
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
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.005,
                ),
                decoration: BoxDecoration(
                  color: isFollowing ? Colors.grey[700] : Scolor.secondry,
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                ),
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.w600,
                    color: isFollowing ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.people,
                count: user.followersCount,
                label: 'Followers',
                screenWidth: screenWidth,
              ),
              SizedBox(width: screenWidth * 0.06),
              _buildStatItem(
                icon: Icons.person_add,
                count: user.followingCount,
                label: 'Following',
                screenWidth: screenWidth,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey[700] : Scolor.secondry,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
              ),
              onPressed: onFollowToggle,
              icon: Icon(
                isFollowing ? Icons.person_remove : Icons.person_add,
                color: isFollowing ? Colors.white : Colors.black,
                size: screenWidth * 0.05,
              ),
              label: Text(
                isFollowing ? "Unfollow" : "Follow",
                style: TextStyle(
                  color: isFollowing ? Colors.white : Colors.black,
                  fontSize: screenWidth * 0.045,
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
    required double screenWidth,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Scolor.secondry,
          size: screenWidth * 0.04,
        ),
        SizedBox(width: screenWidth * 0.015),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
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
