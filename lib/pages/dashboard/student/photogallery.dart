import 'package:flutter/material.dart';

class PhotoGalleryPage extends StatelessWidget {
  final List<String> photos;

  const PhotoGalleryPage({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Gallery'),
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
      ),
      body: photos.isEmpty
          ? const Center(child: Text("No photos available."))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenPhoto(imagePath: photos[index]),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      photos[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class FullScreenPhoto extends StatelessWidget {
  final String imagePath;

  const FullScreenPhoto({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
