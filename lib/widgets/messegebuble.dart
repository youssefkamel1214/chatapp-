import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flowder/flowder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:linkwell/linkwell.dart';
import 'package:open_file/open_file.dart';
import 'package:chatapp/controller/audio_controller.dart';
import 'package:chatapp/controller/messege_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'FullscreenImage.dart';

class Messegbuble extends StatelessWidget {
 final  bool isMe;
 final  Key key;
 final  String messege;
 final  String username;
 final  String imageurl;
 final  String type;
 final bool seen;
 final  Messegcontroller messegcontroller=Get.find<Messegcontroller>();
 Duration? duration;

  String? exte;
   Messegbuble({
    required this.isMe,
    required this.key,
    required this.messege,
    required this.username,
    required this.imageurl,
    required this.type,
    required this.seen,
    this.duration,
    this.exte
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double width=min(140.0,16.0* max(messege.length,username.length));
    double stackpadd=120*width/140;
    return Stack(
      children: [
       Row(
        mainAxisAlignment: isMe?MainAxisAlignment.start:MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
                color: isMe?Theme.of(context).accentColor:Colors.grey[300] ,
                borderRadius: BorderRadius.only(
                  topLeft:const Radius.circular(14),
                  topRight:const Radius.circular(14),
                  bottomLeft:isMe? const Radius.circular(0): const Radius.circular(14),
                  bottomRight:isMe?const Radius.circular(14):const Radius.circular(0),
                )
          ),
          padding:const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16.0),
          margin:const EdgeInsets.symmetric(vertical: 16.0,horizontal: 8.0),
          width:type=='image'||type=='sound'||type=='video'?null: width,
          child: 
          Column(
            crossAxisAlignment:isMe? CrossAxisAlignment.start:CrossAxisAlignment.end,
            children: [
              Text(username,style: TextStyle(fontSize: 15 ,color:isMe?Colors.white:Colors.black  ),textAlign: TextAlign.center,),
              if(type=='text')
                LinkWell(messege,style: TextStyle(fontSize: 14 ,color:isMe?Colors.white:Colors.black ),
                linkStyle:const TextStyle(color: Colors.blue,fontSize: 14),
                textAlign: TextAlign.left),
            if(type=='image')
                 make_image(context),
            if(type=='sound') 
                 make_sound(url: messege,duration: duration!,id: key.toString(),),
            if(type=='video')
                 make_video(isme: isMe,
                 url: messege,seen: seen,id: key.toString(),), 
            if(type=='location')
                 makelocation(messege),  
            if(type=='doc')   
                 make_doc(context,messege,exte!),       
            if(isMe&&type!='video')
            SizedBox(
              width: type=='text'||type=='location'?width:type=='image'?150:type=='sound'?216:45,
              child: Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(seen? Icons.visibility:Icons.visibility_off)
              ],),
            )         
            ],
          ),
          )
        ],
      ),
     Positioned(
     left: isMe?(type!='image'?type=='sound'?220 : stackpadd:170):null,
     right: isMe?null:((type!='image')?type=='sound'?220 : stackpadd:170),
       child: CircleAvatar(
         backgroundImage: 
         Image.network(
                  imageurl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child:CircularProgressIndicator(color: Colors.white,) ,  );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const  Text('Some errors occurred!'),
                  ).image , 
       )),
        ],
    );
  }
  make_image(BuildContext context) {
    return GestureDetector(
      child:Hero(
        tag: key.toString(),
        child: Container(
          child: messege.contains('wiaitng')?const Center(child: CircularProgressIndicator(),):null,
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            image:messege.contains('wiaitng')?null: DecorationImage(
              fit: BoxFit.fill,
              image:    Image.network(
                    messege,
                    loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child:CircularProgressIndicator(color: Colors.white,) ,  );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                    const  Text('Some errors occurred!'),
                    ).image
            )
          ),
        ),
      ),
      onTap:imageurl.contains('wiaitng')?null:()=>  Get.to(()=>
    FullScreenImage(
                  imageUrl:
                  messege,
                  tag: key.toString(),
                 ))

    );
  }

 Widget makelocation(String messege) {
   return 
        Center(
          child: IconButton(onPressed: ()async{       
             await launch(messege);
          }, icon:const Icon (Icons.location_on,size: 30,)),
        );
 }

  make_doc(BuildContext context, String messege,String ext) {
    return Center(
          child: IconButton(onPressed: ()async{       
             Directory? dic=await getExternalStorageDirectory();
             if(dic==null)
             throw 'un acceptable';
             String filepath=dic.path+'/chats/documnts';
             String filename=key.toString()+'.'+ext; 
             if(await  file_exists(filename,filepath)==false)
           {  dowlouadfromurl(filename, 'documnts', messege, (Value){
             }, (){
               OpenFile.open(filepath+'/$filename');
             });
           }
           else{
              OpenFile.open(filepath+'/$filename');
           }
          }, icon:const Icon (Icons.article_rounded,size: 30,)),
        );
  }
}
class make_sound extends StatefulWidget{

