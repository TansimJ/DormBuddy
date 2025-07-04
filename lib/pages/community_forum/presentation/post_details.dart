import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'post_card.dart';

// --------------------------
// Comment Model
// --------------------------
class Comment {
  final String author;
  final String date;
  final String content;

  Comment({
    required this.author,
    required this.date,
    required this.content,
  });
}

// --------------------------
// Post Detail Page Widget
// --------------------------
class PostDetailPage extends StatefulWidget {
  final PostCard post;
  final List<Comment> initialComments;

  const PostDetailPage({
    super.key,
    required this.post,
    this.initialComments = const [],
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

// --------------------------
// Post Detail Page State
// --------------------------
class _PostDetailPageState extends State<PostDetailPage> {
  // --------------------------
  // Controller and State Variables
  // --------------------------
  final TextEditingController _commentController = TextEditingController();
  late List<Comment> _comments;

  // --------------------------
  // Lifecycle Methods
  // --------------------------
  @override
  void initState() {
    super.initState();
    // Initialize with passed comments
    _comments = List.from(widget.initialComments);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // --------------------------
  // Comment Handling Methods
  // --------------------------
  void _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    // Get current user name
    String authorName = 'Anonymous';
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        authorName = userDoc.data()?['name'] ?? 'Anonymous';
      }
    }

    await FirebaseFirestore.instance
        .collection('forum')
        .doc(widget.post.id) // Make sure PostCard has an 'id' field
        .collection('comments')
        .add({
      'author': authorName,
      'date': DateTime.now().toString().substring(0, 16),
      'content': _commentController.text.trim(),
    });

    _commentController.clear();
  }

  // --------------------------
  // UI Building Section
  // --------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      
      // Body Layout
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------
              // Post Header Section
              // --------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.post.author,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    widget.post.date,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // --------------------------
              // Post Title Section
              // --------------------------
              Text(
                widget.post.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // --------------------------
              // Post Content Section
              // --------------------------
              Text(
                widget.post.content,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              
              // --------------------------
              // Tags Section (if available)
              // --------------------------
              if (widget.post.tags != null && widget.post.tags!.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  children: widget.post.tags!
                      .map((tag) => Chip(
                            label: Text(tag),
                            backgroundColor: Colors.grey[200],
                            labelStyle: const TextStyle(fontSize: 12),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
              
              // --------------------------
              // Comments Section Header
              // --------------------------
              const Divider(),
              const Text(
                'Comments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // --------------------------
              // Comments List
              // --------------------------
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('forum')
                    .doc(widget.post.id) // Make sure PostCard has an 'id' field
                    .collection('comments')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final comments = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Comment(
                      author: data['author'] ?? '',
                      date: data['date'] ?? '',
                      content: data['content'] ?? '',
                    );
                  }).toList();

                  if (comments.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No comments yet. Be the first to comment!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return Column(
                    children: comments.map((comment) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Comment Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(comment.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(comment.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Comment Content
                          Text(comment.content),
                        ],
                      ),
                    )).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      
      // --------------------------
      // Comment Input Section
      // --------------------------
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              // Text Input Field
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 8),
              // Send Button
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF800000)),
                onPressed: _submitComment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ------------------------------
//Convert post to json
//-------------------------------
Map<String, dynamic> postToJson(PostCard post) {
  return {
    'title': post.title,
    'content': post.content,
    'author': post.author,
    'date': post.date, //might need to change to DateTime
    'tags': post.tags ?? [],
  };
}

//-------------------------------
// Convert json to post
//-------------------------------
PostCard jsonToPost(Map<String, dynamic> json) {
  return PostCard(
    id: json['id'] as String, 
    title: json['title'] as String,
    content: json['content'] as String,
    author: json['author'] as String,
    date: json['date'] as String,); //highly likely that i will need to adjust this
    }


//-------------------------------
// Convert comment to json
//------------------------------- 
Map<String, dynamic> commentToJson(Comment comment) {
  return {
    'author': comment.author,
    'date': comment.date,
    'content': comment.content,
  };
}