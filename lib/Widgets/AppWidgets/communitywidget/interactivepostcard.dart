import 'package:flutter/material.dart';
import 'package:shakti/Screens/fullcommentpage.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/Widgets/AppWidgets/communitywidget/postservice.dart';
import 'package:shakti/Widgets/AppWidgets/communitywidget/authhelper.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final Function(String)? onComment;
  final Function(PostModel)? onPostUpdated;

  const PostCard({
    super.key,
    required this.post,
    this.onComment,
    this.onPostUpdated,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _showCommentField = false;
  String? currentUserId;
  late PostModel _currentPost;
  bool _isLiking = false;
  bool _isCommenting = false;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _getCurrentUserId();
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post != widget.post) {
      setState(() {
        _currentPost = widget.post;
      });
    }
  }

  Future<void> _getCurrentUserId() async {
    try {
      final userId = await AuthHelper.getUserId();
      if (mounted) {
        setState(() {
          currentUserId = userId;
        });
      }
    } catch (e) {
      debugPrint('Error getting current user ID: $e');
    }
  }

Future<void> _handleLike() async {
  if (_isLiking || currentUserId == null) return;

  // Optimistic update - update UI immediately
  final bool wasLiked = _currentPost.isLikedByCurrentUser(currentUserId!);
  final List<String> newLikes = List<String>.from(_currentPost.likes);
  
  if (wasLiked) {
    newLikes.remove(currentUserId!);
  } else {
    newLikes.add(currentUserId!);
  }

  setState(() {
    _isLiking = true;
    _currentPost = _currentPost.copyWith(
      likes: newLikes,
      likesCount: newLikes.length,
    );
  });

  try {
    final updatedPost = await PostService.likePost(_currentPost.id);
    
    if (updatedPost != null && mounted) {
      setState(() {
        _currentPost = updatedPost.copyWith(
          userFullName: _currentPost.userFullName,
        );
      });

      // Notify parent to update the post in the list
      widget.onPostUpdated?.call(_currentPost);
    }
  } catch (e) {
    debugPrint('Error liking post: $e');
    
    // Revert optimistic update on error
    if (mounted) {
      setState(() {
        _currentPost = _currentPost.copyWith(
          likes: _currentPost.likes,
          likesCount: _currentPost.likes.length,
        );
      });
      _showErrorSnackBar('Failed to like post');
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLiking = false;
      });
    }
  }
}

