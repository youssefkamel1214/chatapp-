import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
class Sendmessegecontroller extends GetxController {
  Rx<String>message=''.obs;
 final String useremail;
 final String id;
 final String username;
  Sendmessegecontroller({
     required this.useremail,
     required this.id,
     required this.username,
  });
  void upadatemessege(String mes){
    message.update((val) => message.value=mes);
  }
  void sendmessge(BuildContext context,TextEditingController controller){
        FocusScope.of(context).unfocus();
        controller.clear();
        String content=message.value.trim();
        upadatemessege('');
        FirebaseFirestore.instance.collection('chat_channel/$id/messages').add({
          'type':'text',
          'content':content,
          'time':Timestamp.now(),
          'email':useremail,
          'username':username
        });
        FirebaseFirestore.instance.collection('chat_channel').doc(id).update({
          'lasttime':Timestamp.now(),
          'lastmessege':content
        });
  }
}
