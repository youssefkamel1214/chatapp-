import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Authprovider extends GetxController{
Rx<bool>islogin=true.obs;
Rx<bool>isloading=false.obs;
Rx<bool>isnonvis=true.obs;
Rx<String>emailerror=''.obs;
Rx<String>passerror=''.obs;
 change_state(){
   islogin.update((val)=>  islogin.value^=true);
 }
 void change_password_opic(){
   isnonvis.update((val) {
     isnonvis.value^=true;
     print(isnonvis.value);
   });
 }
 void clear_errors(){
   emailerror.update((val) {
     emailerror.value='';
   });
   passerror.update((val) {
     passerror.value='';
   });
 }
 Future<bool> submitAuthForm(String email,String password,String user_name,BuildContext context )async{
       final auth=FirebaseAuth.instance;
        UserCredential userCredential;
        isloading.update((val) {isloading.value=true;});
        passerror.update((val) {
          passerror.value='';
        });
        emailerror.update((val) {
          emailerror.value='';
        });
        try{
          if(islogin.value)
            userCredential=await auth.signInWithEmailAndPassword(email: email, password: password);
          else{
           userCredential= await auth.createUserWithEmailAndPassword(email: email, password: password);
           FirebaseFirestore.instance.collection
          ('users').doc(email).set({
            'userid':userCredential.user!.uid,
            'username':user_name,
            'channels':[],
            'users':[]
            }
          )
          ;
          }
          isloading.update((val) {isloading.value=false;});
          return true;    
        }
        on FirebaseAuthException catch(e){
          if(e.message!.contains('password'))
            passerror.update((val) {
              passerror.value=e.message!;
            });
          else if(e.message!.contains('email')||e.message!.contains('user record'))
            emailerror.update((val) {
              emailerror.value=e.message!;
            });
          else {
          Fluttertoast.showToast(msg:e.message!, toastLength: Toast.LENGTH_SHORT);
          }
          isloading.update((val) {isloading.value=false;});
          return false;
        }
        catch (e){
          Fluttertoast.showToast(msg:e.toString(), toastLength: Toast.LENGTH_SHORT);
          isloading.update((val) {isloading.value=false;});
          return false;
        }
 }
}