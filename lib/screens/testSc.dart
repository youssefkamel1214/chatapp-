// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
class buttonscreen extends StatefulWidget{
  @override
  State<buttonscreen> createState() => _buttonscreenState();
}

class _buttonscreenState extends State<buttonscreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   var data = 'تسجيل الدخول';
   return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
             children: [
               for(int i=0;i<17;i++)
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: makebutton(data: data+(i+1).toString()),
                )
             ],    
          ),
        ),
      ),
    ),
   );
  }
}

class makebutton extends StatelessWidget {
  const makebutton({
    Key? key,
    required this.data,
  }) : super(key: key);

  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 200,
      child: ElevatedButton(onPressed: (){},style: ElevatedButton.styleFrom(primary: Colors.blue,shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(14)
       )), child:Text(data)),
    );
  }
}