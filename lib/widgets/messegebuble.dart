import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import 'FullscreenImage.dart';

class Messegbuble extends StatelessWidget {
 final  bool isMe;
 final  Key key;
 final  String messege;
 final  String username;
 final  String imageurl;
 final  String type;
  const Messegbuble({
    required this.isMe,
    required this.key,
    required this.messege,
    required this.username,
    required this.imageurl,
    required this.type,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double width=min(140.0,14.0* max(messege.length,username.length));
    double stackpadd=120*width/140;
    return Stack(
      children: [
       Row(
        mainAxisAlignment: isMe?MainAxisAlignment.start:MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
                color: isMe?Theme.of(context).accentColor:Colors.grey[300] ,
                borderRadius: BorderRadius.only(
                  topLeft:const Radius.circular(14),
                  topRight:const Radius.circular(14),
                  bottomLeft:isMe? const Radius.circular(0): const Radius.circular(14),
                  bottomRight:isMe?const Radius.circular(14):const Radius.circular(0),
                )
          ),
          padding:const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16.0),
          margin:const EdgeInsets.symmetric(vertical: 16.0,horizontal: 8.0),
          width:type=='image'?null: width,
          child: 
          Column(
            crossAxisAlignment:isMe? CrossAxisAlignment.start:CrossAxisAlignment.end,
            children: [
              Text(username,style: TextStyle(fontSize: 15 ,color:isMe?Colors.white:Colors.black  ),textAlign: TextAlign.center,),
              if(type=='text')
                Text(messege,style: TextStyle(fontSize: 14 ,color:isMe?Colors.white:Colors.black ),textAlign: TextAlign.left),
            if(type=='image')
                 make_image(context),
            ],
          ),
          )
        ],
      ),
     Positioned(
     left: isMe?(type!='image'? stackpadd:170):null,
     right: isMe?null:((type!='image')? stackpadd:170),
       child: CircleAvatar(
         backgroundImage: 
         Image.network(
                  imageurl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child:CircularProgressIndicator(color: Colors.white,) ,  );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const  Text('Some errors occurred!'),
                  ).image , 
       )) ],
    );
  }
  make_image(BuildContext context) {
    return GestureDetector(
      child:Hero(
        tag: key.toString(),
        child: Container(
          child: messege.contains('wiaitng')?const Center(child: CircularProgressIndicator(),):null,
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            image:messege.contains('wiaitng')?null: DecorationImage(
              fit: BoxFit.fill,
              image:    Image.network(
                    imageurl,
                    loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child:CircularProgressIndicator(color: Colors.white,) ,  );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                    const  Text('Some errors occurred!'),
                    ).image
            )
          ),
        ),
      ),
      onTap:imageurl.contains('wiaitng')?null:()=>  Navigator.push(context,
              MaterialPageRoute(builder: (_) {
                return FullScreenImage(
                  imageUrl:
                  messege,
                  tag: key.toString(),
                );
              })),
    );
  }
}
