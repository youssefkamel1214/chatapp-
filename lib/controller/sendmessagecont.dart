import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
class Sendmessegecontroller extends GetxController {
  Rx<String>message=''.obs;
 final String useremail;
 final String id;
 final String username;
 Rx<String>imagepath=''.obs;
  Sendmessegecontroller({
     required this.useremail,
     required this.id,
     required this.username,
  });
  void upadatemessege(String mes){
    if(mes.isNotEmpty)
      imagepath.update((val) => imagepath.value='');   
    message.update((val) => message.value=mes);
  }

  void updatefileimage(bool camra ,TextEditingController controller) async{
    Get.focusScope!.unfocus();
       final ImagePicker _picker = ImagePicker();
       final XFile?image;
        if(camra)
           image = await _picker.pickImage(source: ImageSource.camera
           ,imageQuality: 70);
        else
           image = await _picker.pickImage(source: ImageSource.gallery,
           imageQuality:70 );
     if(image==null)
        return;
    controller.clear();
    upadatemessege('');   
    imagepath.update((val) => imagepath.value=image!.path);
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
          'lastmessege':content,
          'type':'text'
        });
  }
  void sendimage(BuildContext context,TextEditingController controller)async{
        FocusScope.of(context).unfocus();
        controller.clear();
        upadatemessege('');
       String path=imagepath.value;
       imagepath.update((val) => imagepath.value='');   
     dynamic mess=  await FirebaseFirestore.instance.collection('chat_channel/$id/messages').add({
          'type':'image',
          'content':'wiaitng to send image',
          'time':Timestamp.now(),
          'email':useremail,
          'username':username
        });
         final ref=  FirebaseStorage.instance.ref().child('chat_images').
           child('${mess.id}.jpg');
           await ref.putFile(File(path));
           final image_url=await ref.getDownloadURL();
        FirebaseFirestore.instance.collection('chat_channel/$id/messages').doc(mess.id).update({
          'content':image_url
        });
        FirebaseFirestore.instance.collection('chat_channel').doc(id).update({
          'lasttime':Timestamp.now(),
          'lastmessege':'image was sent',
          'type':'image'
        });
  }
}
