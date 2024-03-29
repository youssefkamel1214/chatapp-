import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ChannelShower extends StatelessWidget {
  final String title, imageurl, lastmessege, time, type;
  Function function;
  ChannelShower({
    Key? key,
    required this.title,
    required this.imageurl,
    required this.lastmessege,
    required this.time,
    required this.type,
    required this.function,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25.sp,
                          backgroundImage: Image.network(
                            imageurl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;

                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Text('Some errors occurred!'),
                          ).image,
                          backgroundColor: null,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        if (type == 'text') textmess(),
                        if (type == 'image') imagmess(),
                        if (type == 'sound') micmess(),
                        if (type == 'video') viedmess(),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(time, style: const TextStyle(fontSize: 16))
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              IconButton(
                  onPressed: () => function(), icon: const Icon(Icons.chat))
            ],
          )
        ],
      ),
    );
  }

  Expanded textmess() {
    return Expanded(
      child: Text(
        lastmessege,
        maxLines: 1,
        style: TextStyle(fontSize: 12.sp),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget imagmess() {
    return Expanded(
      child: Row(
        children: [
          Icon(
            Icons.photo,
            size: 12.sp,
          ),
          SizedBox(
            width: 1.w,
          ),
          Text(
            'image was sent',
            style: TextStyle(fontSize: 8.sp),
          )
        ],
      ),
    );
  }

  Widget micmess() {
    return Expanded(
      child: Row(
        children: [
          Icon(Icons.mic, size: 12.sp),
          SizedBox(
            width: 1.w,
          ),
          Text('voice was sent', style: TextStyle(fontSize: 8.sp))
        ],
      ),
    );
  }

  Widget viedmess() {
    return Expanded(
      child: Row(
        children: [
          Icon(Icons.video_collection_rounded, size: 12.sp),
          SizedBox(
            width: 1.w,
          ),
          Text('video was sent', style: TextStyle(fontSize: 8.sp))
        ],
      ),
    );
  }
}
