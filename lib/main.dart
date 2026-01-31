import 'package:flutter/material.dart';
//import 'package:mixen/pages/completeprofilepage.dart';
//import 'package:mixen/pages/upload_profile_image_page.dart';
//import 'package:mixen/pages/swipe_page.dart';
//import 'package:mixen/pages/welcome/onboarding_screen.dart';
import 'package:mixen/pages/bottom_nav/bottom_nav.dart';
//ignore: unused_import
//import 'package:mixen/pages/homepage.dart';
//import 'package:mixen/pages/welcome/splash_screen.dart';
//import 'package:mixen/registration/login_screen.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mixen',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      //home: const Homepage( ),
      //home: const LoginScreen(),
      //home: const SplashScreen (),
      home: const BottomNav()
      //home: const SwipePage()
      //home: const UploadProfileImagePage()
      //home: const CompleteProfilePage()
      //home: const OnboardingScreen()
    );
  }
}
