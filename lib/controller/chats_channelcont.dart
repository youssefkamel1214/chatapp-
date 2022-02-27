import 'package:chatapp/controller/messege_controller.dart';
import 'package:chatapp/screens/chatScreen.dart';
import 'package:chatapp/screens/splashscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';


class Chatchannelcont extends GetxController{
  Rx<bool> issearchmode=false.obs;
  Rx<String>searchemail=''.obs;
  Rx<bool>isloading=true.obs;
  String email='';
  final channels=<dynamic>[].obs;
  final users=<dynamic>[].obs;
  final usernames=<dynamic>[].obs;
  late String username;
  late String imageurl;
  void get_user(String email)async{
    isloading.update((val) =>isloading.value=true);
    this.email=email;
    channels.clear();
    users.clear();
     Stream stream=FirebaseFirestore.instance.collection('users').doc(email).snapshots(includeMetadataChanges: true);
          stream.listen((data) { 
          isloading.update((val) =>isloading.value=true);
          try{
          if(data['username']!=null){
                channels.assignAll(data['channels']);
                users.assignAll(data['users']);
                usernames.assignAll( data['usernames']); 
                username=data['username'];
                imageurl=data['image_url'];
          }
          }
          catch(e){

            print('error$e');
            stream.timeout(Duration(seconds: 1));

          }
          isloading.update((val) => isloading.value=false);
     });
  }
 void update_search_email(String email){
   searchemail.update((val) { searchemail.value=email;});
 }
 void siwitch_state_of_search(){
   issearchmode.update((val) => issearchmode.value^=true);
 }
 void addtochannel(dynamic anotheruser) async{ 
   isloading.update((val) =>isloading.value=true);
      if(this.users.contains(anotheruser.id)){
            Fluttertoast.showToast(msg: 'you already in channel with him',toastLength: Toast.LENGTH_SHORT);
     isloading.update((val) =>isloading.value=false);
      
            return;
      
      }
      dynamic channel = await FirebaseFirestore.instance.collection('chat_channel').
      add({'users':[email,anotheruser.id],
      'usersimages':[imageurl,anotheruser['image_url']],
      'lasttime':Timestamp.now(),
      'lastmessege':' no messsage was sent',
      'type':'text',
      });
      this.channels.add(channel.id);
      this.users.add(anotheruser.id);
      this.usernames.add(anotheruser['username']);

      final channels=anotheruser['channels'],users=anotheruser['users'],usernames=anotheruser['usernames'];
      channels.add(channel.id);
      users.add(email);
      usernames.add(this.username);
      FirebaseFirestore.instance.collection('users').doc(email).update({
        'channels':   this.channels,
        'users': this.users,
        'usernames':this.usernames
      });
      FirebaseFirestore.instance.collection('users').doc(anotheruser.id).update({
      'channels':   channels,
      'users': users,
      'usernames':usernames
      });
         FirebaseStorage.instance.ref().child('chat_channels').child(channel.id);
         isloading.update((val) =>isloading.value=false);
         showalertdailog(this.username, anotheruser['username']);

  }
 void  showalertdailog(String n1,String n2){
    final AlertDialog alert=AlertDialog(
      title: Text( 'Congratalotions $n1'),
      content: 
          Text('you and $n2 can talk now through our app hava nice day'),
      actions: [
          TextButton(onPressed: (){
             Navigator.of(Get.context!).pop();
         }, child: Text('OK'))
          ],
         );
    showDialog(context: Get.context!, builder: (contex){
      return alert;
    });
  }
 void movetochatscreen(int index) async {
       Get.to(()=> ChatScreen(title: usernames[index],id: channels[index], useremail: email,username: username));
  }
}