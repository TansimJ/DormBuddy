import 'package:dorm_buddy/widgets/appbar.dart';
import 'package:flutter/material.dart';
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
  bool showMyPostsOnly = false;

  List<PostCard> get filteredPosts {
    var posts = allPosts;
    
    if (showMyPostsOnly) {
      // Filter to show only current user's posts (replace 'Anonymous' with actual user ID)
      posts = posts.where((post) => post.author == 'Anonymous').toList();
    }
    
    if (searchQuery.isNotEmpty) {
      posts = posts.where((post) {
        return post.title.toLowerCase().contains(searchQuery.toLowerCase()) || 
               post.content.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
     // appBar: const StudentNavBar(), idk why its showing up twice lol
      body: Column(
        children: [
          // Custom Header Container
          Container(
            color: Color(0xFF800000), // Same as app bar color
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                // Title
                const Text(
                  'OUR FORUM',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Search Bar
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
                
                // Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person),
                      label: Text(showMyPostsOnly ? 'All Posts' : 'My Posts'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: theme.primaryColor,
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () => setState(() => showMyPostsOnly = !showMyPostsOnly),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Create Post'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: theme.primaryColor,
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreatePostPage()),
                        );
                        if (result != null && result is Map) {
                          setState(() {
                            allPosts.insert(
                              0,
                              PostCard(
                                title: result['title'],
                                content: result['content'],
                                author: 'Anonymous',
                                date: DateTime.now().toString().substring(0, 10),
                              ),
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Posts List
          Expanded(
            child: filteredPosts.isEmpty
                ? Center(
                    child: Text(
                      searchQuery.isNotEmpty 
                          ? 'No posts match your search' 
                          : 'No posts available',
                    ),
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
                        onEdit: () => _editPost(index),
                        onDelete: () => _deletePost(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  // --------------------------
  // Navigation Section
  // --------------------------
  void _navigateToPostDetail(PostCard post) {
    // Sample comments for demonstration
    List<Comment> comments = [];
    
    if (post.title.contains('first time living alone')) {
      comments = [
        Comment(
          author: 'Leon Kennedy',
          date: '29/05/2025',
          content: 'Make sure not to tell strangers that you live alone.',
        ),
        Comment(
          author: 'Nadeeya A.',
          date: '29/05/2025',
          content: 'Buy grocery after 9PM. Fresh food will be on sale.',
        ),
      ];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(
          post: post,
          initialComments: comments,
        ),
      ),
    );
  }

  // --------------------------
  // Edit and Delete Post Functions
  // --------------------------
  void _editPost(int index) async {
    final post = filteredPosts[index];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostPage(
          initialTitle: post.title,
          initialContent: post.content,
        ),
      ),
    );
    if (result != null && result is Map) {
      setState(() {
        // Find the actual index in allPosts (in case of search filtering)
        final realIndex = allPosts.indexOf(post);
        if (realIndex != -1) {
          allPosts[realIndex] = PostCard(
            title: result['title'],
            content: result['content'],
            author: post.author,
            date: post.date,
          );
        }
      });
    }
  }

  void _deletePost(int index) {
    final post = filteredPosts[index];
    setState(() {
      allPosts.remove(post);
    });
  }

}