import 'dart:async';
import 'dart:math';
import 'package:chatapp/controller/audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'FullscreenImage.dart';

class Messegbuble extends StatelessWidget {
 final  bool isMe;
 final  Key key;
 final  String messege;
 final  String username;
 final  String imageurl;
 final  String type;
 Duration? duration;
   Messegbuble({
    required this.isMe,
    required this.key,
    required this.messege,
    required this.username,
    required this.imageurl,
    required this.type,
    this.duration
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double width=min(140.0,14.0* max(messege.length,username.length));
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
          width:type=='image'||type=='sound'?null: width,
          child: 
          Column(
            crossAxisAlignment:isMe? CrossAxisAlignment.start:CrossAxisAlignment.end,
            children: [
              Text(username,style: TextStyle(fontSize: 15 ,color:isMe?Colors.white:Colors.black  ),textAlign: TextAlign.center,),
              if(type=='text')
                Text(messege,style: TextStyle(fontSize: 14 ,color:isMe?Colors.white:Colors.black ),textAlign: TextAlign.left),
            if(type=='image')
                 make_image(context),
            if(type=='sound') 
                 make_sound(url: messege,duration: duration!,)    
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
       )) ],
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
      onTap:imageurl.contains('wiaitng')?null:()=>  Navigator.push(context,
              MaterialPageRoute(builder: (_) {
                return FullScreenImage(
                  imageUrl:
                  messege,
                  tag: key.toString(),
                );
              })),
    );
  }
}
class make_sound extends StatefulWidget{
  const make_sound({Key? key,
  required this.url,
  required this.duration,
  }) : super(key: key);
  final String url;
  final Duration duration;
  @override
  State<make_sound> createState() => _make_soundState();
}

class _make_soundState extends State<make_sound> {
  Duration max_dur=const Duration(microseconds: 1),ind= const Duration(milliseconds: 0);
  bool still_loading=false,playing=false;
  final audiomanger=Get.find<Audiomanger>();
  StreamSubscription<Duration>? listhener;
  String error='';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
       const CircularProgressIndicator(),
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
      Duration tmp =await audiomanger.strartnew(url: widget.url);
      setState(() {
        max_dur=tmp;
      });
      listhener= audiomanger.audioPlayer.positionStream.listen((event) {
       if(audiomanger.URL!=widget.url)
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
    super.dispose();
  }
  start_play()async {
    if(audiomanger.URL!=widget.url)
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
}