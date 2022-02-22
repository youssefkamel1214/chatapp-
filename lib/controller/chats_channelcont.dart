import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';


class Chatchannelcont extends GetxController{
  Rx<bool> issearchmode=false.obs;
  Rx<String>searchemail=''.obs;
  Rx<bool>isloading=true.obs;
  final channels=<dynamic>[].obs;
  final users=<dynamic>[].obs;
  final usernames=<dynamic>[].obs;
  late String username;
  late String imageurl;
  void get_user(String email)async{
    isloading.update((val) =>isloading.value=true);
     Stream stream=FirebaseFirestore.instance.collection('users').doc(email).snapshots(includeMetadataChanges: true);
          stream.listen((data) { 
          isloading.update((val) =>isloading.value=true);
          try{
          if(data['username']!=null){
                channels.assignAll(data['channels']);
                users.assignAll(data['users']);
                usernames.assignAll( data['usernames']); 
                username=data['username'];
                imageurl=data['image_url'];
          }
          }
          catch(e){

            print('error$e');
            stream.timeout(Duration(seconds: 1));

          }
          isloading.update((val) => isloading.value=false);
     });
  }
 void update_search_email(String email){
   searchemail.update((val) { searchemail.value=email;});
 }
 void siwitch_state_of_search(){
   issearchmode.update((val) => issearchmode.value^=true);
 }
 
}