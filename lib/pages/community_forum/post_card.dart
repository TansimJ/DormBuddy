import 'package:flutter/material.dart';

// --------------------------
// Post Card Widget
// --------------------------
class PostCard extends StatelessWidget {
  // --------------------------
  // Properties
  // --------------------------
  final String title;
  final String content;
  final String author;
  final String date;
  final List<String>? tags;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  // --------------------------
  // Constructor
  // --------------------------
  const PostCard({
    super.key,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    this.tags,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  // --------------------------
  // UI Building
  // --------------------------
  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Tap handler for the entire card
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------
            // Title and menu row
            // --------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // --------------------------
            // Content Preview Section
            // --------------------------
            Text(
              content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            // --------------------------
            // Author and Date Section
            // --------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  author,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(date),
              ],
            ),
            
            // --------------------------
            // Tags Section (Conditional), SHOULD REMOVE THIS LATER
            // --------------------------
            if (tags != null && tags!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: tags!
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Colors.grey[200],
                          labelStyle: const TextStyle(fontSize: 12),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}