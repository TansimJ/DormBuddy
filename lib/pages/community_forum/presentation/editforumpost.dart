import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditPostPage extends StatefulWidget {
  final String docId; // <-- Add this
  final String initialTitle;
  final String initialContent;

  const EditPostPage({
    super.key,
    required this.docId, // <-- Add this
    required this.initialTitle,
    required this.initialContent,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  //added by copilot
  String? postOwnerId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    //added by copilot
    _fetchPostOwner();
  }

  Future<void> _fetchPostOwner() async {
    final doc = await FirebaseFirestore.instance
        .collection('forum')
        .doc(widget.docId)
        .get();
    setState(() {
      postOwnerId = doc['userId'];
      loading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Update Firestore document
        await FirebaseFirestore.instance
            .collection('forum')
            .doc(widget.docId)
            .update({
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
        });
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update post: $e')),
          );
        }
      }
    }
  }

  Future<void> _delete() async {
    // Delete Firestore document
    await FirebaseFirestore.instance.collection('forum').doc(widget.docId).delete();
    Navigator.pop(context, true); // Return true to indicate success
  }

  @override
  Widget build(BuildContext context) {
    //added by copilot
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (postOwnerId != currentUserId) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF800000),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Edit Post', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Text(
            "You are not allowed to edit this post.",
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      // AppBar with back button and maroon color
      appBar: AppBar(
        backgroundColor: const Color(0xFF800000),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Edit Post',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Edit your title...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Edit your content...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter content' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800000),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _delete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Delete Post',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
