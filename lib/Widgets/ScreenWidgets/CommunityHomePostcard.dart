// import 'package:flutter/material.dart';
// import 'package:shakti/Utils/constants/colors.dart';
// import 'package:shakti/helpers/helper_functions.dart';

// class PostCard extends StatelessWidget {
//   final String name;
//   final String field;
//   final String time;
//   final String content;
//   final String hashtags;
//   final String? imageUrl;

//   const PostCard({
//     super.key,
//     required this.name,
//     required this.field,
//     required this.time,
//     required this.content,
//     required this.hashtags,
//     this.imageUrl,
//   });

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = THelperFunctions.screenWidth();
//     double screenHeight = THelperFunctions.screenHeight();

//     return Container(
//       margin: EdgeInsets.only(bottom: screenHeight * 0.02),
//       padding: EdgeInsets.all(screenWidth * 0.04),
//       decoration: BoxDecoration(
//         color: Scolor.primary,
//         borderRadius: BorderRadius.circular(screenWidth * 0.03),
//         border: Border.all(color: Scolor.secondry, width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// **Header: Profile + Name + Time**
//           Row(
//             children: [
//               CircleAvatar(
//                 backgroundColor: Scolor.secondry,
//                 radius: screenWidth * 0.06,
//                 child: Icon(Icons.person, color: Colors.black, size: screenWidth * 0.06),
//               ),
//               SizedBox(width: screenWidth * 0.03),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.045,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Text(
//                           "$field  •  $time",
//                           style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey),
//                         ),
//                         SizedBox(width: screenWidth * 0.01),
//                         Icon(Icons.public, color: Colors.grey, size: screenWidth * 0.04),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(Icons.more_vert, color: Colors.white, size: screenWidth * 0.05),
//             ],
//           ),

//           SizedBox(height: screenHeight * 0.015),

//           /// **Post Content**
//           Text(
//             content,
//             style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
//           ),

//           SizedBox(height: screenHeight * 0.015),

//           /// **Post Image (if available)**
//           if (imageUrl != null)
//             ClipRRect(
//               borderRadius: BorderRadius.circular(screenWidth * 0.02),
//               child: Image.asset(
//                 imageUrl!,
//                 width: double.infinity,
//                 height: screenHeight * 0.25,
//                 fit: BoxFit.cover,
//               ),
//             ),

//           SizedBox(height: screenHeight * 0.015),

//           /// **Hashtags**
//           Text(
//             hashtags,
//             style: TextStyle(
//               fontSize: screenWidth * 0.035,
//               color: Scolor.secondry,
//             ),
//           ),

//           SizedBox(height: screenHeight * 0.015),

//           /// **Interaction Buttons (Compact & Responsive)**
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Expanded(child: _actionButton(Icons.thumb_up_alt_outlined, "Like", screenWidth)),
//               Expanded(child: _actionButton(Icons.chat_bubble_outline, "Comment", screenWidth)),
//               Expanded(child: _actionButton(Icons.autorenew, "Repost", screenWidth)),
//               Expanded(child: _actionButton(Icons.send, "Send", screenWidth)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   /// **Reusable Action Button (Compact & Adjusts to Screen)**
//   Widget _actionButton(IconData icon, String label, double screenWidth) {
//     return FittedBox(
//       child: TextButton.icon(
//         onPressed: () {},
//         icon: Icon(icon, color: Colors.white, size: screenWidth * 0.045),
//         label: Text(label, style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.035)),
//       ),
//     );
//   }
// }
