
import 'package:chatapp/controller/chats_channelcont.dart';
import 'package:chatapp/screens/searchscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class MyHomePage extends StatelessWidget {
   MyHomePage({Key? key,required this.user}) : super(key: key);
  final User user;

Chatchannelcont chatchannelcont=Get.find<Chatchannelcont>();
  
  @override
  Widget build(BuildContext context) {
    chatchannelcont.get_user(user.email!);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading:  IconButton(icon: Obx( () =>chatchannelcont.issearchmode.value?const Icon(Icons.arrow_back) :
        const  Icon(Icons.search)
        ),
        onPressed: () => chatchannelcont.siwitch_state_of_search(),),
        title: Obx(() =>chatchannelcont.issearchmode.value?TextField(
        
          onChanged: (value) => chatchannelcont.update_search_email(value),
          decoration:const InputDecoration(
            border: InputBorder.none,
            hintText: 'write heare to search',
          ),
        ) : Text('Chat Channels')
        ),
        actions: [
          DropdownButton(icon: Icon( Icons.more_vert,
       color: Theme.of(context).primaryIconTheme.color,),items: [
            DropdownMenuItem(child: Row(children:const [
               Icon(Icons.exit_to_app,size: 15,color: Colors.black,),
               SizedBox(width: 8,),
               Text('Logout')
            ],),value: 'logout',)
          ],onChanged: (value){
            print(value);
            if(value=='logout')
             FirebaseAuth.instance.signOut();
          },)
        ],
      ),
      body:Obx(
        ()=> chatchannelcont.issearchmode.value?search_screen(user: user,):Obx(
          (){
            if(chatchannelcont.isloading.value)
              return const Center(child: CircularProgressIndicator(),);
            if(chatchannelcont.channels.isEmpty)
             return const Center(child: Text('sorry you havent add anyone in channel '),);
            return ListView.builder(
              itemCount: chatchannelcont.channels.length,
              itemBuilder: (ctx,index){
                   return Container(
                     height: 85,
                     padding: const EdgeInsets.all(8.0),
                     margin:const EdgeInsets.all(10.0),
                     decoration:  BoxDecoration(
                       color: Colors.blue,
                       borderRadius:  BorderRadius.circular(20)
                     ),
                     child:Column(
                     children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Expanded(
                             child: Text(chatchannelcont.users[index],
                             maxLines: 1,
                             style:const TextStyle(fontSize: 18),overflow: TextOverflow.ellipsis,),
                           ),
                           IconButton(onPressed: ()=> movetochatscreen(index), icon: const Icon(Icons.chat))
                         ],
                       )
                     ],),
                   );
              },
            );
          }
        )
      ) ,
    );
  }

  movetochatscreen(int index) {
           
  }
}
