import 'package:chatapp/controller/messege_controller.dart';
import 'package:chatapp/controller/sendmessagecont.dart';
import 'package:chatapp/widgets/messeges.dart';
import 'package:chatapp/widgets/new_messege.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart' as jap;
class ChatScreen extends StatelessWidget{
   ChatScreen({Key? key,
  required this.title,
  required this.useremail,
  required this.id,
  required this.username,
  }) : super(key: key);
 final String title;
 final String id;
 final String useremail;
 final String username;

  @override
  Widget build(BuildContext context) {
      var sendmessegecontroller = Sendmessegecontroller(useremail: useremail, id: id, username: username);
       Messegcontroller messegcontroller = Messegcontroller(id: id, useremail: useremail,username: username);
       Get.put(sendmessegecontroller);
       Get.put(messegcontroller);
    jap.AudioPlayer audioPlayer = jap.AudioPlayer();
     return  Scaffold(
           appBar: AppBar(centerTitle: true,  title:Text(title),),
           body: Container(
             padding:const EdgeInsets.symmetric(horizontal: 5.0),
             child: Column(
               children: [
                 Obx(
                    () {
                      if(messegcontroller.loading.value)
                       return const Expanded(child:  Center(child: CircularProgressIndicator(),)) ;
                      else 
                      return Expanded(child:Messeges(audioPlayer: audioPlayer,));
                    }
                 ),
                 NewMesseges()

               ],
             ),
           ),
           
         );
  }
}