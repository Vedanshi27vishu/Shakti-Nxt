import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  static const String baseUrl = 'http://65.2.82.85:5000/api';

  // Get auth token from shared preferences
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get headers with authorization
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Debug function to test API connectivity
  static Future<void> testApiConnectivity() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/post/Interestfeed'),
        headers: headers,
      );
      print('API Test Response: Status ${response.statusCode}');
      print('Response Body: ${response.body}');
    } catch (e) {
      print('API Test Error: $e');
    }
  }

  // Get posts by interest
  static Future<List<PostModel>> getPostsByInterest() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/post/Interestfeed'),
        headers: headers,
      );

      print('Get Posts Response: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        List<dynamic> jsonData;
        if (responseData is List) {
          jsonData = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          jsonData = responseData['data'];
        } else if (responseData is Map && responseData.containsKey('posts')) {
          jsonData = responseData['posts'];
        } else {
          throw Exception('Unexpected response format');
        }

        return jsonData.map((json) => PostModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load posts: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching posts: $e');
      throw Exception('Error fetching posts: $e');
    }
  }

  // Like/Unlike a post - Returns updated post data
  static Future<PostModel?> likePost(String postId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/post/L/$postId'),
        headers: headers,
      );

      print('Like Response: Status ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['post'] != null) {
          return PostModel.fromJson(responseData['post']);
        }
      }

      throw Exception('Failed to like post: ${response.statusCode}');
    } catch (e) {
      print('Error liking post: $e');
      throw Exception('Error liking post: $e');
    }
  }

  // Comment on a post - Returns updated post data
  // Comment on a post - Returns updated post data
  static Future<PostModel?> commentOnPost(
      String postId, String commentText) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/post/C/$postId'),
        headers: headers,
        body: json.encode({'text': commentText}),
      );

      print('Comment Response: Status ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Check different possible response structures
        if (responseData['post'] != null) {
          return PostModel.fromJson(responseData['post']);
        } else if (responseData['data'] != null) {
          return PostModel.fromJson(responseData['data']);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('_id')) {
          // Direct post object
          return PostModel.fromJson(responseData);
        }

        // If no post data returned, return null to indicate success without updated data
        return null;
      }

      throw Exception(
          'Failed to comment: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Error commenting: $e');
      throw Exception('Error commenting: $e');
    }
  }

// Update a comment
  static Future<PostModel?> updateComment(
      String postId, String commentId, String updatedText) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/post/$postId/comments/$commentId'),
        headers: headers,
        body: json.encode({'text': updatedText}),
      );

      print('Update Comment Response: Status ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['post'] != null) {
          return PostModel.fromJson(responseData['post']);
        }
      }

      throw Exception(
          'Failed to update comment: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Error updating comment: $e');
      throw Exception('Error updating comment: $e');
    }
  }

// Delete a comment
  static Future<PostModel?> deleteComment(
      String postId, String commentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/post/$postId/comments/$commentId'),
        headers: headers,
      );

      print('Delete Comment Response: Status ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // For delete, we might not get the full post back, so fetch it
        return await getPostsByInterest().then((posts) => posts.firstWhere(
            (p) => p.id == postId,
            orElse: () => throw Exception('Post not found')));
      }

      throw Exception(
          'Failed to delete comment: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Error deleting comment: $e');
      throw Exception('Error deleting comment: $e');
    }
  }

  // Create a new post
  static Future<bool> createPost(String content, {String? mediaUrl}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/post/create'),
        headers: headers,
        body: json.encode({
          'content': content,
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
        }),
      );

      print('Create Post Response: Status ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Failed to create post: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error creating post: $e');
      throw Exception('Error creating post: $e');
    }
  }
}

// FIXED Post Model with better error handling and null safety
class PostModel {
  final String id;
  final String userId;
  final String userFullName;
  final String content;
  final String? mediaUrl;
  final List<String> interestTags;
  final List<String> likes;
  final List<CommentModel> comments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final int commentsCount;

  PostModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.content,
    this.mediaUrl,
    required this.interestTags,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
    required this.likesCount,
    required this.commentsCount,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    try {
      // Debug print to see the actual JSON structure
      print('Parsing PostModel from JSON: $json');

      // Handle likes array safely
      List<String> likesList = [];
      if (json['likes'] != null) {
        if (json['likes'] is List) {
          likesList = (json['likes'] as List).map((e) => e.toString()).toList();
        }
      }

      // Handle comments array safely
      List<CommentModel> commentsList = [];
      if (json['comments'] != null) {
        if (json['comments'] is List) {
          commentsList = (json['comments'] as List)
              .where((c) => c != null)
              .map((c) {
                try {
                  return CommentModel.fromJson(c as Map<String, dynamic>);
                } catch (e) {
                  print('Error parsing comment: $e, Comment data: $c');
                  return null;
                }
              })
              .where((c) => c != null)
              .cast<CommentModel>()
              .toList();
        }
      }

      // Handle interest tags safely
      List<String> interestTagsList = [];
      if (json['interestTags'] != null) {
        if (json['interestTags'] is List) {
          interestTagsList =
              (json['interestTags'] as List).map((e) => e.toString()).toList();
        }
      }

      // Parse dates safely
      DateTime createdAtDate = DateTime.now();
      DateTime updatedAtDate = DateTime.now();

      try {
        if (json['createdAt'] != null) {
          createdAtDate = DateTime.parse(json['createdAt'].toString());
        }
      } catch (e) {
        print('Error parsing createdAt: $e');
      }

      try {
        if (json['updatedAt'] != null) {
          updatedAtDate = DateTime.parse(json['updatedAt'].toString());
        }
      } catch (e) {
        print('Error parsing updatedAt: $e');
      }

      return PostModel(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        userId: json['user']?.toString() ?? json['userId']?.toString() ?? '',
        userFullName: json['userFullName']?.toString() ?? 'Unknown User',
        content: json['content']?.toString() ?? '',
        mediaUrl: json['mediaUrl']?.toString(),
        interestTags: interestTagsList,
        likes: likesList,
        comments: commentsList,
        createdAt: createdAtDate,
        updatedAt: updatedAtDate,
        likesCount: _parseIntSafely(json['likesCount']) ?? likesList.length,
        commentsCount:
            _parseIntSafely(json['commentsCount']) ?? commentsList.length,
      );
    } catch (e) {
      print('Error parsing PostModel: $e');
      print('JSON Data: $json');
      // Return a default PostModel instead of throwing
      return PostModel(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        userId: '',
        userFullName: 'Unknown User',
        content: json['content']?.toString() ?? '',
        mediaUrl: null,
        interestTags: [],
        likes: [],
        comments: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
      );
    }
  }

  // Helper method to safely parse integers
  static int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  bool isLikedByCurrentUser(String currentUserId) {
    return likes.contains(currentUserId);
  }

  // Create a copy with updated data
  PostModel copyWith({
    String? id,
    String? userId,
    String? userFullName,
    String? content,
    String? mediaUrl,
    List<String>? interestTags,
    List<String>? likes,
    List<CommentModel>? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? commentsCount,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userFullName: userFullName ?? this.userFullName,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      interestTags: interestTags ?? this.interestTags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }

  // Override equality operators for better comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// FIXED Comment Model with better error handling
class CommentModel {
  final String text;
  final String postedBy;
  final DateTime createdAt;
  final String? id;

  CommentModel({
    required this.text,
    required this.postedBy,
    required this.createdAt,
    this.id,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse date safely
      DateTime commentDate = DateTime.now();
      try {
        if (json['createdAt'] != null) {
          commentDate = DateTime.parse(json['createdAt'].toString());
        }
      } catch (e) {
        print('Error parsing comment date: $e');
      }

      return CommentModel(
        text: json['text']?.toString() ?? '',
        postedBy: json['postedBy']?.toString() ?? '',
        createdAt: commentDate,
        id: json['_id']?.toString() ?? json['id']?.toString(),
      );
    } catch (e) {
      print('Error parsing CommentModel: $e');
      print('Comment JSON: $json');
      // Return a default comment instead of throwing
      return CommentModel(
        text: 'Error loading comment',
        postedBy: '',
        createdAt: DateTime.now(),
        id: null,
      );
    }
  }

  // Override equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentModel &&
        other.text == text &&
        other.postedBy == postedBy &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(text, postedBy, id);
}
