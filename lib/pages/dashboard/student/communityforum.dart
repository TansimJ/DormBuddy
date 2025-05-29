import 'package:flutter/material.dart';

class CommunityForum extends StatelessWidget {
  const CommunityForum({super.key});


//PLACEHOLDER FOR NOW
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Forum'),
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Under Construction...',
          style: TextStyle(fontSize: 20, color: Colors.grey[600]),
        ),
      ),
    );
  }
}

