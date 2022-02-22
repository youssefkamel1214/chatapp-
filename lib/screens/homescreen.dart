

import 'package:chatapp/controller/chats_channelcont.dart';
import 'package:chatapp/screens/chatScreen.dart';
import 'package:chatapp/widgets/Channelshower.dart';
import 'package:chatapp/widgets/searchuser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
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
  movetochatscreen(int index,List<String> anoimageurl,List<String> useremails) async {
          Get.to(ChatScreen(useremail: email, title: chatchannelcont.usernames[index],
          id: chatchannelcont.channels[index],username:chatchannelcont.username ,
          imagesurls:anoimageurl,emails: useremails,));
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
                  DateFormat DMY=new DateFormat('dd-MMM-yyyy'),HM=new DateFormat('HH:mm a');
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
                        time: diff.inDays>2?'${DMY.format(allchannels[index]['lasttime'].toDate())} ': diff.inDays>0?'Yesterday'
                        :'${HM.format(allchannels[index]['lasttime'].toDate())}', function: ()=>
                         movetochatscreen(currnindex,imagesurls,useremails));
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
           return const Center(child: Text("we have found nothing like this"),);
     return ListView.builder(itemCount: users.length,itemBuilder:(contxt,index){
       int currindex=chatchannelcont.users.indexWhere((el)=>el==users[index].id);
       return SearchUser(imageurl: users[index]['image_url'], useremail: users[index].id, username: users[index]['username'],
        isexist: currindex!=-1, function1: ()=> addtochannel(users[index] ), function2: 
         ()=> 
         movetochatscreen(currindex,[chatchannelcont.imageurl,users[index]['image_url']],
         [email,users[index].id]));
     });});
     } ,)
     ;
  }
  addtochannel(dynamic anotheruser) async{ 
   chatchannelcont.isloading.update((val) =>chatchannelcont.isloading.value=true);
      if(chatchannelcont.users.contains(anotheruser.id)){
            Fluttertoast.showToast(msg: 'you already in channel with him',toastLength: Toast.LENGTH_SHORT);
      chatchannelcont.isloading.update((val) =>chatchannelcont.isloading.value=false);
      
            return;
      
      }
      dynamic channel = await FirebaseFirestore.instance.collection('chat_channel').
      add({'users':[email,anotheruser.id],
      'usersimages':[chatchannelcont.imageurl,anotheruser['image_url']],
      'lasttime':Timestamp.now(),
      'lastmessege':' no messsage was sent',
      'type':'text'
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
         FirebaseStorage.instance.ref().child('chat_channels').child(channel.id);
         chatchannelcont.isloading.update((val) =>chatchannelcont.isloading.value=false);
         showalertdailog(chatchannelcont.username, anotheruser['username']);

  }
}
