import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shakti/Screens/chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  List<User> users = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  void dispose() {
    // Cancel any ongoing operations here if needed
    super.dispose();
  }

  Future<void> fetchUsers() async {
    try {
      if (!mounted) return;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Authentication token not found. Please login.';
          isLoading = false;
        });
        return;
      }

      if (!mounted) return;

      final response = await http.post(
        Uri.parse('http://65.2.82.85:5000/api/followers_following'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<User> allUsers = [];

        if (data['followers'] != null) {
          for (var follower in data['followers']) {
            if (follower['userId'] != null && follower['fullName'] != null) {
              allUsers.add(User.fromJson(follower));
            }
          }
        }

        if (data['following'] != null) {
          for (var following in data['following']) {
            if (following['userId'] != null && following['fullName'] != null) {
              allUsers.add(User.fromJson(following));
            }
          }
        }

        if (!mounted) return;
        setState(() {
          users = allUsers;
          isLoading = false;
          errorMessage = '';
        });
      } else if (response.statusCode == 401) {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Authentication failed. Please login.';
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Failed to load users (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void navigateToChat(String userId, String fullName) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          recipientUserId: userId,
          recipientName: fullName,
        ),
      ),
    );
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // --- Responsive width logic ---
    double contentMaxWidth;
    if (screenWidth < 600) {
      contentMaxWidth = screenWidth; // Phone: full width
    } else if (screenWidth < 1000) {
      contentMaxWidth = 700; // Tablet: max width
    } else {
      contentMaxWidth = 900; // Laptop/Desktop: max width
    }
    // -------------------------------------

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Users'),
      //   backgroundColor: const Color(0xFF1E3A8A), // Dark blue
      //   foregroundColor: Colors.white,
      //   elevation: 2,
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Center(
          child: Container(
            width: contentMaxWidth,
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading users...',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red[400]),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage,
                              style: TextStyle(
                                  color: Colors.red[600], fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (!mounted) return;
                                safeSetState(() {
                                  isLoading = true;
                                  errorMessage = '';
                                });
                                fetchUsers();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF1E3A8A), // Dark blue
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : users.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline,
                                    size: 64, color: Colors.grey[600]),
                                const SizedBox(height: 16),
                                Text(
                                  'No users found',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: fetchUsers,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Card(
                                    elevation: 3,
                                    shadowColor: Colors.grey.withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                      leading: CircleAvatar(
                                        radius: 25,
                                        backgroundColor:
                                            const Color(0xFFFBBF24),
                                        child: Text(
                                          user.fullName.isNotEmpty
                                              ? user.fullName[0]
                                                  .toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            color:
                                                Color(0xFF1E3A8A),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        user.fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'ID: ${user.userId}',
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 12,
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.chat_bubble_outline,
                                        color: const Color(0xFF1E3A8A),
                                        size: 20,
                                      ),
                                      onTap: () => navigateToChat(
                                          user.userId, user.fullName),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ),
      ),
    );
  }
}

class User {
  final String userId;
  final String fullName;

  User({required this.userId, required this.fullName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
    );
  }
}
