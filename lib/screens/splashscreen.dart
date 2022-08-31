import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({Key? key, required this.content}) : super(key: key);
  final String content;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).backgroundColor,
              ]),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            CircleAvatar(
                radius: 40.sp,
                backgroundImage: Image.asset(
                  'assets/images/chat.png',
                ).image),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  content,
                  style: TextStyle(fontSize: 12.sp),
                ),
                SizedBox(
                  width: 5.w,
                ),
                const CircularProgressIndicator()
              ],
            )
          ],
        ),
      ),
    );
  }
}
