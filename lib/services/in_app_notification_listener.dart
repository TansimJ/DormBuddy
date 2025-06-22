import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InAppNotificationListener extends StatefulWidget {
  final Widget child;
  const InAppNotificationListener({required this.child, super.key});

  @override
  State<InAppNotificationListener> createState() => _InAppNotificationListenerState();
}

class _InAppNotificationListenerState extends State<InAppNotificationListener> {
  late Stream<QuerySnapshot> _notificationStream;
  String? _lastNotifId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _notificationStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots();

      _notificationStream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final notif = snapshot.docs.first;
          if (_lastNotifId != notif.id) {
            _lastNotifId = notif.id;
            final data = notif.data() as Map<String, dynamic>;
            // Show snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['title'] ?? 'You have a new notification!'),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'View',
                  onPressed: () {
                    // Optionally, navigate to notification page
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),
              ),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}