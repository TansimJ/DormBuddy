import 'package:flutter/material.dart';
import 'landlord_appbar.dart';
import 'landlord_bottombar.dart';

class LandlordChatPage extends StatefulWidget {
  const LandlordChatPage({super.key});

  @override
  State<LandlordChatPage> createState() => _LandlordChatPageState();
}

class _LandlordChatPageState extends State<LandlordChatPage> {
  int _currentIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Navigation logic same as dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LandlordAppBar(),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF800000),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text('Tenant ${index + 1}'),
            subtitle: const Text('Last message...'),
            trailing: const Text('2h ago'),
          );
        },
      ),
      bottomNavigationBar: LandlordBottomBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}