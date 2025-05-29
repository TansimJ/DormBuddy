import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register/register_student_page.dart';
import 'pages/register/register_landlord_page.dart';
import 'pages/dashboard/student_dashboard.dart';
import 'pages/dashboard/landlord_dashboard.dart';
import 'pages/forgot_password_page.dart';
import 'pages/dashboard/student/profile.dart';

void main() {
  runApp(const DormBuddyApp());
}

class DormBuddyApp extends StatelessWidget {
  const DormBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable debug banner
      title: 'DormBuddy',
      theme: ThemeData(
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF800000),
          secondary: const Color(0xFFA52A2A),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register/student': (context) => const RegisterStudentPage(),
        '/register/landlord': (context) => const RegisterLandlordPage(),
        '/student-dashboard': (context) => const StudentDashboard(),
        '/landlord-dashboard': (context) => const LandlordDashboard(),
        '/forgot': (context) => const ForgotPasswordPage(),
        '/search': (context) => const StudentDashboard(),//temporary
        '/profile': (context) => const StudentProfilePage(),


      },
    );
  }
}
