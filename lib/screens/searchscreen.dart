import 'package:chatapp/controller/chats_channelcont.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
class search_screen extends StatelessWidget{
  search_screen({Key? key,required this.user}) : super(key: key);
Chatchannelcont chat=Get.find<Chatchannelcont>();
final User user;
  @override
  Widget build(BuildContext context) {
     return StreamBuilder(stream: 
     FirebaseFirestore.instance.collection('users').snapshots(),
     builder:(context,snapshot){
        if(snapshot.connectionState==ConnectionState.waiting)
                  return const Center(child:  CircularProgressIndicator());
       dynamic docs=snapshot.data;
       docs=docs.docs;
       return Obx((){
       List<dynamic> users=  docs.where((element) {
         String s=element.id;
         return (s.contains(chat.searchemail.value)||chat.searchemail.value.isEmpty)&&s!=user.email;
       }).toList() ;
       if(users.length<1)
           return Center(child: Text("we have found nothing like this"),);
     return ListView.builder(itemCount: users.length,itemBuilder:(contxt,index){
       return Container(
               margin:const EdgeInsets.all( 5.0),
               padding:const EdgeInsets.all(8.0),
               decoration: BoxDecoration(
                 color: Colors.pink,
                 borderRadius: BorderRadius.circular(20)
               ), 
               child: Column(mainAxisSize: MainAxisSize.min,
                 children:[ 
                   Text('user email: ${users[index].id}'),
                   Text('username :${users[index]['username']}'),
                   SizedBox(height: 25, child: Row( 
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: [
                       IconButton(onPressed:()=> addtochannel(users[index].id ), icon:Icon( Icons.add)),
                       IconButton(onPressed: null, icon: Icon(Icons.block)),
                       IconButton(onPressed: null, icon: Icon(Icons.chat))
                     ],
                   ))
                 ]),
       );
     });});
     } ,)
     ;
  }

  addtochannel(String anotheruserid) async{
      dynamic channel1 = await FirebaseFirestore.instance.collection('users').
      doc(user.email).get();
       dynamic channel2 = await FirebaseFirestore.instance.collection('users').
      doc(anotheruserid).get();
      dynamic list1=channel1['channels'],userlist1=channel1['users'];
      dynamic list2=channel2['channels'],userlist2=channel2['users'];
      if(userlist1.contains(anotheruserid)){
            Fluttertoast.showToast(msg: 'you already in channel with him',toastLength: Toast.LENGTH_SHORT);
            return;
      }
      dynamic channel = await FirebaseFirestore.instance.collection('chat_channel').
      add({'users':[user.email,anotheruserid]});
      list1.add(channel.id);
      userlist1.add(anotheruserid);
       FirebaseFirestore.instance.collection('users').doc(user.email).update({
        'channels':  list1,
        'users':userlist1
      });
     
      list2.add(channel.id);
      userlist2.add(user.email);
      FirebaseFirestore.instance.collection('users').doc(anotheruserid).update({
      'channels':  list2,
      'users':userlist2
      });
  }
}