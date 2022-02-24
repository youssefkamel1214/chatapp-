import 'package:chatapp/controller/Auth_provider.dart';
import 'package:chatapp/controller/chats_channelcont.dart';
import 'package:chatapp/screens/AuthScreen.dart';
import 'package:chatapp/screens/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
  
   
   Chatchannelcont chatchannelcont= Chatchannelcont();
    Get.put(Authprovider());
    Get.put(chatchannelcont);
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        backgroundColor: Colors.pink,
        accentColor: Colors.deepPurple,
        accentColorBrightness: Brightness.dark,
        elevatedButtonTheme:ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
          primary: Colors.pink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          )
          )
        ) ,
        buttonTheme:ButtonTheme.of(context).copyWith(
          buttonColor: Colors.pink,
          textTheme:ButtonTextTheme.primary ,  
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          )
        ) 
      ),
      debugShowCheckedModeBanner:false,
      home:  StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),builder: (ctx,snapshot){
        if(snapshot.hasData)
          return MyHomePage(email: FirebaseAuth.instance.currentUser!.email!,);
        else 
          return AuthScreen() ;
      },),
    );
  }
}

