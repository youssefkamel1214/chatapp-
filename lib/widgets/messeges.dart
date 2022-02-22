import 'package:chatapp/widgets/messegebuble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class Messeges extends StatelessWidget{
     const Messeges({Key? key, 
     required this.id,
     required this.user_email,
     required this.imagesurls,
     required this.emails,
     }) : super(key: key);
 final String id;
 final String user_email;
 final List<String>imagesurls;
 final List<String>emails;


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return StreamBuilder(
         stream: FirebaseFirestore.instance.collection('chat_channel/$id/messages').
         orderBy('time',descending: true) .snapshots(),
         builder:(context,snapshot){
           if(snapshot.connectionState==ConnectionState.waiting)
             return const Center(child: CircularProgressIndicator(),);
           dynamic docs=snapshot.data;
           docs= docs.docs;
           if(docs==null)
           return Container();
           return ListView.builder(itemCount: docs.length,reverse: true,
           itemBuilder: (ctx,index) {
             int imageindex=emails.indexWhere((element) =>element==docs[index]['email']);
             return  Messegbuble(isMe: docs[index]['email']==user_email, 
             key: ValueKey(docs[index].id), messege: docs[index]['content'],type:docs[index]['type'] ,
              username: docs[index]['username'],imageurl:imagesurls[imageindex] ,
              );
              }); 
         } ,
       );
  }

}