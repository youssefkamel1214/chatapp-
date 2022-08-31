import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Imagepicking extends StatelessWidget {
  Imagepicking({Key? key, required this.function, this.imagefile})
      : super(key: key);
  final Function(bool camera) function;
  File? imagefile;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 35.sp,
          backgroundColor: imagefile == null ? Colors.grey : null,
          backgroundImage: imagefile == null ? null : FileImage(imagefile!),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
                onPressed: () => function(true),
                icon: Icon(
                  Icons.photo_camera_outlined,
                  size: 18.sp,
                ),
                label: Text(
                  'Add image\n from Camera',
                  style: TextStyle(fontSize: 12.sp),
                  textAlign: TextAlign.center,
                )),
            TextButton.icon(
                onPressed: () => function(false),
                icon: const Icon(Icons.image_outlined),
                label: Text(
                  'Add image\n from Gallery',
                  style: TextStyle(fontSize: 12.sp),
                  textAlign: TextAlign.center,
                ))
          ],
        )
      ],
    );
  }
}
