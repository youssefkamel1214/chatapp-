import 'package:flutter/material.dart';

class Messegbuble extends StatelessWidget {
 final  bool isMe;
 final  Key key;
 final  String messege;
 final  String username;
  const Messegbuble({
    required this.isMe,
    required this.key,
    required this.messege,
    required this.username,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
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
        width: 140,
        padding:const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16.0),
        margin:const EdgeInsets.symmetric(vertical: 10.0,horizontal: 8.0),
        child: 
        Column(
          children: [
            Text(username,style: TextStyle(fontSize: 16 ,color:isMe?Colors.white:Colors.black ),),
            Text(messege,style: TextStyle(fontSize: 14 ,color:isMe?Colors.white:Colors.black ),)
          ],

        ),
        )
      ],
    );
  }
}
