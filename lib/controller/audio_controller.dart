import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class Audiomanger  {
  String _url='';
  String get URL =>_url; 
  final AudioPlayer audioPlayer;
  Audiomanger({
    required this.audioPlayer,
  });
  void make_empty(){
    _url='';
  }
  Future<Duration> strartnew({required String url})async
  {
      if(_url.isNotEmpty) {
      audioPlayer.stop();
      }
      _url=url;
     await audioPlayer.seek(Duration(milliseconds: 0));
     Duration dur= await audioPlayer.setFilePath(url)??const Duration(milliseconds: 0);
     return dur;
  }

}
