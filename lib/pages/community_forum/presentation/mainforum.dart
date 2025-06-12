import 'package:dorm_buddy/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_card.dart';
import 'post_details.dart';
import 'createforumpost.dart';
import 'editforumpost.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  bool showMyPostsOnly = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Header and search bar (same as before)
          Container(
            color: const Color(0xFF800000),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                const Text(
                  'COMMUNITY FORUM',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search posts...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // You can implement showMyPostsOnly if you store userId in each post
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Create Post'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: theme.primaryColor,
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreatePostPage()),
                        );
                        // No setState needed, StreamBuilder will update automatically
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Posts List from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('forum')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No posts available'));
                }
                final posts = snapshot.data!.docs
                    .map((doc) => {
                          'id': doc.id,
                          ...doc.data() as Map<String, dynamic>,
                        })
                    .where((post) =>
                        post['title']
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        post['content']
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                    .toList();

                if (posts.isEmpty) {
                  return const Center(child: Text('No posts match your search'));
                }

                return ListView.separated(
                  itemCount: posts.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostCard(
                      id: post['id'],
                      title: post['title'] ?? '',
                      content: post['content'] ?? '',
                      author: post['author'] ?? '',
                      date: post['date'] ?? '',
                      onTap: () => _navigateToPostDetail(post),
                      onEdit: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPostPage(
                              docId: post['id'], // Firestore doc id
                              initialTitle: post['title'] ?? '',
                              initialContent: post['content'] ?? '',
                            ),
                          ),
                        );
                        // Optionally show a snackbar if result == true
                        if (result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Post updated!')),
                          );
                        }
                      },
                      onDelete: () async {
                        await FirebaseFirestore.instance
                            .collection('forum')
                            .doc(post['id'])
                            .delete();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPostDetail(Map<String, dynamic> post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(
          post: PostCard(
            id: post['id'],
            title: post['title'] ?? '',
            content: post['content'] ?? '',
            author: post['author'] ?? '',
            date: post['date'] ?? '',
          ),
          initialComments: const [],
        ),
      ),
    );
  }
}