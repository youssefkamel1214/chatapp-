import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';

import 'package:chatapp/controller/sendmessagecont.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class NewMesseges extends StatelessWidget {
  NewMesseges({Key? key}) : super(key: key);
  final controller = TextEditingController();
  final Sendmessegecontroller sendmescont = Get.find<Sendmessegecontroller>();
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Obx(() => sendmescont.message.value.isEmpty &&
                      sendmescont.imagepath.value.isEmpty
                  ? IconButton(
                      onPressed: () async {
                        if (!sendmescont.isrecodmode.value) {
                          sendmescont.beginrecoding();
                        } else {
                          sendmescont.candelrecord();
                        }
                      },
                      icon: sendmescont.isrecodmode.value
                          ? const Icon(Icons.delete)
                          : const Icon(Icons.mic))
                  : Container()),
              Obx(() => sendmescont.message.value.isEmpty &&
                      !sendmescont.isrecodmode.value
                  ? GestureDetector(
                      onTap: () => sendmescont.updatefileimage(
                          context, true, controller),
                      onLongPress: () => sendmescont.updatevediopaht(
                          context, true, controller),
                      child: const Icon(Icons.photo_camera_outlined))
                  : Container()),
              Obx(() => sendmescont.message.value.isEmpty &&
                      !sendmescont.isrecodmode.value
                  ? GestureDetector(
                      onTap: () => showbottomsheet(context, controller),
                      child: const Icon(Icons.attach_file))
                  : Container()),
              Expanded(
                  child: Obx(() => sendmescont.isrecodmode.value
                      ? raw_record()
                      : TextField(
                          controller: controller,
                          style: TextStyle(fontSize: 12.sp),
                          onChanged: (val) => sendmescont.upadatemessege(val),
                          decoration: InputDecoration(
                              labelText: 'Tybe here to send',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                        ))),
              Obx(() {
                return sendmescont.waitingforsend.value ||
                        sendmescont.imagepath.value.isNotEmpty ||
                        sendmescont.lenthbool.value == 0
                    ? const CircularProgressIndicator()
                    : sendmescont.message.isNotEmpty
                        ? IconButton(
                            onPressed: () =>
                                sendmescont.sendmessge(context, controller),
                            color: Get.theme.primaryColor,
                            icon: Icon(
                              Icons.send,
                              size: 16.sp,
                            ))
                        : sendmescont.isrecodmode.value
                            ? IconButton(
                                onPressed: () =>
                                    sendmescont.sendrecord(context, controller),
                                color: Get.theme.primaryColor,
                                icon: Icon(Icons.send, size: 16.sp))
                            : IconButton(
                                onPressed: null,
                                color: Get.theme.primaryColor,
                                icon: Icon(Icons.send, size: 16.sp));
              })
            ],
          ),
          Obx(() => sendmescont.imagepath.isEmpty
              ? Container()
              : Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image:
                                FileImage(File(sendmescont.imagepath.value)))),
                  ),
                ))
        ],
      ),
    );
  }

  raw_record() {
    return Row(
      children: [
        IconButton(
            onPressed: () => sendmescont.isrecoding
                ? sendmescont.stoprecord()
                : sendmescont.stop_playing(),
            icon: const Icon(Icons.stop),
            iconSize: 12.sp),
        IconButton(
            onPressed: () => sendmescont.isrecoding
                ? sendmescont.puase_recordin()
                : sendmescont.puase_playing(),
            icon: const Icon(Icons.pause),
            iconSize: 15),
        IconButton(
          onPressed: () => sendmescont.isrecoding
              ? sendmescont.reuseme_recordin()
              : sendmescont.reuseme_playing(),
          icon: const Icon(Icons.play_arrow),
          iconSize: 15,
        ),
        Obx(() => Text(
            '${(sendmescont.durrec.value.inSeconds / 60).floor()}:${(sendmescont.durrec.value.inSeconds % 60)}')),
        Expanded(
          child: Obx(() => sendmescont.recordfinish.value
              ? make_slider(sendmescont: sendmescont)
              : Container(
                  height: 100,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  child: ListView.builder(
                      itemCount: (sendmescont.dcblevls.length),
                      scrollDirection: Axis.horizontal,
                      controller: scrollController,
                      itemBuilder: (context, index) {
                        if (index > 20)
                          scrollController.jumpTo(
                              scrollController.position.maxScrollExtent);
                        return Center(
                            child: Container(
                          height:
                              min(90, max(sendmescont.dcblevls[index] - 15, 5)),
                          child: const VerticalDivider(
                            width: 3,
                            color: Colors.white,
                          ),
                        ));
                      }),
                )),
        )
      ],
    );
  }

  showbottomsheet(BuildContext context, TextEditingController controller) {
    Get.bottomSheet(
        Container(
          child: GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              GestureDetector(
                onTap: () => sendmescont.senddcomuntfile(context, controller),
                child: const CircleAvatar(
                  child: Icon(Icons.article_rounded),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sendmescont.updatevediopaht(context, false, controller);
                },
                child: const CircleAvatar(
                  child: Icon(Icons.video_camera_back),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sendmescont.updatefileimage(context, false, controller);
                },
                child: const CircleAvatar(
                  child: Icon(Icons.image_outlined),
                ),
              ),
              GestureDetector(
                onTap: () => sendmescont.sendlocation(context, controller),
                child: const CircleAvatar(
                  child: Icon(Icons.location_on),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Get.theme.accentColor);
  }
}

class make_slider extends StatefulWidget {
  const make_slider({
    Key? key,
    required this.sendmescont,
  }) : super(key: key);

  final Sendmessegecontroller sendmescont;

  @override
  State<make_slider> createState() => _make_sliderState();
}

class _make_sliderState extends State<make_slider> {
  double value = 0, maxtime = 1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.sendmescont.audioPlayer.positionStream.listen((event) {
      setState(() {
        widget.sendmescont.maxtime != null
            ? maxtime = widget.sendmescont.maxtime!.inMilliseconds.toDouble()
            : null;
        value = event.inMilliseconds.toDouble();
        if (value > maxtime) value = maxtime;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
        max: maxtime,
        value: value,
        onChanged: (val) {
          widget.sendmescont.audioPlayer
              .seek(Duration(milliseconds: val.ceil()));
        });
  }
}
