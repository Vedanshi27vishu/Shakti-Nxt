import 'package:flutter/material.dart';
import 'package:shakti/Screens/CreatePost.dart';
import 'package:shakti/Screens/Mentors.dart';
import 'package:shakti/Screens/followers.dart';
import 'package:shakti/Screens/userprofile.dart';
import 'package:shakti/Widgets/AppWidgets/ScreenHeadings.dart';
import 'package:shakti/Widgets/AppWidgets/communitywidget/authhelper.dart';
import 'package:shakti/Widgets/AppWidgets/communitywidget/interactivepostcard.dart';
import 'package:shakti/Widgets/AppWidgets/communitywidget/postservice.dart';
import 'package:shakti/helpers/helper_functions.dart';
import 'package:shakti/Utils/constants/colors.dart';

class CommunityHomeScreen extends StatefulWidget {
  const CommunityHomeScreen({super.key});

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen>
    with SingleTickerProviderStateMixin {
  List<PostModel> posts = [];
  bool isLoading = true;
  String errorMessage = '';
  bool showDebugInfo = false;
  bool isCommenting = false;

  // Tab/Slider related variables
  late TabController _tabController;
  late PageController _pageController;
  int _currentIndex = 0;

  final List<Tab> _tabs = [
    const Tab(icon: Icon(Icons.home), text: "Home"),
    const Tab(icon: Icon(Icons.group), text: "Follow"),
    const Tab(icon: Icon(Icons.add), text: "Create"),
    const Tab(icon: Icon(Icons.message), text: "Messages"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _pageController = PageController(initialPage: 0);

    // Listen to tab controller changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Animate to the selected page when tab is tapped
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    _initializeScreen();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Handle page view changes
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Update tab controller without triggering listener
    _tabController.animateTo(index);
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = THelperFunctions.screenHeight(context);
    return Scaffold(
      backgroundColor: Scolor.primary,
      body: CustomScrollView(
        slivers: [
          // SliverAppBar with tab navigation
          SliverAppBar(
            backgroundColor: Scolor.primary,
            elevation: 0,
            pinned: true,
            floating: false,
            expandedHeight: 120.0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Scolor.primary,
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    // Tab indicator
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        labelColor: Scolor.primary,
                        unselectedLabelColor: Colors.white,
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                        tabs: _tabs,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content with PageView for sliding
          SliverFillRemaining(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildHomeContent(screenHeight),
                _buildFollowUsersContent(),
                _buildCreatePostContent(),
                _buildMessagesContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Home content (Posts)
  Widget _buildHomeContent(double screenHeight) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with Posts title and Profile button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
            child: _buildHeader(screenHeight),
          ),

          // Debug info (if enabled)
          if (showDebugInfo)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
              child: _buildDebugInfo(),
            ),

          // Posts content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
            child: _buildPostsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenHeight) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = _getMaxWidth(constraints.maxWidth);

        return Container(
          width: maxWidth,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ScreenHeadings(text: _getHeaderTitle()),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserProfileScreen(),
                    ),
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
    );
  }

  String _getHeaderTitle() {
    switch (_currentIndex) {
      case 0:
        return "Posts";
      case 1:
        return "Follow Users";
      case 2:
        return "Create Post";
      case 3:
        return "Messages";
      default:
        return "Posts";
    }
  }

  Widget _buildDebugInfo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = _getMaxWidth(constraints.maxWidth, isDebug: true);

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
              Text('Current Tab: $_currentIndex',
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              Text('Loading: $isLoading',
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              Text('Posts Count: ${posts.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              Text('Error: $errorMessage',
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
              ElevatedButton(
                  onPressed: AuthHelper.debugAuthData,
                  child: const Text('Log Auth Data')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostsContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = _getMaxWidth(constraints.maxWidth, isPost: true);

        return Center(
          child: Container(
            width: maxWidth,
            padding: EdgeInsets.symmetric(horizontal: maxWidth < 600 ? 0 : 16),
            child: _buildPostsList(maxWidth),
          ),
        );
      },
    );
  }

  Widget _buildFollowUsersContent() {
    return FollowUsersScreen(); //
  }

  Widget _buildCreatePostContent() {
    return CreatePostScreen(); //
  }

  Widget _buildMessagesContent() {
    return UsersListScreen();
  }

  double _getMaxWidth(double availableWidth,
      {bool isDebug = false, bool isPost = false}) {
    if (availableWidth < 600) {
      return availableWidth;
    } else if (availableWidth < 1000) {
      return isDebug ? 700 : (isPost ? 700 : 600);
    } else {
      return isDebug ? 900 : (isPost ? 900 : 700);
    }
  }

  Widget _buildPostsList(double containerWidth) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
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
      return const Center(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
