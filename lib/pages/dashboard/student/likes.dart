import 'package:flutter/material.dart';

class LikesPage extends StatelessWidget {
  const LikesPage({super.key});


//PLACEHOLDER FOR NOW
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Posts'),
        backgroundColor: const Color(0xFF800000),
      ),
      body: Center(
        child: Text(
          'No liked posts yet.',
          style: TextStyle(fontSize: 20, color: Colors.grey[600]),
        ),
      ),
    );
  }
}

