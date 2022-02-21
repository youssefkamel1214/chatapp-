import 'package:chatapp/controller/sendmessagecont.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class NewMesseges extends StatelessWidget{
   NewMesseges({Key? key,}) 
  : super(key: key);
  final controller=TextEditingController();
  final sendmescont=Get.find<Sendmessegecontroller>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin:const EdgeInsets.only(top: 10.0),
      padding:const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(child: TextField(
            controller: controller,
            onChanged: (val)=>sendmescont.upadatemessege(val),
            decoration: InputDecoration(labelText: 'Tybe here to send',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0)
            )),
          )),
          Obx( () {
              return sendmescont.message.isEmpty? IconButton(onPressed:null, color:Get.theme.primaryColor ,
               icon:const Icon(Icons.send,)):IconButton(onPressed:()=>sendmescont.sendmessge(context, controller), color:Get.theme.primaryColor ,
               icon:const Icon(Icons.send,));
            }
          )
        ],
      ),
    );
  }

}