import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shakti/Screens/userfollowers.dart';
import 'package:shakti/Screens/userfollowing.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  String userName = "Loading...";
  String userEmail = "";
  String businessName = "";
  String businessSector = "";
  String businessLocation = "";
  int followersCount = 0;
  int followingCount = 0;
  int postsCount = 0;
  List<dynamic> userPosts = [];
  late TabController _tabController;

  // Color palette
  static const Color darkBlue = Color(0xFF1A1B3A);
  static const Color lightBlue = Color(0xFF2A2D5A);
  static const Color yellow = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchUserProfile() async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token found');
      }

      final response = await http.get(
        Uri.parse('http://65.2.82.85:5000/profile/details'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);

        setState(() {
          userName = profileData['name'] ?? 'Unknown User';
          userEmail = profileData['email'] ?? '';
          businessName = profileData['businessName'] ?? '';
          businessSector = profileData['businessSector'] ?? '';
          businessLocation = profileData['businessLocation'] ?? '';
          followersCount = profileData['followersCount'] ?? 0;
          followingCount = profileData['followingCount'] ?? 0;
          postsCount = profileData['postCount'] ?? 0;
          userPosts = profileData['posts'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() {
        isLoading = false;
        userName = "Error loading profile";
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: darkBlue,
            title: Text(
              'Error',
              style: TextStyle(color: yellow),
            ),
            content: Text(
              'Failed to load profile data. Please check your connection and try again.',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  fetchUserProfile(); // Retry
                },
                child: Text('Retry', style: TextStyle(color: yellow)),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // <-- Added responsive width logic here
    double contentMaxWidth;
    if (screenWidth < 600) {
      contentMaxWidth = screenWidth; // Phone: full width
    } else if (screenWidth < 1000) {
      contentMaxWidth = 700; // Tablet: max width 700
    } else {
      contentMaxWidth = 900; // Laptop/Desktop: max width 900
    }
    // -->

    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        title: Text(
          userName,
          style: TextStyle(
            color: yellow,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: yellow),
            onPressed: () {
              // Add menu functionality
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(yellow),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await fetchUserProfile();
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      // <-- constrained container width for profile header
                      child: Container(
                        width: contentMaxWidth,
                        child: _buildProfileHeader(screenWidth, screenHeight),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: Container(
                        width: contentMaxWidth,
                        child: _buildTabBar(),
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    child: Center(
                      child: Container(
                        width: contentMaxWidth,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildPostsGrid(),
                            _buildTaggedPosts(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Picture and Stats Row
          Row(
            children: [
              // Profile Picture
              Container(
                width: screenWidth * 0.25,
                height: screenWidth * 0.25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: yellow, width: 3),
                  gradient: LinearGradient(
                    colors: [yellow.withOpacity(0.3), lightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: screenWidth * 0.12,
                  backgroundColor: lightBlue,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: yellow,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 20),

              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('Posts', postsCount),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FollowersPage()));
                        },
                        child: _buildStatColumn('Followers', followersCount)),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FollowingPage()));
                        },
                        child: _buildStatColumn('Following', followingCount)),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Name and Bio
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                if (businessName.isNotEmpty) ...[
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: yellow.withOpacity(0.3)),
                    ),
                    child: Text(
                      businessName,
                      style: TextStyle(
                        color: yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                if (businessSector.isNotEmpty || businessLocation.isNotEmpty) ...[
                  SizedBox(height: 10),
                  Row(
                    children: [
                      if (businessSector.isNotEmpty) ...[
                        Icon(Icons.business, color: Colors.grey[400], size: 16),
                        SizedBox(width: 5),
                        Text(
                          businessSector,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ],
                      if (businessSector.isNotEmpty && businessLocation.isNotEmpty)
                        Text(
                          ' • ',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      if (businessLocation.isNotEmpty) ...[
                        Icon(Icons.location_on, color: Colors.grey[400], size: 16),
                        SizedBox(width: 5),
                        Text(
                          businessLocation,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Edit Profile',
                  Icons.edit,
                  () {
                    // Add edit profile functionality
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildActionButton(
                  'Share Profile',
                  Icons.share,
                  () {
                    // Add share functionality
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      height: 35,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: lightBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: yellow.withOpacity(0.3)),
          ),
          elevation: 0,
        ),
        icon: Icon(icon, size: 16),
        label: Text(
          text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: yellow,
        indicatorWeight: 2,
        labelColor: yellow,
        unselectedLabelColor: Colors.grey[500],
        tabs: [
          Tab(
            icon: Icon(Icons.grid_on),
            text: 'Posts',
          ),
          Tab(
            icon: Icon(Icons.person_pin),
            text: 'Tagged',
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    if (userPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 80, color: Colors.grey[600]),
            SizedBox(height: 20),
            Text(
              'No posts yet',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Share photos and videos to get started',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(2),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        final post = userPosts[index];
        return GestureDetector(
          onTap: () {
            _showPostDetails(post);
          },
          child: Container(
            decoration: BoxDecoration(
              color: lightBlue,
              border: Border.all(color: Colors.grey[800]!, width: 0.5),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Display post image if available
                if (post['mediaUrl'] != null &&
                    post['mediaUrl'].toString().isNotEmpty)
                  ClipRRect(
                    child: Image.network(
                      post['mediaUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: lightBlue,
                          child: Icon(
                            Icons.broken_image,
                            color: yellow.withOpacity(0.7),
                            size: 40,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: lightBlue,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(yellow),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  // Placeholder for posts without images
                  Container(
                    color: lightBlue,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.text_fields,
                            color: yellow.withOpacity(0.7),
                            size: 30,
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Text Post',
                            style: TextStyle(
                              color: yellow.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Overlay for interaction indicators
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (post['likes'] != null &&
                          (post['likes'] as List).isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.favorite, color: Colors.red, size: 12),
                              SizedBox(width: 2),
                              Text(
                                '${(post['likes'] as List).length}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(width: 3),
                      if (post['comments'] != null &&
                          (post['comments'] as List).isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.comment, color: Colors.blue, size: 12),
                              SizedBox(width: 2),
                              Text(
                                '${(post['comments'] as List).length}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaggedPosts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_pin_outlined, size: 80, color: Colors.grey[600]),
          SizedBox(height: 20),
          Text(
            'No tagged posts',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Posts where you\'re tagged will appear here',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showPostDetails(dynamic post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: darkBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            constraints:
                BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Post Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: lightBlue,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: TextStyle(color: yellow, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (post['interestTags'] != null &&
                              (post['interestTags'] as List).isNotEmpty)
                            Text(
                              (post['interestTags'] as List).join(', '),
                              style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                // Post Image or Content
                if (post['mediaUrl'] != null && post['mediaUrl'].toString().isNotEmpty)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        post['mediaUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: lightBlue,
                            child: Icon(Icons.broken_image, color: yellow, size: 60),
                          );
                        },
                      ),
                    ),
                  )
                else
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(Icons.text_fields, color: yellow, size: 40),
                    ),
                  ),
                SizedBox(height: 15),

                // Post Content
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    post['content'] ?? 'No content',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                SizedBox(height: 15),

                // Post Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red, size: 20),
                        SizedBox(width: 5),
                        Text(
                          '${post['likes'] != null ? (post['likes'] as List).length : 0}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.comment, color: yellow, size: 20),
                        SizedBox(width: 5),
                        Text(
                          '${post['comments'] != null ? (post['comments'] as List).length : 0}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.share_outlined, color: yellow),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                // Close button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close', style: TextStyle(color: yellow)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
