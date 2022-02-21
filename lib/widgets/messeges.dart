import 'package:chatapp/widgets/messegebuble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class Messeges extends StatelessWidget{
     const Messeges({Key? key, required this.id,required this.user_email}) : super(key: key);
 final String id;
 final String user_email;

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
             return docs[index]['type']=='text'? Messegbuble(isMe: docs[index]['email']==user_email, 
             key: ValueKey(docs[index].id), messege: docs[index]['content'], username: docs[index]['username']):
             Container();
              }); 
         } ,
       );
  }

}