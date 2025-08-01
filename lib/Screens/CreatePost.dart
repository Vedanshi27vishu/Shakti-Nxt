import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shakti/Screens/BottomNavBar.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/Widgets/AppWidgets/CommunityPostAppBar.dart';
import 'package:shakti/Widgets/AppWidgets/ScreenHeadings.dart';
import 'package:shakti/Widgets/AppWidgets/YellowLine.dart';
import 'package:shakti/helpers/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController contentController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  File? selectedImage;
  bool isUploading = false;

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'dbiwykg29';
    const uploadPreset = 'Images';

    final mimeTypeData = lookupMimeType(imageFile.path)?.split('/');
    if (mimeTypeData == null) return null;

    final imageUploadRequest = http.MultipartRequest(
      'POST',
      Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload"),
    );

    final file = await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
    );

    imageUploadRequest.files.add(file);
    imageUploadRequest.fields['upload_preset'] = uploadPreset;

    // Remove the Authorization header (no need for unsigned upload)
    // imageUploadRequest.headers['Authorization'] = auth;

    final streamedResponse = await imageUploadRequest.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['secure_url'];
    } else {
      print("Upload failed: ${response.body}");
      return null;
    }
  }

  Future<void> createPost() async {
    final content = contentController.text.trim();
    final tags = tagsController.text.trim().split(',');

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post content is required")),
      );
      return;
    }

    setState(() => isUploading = true);

    String? mediaUrl;
    if (selectedImage != null) {
      mediaUrl = await uploadImageToCloudinary(selectedImage!);
      if (mediaUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image upload failed")),
        );
        setState(() => isUploading = false);
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to post.")),
      );
      setState(() => isUploading = false);
      return;
    }

    final response = await http.post(
      Uri.parse("http://65.2.82.85:5000/api/post/create"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "content": content,
        "mediaUrl": mediaUrl,
        "interestTags": tags,
      }),
    );

    setState(() => isUploading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post created successfully!")),
      );
      contentController.clear();
      tagsController.clear();
      setState(() => selectedImage = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create post: ${response.body}")),
      );
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => selectedImage = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = THelperFunctions.screenWidth(context);
    double screenHeight = THelperFunctions.screenHeight(context);

    // --- Added this for responsive width as in login page ---
    double contentMaxWidth;
    if (screenWidth < 600) {
      contentMaxWidth = screenWidth; // Mobile: full width
    } else if (screenWidth < 1000) {
      contentMaxWidth = 700; // Tablet: capped at 700 px
    } else {
      contentMaxWidth = 900; // Laptop/Desktop: capped at 900 px
    }
    // --------------------------------------------------------

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Scolor.primary,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Scolor.secondry),
      //     onPressed: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => BottomNavBarExample()),
      //       );
      //     },
      //   ),
      // ),
      body: Center(
        child: Container(
          width: contentMaxWidth,     // Applying the responsive width here
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              //  CustomTopBar3(),
                SizedBox(height: screenHeight * 0.015),
                Center(child: ScreenHeadings(text: "Create New Post")),
                SizedBox(height: screenHeight * 0.005),
                const Text(
                  "Add the main post details here. They'll be connected to the layout and take on the layout design.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.02),
                const Text("Post Content", style: TextStyle(color: Colors.white, fontSize: 14)),
                TextField(
                  controller: contentController,
                  maxLength: 300,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Scolor.secondry, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Scolor.secondry, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.amber, width: 3),
                    ),
                    counterStyle: const TextStyle(color: Colors.white70),
                  ),
                ),
                const Text("Interest Tags (comma-separated)", style: TextStyle(color: Colors.white, fontSize: 14)),
                TextField(
                  controller: tagsController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Scolor.secondry, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.amber, width: 3),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: screenWidth * 0.3,
                      height: screenWidth * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: selectedImage == null
                          ? const Icon(Icons.add_a_photo, color: Colors.white, size: 40)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(selectedImage!, fit: BoxFit.cover),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Scolor.secondry,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isUploading ? null : createPost,
                    child: isUploading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text("Submit Post", style: TextStyle(color: Colors.black)),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Yellowline(screenWidth: screenWidth),
                SizedBox(height: screenHeight * 0.02),
                const Text(
                  "Previous Posts",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