Future<void> _handleComment(String commentText) async {
  if (_isCommenting || currentUserId == null || commentText.trim().isEmpty) return;

  setState(() {
    _isCommenting = true;
  });

  try {
    final updatedPost = await PostService.commentOnPost(_currentPost.id, commentText.trim());
    
    if (mounted) {
      if (updatedPost != null) {
        // Use the updated post data from server
        setState(() {
          _currentPost = updatedPost.copyWith(
            userFullName: _currentPost.userFullName,
          );
          _commentController.clear();
          _showCommentField = false;
        });
      } else {
        // If no updated post returned, just refresh the UI
        setState(() {
          _commentController.clear();
          _showCommentField = false;
        });
        // Trigger a refresh from parent component
        widget.onComment?.call(commentText.trim());
      }

      // Remove focus from comment field
      _commentFocusNode.unfocus();
      
      // Only call onPostUpdated if we have updated data
      if (updatedPost != null) {
        widget.onPostUpdated?.call(_currentPost);
      }
    }
  } catch (e) {
    if (mounted) {
      _showErrorSnackBar('Failed to add comment: $e');
    }
  } finally {
    if (mounted) {
      setState(() {
        _isCommenting = false;
      });
    }
  }
}
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _submitComment() {
    final commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      _handleComment(commentText);
    }
  }

  void _toggleCommentField() {
    setState(() {
      _showCommentField = !_showCommentField;
    });
    
    if (_showCommentField) {
      // Focus the comment field when it's shown
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _commentFocusNode.requestFocus();
      });
    }
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Scolor.primary,
      child: Text(
        _currentPost.userFullName.isNotEmpty
            ? _currentPost.userFullName[0].toUpperCase()
            : 'U',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPostHeader() {
    return Row(
      children: [
        _buildUserAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentPost.userFullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Text(
          _currentPost.getTimeAgo(),
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  void _showEditCommentDialog(CommentModel comment) {
  final TextEditingController editController = TextEditingController(text: comment.text);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Comment'),
      content: TextField(
        controller: editController,
        decoration: const InputDecoration(
          hintText: 'Edit your comment...',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final updatedText = editController.text.trim();
            if (updatedText.isNotEmpty && comment.id != null) {
              Navigator.pop(context);
              await _updateComment(comment.id!, updatedText);
            }
          },
          child: const Text('Update'),
        ),
      ],
    ),
  );
}

void _showDeleteCommentDialog(CommentModel comment) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Comment'),
      content: const Text('Are you sure you want to delete this comment?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (comment.id != null) {
              Navigator.pop(context);
              await _deleteComment(comment.id!);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

Future<void> _updateComment(String commentId, String updatedText) async {
  try {
    final updatedPost = await PostService.updateComment(_currentPost.id, commentId, updatedText);
    
    if (updatedPost != null && mounted) {
      setState(() {
        _currentPost = updatedPost.copyWith(
          userFullName: _currentPost.userFullName,
        );
      });
      widget.onPostUpdated?.call(_currentPost);
    }
  } catch (e) {
    _showErrorSnackBar('Failed to update comment: $e');
  }
}

Future<void> _deleteComment(String commentId) async {
  try {
    final updatedPost = await PostService.deleteComment(_currentPost.id, commentId);
    
    if (updatedPost != null && mounted) {
      setState(() {
        _currentPost = updatedPost.copyWith(
          userFullName: _currentPost.userFullName,
        );
      });
      widget.onPostUpdated?.call(_currentPost);
    }
  } catch (e) {
    _showErrorSnackBar('Failed to delete comment: $e');
  }
}

  Widget _buildPostContent() {
    return Text(
      _currentPost.content,
      style: const TextStyle(
        fontSize: 14,
        height: 1.4,
      ),
    );
  }

  Widget _buildMediaContent() {
    if (_currentPost.mediaUrl == null || _currentPost.mediaUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _currentPost.mediaUrl!,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: Colors.grey[100],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  valueColor: AlwaysStoppedAnimation<Color>(Scolor.primary),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Image failed to load', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterestTags() {
    if (_currentPost.interestTags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: _currentPost.interestTags.map((tag) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Scolor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tag.startsWith('#') ? tag : '#$tag',
              style: TextStyle(
                color: Scolor.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionBar() {
    final bool isLiked = currentUserId != null && _currentPost.likes.contains(currentUserId!);
    
    // Debug prints
    debugPrint('Current User ID: $currentUserId');
    debugPrint('Post Likes: ${_currentPost.likes}');
    debugPrint('Is Liked: $isLiked');
    debugPrint('Likes Count: ${_currentPost.likesCount}');

    return Row(
      children: [
        // Like button
        InkWell(
          onTap: _isLiking ? null : _handleLike,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _isLiking
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isLiked ? Colors.red : Colors.grey[600]!,
                          ),
                        ),
                      )
                    : Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey[600],
                        size: 20,
                      ),
                const SizedBox(width: 4),
                Text(
                  '${_currentPost.likesCount}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Comment button
        InkWell(
          onTap: _toggleCommentField,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Icon(
                  _showCommentField ? Icons.chat_bubble : Icons.chat_bubble_outline,
                  color: _showCommentField ? Scolor.primary : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_currentPost.commentsCount}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput() {
    if (!_showCommentField) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Scolor.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              enabled: !_isCommenting,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isCommenting ? null : _submitComment,
            icon: _isCommenting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Scolor.primary),
                    ),
                  )
                : Icon(
                    Icons.send,
                    color: Scolor.primary,
                  ),
          ),
        ],
      ),
    );
  }

 Widget _buildCommentsList() {
  if (_currentPost.comments.isEmpty) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments (${_currentPost.comments.length}):',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        ..._currentPost.comments.take(3).map((comment) {
          final bool isCurrentUserComment = comment.postedBy == currentUserId;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          comment.text,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      if (isCurrentUserComment)
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditCommentDialog(comment);
                            } else if (value == 'delete') {
                              _showDeleteCommentDialog(comment);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          child: Icon(
                            Icons.more_vert,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isCurrentUserComment ? 'You' : 'User',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _getCommentTimeAgo(comment.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        if (_currentPost.comments.length > 3)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentsScreen(
                    post: _currentPost,
                    onPostUpdated: (updatedPost) {
                      setState(() {
                        _currentPost = updatedPost;
                      });
                      widget.onPostUpdated?.call(updatedPost);
                    },
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'View all ${_currentPost.comments.length} comments',
                style: TextStyle(
                  color: Scolor.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(),
            const SizedBox(height: 12),
            _buildPostContent(),
            _buildMediaContent(),
            _buildInterestTags(),
            const SizedBox(height: 12),
            _buildActionBar(),
            _buildCommentInput(),
            _buildCommentsList(),
          ],
        ),
      ),
    );
  }

  String _getCommentTimeAgo(DateTime commentTime) {
    final now = DateTime.now();
    final diff = now.difference(commentTime);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }
}

