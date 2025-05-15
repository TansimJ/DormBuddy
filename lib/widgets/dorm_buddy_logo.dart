import 'package:flutter/material.dart';

class DormBuddyLogo extends StatelessWidget {
  const DormBuddyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset('lib/assets/logo.png', width: 150, height: 150),
    );
  }
}
