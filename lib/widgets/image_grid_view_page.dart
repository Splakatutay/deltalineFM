import 'package:flutter/material.dart';

class ImageGridViewPage extends StatelessWidget {
  final List<String>? imageUrls;

  ImageGridViewPage({this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Grid View'),
      ),
      body: imageUrls == null || imageUrls!.isEmpty
          ? Center(child: Text('No images available'))
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns in the grid
            crossAxisSpacing: 8.0, // Space between columns
            mainAxisSpacing: 8.0, // Space between rows
          ),
          itemCount: imageUrls!.length,
          itemBuilder: (context, index) {
            return GridTile(
              child: Image.network(
                imageUrls![index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text('Could not load image'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
