import 'package:flutter/material.dart';

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
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: tag,
            child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child:CircularProgressIndicator(color: Colors.white,) ,  );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const  Text('Some errors occurred!'),
                  )
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
