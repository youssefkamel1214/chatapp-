import 'dart:io';
import 'dart:async';
import 'package:chatapp/widgets/messegebuble.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart'as audplay;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum Status { 
   none, 
   running, 
   stopped, 
   paused 
}
class Sendmessegecontroller extends GetxController {
Status status=Status.none;
final FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder(logLevel:Level.nothing );
 bool recoderinal=false;
 StreamSubscription? _recorderSubscription;
 final audplay.AudioPlayer audioPlayer=audplay.AudioPlayer();
 String recordpath='';
 Rx<String>message=''.obs;
 Rx<int>lenthbool=0.obs;
 DateTime? timeofrecord;
 final String useremail;
 final String id;
 final String username;
 int index=-1;
 Rx<String>imagepath=''.obs;
 Rx<bool>isrecodmode=false.obs;
 Rx<bool>recordfinish=false.obs;
 Rx<int>socendspast=0.obs;
 Rx<bool>waitingforsend=false.obs;
 Duration? maxtime=null;
 final dcblevls=[].obs;
 Rx<Duration>durrec= Duration(milliseconds: 0).obs;
  Sendmessegecontroller({
     required this.useremail,
     required this.id,
     required this.username,
  }){
    inailaze_recoder();
  }
  void upadate_lentghtbool(int len,int index){
    lenthbool.update((val) => lenthbool.value=len);
    this.index=index;
  }
  void upadatemessege(String mes){
    if(mes.isNotEmpty)
      imagepath.update((val) => imagepath.value='');   
    message.update((val) => message.value=mes);
  }

