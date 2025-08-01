import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  List<Following> followingList = [];
  bool isLoading = true;
  String errorMessage = '';

  // Static data for demonstration (will be replaced by API data)
  final List<Following> staticFollowing = [
    Following(
      id: "1",
      fullName: "Ankit Verma",
      email: "ankit.verma@gmail.com",
      followersCount: 1.2,
      followingCount: 456,
      isFollowing: true,
    ),
    Following(
      id: "2",
      fullName: "Kavya Nair",
      email: "kavya.nair@gmail.com",
      followersCount: 2.8,
      followingCount: 189,
      isFollowing: true,
    ),
    Following(
      id: "3",
      fullName: "Rahul Gupta",
      email: "rahul.gupta@gmail.com",
      followersCount: 567,
      followingCount: 234,
      isFollowing: true,
    ),
    Following(
      id: "4",
      fullName: "Meera Patel",
      email: "meera.patel@gmail.com",
      followersCount: 890,
      followingCount: 345,
      isFollowing: true,
    ),
    Following(
      id: "5",
      fullName: "Vikash Singh",
      email: "vikash.singh@gmail.com",
      followersCount: 1.5,
      followingCount: 678,
      isFollowing: true,
    ),
    Following(
      id: "6",
      fullName: "Shreya Sharma",
      email: "shreya.sharma@gmail.com",
      followersCount: 3.2,
      followingCount: 812,
      isFollowing: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    fetchFollowing();
  }

  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchFollowing() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
      final authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token found');
      }

      // Try to fetch from API
      final response = await http.get(
        Uri.parse('http://65.2.82.85:5000/user/following'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> followingData = data['following'] ?? [];

        setState(() {
          followingList = followingData
              .map((item) => Following.fromJson(item))
              .where((following) =>
                  following.id.isNotEmpty) // Filter out invalid entries
              .toList();

          // If API returns empty or invalid data, use static data
          if (followingList.isEmpty) {
            followingList = staticFollowing;
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load following');
      }
    } catch (e) {
      // Use static data when API fails
      setState(() {
        followingList = staticFollowing;
        isLoading = false;
        errorMessage = 'Using demo data - API connection failed';
      });
    }
  }

  Future<void> toggleFollow(String userId, int index) async {
    try {
      // Optimistically update UI
      setState(() {
        followingList[index].isFollowing = !followingList[index].isFollowing;
      });
      final authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token found');
      }

      // Make API call to unfollow/follow
      final response = await http.post(
        Uri.parse('http://65.2.82.85:5000/user/toggle-follow'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode != 200) {
        // Revert the change if API call fails
        setState(() {
          followingList[index].isFollowing = !followingList[index].isFollowing;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update follow status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Revert the change if error occurs
      setState(() {
        followingList[index].isFollowing = !followingList[index].isFollowing;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Following',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F1419), Color(0xFF1A2332)],
          ),
        ),
        child: Column(
          children: [
            // Header with following count
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: const Color(0xFFFFD700),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${followingList.length} Following',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Error message (if any)
            if (errorMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: const Color(0xFFFFD700), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // Following list
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      ),
                    )
                  : followingList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add_outlined,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Not following anyone yet',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Discover people to follow',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: fetchFollowing,
                          color: const Color(0xFFFFD700),
                          backgroundColor: const Color(0xFF1E3A5F),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: followingList.length,
                            itemBuilder: (context, index) {
                              return FollowingCard(
                                following: followingList[index],
                                onToggleFollow: () => toggleFollow(
                                    followingList[index].id, index),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class FollowingCard extends StatelessWidget {
  final Following following;
  final VoidCallback onToggleFollow;

  const FollowingCard({
    super.key,
    required this.following,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E3A5F).withOpacity(0.6),
            const Color(0xFF2C5282).withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                following.getInitials(),
                style: const TextStyle(
                  color: Color(0xFF0F1419),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  following.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  following.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatChip(
                        following.getFormattedFollowersCount(), 'Followers'),
                    const SizedBox(width: 12),
                    _buildStatChip('${following.followingCount}', 'Following'),
                  ],
                ),
              ],
            ),
          ),

          // Follow/Unfollow Button
          GestureDetector(
            onTap: onToggleFollow,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: following.isFollowing
                    ? LinearGradient(
                        colors: [
                          Colors.grey.withOpacity(0.6),
                          Colors.grey.withOpacity(0.4),
                        ],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                borderRadius: BorderRadius.circular(20),
                border: following.isFollowing
                    ? Border.all(color: Colors.white.withOpacity(0.3))
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: following.isFollowing
                        ? Colors.grey.withOpacity(0.2)
                        : const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                following.isFollowing ? 'Following' : 'Follow',
                style: TextStyle(
                  color: following.isFollowing
                      ? Colors.white
                      : const Color(0xFF0F1419),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class Following {
  final String id;
  final String fullName;
  final String email;
  final dynamic followersCount; // Can be int or double for K format
  final int followingCount;
  bool isFollowing;

  Following({
    required this.id,
    required this.fullName,
    required this.email,
    required this.followersCount,
    required this.followingCount,
    this.isFollowing = true,
  });

  factory Following.fromJson(Map<String, dynamic> json) {
    return Following(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'Unknown User',
      email: json['email']?.toString() ?? 'Email not found',
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      isFollowing: json['isFollowing'] ?? true,
    );
  }

  String getInitials() {
    if (fullName.isEmpty) return 'U';
    List<String> names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName[0].toUpperCase();
  }

  String getFormattedFollowersCount() {
    if (followersCount is double) {
      return '${followersCount}K';
    } else if (followersCount is int) {
      if (followersCount >= 1000) {
        return '${(followersCount / 1000).toStringAsFixed(1)}K';
      }
      return followersCount.toString();
    }
    return followersCount.toString();
  }
}

// Usage in your main app:
// Navigator.push(
//   context,
//   MaterialPageRoute(builder: (context) => FollowingPage()),
// );
