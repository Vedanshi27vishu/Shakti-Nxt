import 'package:flutter/material.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/Widgets/AppWidgets/communitywidget/postservice.dart';
import 'package:shakti/Widgets/AppWidgets/communitywidget/authhelper.dart';

class CommentsScreen extends StatefulWidget {
  final PostModel post;
  final Function(PostModel)? onPostUpdated;

  const CommentsScreen({
    super.key,
    required this.post,
    this.onPostUpdated,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  late PostModel _currentPost;
  String? currentUserId;
  bool _isCommenting = false;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _getCurrentUserId();
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

  Future<void> _handleComment(String commentText) async {
    if (_isCommenting || currentUserId == null || commentText.trim().isEmpty) return;

    setState(() {
      _isCommenting = true;
    });

    try {
      final updatedPost = await PostService.commentOnPost(_currentPost.id, commentText.trim());
      
      if (updatedPost != null && mounted) {
        setState(() {
          _currentPost = updatedPost.copyWith(
            userFullName: _currentPost.userFullName,
          );
          _commentController.clear();
        });

        // Notify parent about the updated post
        widget.onPostUpdated?.call(_currentPost);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCommenting = false;
        });
      }
    }
  }

  // ADD THIS: Edit comment dialog
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

  // ADD THIS: Delete comment dialog
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

  // ADD THIS: Update comment function
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
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update comment: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ADD THIS: Delete comment function
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
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete comment: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _submitComment() {
    final commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      _handleComment(commentText);
    }
  }

  Widget _buildPostSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Scolor.primary,
                child: Text(
                  _currentPost.userFullName.isNotEmpty
                      ? _currentPost.userFullName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentPost.userFullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
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
          ),
          const SizedBox(height: 8),
          Text(
            _currentPost.content.length > 100 
                ? '${_currentPost.content.substring(0, 100)}...'
                : _currentPost.content,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  // UPDATE THIS: Modified comment item with edit/delete options
  Widget _buildCommentItem(CommentModel comment, int index) {
    final bool isCurrentUser = comment.postedBy == currentUserId;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Scolor.primary.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? Scolor.primary.withOpacity(0.2) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isCurrentUser ? Scolor.primary : Colors.grey[400],
                child: Text(
                  isCurrentUser ? 'Y' : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCurrentUser ? 'You' : 'User ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isCurrentUser ? Scolor.primary : Colors.grey[700],
                  ),
                ),
              ),
              Text(
                _getCommentTimeAgo(comment.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
              // ADD THIS: Three-dot menu for current user's comments
              if (isCurrentUser && comment.id != null)
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
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Scolor.primary,
              child: const Text(
                'Y',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
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
                    vertical: 10,
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
                      Icons.send_rounded,
                      color: Scolor.primary,
                      size: 20,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCommentTimeAgo(DateTime commentTime) {
    final now = DateTime.now();
    final diff = now.difference(commentTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Scolor.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Comments (${_currentPost.comments.length})',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Post Summary
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildPostSummary(),
            ),
          ),
          
          // Comments List
          Expanded(
            child: _currentPost.comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No comments yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to comment!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _currentPost.comments.length,
                    itemBuilder: (context, index) {
                      final comment = _currentPost.comments[index];
                      return _buildCommentItem(comment, index);
                    },
                  ),
          ),
          
          // Comment Input
          _buildCommentInput(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}