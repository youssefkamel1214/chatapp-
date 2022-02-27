import 'dart:async';
import 'dart:ffi';

import 'package:chatapp/controller/sendmessagecont.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Messegcontroller extends GetxController {
   Rx<bool>loading=true.obs;
   int inialindex=-1;
   final String id;
   final String useremail;
   final String username;
   final List<dynamic>imagesurls=[];
   final List<dynamic>emails=[];
   final List<dynamic>messeges=[].obs;
  Messegcontroller({
    required this.id,
    required this.useremail,
    required this.username,
  }){
    inilize_channelstream();
 
  }
   late StreamSubscription streamSubscription;
   late StreamSubscription streamSubscription2;
   @override
  void dispose() {
    streamSubscription.cancel();
    streamSubscription2.cancel();
    super.dispose();
  }

  void inilize_channelstream() async{
     final s1= FirebaseFirestore.instance.collection('chat_channel').doc(id).snapshots(includeMetadataChanges:true );
  streamSubscription=  s1.listen((data)  {
      if(data.data()==null)
        {
          Get.back();
          return;
        }

      int currentindex=data['users'].indexWhere((elment)=>elment==useremail);
      emails.assignAll(data['users']);
      imagesurls.assignAll(data['usersimages']);
        final Sendmessegecontroller sendmescont=Get.find<Sendmessegecontroller>();
        sendmescont.upadate_lentghtbool(emails.length,currentindex);
      inilize_messege_steam();
     });
  }

  void inilize_messege_steam()  {
    final s2= FirebaseFirestore.instance.collection('chat_channel/$id/messages').orderBy('time',descending: true) .snapshots();
    streamSubscription2=s2.listen((event) async{ 
            List<QueryDocumentSnapshot<Map<String, dynamic>>> data=event.docs;
            messeges.removeWhere((element) => !data.contains(element));
            messeges.insertAll(0,data.where((element) => !messeges.contains(element)));
            messeges.sort((channel1,channel2){
                        if(channel1['time'].toDate().isBefore(channel2['time'].toDate()))
                              return 1;
                        else if(channel2['time'].toDate().isBefore(channel1['time'].toDate())) 
                              return -1; 
                        else 
                              return 0;     
                         });
            if(inialindex==-1&&messeges.isNotEmpty){
                  inialindex= messeges.indexWhere((elment) {
                    return (!(elment['seen'].contains(false)))||elment['email']==useremail;
                    });
                  if(inialindex==-1)
                    inialindex=messeges.length;  
            }  
            loading.update((val) => loading.value=false);   
       });
  }
  void updateseen(int index){
    if(messeges[index]['email']==useremail)
      return;
    final List<dynamic>seens=messeges[index]['seen'];                   
    int boolindex=emails.indexWhere((element) =>element==useremail);
    seens[boolindex]=true;
    FirebaseFirestore.instance.collection('chat_channel/$id/messages').doc(messeges[index].id).update({'seen':seens});
  }

  Future<void> update_seen(dynamic data) async{
    do {
       int tmp=-1;
       int id=  messeges.indexWhere((element) {
               tmp=data.indexWhere((element2) => element.id==element2);
                if(tmp==-1)
                  return false;
                if(element['seen']!=data[tmp]['seen'])
                  return true;
                return false;  
            },);
            if(id!=-1)
              messeges[id]['seen'] =data[tmp]['seen'];
    } while (id!=-1);
        
  }
}
