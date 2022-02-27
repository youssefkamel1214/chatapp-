import 'package:flutter/material.dart';
class Splashscreen extends StatelessWidget{
  const Splashscreen({Key? key,required this.content}) : super(key: key);
  final String content;
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).backgroundColor,
            ]
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:  [
              const Spacer(),
               CircleAvatar(radius: 50,
                 backgroundImage: Image.asset('assets/images/chat.png',).image),
              const Spacer(),
               Row(mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text(content),
                  const SizedBox(width: 15,),
                  const CircularProgressIndicator()
                 ],
               )
          ],
        ),
      ),
    );
  }

}