  const make_sound({Key? key,
  required this.url,
  required this.duration,
  required this.id,
  }) : super(key: key);
  final String url;
  final Duration duration;
  final  String id;
  @override
  State<make_sound> createState() => _make_soundState();
}

class _make_soundState extends State<make_sound> {
  Duration max_dur=const Duration(microseconds: 1),ind= const Duration(milliseconds: 0);
  bool still_loading=false,playing=false;
  final audiomanger=Get.find<Audiomanger>();
  StreamSubscription<Duration>? listhener;
  String error='';
      String url2 = '';

  DownloaderCore? _core;

  double _percent=0.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    inilze_pathes();
    max_dur=widget.duration;
  }
  @override
  Widget build(BuildContext context) {
  String todis='${max_dur.inMinutes}:${max_dur.inSeconds}';
  if(ind.inMilliseconds>0)
     todis='${ind.inMinutes}:${ind.inSeconds}';
   return Row(
   children: [
     if(still_loading)
        CircularPercentIndicator(
        radius: 20,
        lineWidth: 1,
        percent: _percent,
        animation: true,
        animationDuration: 100,
        progressColor: Colors.pink,
        backgroundColor: Get.isDarkMode?Colors.black:Colors.white,
       ),
     if(!still_loading) 
        IconButton(onPressed:()=> !playing?start_play():pause_play(), icon:Icon(playing?Icons.pause:Icons.play_arrow) ),
        Text(todis,style: TextStyle(fontSize: 14),),
        Container(
          width: 140,
          child: Slider(value: ind.inMilliseconds.toDouble(),max: max_dur.inMilliseconds.toDouble(),
          onChanged:(val)=>audiomanger.audioPlayer.seek(Duration(milliseconds:val.ceil() )) ,
          ),
        )

],
   );
  }

  Future<void> inlaze_var()async {
    try{
      setState(() {
        still_loading=true;
        playing=false;
      });
           
      Duration tmp =await audiomanger.strartnew(url: url2);
      setState(() {
        max_dur=tmp;
      });
      listhener= audiomanger.audioPlayer.positionStream.listen((event) {
       if(audiomanger.URL!=url2)
            cancel_stream();  
      setState(() {
      ind=event;
      ind.inMilliseconds>max_dur.inMilliseconds?ind=max_dur:null;
      if(ind.inMilliseconds==max_dur.inMilliseconds)
        {
          ind=const Duration(milliseconds: 0);
          pause_play();
          audiomanger.audioPlayer.seek(ind);
        }
      });
        });
      setState(() {
        still_loading=false;
      });
    
    }catch(e){
      error='$e';
    }
  }
  @override
  void dispose() {
    if(listhener!=null)
    listhener!.cancel();
    playing=false;
    if(audiomanger.URL==widget.url){
    audiomanger.audioPlayer.stop();
    audiomanger.make_empty();
    }
    if(_core!=null&&still_loading)
    _core!.cancel();   
    super.dispose();
  }
  start_play()async {
    if(audiomanger.URL!=url2)
            await inlaze_var();
    audiomanger.audioPlayer.play();
    setState(() {
      playing=true;
    });
  }

  pause_play() {
        audiomanger.audioPlayer.pause();
        setState(() {
      playing=false;
    });

  }

  void cancel_stream() {
    if(listhener!=null)
   listhener!.cancel();
   setState(() {
     playing=false;
   });
  }

  Future<void> dowlnload_file() async {
    _core=await dowlouadfromurl( '${widget.id}.aac', 'records',widget.url,(val){
      setState(() {
        _percent=val;
      });
    },null);
  }

  void inilze_pathes() async{
    setState(() {
      still_loading=true;
    });
      Directory? dic= await getExternalStorageDirectory();
            if(dic==null)
                throw 'un acceplte';
            String filepath =dic.path+'/chats/records';
            if(await  file_exists('${widget.id}.aac',filepath)==false)
                  await   dowlnload_file();   
      url2 = filepath+'/${widget.id}.aac';
   url2 = filepath+'/${widget.id}.aac';
    setState(() {
      still_loading=false;
    });
  }
}
class make_video extends StatefulWidget {
  final String url;
  final bool seen;
  final bool isme;
  final String id;
  const make_video({
    Key? key,
    required this.url,
    required this.seen,
    required this.isme,
    required this.id,
  }) : super(key: key);
  @override
  State<make_video> createState() => _make_videoState();
}

