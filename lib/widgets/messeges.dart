import 'package:chatapp/controller/audio_controller.dart';
import 'package:chatapp/controller/messege_controller.dart';
import 'package:chatapp/widgets/messegebuble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
class Messeges extends StatelessWidget{
      Messeges({Key? key, 

     required this.audioPlayer,
     }) : super(key: key);

 final AudioPlayer audioPlayer;
 // ignore: non_constant_identifier_names
 final mess_contrl=Get.find<Messegcontroller>(); 
  @override
  Widget build(BuildContext context) {
   Get.put(Audiomanger(audioPlayer:audioPlayer));
   return Obx(
      () =>mess_contrl.messeges.isEmpty?Container(): Obx(
         ()=>ScrollablePositionedList.builder(itemCount: mess_contrl.messeges.length,reverse: true,
               itemBuilder: (ctx,index) {
                 mess_contrl.updateseen(index);
                 int imageindex=mess_contrl.emails.indexWhere((element) =>element==mess_contrl.messeges[index]['email']);
                 return  Messegbuble(isMe: mess_contrl.messeges[index]['email']==mess_contrl.useremail,
                  exte:mess_contrl.messeges[index]['type']=='doc'?mess_contrl.messeges[index]['ext']:null ,key: ValueKey(mess_contrl.messeges[index].id), 
                  messege: mess_contrl.messeges[index]['content'],type:mess_contrl.messeges[index]['type'] ,
                  username: mess_contrl.messeges[index]['username'],imageurl:mess_contrl.imagesurls[imageindex] ,
                  duration:mess_contrl.messeges[index]['type']=='sound'?Duration(milliseconds:  mess_contrl.messeges[index]['duration']):null ,
                  seen: !(mess_contrl.messeges[index]['seen'].contains(false)&&mess_contrl.messeges[index]['email']==mess_contrl.useremail),
                  );
                  },
                  initialScrollIndex:mess_contrl.inialindex,
                   )
       )
   );
  }

}