  void updatefileimage(BuildContext context,bool camra ,TextEditingController controller) async{
    Get.focusScope!.unfocus();
       final ImagePicker _picker = ImagePicker();
       final XFile?image;
        if(camra)
           image = await _picker.pickImage(source: ImageSource.camera
           ,imageQuality: 70);
        else
           image = await _picker.pickImage(source: ImageSource.gallery,
           imageQuality:70 );
     if(image==null)
        return;
    controller.clear();
    upadatemessege('');   
    imagepath.update((val) => imagepath.value=image!.path);
    if(imagepath.value.isNotEmpty)
      sendimage(context, controller);

 }
 void sendnewmess(String type,String content,Duration? duration,String? ext){
    final boolarr=[];
    for(int i=0;i<lenthbool.value;i++)
     boolarr.add(false);
    boolarr[index]=true; 
    print(duration);
    FirebaseFirestore.instance.collection('chat_channel/$id/messages').add({
        'type':type,
        'content':content,
        'time':Timestamp.now(),
        'email':useremail,
        'username':username,
        'seen':boolarr,
        'ext':ext,
        'duration':duration!=null?duration.inMilliseconds:null
      }).then((value) => waitingforsend.update((val) => waitingforsend.value=false));
 }
  void sendmessge(BuildContext context,TextEditingController controller){
        waitingforsend.update((val) => waitingforsend.value=true);
        FocusScope.of(context).unfocus();
        controller.clear();
        String content=message.value.trim();
        upadatemessege('');
        sendnewmess('text', content,null,null);
        FirebaseFirestore.instance.collection('chat_channel').doc(id).update({
          'lasttime':Timestamp.now(),
          'lastmessege':content,
          'type':'text'
        });
  }
  void sendlocation(BuildContext context,TextEditingController controller)async{
        waitingforsend.update((val) => waitingforsend.value=true);
        FocusScope.of(context).unfocus();
        controller.clear();
        Position position = await 
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        
        String content='https://maps.google.com/maps/search/?&query=${position.latitude},${position.longitude}';
        upadatemessege('');
        sendnewmess('location', content,null,null);
        FirebaseFirestore.instance.collection('chat_channel').doc(id).update({
          'lasttime':Timestamp.now(),
          'lastmessege':content,
          'type':'location'
        });
  }
  void sendimage(BuildContext context,TextEditingController controller)async{
      waitingforsend.update((val) => waitingforsend.value=true);
      FocusScope.of(context).unfocus();
      controller.clear();
      upadatemessege('');
      String path=imagepath.value;
      imagepath.update((val) => imagepath.value='');   
      DateTime savetime= DateTime.now();
      final ref=  FirebaseStorage.instance.ref().child('chat_images').
      child('$savetime.jpg');
      await ref.putFile(File(path));
      final image_url=await ref.getDownloadURL();
      sendnewmess('image', image_url,null,null);
      FirebaseFirestore.instance.collection('chat_channel').doc(id).update({
        'lasttime':Timestamp.now(),
        'lastmessege':'image was sent',
        'type':'image'
      });
  }
void sendvideo(BuildContext context,TextEditingController controller)async{
      waitingforsend.update((val) => waitingforsend.value=true);
      FocusScope.of(context).unfocus();
      controller.clear();
      upadatemessege('');
      String path=imagepath.value;
      imagepath.update((val) => imagepath.value='');   
      DateTime savetime= DateTime.now();
      final ref=  FirebaseStorage.instance.ref().child('chat_images').
      child('$savetime.mp4');
      await ref.putFile(File(path));
      final image_url=await ref.getDownloadURL();
      sendnewmess('video', image_url,null,null);
      FirebaseFirestore.instance.collection('chat_channel').doc(id).update({
        'lasttime':Timestamp.now(),
        'lastmessege':'video was sent',
        'type':'video'
      });
  }

void sendrecord(BuildContext context,TextEditingController controller)async{
  try{
            waitingforsend.update((val) => waitingforsend.value=true);
            FocusScope.of(context).unfocus();
            controller.clear();
            isrecodmode.update((val) => isrecodmode.value=false);
            upadatemessege('');
            if(!_mRecorder!.isStopped)
                stoprecord();
            String path=recordpath+'$timeofrecord.aac';
            Duration? totdu=durrec.value;
            imagepath.update((val) => imagepath.value='');   
            DateTime savetime= DateTime.now();
            final ref=  FirebaseStorage.instance.ref().child('chat_records').
            child('$savetime.aac');
            await ref.putFile(File(path));
            candelrecord();
            final record_url=await ref.getDownloadURL();
            sendnewmess('sound', record_url,totdu,null);
            FirebaseFirestore.instance.collection('chat_channel').doc(id).update({
              'lasttime':Timestamp.now(),
              'lastmessege':'sound was sent',
              'type':'sound'
            });
  }catch(e){
    print('error=$e');
  }
  }
 void sendfile(BuildContext context,TextEditingController controller,String path,String ext)async{
      waitingforsend.update((val) => waitingforsend.value=true);
      FocusScope.of(context).unfocus();
      controller.clear();
      upadatemessege('');
      DateTime savetime= DateTime.now();
      final ref=  FirebaseStorage.instance.ref().child('chat_doc').
      child('$savetime.$ext');
      await ref.putFile(File(path));
      final image_url=await ref.getDownloadURL();
      sendnewmess('doc', image_url,null,ext);
      FirebaseFirestore.instance.collection('chat_channel').doc(id).update({
        'lasttime':Timestamp.now(),
        'lastmessege':'video was sent',
        'type':'doc'
      });
  } 
  void senddcomuntfile(BuildContext context,TextEditingController controller)async{
 FilePickerResult? result = await FilePicker.platform.pickFiles(
   type: FileType.custom,
   allowedExtensions: ['docx','doc','pdf','txt','ppt','pptx']
 );

if (result != null) {
  PlatformFile file = result.files.first;
    sendfile(context,controller,file.path!,file.extension!);
} else {
  // User canceled the picker
}
  }
  void inailaze_recoder() async{
    try{
      if(!await checkpremsion())
       await take_premssion();
       Directory? dic= await getExternalStorageDirectory();
       if(dic==null)
          throw 'un acceplte';
       recordpath=dic.path+'/records/';   
       if(! await Directory(recordpath).exists())
              await Directory(recordpath).create();     
      await _mRecorder!.openRecorder();
       _recorderSubscription = _mRecorder!.onProgress!.listen((e) {
         durrec.update((val) => durrec.value= e.duration);
         dcblevls.add(e.decibels);
        } 
    ); 
    await _mRecorder!.setSubscriptionDuration(Duration(milliseconds: 50)); 
    recoderinal=true;
    }catch (e)  {
      print(e);
    }
  }
bool get isrecoding =>  _mRecorder!.isRecording||_mRecorder!.isPaused;

