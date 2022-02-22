import 'package:chatapp/controller/sendmessagecont.dart';
import 'package:chatapp/widgets/messeges.dart';
import 'package:chatapp/widgets/new_messege.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class ChatScreen extends StatelessWidget{
  const ChatScreen({Key? key,
  required this.useremail,
  required this.title,
  required this.id,
  required this.username,
  required this.emails,
  required this.imagesurls
  }) : super(key: key);
 final String useremail;
 final String title;
 final String id;
 final String username;
 final List<String>imagesurls;
 final List<String>emails;

  @override
  Widget build(BuildContext context) {
    Get.put(Sendmessegecontroller(useremail: useremail, id: id,username: username));
    print('chatscreen');
     return Scaffold(
       appBar: AppBar(centerTitle: true,  title:Text(title),),
       body: Container(
         padding:const EdgeInsets.symmetric(horizontal: 5.0),
         child: Column(
           children: [
             Expanded(child:Messeges(id: id, user_email: useremail,emails: emails,imagesurls: imagesurls,)),
             NewMesseges()

           ],
         ),
       ),
       
     );
  }
}