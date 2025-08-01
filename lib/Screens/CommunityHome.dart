import 'package:flutter/material.dart';
import 'package:shakti/Screens/CreatePost.dart';
import 'package:shakti/Screens/Mentors.dart';
import 'package:shakti/Screens/followers.dart';
import 'package:shakti/Screens/userprofile.dart';
import 'package:shakti/Widgets/AppWidgets/ScreenHeadings.dart';
import 'package:shakti/Widgets/AppWidgets/communitywidget/authhelper.dart';
import 'package:shakti/Widgets/AppWidgets/communitywidget/interactivepostcard.dart'; // Assume PostCard
import 'package:shakti/Widgets/AppWidgets/communitywidget/postservice.dart';
import 'package:shakti/helpers/helper_functions.dart';
import 'package:shakti/Utils/constants/colors.dart';
class CommunityHomeScreen extends StatefulWidget {
  const CommunityHomeScreen({super.key});

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen> {
  List<PostModel> posts = [];
  bool isLoading = true;
  String errorMessage = '';
  bool showDebugInfo = false;
  bool isCommenting = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await AuthHelper.debugAuthData();
    final isLoggedIn = await AuthHelper.isLoggedIn();

    if (!isLoggedIn) {
      if (mounted) {
        setState(() {
          errorMessage = 'User not logged in. Please login first.';
          isLoading = false;
        });
      }
      return;
    }

    await _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      if (!mounted) return;
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
      final fetchedPosts = await PostService.getPostsByInterest();
      if (!mounted) return;
      setState(() {
        posts = fetchedPosts;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _onCommentPost(String postId, String comment) async {
    if (isCommenting) return;
    isCommenting = true;
    if (mounted) setState(() {});

    try {
      await PostService.commentOnPost(postId, comment);
      final updatedPosts = await PostService.getPostsByInterest();
      final updatedPost = updatedPosts.firstWhere((p) => p.id == postId);
      _updatePostInList(updatedPost);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to comment: $e')));
      }
    } finally {
      isCommenting = false;
      if (mounted) setState(() {});
    }
  }

  void _updatePostInList(PostModel updatedPost) {
    if (!mounted) return;
    setState(() {
      final index = posts.indexWhere((post) => post.id == updatedPost.id);
      if (index != -1) {
        posts[index] = updatedPost;
      }
    });
  }

  // Widget for SliverAppBar icon+text navigation button
  Widget _buildIconTextButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: Colors.white),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = THelperFunctions.screenHeight(context);

    return Scaffold(
      backgroundColor: Scolor.primary,
      body: CustomScrollView(
        slivers: [
          // --- SliverAppBar on top ---
          SliverAppBar(
            backgroundColor: Scolor.primary,
            pinned: true,
            floating: true,
            snap: false,
            elevation: 2,
            title: const Text('Community', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                color: Scolor.primary,
                padding: const EdgeInsets.symmetric(vertical: 6),
                height: 56,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildIconTextButton(context, Icons.home, "Home", () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CommunityHomeScreen()));
                      }),
                      _buildIconTextButton(context, Icons.group, "Followers", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowUsersScreen()));
                      }),
                      _buildIconTextButton(context, Icons.add, "Add Post", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen()));
                      }),
                      _buildIconTextButton(context, Icons.message, "Chat", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersListScreen()));
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Your existing content below as a single sliver ---
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double maxWidth;
                      if (constraints.maxWidth < 600) {
                        maxWidth = constraints.maxWidth;
                      } else if (constraints.maxWidth < 1000) {
                        maxWidth = 600;
                      } else {
                        maxWidth = 700;
                      }

                      return Container(
                        width: maxWidth,
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const ScreenHeadings(text: "Posts"),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UserProfileScreen()),
                                );
                              },
                              child: Text(
                                "Profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: maxWidth < 600 ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (showDebugInfo)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double maxWidth;
                        if (constraints.maxWidth < 600) {
                          maxWidth = constraints.maxWidth;
                        } else if (constraints.maxWidth < 1000) {
                          maxWidth = 700;
                        } else {
                          maxWidth = 900;
                        }

                        return Container(
                          width: maxWidth,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('DEBUG INFO:',
                                  style: TextStyle(
                                      color: Colors.yellow, fontWeight: FontWeight.bold)),
                              Text('Loading: $isLoading',
                                  style:
                                      const TextStyle(color: Colors.white, fontSize: 12)),
                              Text('Posts Count: ${posts.length}',
                                  style:
                                      const TextStyle(color: Colors.white, fontSize: 12)),
                              Text('Error: $errorMessage',
                                  style: const TextStyle(color: Colors.red, fontSize: 12)),
                              ElevatedButton(
                                  onPressed: AuthHelper.debugAuthData,
                                  child: const Text('Log Auth Data')),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                // The post list
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double maxWidth;
                      if (constraints.maxWidth < 600) {
                        maxWidth = constraints.maxWidth;
                      } else if (constraints.maxWidth < 1000) {
                        maxWidth = 700;
                      } else {
                        maxWidth = 900;
                      }

                      return Center(
                        child: Container(
                          width: maxWidth,
                          padding: EdgeInsets.symmetric(horizontal: maxWidth < 600 ? 0 : 16),
                          child: _buildPostsList(maxWidth),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(double containerWidth) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Error loading posts',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  errorMessage,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadPosts, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (posts.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.post_add, color: Colors.white, size: 48),
              SizedBox(height: 16),
              Text('No posts available',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              Text('Be the first to create a post!',
                  style: TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Padding(
            padding: EdgeInsets.only(bottom: containerWidth * 0.02),
            child: PostCard(
              post: post,
              onComment: (comment) => _onCommentPost(post.id, comment),
              onPostUpdated: _updatePostInList,
            ),
          );
        },
      ),
    );
  }
}
