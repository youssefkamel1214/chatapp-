

import 'package:chatapp/controller/chats_channelcont.dart';
import 'package:chatapp/widgets/Channelshower.dart';
import 'package:chatapp/widgets/searchuser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatelessWidget {
   MyHomePage({Key? key,required this.email}) : super(key: key);
  final String email;

final chatchannelcont=Get.find<Chatchannelcont>();
  
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
      ) :const Text('Chat Channels')
      ),
      actions: [
        DropdownButton(underline:Container() ,
        icon: Icon( Icons.more_vert,
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
  show_chat_channels(){
    return    StreamBuilder(stream:FirebaseFirestore.instance.collection('chat_channel').
    where('users',arrayContains:email ).snapshots(includeMetadataChanges: true) ,
      builder: (context,snapshot) {
        return Obx(
              (){ 
                if(chatchannelcont.isloading.value||snapshot.connectionState==ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator(),);
                if(chatchannelcont.channels.isEmpty||! snapshot.hasData)
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
                  final dmy= DateFormat('dd-MMM-yyyy'),hm= DateFormat('HH:mm a');
                  return ListView.builder(
                  itemCount: allchannels.length,
                  itemBuilder: (ctx,index){
                        int currnindex=
                        chatchannelcont.channels.indexWhere((element) => element==allchannels[index].id),
                        differindex=allchannels[index]['users'].indexWhere((elment)=>elment==email);
                        differindex=1-differindex;
                        Duration diff= DateTime.now().difference(allchannels[index]['lasttime'].toDate());
                      final imagesurls = (allchannels[index]['usersimages'] as List).map((e) => e as String).toList();
                      final useremails = (allchannels[index]['users'] as List).map((e) => e as String).toList();
                      return ChannelShower(title: chatchannelcont.usernames[currnindex], 
                      imageurl:  allchannels[index]['usersimages'][differindex]
                      , lastmessege: allchannels[index]['lastmessege'], type: allchannels[index]['type'], 
                        time: diff.inDays>2?'${dmy.format(allchannels[index]['lasttime'].toDate())} ': diff.inDays>0?'Yesterday'
                        :hm.format(allchannels[index]['lasttime'].toDate()), function: ()=>
                        chatchannelcont.movetochatscreen(currnindex));
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
       if(users.isEmpty)
           return const Center(child: Text("we have found nothing like this"),);
     return ListView.builder(itemCount: users.length,itemBuilder:(contxt,index){
       int currindex=chatchannelcont.users.indexWhere((el)=>el==users[index].id);
       return SearchUser(imageurl: users[index]['image_url'], useremail: users[index].id, username: users[index]['username'],
        isexist: currindex!=-1, function1: ()=>chatchannelcont.addtochannel(users[index] ), function2: 
         ()=>  chatchannelcont.movetochatscreen(currindex)
         );
     });});
     } ,)
     ;
  }
 
}
