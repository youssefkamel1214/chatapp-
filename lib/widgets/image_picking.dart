import 'dart:io';

import 'package:flutter/material.dart';
class Imagepicking extends StatelessWidget{
   Imagepicking({Key? key,
   required this.function,
   this.imagefile}) : super(key: key);
 final Function(bool camera) function;
 File? imagefile;
  @override
  Widget build(BuildContext context) {
      return Column(mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor:imagefile==null?Colors.grey:null ,
            backgroundImage:imagefile==null? null:FileImage(imagefile!),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                TextButton.icon(onPressed: ()=>function(true), icon:const Icon(Icons.photo_camera_outlined),
                 label:const Text( 'Add image\n from Camera',textAlign: TextAlign.center,)),
                  TextButton.icon(onPressed:()=>function(false), icon:const Icon(Icons.image_outlined),
                 label:const Text( 'Add image\n from Gallery',textAlign: TextAlign.center,))
            ],
          )
        ],
      );
  }

}