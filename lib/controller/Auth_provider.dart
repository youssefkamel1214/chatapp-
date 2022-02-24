import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
class Authprovider extends GetxController{
Rx<bool>islogin=true.obs;
Rx<bool>isloading=false.obs;
Rx<bool>isnonvis=true.obs;
Rx<String>emailerror=''.obs;
Rx<String>passerror=''.obs;
 Rx<String> imagepath=''.obs;
 
 change_state(){
   islogin.update((val)=>  islogin.value^=true);
 }
 void change_password_opic(){
   isnonvis.update((val) {
     isnonvis.value^=true;
     print(isnonvis.value);
   });
 }
 void updatefileimage(bool camra) async{
       final ImagePicker _picker = ImagePicker();
       final XFile?image;
        if(camra)
           image = await _picker.pickImage(source: ImageSource.camera
           ,imageQuality: 50,maxHeight: 150);
        else
           image = await _picker.pickImage(source: ImageSource.gallery,
           imageQuality:50 ,maxWidth: 150);
     if(image==null)
        return;
    imagepath.update((val) => imagepath.value=image!.path);
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
           userCredential= await auth.createUserWithEmailAndPassword(email: email, password: password,);
          final ref=  FirebaseStorage.instance.ref().child('user_images').
           child('${email}.jpg');
          await ref.putFile(File(imagepath.value));
           final image_url=await ref.getDownloadURL();
       await FirebaseFirestore.instance.collection
          ('users').doc(email).set({
            'userid':userCredential.user!.uid,
            'username':user_name,
            'channels':[],
            'users':[],
            'usernames':[],
            'image_url':image_url
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
        on FirebaseStorage catch(e) {
          print('error in fucking Storage: $e');
          await FirebaseAuth.instance.currentUser!.delete();
          Fluttertoast.showToast(msg: 'sorry another error abn a7ba');
          return false;
        }
        catch (e){
          await FirebaseAuth.instance.signOut();
          Fluttertoast.showToast(msg:e.toString(), toastLength: Toast.LENGTH_SHORT);
          isloading.update((val) {isloading.value=false;});
          print(e);
          await FirebaseAuth.instance.currentUser!.delete();
          Fluttertoast.showToast(msg: 'sorry another error abn a7ba');
          return false;
        }
 }
}