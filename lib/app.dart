import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shakti/Screens/BottomNavBar.dart';
import 'package:shakti/Screens/CommunityHome.dart';
import 'package:shakti/Screens/avatar.dart';
import 'package:shakti/Screens/splash_Screen.dart';
import 'package:shakti/Utils/constants/colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Base mobile design
      minTextAdapt: true,
      builder: (_, child) {
        return GetMaterialApp(
          theme: ThemeData(scaffoldBackgroundColor: Scolor.primary),
          debugShowCheckedModeBanner: false,
         home:  SplashScreen(),
          //home:CommunityHomeScreen(),
        );
      },
    );
  }
}
