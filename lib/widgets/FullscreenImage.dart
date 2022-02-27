import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const FullScreenImage({Key? key,
  required this.imageUrl,
  required  this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.black87,
      ),
      body: Row(
        children: [
          Expanded(
            child: FullScreenWidget(
              child: GestureDetector(
                child: Hero(
                  tag: tag,
                  child: Image.network(
                        imageUrl,
                        fit: BoxFit.fill,
                        loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child:CircularProgressIndicator(color: Colors.white,) ,  );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                        const  Text('Some errors occurred!'),
                        )
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
