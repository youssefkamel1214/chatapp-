

import 'package:chatapp/controller/chats_channelcont.dart';
import 'package:chatapp/screens/chatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatelessWidget {
   MyHomePage({Key? key,required this.email}) : super(key: key);
  final String email;

Chatchannelcont chatchannelcont=Get.find<Chatchannelcont>();
  
  @override
  Widget build(BuildContext context) {
    chatchannelcont.get_user(email);
    return Scaffold(
      appBar: makeappbar(context),
      body:Obx( ()=> chatchannelcont.issearchmode.value?getsearchscreen():show_chat_channels()) ,
    );
  }

  AppBar makeappbar(BuildContext context) {
    return AppBar(
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
    );
  }
  showalertdailog(String n1,String n2){
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
  movetochatscreen(int index) async {
          Get.to(ChatScreen(useremail: email, title: chatchannelcont.usernames[index],
          id: chatchannelcont.channels[index],username:chatchannelcont.username ,));
  }
  show_chat_channels(){
    return    StreamBuilder(stream:FirebaseFirestore.instance.collection('chat_channel').
    where('users',arrayContains:email ).snapshots(includeMetadataChanges: true) ,
      builder: (context,snapshot) {
        return Obx(
              (){ 
                if(chatchannelcont.isloading.value||snapshot.connectionState==ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator(),);
                if(chatchannelcont.channels.isEmpty)
                 return const Center(child: Text('sorry you havent add anyone in channel '),);
                 dynamic allchannels=snapshot.data;
                 allchannels=allchannels.docs;
                 if(allchannels.length>0)
                 allchannels.sort((channel1,channel2){
                        if(channel1['lasttime'].toDate().isBefore(channel2['lasttime'].toDate()))
                              return 1;
                        else if(channel2['lasttime'].toDate().isBefore(channel1['lasttime'].toDate())) 
                              return -1; 
                        else 
                              return 0;     
                         });
                  DateFormat DMY=new DateFormat('dd-MMM-yyyy'),HM=new DateFormat('HH:mm a');
                  return ListView.builder(
                  itemCount: allchannels.length,
                  itemBuilder: (ctx,index){
                        int currnindex=
                        chatchannelcont.channels.indexWhere((element) => element==allchannels[index].id);
                        Duration diff= DateTime.now().difference(allchannels[index]['lasttime'].toDate());
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
                              const SizedBox(width: 20,),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(chatchannelcont.usernames[currnindex],
                                     maxLines: 1,
                                     style:const TextStyle(fontSize: 18),overflow: TextOverflow.ellipsis,),
                                     const SizedBox(height: 10,),
                                     Row(
                                       children: [
                                         Expanded(
                                           child: Text(allchannels[index]['lastmessege'],
                                                maxLines: 1,
                                                style:const TextStyle(fontSize: 16),overflow: TextOverflow.ellipsis,),
                                         ),
                                         Text(diff.inDays>2?'${DMY.format(allchannels[index]['lasttime'].toDate())} ':
                                         diff.inDays>0?'Yesterday'
                                         :'${HM.format(allchannels[index]['lasttime'].toDate())}',style:  const TextStyle(fontSize: 16))
                                       ],
                                     )
                                   ],
                                 ),
                               ),
                              const SizedBox(width: 10,),
                               IconButton(onPressed: ()=> movetochatscreen(currnindex), icon: const Icon(Icons.chat))
                             ],
                           )
                         ],),
                       );
                  },
                );
              }
            );
      }
    );
  }
  getsearchscreen() {
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
         return (s.contains(chatchannelcont.searchemail.value)
         ||element['username'].contains(chatchannelcont.searchemail.value)||
         chatchannelcont.searchemail.value.isEmpty)&&s!=email;
       }).toList() ;
       if(users.length<1)
           return Center(child: Text("we have found nothing like this"),);
     return ListView.builder(itemCount: users.length,itemBuilder:(contxt,index){
       int currindex=chatchannelcont.users.indexWhere((el)=>el==users[index].id);
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
                       IconButton(onPressed:()=> addtochannel(users[index] ), icon:Icon( Icons.add)),
                       IconButton(onPressed: null, icon: Icon(Icons.block)),
                       IconButton(onPressed:currindex==-1?null:()=> movetochatscreen(currindex)
                       ,
                        icon: Icon(Icons.chat))
                     ],
                   ))
                 ]),
       );
     });});
     } ,)
     ;
  }
  addtochannel(dynamic anotheruser) async{ 
   chatchannelcont.isloading.update((val) =>chatchannelcont.isloading.value=true);
      if(chatchannelcont.users.contains(anotheruser.id)){
            Fluttertoast.showToast(msg: 'you already in channel with him',toastLength: Toast.LENGTH_SHORT);
            return;
      }
      dynamic channel = await FirebaseFirestore.instance.collection('chat_channel').
      add({'users':[email,anotheruser.id],
      'messages':null,
      'lasttime':Timestamp.now(),
      'lastmessege':'this channel has no messsage'
      });
      chatchannelcont.channels.add(channel.id);
      chatchannelcont.users.add(anotheruser.id);
      chatchannelcont.usernames.add(anotheruser['username']);

      final channels=anotheruser['channels'],users=anotheruser['users'],usernames=anotheruser['usernames'];
      channels.add(channel.id);
      users.add(email);
      usernames.add(chatchannelcont.username);
      FirebaseFirestore.instance.collection('users').doc(email).update({
        'channels':   chatchannelcont.channels,
        'users': chatchannelcont.users,
        'usernames':chatchannelcont.usernames
      });
      FirebaseFirestore.instance.collection('users').doc(anotheruser.id).update({
      'channels':   channels,
      'users': users,
      'usernames':usernames
      });
         chatchannelcont.isloading.update((val) =>chatchannelcont.isloading.value=false);
         showalertdailog(chatchannelcont.username, anotheruser['username']);

  }
}