  void startrecord()async{
    upadatemessege('');
    imagepath.update((val) => imagepath.value='');
    while(!recoderinal);
    recordfinish.update((val) => recordfinish.value=false);
    try{
      if(!await checkpremsion())
        await take_premssion();
        timeofrecord=DateTime.now();
      if(_mRecorder!=null)
        await _mRecorder!.startRecorder(codec: Codec.aacMP4,toFile:recordpath+'$timeofrecord.aac');
      else
          timeofrecord=null;
    }catch(e){
      print('error= $e');
    } 
  }
  Future<void> stoprecord()async{
          try{
            if(_mRecorder!=null)
            await _mRecorder!.stopRecorder();
          }
          catch( e)
          {
            timeofrecord=null;
            print(e);
          }
          recordfinish.update((val) => recordfinish.value=true);
  }
  void cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription!.cancel();
      _recorderSubscription = null;
    }
  }

  @override
  void dispose() {
    _mRecorder!.closeRecorder();
    cancelRecorderSubscriptions();
    super.dispose();    
  }
Future<bool>checkpremsion()async{
  return await Permission.microphone.isGranted&&await Permission.storage.isGranted;
}
  Future<void> take_premssion() async{
     var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
      Fluttertoast.showToast(msg: 'mic is not granted you cant use voice nots');
      }
      status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
      Fluttertoast.showToast(msg: 'storage is not granted you cant use voice nots');
      }
     status=await Permission.location.request();
      if (status != PermissionStatus.granted) {
      Fluttertoast.showToast(msg: 'location is not granted you cant use voice nots');
      }
  }

  void candelrecord() async{
    isrecodmode.update((val) => isrecodmode.value=false);
    durrec.update((val) => durrec.value=const Duration(milliseconds: 0));
    dcblevls.clear();
    await stoprecord();
    try{
    File(recordpath+'$timeofrecord.aac').delete();
    timeofrecord=null;
    }
    catch(e){ print(e);}
  }

  void beginrecoding() {
    isrecodmode.update((val) => isrecodmode.value=true);
    startrecord();
  }

  puase_recordin()async{
    if(!_mRecorder!.isPaused)
    await _mRecorder!.pauseRecorder();
  }

  puase_playing() async{
      status=Status.paused;
     await audioPlayer.pause();

  }

  reuseme_recordin() async{
     if(!_mRecorder!.isRecording)
          await _mRecorder!.resumeRecorder();
  }

  reuseme_playing() async{
    if(status!=Status.paused)
     { 
      maxtime= await audioPlayer.setFilePath(recordpath+'$timeofrecord.aac');
     }
     status=Status.running;
     await audioPlayer.play();
}

  stop_playing() async{
        await audioPlayer.stop();
        status=Status.stopped;
       
  }

  updatevediopaht(BuildContext context, bool camra, TextEditingController controller) async{
      Get.focusScope!.unfocus();
       final ImagePicker _picker = ImagePicker();
       final XFile?image;
        if(camra)
           image = await _picker.pickVideo(source: ImageSource.camera,maxDuration:const Duration(minutes: 5)
          );
        else
           image = await _picker.pickVideo(source: ImageSource.gallery,
           maxDuration: Duration(minutes: 10));
     if(image==null)
        return;
    controller.clear();
    upadatemessege('');  
    print(await image.length()); 
    imagepath.update((val) => imagepath.value=image!.path);
    if(imagepath.value.isNotEmpty)
      sendvideo(context, controller);
  }
}