class _make_videoState extends State<make_video> {
  VideoPlayerController? _controller;
    DownloaderCore? _core;

  double _percent=0.0;
 @override
  void initState() {
    super.initState();
    inilzee();
  
  }
  @override
  void dispose() {
    super.dispose();
    if(_controller!=null)
       _controller!.dispose();
    if(_core!=null&&_controller==null)
    _core!.cancel();   
  }
  @override
  Widget build(BuildContext context) {
    _controller==null?null:
    print(_controller!.value.size);
    return Container(
      width: 220,
      child:_controller==null?Center(child: CircularPercentIndicator(
        radius: 20,
        lineWidth: 1,
        percent: _percent,
        animation: true,
        animationDuration: 100,
        progressColor: Colors.pink,
        backgroundColor: Get.isDarkMode?Colors.black:Colors.white,
      ),): Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width:_controller!.value.isInitialized?  300:15,
            child: _controller!.value.isInitialized? FittedBox(
              fit: BoxFit.cover,
              child: GestureDetector(
                onTap:() {
                      setState(() {
                      _controller!.value.isPlaying? _controller!.pause()
                      :_controller!.play();
                      });
                } ,
                child: Stack(
                  children: [
                    SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),),
                    ),
                  ],
                ),
              ),
            ):  Container(),
          ),
          SizedBox(height: 15, child: VideoProgressIndicator(_controller!
          , allowScrubbing: true)),
            if(widget.isme)
          Icon(widget.seen? Icons.visibility:Icons.visibility_off)      
            ],
      ),
    );
  }

  Future<void> dowlnload_file(String filepath) async {
    _core=await dowlouadfromurl( '${widget.id}.mp4', 'videos',widget.url,(val){
              setState(() {
                _percent=val;
              });
    },(){
      
        _controller=VideoPlayerController.
                file(File(filepath+'/${widget.id}.mp4'));
                _controller!.initialize().then((value) {
                  setState(() {
                  });
                });
    });
  }

  void inilzee() async{  
     Directory? dic= await getExternalStorageDirectory();
            if(dic==null)
                throw 'un acceplte';
            String filepath =dic.path+'/chats/videos';
            if(await  file_exists('${widget.id}.mp4',filepath)==false)
                  await   dowlnload_file(filepath);   
            else{
               _controller=VideoPlayerController.
                file(File(filepath+'/${widget.id}.mp4'));
                _controller!.initialize().then((value) {
                  setState(() {
                  });
                });
            }    
  }

 
}
 Future<bool> file_exists(String filename,String filepath,) async{
bool directoryExists = await Directory(filepath).exists();
bool fileExists = await File('$filepath/$filename').exists();
      return directoryExists&&fileExists;
 }
Future<DownloaderCore> dowlouadfromurl(String filename, String dicname,String url,Function? fnc,Function? fnc4) async {
   Directory? dic= await getExternalStorageDirectory();
       if(dic==null)
          throw 'un acceplte';
       String filepath =dic.path+'/chats/$dicname';   
       if(! await Directory(filepath).exists()){
         if(!await Directory( dic.path+'/chats').exists())
               await Directory( dic.path+'/chats').create();
              await Directory(filepath).create();
       }
              print('sat');
              final downloaderUtils = DownloaderUtils(
                  progressCallback: (current, total) {
                    if(fnc!=null)
                   fnc(current/total);
                  },
                  file: File('$filepath/$filename'),
                  progress: ProgressImplementation(),
                  onDone: () {
                    if(fnc4!=null)
                      fnc4();
                  },
                  deleteOnCancel: true,
                );
                              print('sataaa');
           return  await Flowder.download(url, downloaderUtils);     
}