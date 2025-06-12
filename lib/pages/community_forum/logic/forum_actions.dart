import 'package:flutter/material.dart';

class ForumActions extends StatefulWidget {
  final Function(String) onSearch;

  const ForumActions({
    super.key,
    required this.onSearch,
  });

  @override
  State<ForumActions> createState() => _ForumActionsState();
}

class _ForumActionsState extends State<ForumActions> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Posts'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter search terms...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _searchController.clear();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onSearch(_searchController.text);
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search),
            label: const Text('Search Post'),
          ),
          TextButton.icon(
            onPressed: () {
              // Implement create new post functionality
            },
            icon: const Icon(Icons.add),
            label: const Text('Create New Post'),
          ),
        ],
      ),
    );
  }
}