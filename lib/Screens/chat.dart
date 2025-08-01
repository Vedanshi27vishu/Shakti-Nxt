// chat.dart
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final String recipientUserId;
  final String recipientName;
  final String? recipientAvatar;

  const ChatScreen({
    super.key,
    required this.recipientUserId,
    required this.recipientName,
    this.recipientAvatar,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late IO.Socket socket;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingAnimationController;

  String? _status;
  String? myUserId;
  List<Map<String, dynamic>> _messages = [];
  bool _hasSetupListeners = false;
  bool _isDisposed = false;
  bool _isTyping = false;
  String? _typingUserId;
  bool _isOnline = false;
  String? _replyToMessageId;
  Map<String, dynamic>? _replyToMessage;
  String? _editingMessageId;
  bool _isUploading = false;

  // Base URL for your backend
  final String baseUrl = 'http://13.233.25.114:5000';

  // Color palette
  final Color primaryColor = const Color(0xFF1E3A8A); // Dark blue
  final Color secondaryColor = const Color(0xFFFBBF24); // Yellow
  final Color backgroundColor = const Color(0xFFF8FAFC);
  final Color messageBackgroundColor = const Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    connectSocket();
    Future.delayed(const Duration(seconds: 2), () {
      _testUploadEndpoints();
    });
  }

// Add this enhanced debug version of your upload method
  Future<void> _uploadAndSendFile(String type) async {
    if (_isUploading) return;

    setState(() => _isUploading = true);

    try {
      File? file;
      String endpoint;
      String fieldName;

      if (type == 'image') {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80, // Compress image
        );
        if (pickedFile != null) {
          file = File(pickedFile.path);

          // More thorough file validation
          String fileName = pickedFile.name.toLowerCase();
          String extension = fileName.split('.').last;

          // Check if it's a supported image format
          List<String> supportedFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
          if (!supportedFormats.contains(extension)) {
            _showSnackBar(
                'Unsupported image format. Please select JPG, PNG, GIF, or WebP');
            setState(() => _isUploading = false);
            return;
          }

          // Check file size (max 10MB)
          int fileSize = await file.length();
          if (fileSize > 10 * 1024 * 1024) {
            _showSnackBar('File too large. Maximum size is 10MB');
            setState(() => _isUploading = false);
            return;
          }

          endpoint = '/api/upload/image';
          fieldName = 'image';

          print('Image details:');
          print('- Original name: ${pickedFile.name}');
          print('- Extension: $extension');
          print('- File size: ${_formatFileSize(fileSize)}');
          print('- MIME type: ${pickedFile.mimeType}');
        } else {
          setState(() => _isUploading = false);
          return;
        }
      } else {
        final FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
        );
        if (result != null && result.files.single.path != null) {
          file = File(result.files.single.path!);

          // Check file size (max 25MB for files)
          int fileSize = await file.length();
          if (fileSize > 25 * 1024 * 1024) {
            _showSnackBar('File too large. Maximum size is 25MB');
            setState(() => _isUploading = false);
            return;
          }

          endpoint = '/api/upload/file';
          fieldName = 'file';

          print('File details:');
          print('- Original name: ${result.files.single.name}');
          print('- Extension: ${result.files.single.extension}');
          print('- File size: ${_formatFileSize(fileSize)}');
        } else {
          setState(() => _isUploading = false);
          return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('Authentication token not found');
        setState(() => _isUploading = false);
        return;
      }

      final fullUrl = '$baseUrl$endpoint';
      print('Uploading to: $fullUrl');

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(fullUrl));

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'multipart/form-data';

      // Add file with explicit MIME type
      var multipartFile = await http.MultipartFile.fromPath(
        fieldName,
        file.path,
        // Explicitly set content type based on file extension
        contentType: type == 'image'
            ? MediaType(
                'image',
                file.path.split('.').last.toLowerCase() == 'png'
                    ? 'png'
                    : 'jpeg')
            : null,
      );

      request.files.add(multipartFile);

      print('Multipart file details:');
      print('- Field: ${multipartFile.field}');
      print('- Filename: ${multipartFile.filename}');
      print('- Content Type: ${multipartFile.contentType}');
      print('- Length: ${multipartFile.length}');

      // Send request with timeout
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Upload timeout after 30 seconds');
        },
      );

      final responseBody = await response.stream.bytesToString();

      print('=== UPLOAD RESPONSE DEBUG ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: $responseBody');
      print('============================');

      // Check if response is HTML (error page)
      if (responseBody.trim().startsWith('<!DOCTYPE html>') ||
          responseBody.trim().startsWith('<html') ||
          responseBody.contains('<html')) {
        print('ERROR: Received HTML response instead of JSON');

        // Extract more specific error messages
        String errorMessage = 'Server error';
        if (responseBody.contains('File type not supported')) {
          errorMessage =
              'File type not supported by server. Try JPG or PNG format.';
        } else if (responseBody.contains('Only image files are allowed')) {
          errorMessage = 'Only image files are allowed for image upload';
        } else if (responseBody.contains('File too large') ||
            responseBody.contains('413')) {
          errorMessage = 'File too large. Try a smaller file.';
        } else if (responseBody.contains('404')) {
          errorMessage = 'Upload endpoint not found';
        } else if (responseBody.contains('500')) {
          errorMessage = 'Internal server error. Please try again.';
        } else if (responseBody.contains('401') ||
            responseBody.contains('Unauthorized')) {
          errorMessage = 'Authentication failed';
        }

        _showSnackBar(errorMessage);
        setState(() => _isUploading = false);
        return;
      }

      // Try to parse JSON response
      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(responseBody);
        print('Parsed JSON response: $responseData');
      } catch (e) {
        print('JSON parsing error: $e');
        _showSnackBar('Invalid response format');
        setState(() => _isUploading = false);
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          // Send file message via socket
          final messageData = {
            'toUserId': widget.recipientUserId,
            'messageType': type,
          };

          if (type == 'image') {
            messageData['image'] = responseData['image'];
          } else {
            messageData['file'] = responseData['file'];
          }

          if (_replyToMessageId != null) {
            messageData['replyTo'] = _replyToMessageId!;
            _clearReply();
          }

          socket.emit('private-message', messageData);
          _showSnackBar(
              '${type == 'image' ? 'Image' : 'File'} uploaded successfully');
        } else {
          _showSnackBar(
              'Upload failed: ${responseData['error'] ?? responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        _showSnackBar(
            'Upload failed (${response.statusCode}): ${responseData['error'] ?? responseData['message'] ?? 'Server error'}');
      }
    } catch (e) {
      print('Upload exception: $e');
      _showSnackBar('Upload error: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _uploadFile(File file, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showSnackBar('Authentication token not found');
      return;
    }

    try {
      String endpoint =
          type == 'image' ? '/api/upload/image' : '/api/upload/file';
      String fieldName = type == 'image' ? 'image' : 'file';

      final fullUrl = '$baseUrl$endpoint';
      var request = http.MultipartRequest('POST', Uri.parse(fullUrl));

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.files
          .add(await http.MultipartFile.fromPath(fieldName, file.path));

      final response =
          await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(responseBody);
        if (responseData['success'] == true) {
          final messageData = {
            'toUserId': widget.recipientUserId,
            'messageType': type,
          };

          if (type == 'image') {
            messageData['image'] = responseData['image'];
          } else {
            messageData['file'] = responseData['file'];
          }

          if (_replyToMessageId != null) {
            messageData['replyTo'] = _replyToMessageId!;
            _clearReply();
          }

          socket.emit('private-message', messageData);
          _showSnackBar(
              '${type == 'image' ? 'Image' : 'File'} uploaded successfully');
        }
      }
    } catch (e) {
      _showSnackBar('Upload error: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _testUploadEndpoints() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('No token found for testing');
      return;
    }

    print('=== TESTING UPLOAD ENDPOINTS ===');

    // Test image endpoint
    try {
      final imageResponse = await http.get(
        Uri.parse('$baseUrl/api/upload/image'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Image endpoint GET test:');
      print('Status: ${imageResponse.statusCode}');
      print('Headers: ${imageResponse.headers}');
      print('Body: ${imageResponse.body}');
    } catch (e) {
      print('Image endpoint GET test error: $e');
    }

    // Test file endpoint
    try {
      final fileResponse = await http.get(
        Uri.parse('$baseUrl/api/upload/file'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('File endpoint GET test:');
      print('Status: ${fileResponse.statusCode}');
      print('Headers: ${fileResponse.headers}');
      print('Body: ${fileResponse.body}');
    } catch (e) {
      print('File endpoint GET test error: $e');
    }

    // Test base API endpoint
    try {
      final baseResponse = await http.get(
        Uri.parse('$baseUrl/api/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Base API endpoint test:');
      print('Status: ${baseResponse.statusCode}');
      print('Headers: ${baseResponse.headers}');
      print('Body: ${baseResponse.body}');
    } catch (e) {
      print('Base API endpoint test error: $e');
    }

    print('=== END ENDPOINT TESTING ===');
  }

  // ADD THIS METHOD - Show Snackbar
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _uploadFileFromPicker(String type) async {
    setState(() => _isUploading = true);
    File? file;
    String endpoint;
    String fieldName;

    try {
      if (type == 'image') {
        final XFile? picked =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (picked == null) {
          setState(() => _isUploading = false);
          return;
        }

        final ext = picked.name.split('.').last.toLowerCase();
        if (!(ext == 'jpg' || ext == 'jpeg' || ext == 'png')) {
          _showSnackBar('Only JPG/PNG allowed');
          setState(() => _isUploading = false);
          return;
        }

        file = File(picked.path);
        endpoint = '/api/upload/image';
        fieldName = 'image';
      } else {
        final result = await FilePicker.platform.pickFiles();
        if (result == null || result.files.single.path == null) {
          setState(() => _isUploading = false);
          return;
        }

        file = File(result.files.single.path!);
        endpoint = '/api/upload/file';
        fieldName = 'file';
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('Token missing');
        setState(() => _isUploading = false);
        return;
      }

      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json';

      final mimeType = lookupMimeType(file.path);
      request.files.add(await http.MultipartFile.fromPath(
        fieldName,
        file.path,
        contentType: mimeType != null
            ? MediaType.parse(mimeType)
            : MediaType('application', 'octet-stream'),
      ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          // Optimistically add the message to the UI
          final tempMessage = {
            'id': DateTime.now()
                .millisecondsSinceEpoch
                .toString(), // Temporary ID
            'from': myUserId,
            'message': null,
            'messageType': type,
            'file': type == 'file' ? data['file'] : null,
            'image': type == 'image' ? data['image'] : null,
            'timestamp': DateTime.now().toIso8601String(),
            'seen': false,
            'edited': false,
            'deleted': false,
            'reactions': [],
          };

          safeSetState(() {
            _messages.add(tempMessage);
          });
          _scrollToBottom();

          final message = {
            'toUserId': widget.recipientUserId,
            'messageType': type,
            if (type == 'image') 'image': data['image'],
            if (type == 'file') 'file': data['file'],
          };

          socket.emit('private-message', message);

          _showSnackBar('${type == 'image' ? 'Image' : 'File'} uploaded');
        } else {
          _showSnackBar('Upload failed');
        }
      } else {
        _showSnackBar('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Upload error: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

// Add this method to show image source selection
  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isUploading) return;

    setState(() => _isUploading = true);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        // Validate file extension
        String fileName = pickedFile.name.toLowerCase();
        if (!fileName.endsWith('.jpg') &&
            !fileName.endsWith('.jpeg') &&
            !fileName.endsWith('.png') &&
            !fileName.endsWith('.gif') &&
            !fileName.endsWith('.webp')) {
          _showSnackBar(
              'Please select a valid image file (jpg, png, gif, webp)');
          setState(() => _isUploading = false);
          return;
        }

        await _uploadFile(File(pickedFile.path), 'image');
      } else {
        setState(() => _isUploading = false);
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
      setState(() => _isUploading = false);
    }
  }

  // ADD THIS METHOD - Clear Reply
  void _clearReply() {
    setState(() {
      _replyToMessageId = null;
      _replyToMessage = null;
    });
  }

  // ADD THIS METHOD - Start Reply
  void _startReply(Map<String, dynamic> message) {
    setState(() {
      _replyToMessageId = message['id'];
      _replyToMessage = message;
    });
  }

  // ADD THIS METHOD - Start Edit
  void _startEdit(Map<String, dynamic> message) {
    setState(() {
      _editingMessageId = message['id'];
      _editController.text = message['message'] ?? '';
    });
  }

  // ADD THIS METHOD - Save Edit
  void _saveEdit() {
    if (_editingMessageId == null || _editController.text.trim().isEmpty)
      return;

    socket.emit('edit-message', {
      'messageId': _editingMessageId,
      'newMessage': _editController.text.trim(),
    });

    _cancelEdit();
  }

  // ADD THIS METHOD - Cancel Edit
  void _cancelEdit() {
    setState(() {
      _editingMessageId = null;
      _editController.clear();
    });
  }

  // ADD THIS METHOD - Delete Message
  void _deleteMessage(Map<String, dynamic> message, String deleteFor) {
    socket.emit('delete-message', {
      'messageId': message['id'],
      'deleteFor': deleteFor,
    });
  }

  // ADD THIS METHOD - Add Reaction
  void _addReaction(Map<String, dynamic> message, String emoji) {
    socket.emit('add-reaction', {
      'messageId': message['id'],
      'emoji': emoji,
    });
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recipientUserId != oldWidget.recipientUserId) {
      if (mounted && !_isDisposed) {
        setState(() {
          _messages = [];
        });
      }
    }
  }

  void safeSetState(VoidCallback fn) {
    if (mounted && !_isDisposed) {
      setState(fn);
    }
  }

  Future<void> connectSocket() async {
    if (_isDisposed) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        safeSetState(() => _status = "⚠️ Token missing");
        return;
      }

      if (_isDisposed) return;

      final payload = token.split('.')[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      myUserId = json.decode(decoded)['userId'];

      socket = IO.io(
        'http://13.233.25.114:5000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .build(),
      );

      if (!_hasSetupListeners && !_isDisposed) {
        _setupSocketListeners();
        _hasSetupListeners = true;
      }

      if (!_isDisposed) {
        socket.connect();
      }
    } catch (e) {
      safeSetState(() => _status = "❌ Connection error: $e");
    }
  }

  void _setupSocketListeners() {
    socket.onConnect((_) {
      safeSetState(() {
        _status = "✅ Connected";
        _isOnline = true;
      });

      if (!_isDisposed) {
        socket.emit('fetch-messages', {'userId': widget.recipientUserId});
      }
    });

    socket.onDisconnect((_) {
      safeSetState(() {
        _status = "🔌 Disconnected. Reconnecting...";
        _isOnline = false;
      });

      if (!_isDisposed) {
        Future.delayed(const Duration(seconds: 3), () {
          if (!_isDisposed && !socket.connected) {
            socket.connect();
          }
        });
      }
    });

    socket.onConnectError((data) {
      safeSetState(() => _status = "❌ Connect error: $data");
    });

    // Handle old messages
    socket.on('old-messages', (data) {
      if (_isDisposed) return;

      if (data is Map && data['messages'] is List) {
        try {
          final List<Map<String, dynamic>> oldMsgs =
              (data['messages'] as List).map<Map<String, dynamic>>((msg) {
            return {
              'id': msg['_id'],
              'from': msg['senderId'],
              'message': msg['message'],
              'messageType': msg['messageType'] ?? 'text',
              'file': msg['file'],
              'image': msg['image'],
              'timestamp': msg['createdAt'] ?? msg['timestamp'],
              'seen': msg['seen'] ?? false,
              'edited': msg['edited'] ?? false,
              'editedAt': msg['editedAt'],
              'deleted': msg['deleted'] ?? false,
              'replyTo': msg['replyTo'],
              'reactions': msg['reactions'] ?? [],
            };
          }).toList();

          oldMsgs.sort((a, b) => DateTime.parse(a['timestamp'])
              .compareTo(DateTime.parse(b['timestamp'])));

          safeSetState(() {
            _messages = oldMsgs;
          });

          if (!_isDisposed) {
            _scrollToBottom();
            _markMessagesAsSeen();
          }
        } catch (e) {
          safeSetState(() => _status = "❌ Error parsing old messages: $e");
        }
      }
    });

    // Handle new messages - UPDATED
    socket.on('private-message', (data) {
      if (_isDisposed) return;

      if (data is Map) {
        try {
          final newMsg = {
            'id': data['_id'],
            'from': data['from'],
            'message': data['message'],
            'messageType': data['messageType'] ?? 'text',
            'file': data['file'],
            'image': data['image'],
            'timestamp': data['timestamp'],
            'seen': data['seen'] ?? false,
            'edited': data['edited'] ?? false,
            'editedAt': data['editedAt'],
            'deleted': data['deleted'] ?? false,
            'replyTo': data['replyTo'],
            'reactions': data['reactions'] ?? [],
          };

          bool isDuplicate = _messages.any((msg) => msg['id'] == newMsg['id']);

          if (!isDuplicate) {
            safeSetState(() {
              _messages.add(newMsg);
            });

            if (!_isDisposed) {
              _scrollToBottom();
              if (data['from'] != myUserId) {
                _markMessagesAsSeen();
              }
            }
          }
        } catch (e) {
          safeSetState(() => _status = "❌ Error processing message: $e");
        }
      }
    });

    // ADD THESE NEW SOCKET LISTENERS
    socket.on('message-edited', (data) {
      if (_isDisposed) return;

      safeSetState(() {
        final index =
            _messages.indexWhere((msg) => msg['id'] == data['messageId']);
        if (index != -1) {
          _messages[index]['message'] = data['newMessage'];
          _messages[index]['edited'] = true;
          _messages[index]['editedAt'] = data['editedAt'];
        }
      });
    });

    socket.on('message-deleted', (data) {
      if (_isDisposed) return;

      safeSetState(() {
        if (data['deletedFor'] == 'everyone') {
          final index =
              _messages.indexWhere((msg) => msg['id'] == data['messageId']);
          if (index != -1) {
            _messages[index]['deleted'] = true;
            _messages[index]['message'] = 'This message was deleted';
          }
        } else {
          _messages.removeWhere((msg) => msg['id'] == data['messageId']);
        }
      });
    });

    socket.on('reaction-added', (data) {
      if (_isDisposed) return;

      safeSetState(() {
        final index =
            _messages.indexWhere((msg) => msg['id'] == data['messageId']);
        if (index != -1) {
          _messages[index]['reactions'] = data['reactions'];
        }
      });
    });

    // Handle message seen status
    socket.on('messages-seen', (data) {
      if (_isDisposed) return;

      if (data is Map && data['byUserId'] == widget.recipientUserId) {
        safeSetState(() {
          for (var msg in _messages) {
            if (msg['from'] == myUserId) {
              msg['seen'] = true;
            }
          }
        });
      }
    });

    // Handle typing indicators
    socket.on('typing', (data) {
      if (_isDisposed) return;

      if (data is Map && data['fromUserId'] == widget.recipientUserId) {
        safeSetState(() {
          _isTyping = true;
          _typingUserId = data['fromUserId'];
        });
      }
    });

    socket.on('stop-typing', (data) {
      if (_isDisposed) return;

      if (data is Map && data['fromUserId'] == widget.recipientUserId) {
        safeSetState(() {
          _isTyping = false;
          _typingUserId = null;
        });
      }
    });
  }

  void _markMessagesAsSeen() {
    if (!_isDisposed) {
      socket.emit('message-seen', {'fromUserId': widget.recipientUserId});
    }
  }

  void sendMessage() {
    if (_isDisposed) return;

    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      final messageData = {
        'toUserId': widget.recipientUserId,
        'message': message,
      };

      if (_replyToMessageId != null) {
        messageData['replyTo'] = _replyToMessageId!;
        _clearReply();
      }

      // Add message to local UI immediately
      final tempMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        'from': myUserId,
        'message': message,
        'messageType': 'text',
        'timestamp': DateTime.now().toIso8601String(),
        'seen': false,
        'edited': false,
        'deleted': false,
        'reactions': [],
      };

      safeSetState(() {
        _messages.add(tempMessage);
      });

      socket.emit('private-message', messageData);

      _messageController.clear();
      _stopTyping();

      if (!_isDisposed) {
        _scrollToBottom();
      }
    } catch (e) {
      safeSetState(() => _status = "❌ Error sending message: $e");
    }
  }

  void _onTyping() {
    if (!_isDisposed) {
      socket.emit('typing', {'toUserId': widget.recipientUserId});
    }
  }

  void _stopTyping() {
    if (!_isDisposed) {
      socket.emit('stop-typing', {'toUserId': widget.recipientUserId});
    }
  }

  void _scrollToBottom() {
    if (_isDisposed) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && _scrollController.hasClients) {
        try {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } catch (e) {
          // Ignore scroll errors if widget is disposed
        }
      }
    });
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: messageBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Typing',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _typingAnimationController,
                builder: (context, child) {
                  return Row(
                    children: List.generate(3, (index) {
                      final delay = index * 0.2;
                      final animationValue =
                          (_typingAnimationController.value + delay) % 1.0;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        child: Transform.translate(
                          offset: Offset(
                              0,
                              -4 *
                                  (animationValue > 0.5
                                      ? 1 - animationValue
                                      : animationValue)),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMessageBubble(Map<String, dynamic> messageData) {
    String sender = messageData['from'];
    String? message = messageData['message'];
    String messageType = messageData['messageType'] ?? 'text';
    Map<String, dynamic>? file = messageData['file'];
    Map<String, dynamic>? image = messageData['image'];
    bool seen = messageData['seen'] ?? false;
    String timestamp = messageData['timestamp'];
    bool edited = messageData['edited'] ?? false;
    bool deleted = messageData['deleted'] ?? false;
    Map<String, dynamic>? replyTo = messageData['replyTo'];
    List reactions = messageData['reactions'] ?? [];

    bool isMe = sender == myUserId;

    if (deleted) {
      return _buildDeletedMessage(isMe, timestamp);
    }

    return GestureDetector(
      onLongPress: () => _showMessageOptions(messageData),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Reply preview
              if (replyTo != null) _buildReplyPreview(replyTo),

              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? primaryColor : messageBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMessageContent(
                        messageType, message, file, image, isMe),
                    if (reactions.isNotEmpty) _buildReactions(reactions),
                  ],
                ),
              ),

              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTimestamp(timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (edited) ...[
                    const SizedBox(width: 4),
                    Text(
                      'edited',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      seen ? Icons.done_all : Icons.done,
                      size: 16,
                      color: seen ? secondaryColor : Colors.grey[600],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(String messageType, String? message,
      Map<String, dynamic>? file, Map<String, dynamic>? image, bool isMe) {
    switch (messageType) {
      case 'image':
        return _buildImageMessage(image, isMe);
      case 'file':
        return _buildFileMessage(file, isMe);
      default:
        return Text(
          message ?? '',
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        );
    }
  }

  Widget _buildImageMessage(Map<String, dynamic>? image, bool isMe) {
    if (image == null || image['url'] == null) {
      return Text(
        'Image not available',
        style: TextStyle(
          color: isMe ? Colors.white70 : Colors.black54,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: image['url'],
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 200,
          height: 200,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          width: 200,
          height: 200,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildFileMessage(Map<String, dynamic>? file, bool isMe) {
    if (file == null) {
      return Text(
        'File not available',
        style: TextStyle(
          color: isMe ? Colors.white70 : Colors.black54,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        // Handle file download/open
        _openFile(file['url']);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFileIcon(file['mimeType']),
              color: isMe ? Colors.white : primaryColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file['originalName'] ?? 'Unknown file',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (file['size'] != null)
                    Text(
                      _formatFileSize(file['size']),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletedMessage(bool isMe, String timestamp) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'This message was deleted',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview(Map<String, dynamic> replyTo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: primaryColor, width: 3),
        ),
      ),
      child: Text(
        replyTo['message'] ?? 'Media message',
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 12,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildReactions(List reactions) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    Map<String, int> reactionCounts = {};
    for (var reaction in reactions) {
      String emoji = reaction['emoji'];
      reactionCounts[emoji] = (reactionCounts[emoji] ?? 0) + 1;
    }

    return Wrap(
      spacing: 4,
      children: reactionCounts.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${entry.key} ${entry.value}',
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }

  // ADD UTILITY METHODS
  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;

    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('video/')) return Icons.video_file;
    if (mimeType.startsWith('audio/')) return Icons.audio_file;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('document') || mimeType.contains('word'))
      return Icons.description;

    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _openFile(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Cannot open file');
      }
    } catch (e) {
      _showSnackBar('Error opening file: $e');
    }
  }

  void _showMessageOptions(Map<String, dynamic> message) {
    bool isMe = message['from'] == myUserId;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(context);
                  _startReply(message);
                },
              ),
              if (isMe && message['messageType'] == 'text') ...[
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _startEdit(message);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete for me'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteMessage(message, 'me');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Delete for everyone'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteMessage(message, 'everyone');
                  },
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['❤️', '👍', '😂', '😮', '😢'].map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _addReaction(message, emoji);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ADD REPLY WIDGET
  Widget _buildReplyWidget() {
    if (_replyToMessage == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          left: BorderSide(color: primaryColor, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _replyToMessage!['message'] ?? 'Media message',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[600]),
            onPressed: _clearReply,
          ),
        ],
      ),
    );
  }

  // ADD EDIT WIDGET
  Widget _buildEditWidget() {
    if (_editingMessageId == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: const Border(
          left: BorderSide(color: Colors.orange, width: 3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _editController,
              decoration: const InputDecoration(
                hintText: 'Edit message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _saveEdit(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: _saveEdit,
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[600]),
            onPressed: _cancelEdit,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return "${difference.inDays}d ago";
      } else if (difference.inHours > 0) {
        return "${difference.inHours}h ago";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes}m ago";
      } else {
        return "Just now";
      }
    } catch (e) {
      return "Now";
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    // Clean up socket listeners
    if (_hasSetupListeners) {
      try {
        socket.off('private-message');
        socket.off('old-messages');
        socket.off('messages-seen');
        socket.off('typing');
        socket.off('stop-typing');
        socket.off('message-edited'); // ADD THIS
        socket.off('message-deleted'); // ADD THIS
        socket.off('reaction-added');
        socket.off('connect');
        socket.off('disconnect');
        socket.off('connect_error');
      } catch (e) {
        // Ignore cleanup errors
      }
    }

    // Dispose socket
    try {
      if (socket.connected) {
        socket.disconnect();
      }
      socket.dispose();
    } catch (e) {
      // Ignore disposal errors
    }

    // Dispose controllers and animations
    _typingAnimationController.dispose();
    _messageController.dispose();
    _editController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _startTyping() {
    if (!_isDisposed) {
      socket.emit('typing', {'toUserId': widget.recipientUserId});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _status?.startsWith("✅") ?? false;
    final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  // Determine max width of main content based on screen size
  double contentMaxWidth;
  if (screenWidth < 600) {
    contentMaxWidth = screenWidth;           // Phones — full width
  } else if (screenWidth < 1000) {
    contentMaxWidth = 700;                   // Tablets — max width 700
  } else {
    contentMaxWidth = 900;                   // Laptops/Desktops — max width 900
  }

    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: secondaryColor,
                backgroundImage: widget.recipientAvatar != null
                    ? NetworkImage(widget.recipientAvatar!)
                    : null,
                child: widget.recipientAvatar == null
                    ? Text(
                        widget.recipientName[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipientName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                // Show more options
              },
            ),
          ],
        ),
        body: Center(
          child: Container(
              width: contentMaxWidth,
            child: Column(
              children: [
                // Status bar
                if (_status != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: isConnected ? Colors.green[100] : Colors.red[100],
                    child: Text(
                      _status!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isConnected ? Colors.green[800] : Colors.red[800],
                        fontSize: 12,
                      ),
                    ),
                  ),
            
                // Messages list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      return buildMessageBubble(_messages[index]);
                    },
                  ),
                ),
            
                // Reply widget
                _buildReplyWidget(),
            
                // Edit widget
                _buildEditWidget(),
            
                // Input area
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.attach_file, color: primaryColor),
                          onPressed: () => _uploadFileFromPicker('file'),
                        ),
                        IconButton(
                          icon: Icon(Icons.image, color: primaryColor),
                          onPressed: () => _uploadFileFromPicker('image'),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            onChanged: (text) {
                              if (text.isNotEmpty) {
                                _startTyping();
                              } else {
                                _stopTyping();
                              }
                            },
                            onSubmitted: (_) => sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: _isUploading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.send, color: Colors.white),
                            onPressed: _isUploading ? null : sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
