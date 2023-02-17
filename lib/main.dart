import 'package:chatapp/controller/Auth_provider.dart';
import 'package:chatapp/controller/chats_channelcont.dart';
import 'package:chatapp/screens/AuthScreen.dart';
import 'package:chatapp/screens/homescreen.dart';
import 'package:chatapp/screens/splashscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'firebase_options.dart';

Rx<bool> loading = true.obs;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) => loading.update((val) => loading.value = false));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Chatchannelcont chatchannelcont = Chatchannelcont();
    Get.put(Authprovider());
    Get.put(chatchannelcont);
    return Sizer(
      builder: (context, orientation, deviceType) => GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromARGB(255, 44, 138, 161),
            accentColorBrightness: Brightness.dark,
            appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromARGB(255, 44, 138, 161),
                elevation: .5),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.sp)))),
            buttonTheme: ButtonTheme.of(context).copyWith(
                buttonColor: Colors.pink,
                textTheme: ButtonTextTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                )),
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink)
                .copyWith(secondary: Colors.deepPurple)
                .copyWith(background: const Color.fromARGB(255, 44, 138, 161))),
        darkTheme: ThemeData(
            backgroundColor: const Color.fromARGB(255, 33, 35, 36),
            scaffoldBackgroundColor: const Color.fromARGB(255, 33, 35, 36),
            accentColorBrightness: Brightness.light,
            appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromARGB(255, 33, 35, 36),
                elevation: .5,
                systemOverlayStyle: SystemUiOverlayStyle.dark),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.sp)))),
            buttonTheme: ButtonTheme.of(context).copyWith(
                buttonColor: Colors.pink,
                textTheme: ButtonTextTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.sp),
                )),
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink)
                .copyWith(secondary: Colors.deepPurple)),
        debugShowCheckedModeBanner: false,
        home: Obx(() {
          return loading.value
              ? const Splashscreen(
                  content: 'we make ever thing ready',
                )
              : StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Splashscreen(
                          content: 'we make ever thing ready');
                    if (snapshot.hasData)
                      return MyHomePage(
                        email: FirebaseAuth.instance.currentUser!.email!,
                      );
                    else
                      return AuthScreen();
                  },
                );
        }),
      ),
    );
  }
}
