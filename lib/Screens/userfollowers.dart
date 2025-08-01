import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FollowersPage extends StatefulWidget {
  const FollowersPage({super.key});

  @override
  _FollowersPageState createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  List<Follower> followers = [];
  bool isLoading = true;
  String errorMessage = '';

  // Static data for demonstration (will be replaced by API data)
  final List<Follower> staticFollowers = [
    Follower(
      id: "1",
      fullName: "Vedanshi Aggarwal",
      email: "vedanshi27vishu@gmail.com",
      followersCount: 156,
      followingCount: 89,
    ),
    Follower(
      id: "2",
      fullName: "Arjun Sharma",
      email: "arjun.sharma@gmail.com",
      followersCount: 243,
      followingCount: 167,
    ),
    Follower(
      id: "3",
      fullName: "Priya Singh",
      email: "priya.singh@gmail.com",
      followersCount: 89,
      followingCount: 134,
    ),
    Follower(
      id: "4",
      fullName: "Rohit Kumar",
      email: "rohit.kumar@gmail.com",
      followersCount: 321,
      followingCount: 98,
    ),
    Follower(
      id: "5",
      fullName: "Sneha Patel",
      email: "sneha.patel@gmail.com",
      followersCount: 178,
      followingCount: 203,
    ),
  ];

  @override
  void initState() {
    super.initState();
    fetchFollowers();
  }

  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchFollowers() async {
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
        Uri.parse('http://65.2.82.85:5000/user/followers'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> followersData = data['followers'] ?? [];

        setState(() {
          followers = followersData
              .map((item) => Follower.fromJson(item))
              .where((follower) =>
                  follower.id.isNotEmpty) // Filter out invalid entries
              .toList();

          // If API returns empty or invalid data, use static data
          if (followers.isEmpty) {
            followers = staticFollowers;
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load followers');
      }
    } catch (e) {
      // Use static data when API fails
      setState(() {
        followers = staticFollowers;
        isLoading = false;
        errorMessage = 'Using demo data - API connection failed';
      });
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
          'Followers',
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
            // Header with follower count
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    color: const Color(0xFFFFD700),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${followers.length} Followers',
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

            // Followers list
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      ),
                    )
                  : followers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No followers yet',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: fetchFollowers,
                          color: const Color(0xFFFFD700),
                          backgroundColor: const Color(0xFF1E3A5F),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: followers.length,
                            itemBuilder: (context, index) {
                              return FollowerCard(follower: followers[index]);
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

class FollowerCard extends StatelessWidget {
  final Follower follower;

  const FollowerCard({super.key, required this.follower});

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
                follower.getInitials(),
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
                  follower.fullName,
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
                  follower.email,
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
                    _buildStatChip('${follower.followersCount}', 'Followers'),
                    const SizedBox(width: 12),
                    _buildStatChip('${follower.followingCount}', 'Following'),
                  ],
                ),
              ],
            ),
          ),

          // Follow Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'Following',
              style: TextStyle(
                color: Color(0xFF0F1419),
                fontSize: 12,
                fontWeight: FontWeight.w600,
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

class Follower {
  final String id;
  final String fullName;
  final String email;
  final int followersCount;
  final int followingCount;

  Follower({
    required this.id,
    required this.fullName,
    required this.email,
    required this.followersCount,
    required this.followingCount,
  });

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'Unknown User',
      email: json['email']?.toString() ?? 'Email not found',
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
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
}

// Usage in your main app:
// Add this to your dependencies in pubspec.yaml:
// dependencies:
//   http: ^0.13.5
