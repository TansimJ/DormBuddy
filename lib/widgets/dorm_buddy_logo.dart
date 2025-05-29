import 'package:flutter/material.dart';

class DormBuddyLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const DormBuddyLogo({
    super.key,
    this.size = 150,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'lib/assets/logo.png',
        width: size,
        height: size,
      ),
    );
  }
}
