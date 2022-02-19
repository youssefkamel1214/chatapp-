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
  void get_user(String email)async{
    isloading.update((val) =>isloading.value=true);
    dynamic data=await FirebaseFirestore.instance.collection('users').doc(email).get();
    channels.assignAll(data['channels']);
    users.assignAll(data['users']);
    isloading.update((val) => isloading.value=false);
  }
 void update_search_email(String email){
   searchemail.update((val) { searchemail.value=email;});
 }
 void siwitch_state_of_search(){
   issearchmode.update((val) => issearchmode.value^=true);
 }
 
}