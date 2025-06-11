import 'package:flutter/material.dart';
import 'post_card.dart';
import 'post_details.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final List<PostCard> allPosts = [
    PostCard(
      title: 'Looking for a male student to rent together',
      content: 'I\'m renting a unit at Avenger HQ. Hoping to find a fellow student who values cleanliness, does not smoke, eat healthy.',
      author: 'Leon Kennedy',
      date: '01/06/2025',
    ),
    PostCard(
      title: 'Advice on first time living alone?',
      content: 'Hello this is my first time living far from home. Please give me advice on what should I take note when living by myself.',
      author: 'Peter Parker',
      date: '29/05/2025',
    ),
    PostCard(
      title: 'Advice on being your friendly neighbourhood spiderman?',
      content: 'Exactly what I wrote in the title.',
      author: 'Peter Parker',
      date: '29/05/2025',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  List<PostCard> get filteredPosts {
    if (searchQuery.isEmpty) return allPosts;
    
    return allPosts.where((post) {
      return post.title.toLowerCase().contains(searchQuery.toLowerCase()) || 
             post.content.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  void _navigateToPostDetail(PostCard post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(post: post),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OUR FORUM',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search posts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement create new post functionality
        },
        child: const Icon(Icons.add),
      ),
      body: filteredPosts.isEmpty && searchQuery.isNotEmpty
          ? const Center(
              child: Text('No posts match your search'),
            )
          : ListView.separated(
              itemCount: filteredPosts.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                return PostCard(
                  title: post.title,
                  content: post.content,
                  author: post.author,
                  date: post.date,
                  onTap: () => _navigateToPostDetail(post),
                );
              },
            ),
    );
  }
}