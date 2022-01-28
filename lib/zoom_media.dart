import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'shared.dart';

class ZoomMedia extends StatelessWidget {
  String type = "", url = "";
  var isPlaying = false.obs;
  ZoomMedia(type, url) {
    this.type = type;
    this.url = url;
  }
  @override
  Widget build(BuildContext context) {
//    VideoPlayerController vc = VideoPlayerController.network(url)..initialize();
    return Scaffold(
      body: Container(
          width: Get.width,
          height: Get.height,
          color: bodyColor.value,
          child: Image.network(
            this.url,
            fit: BoxFit.fill,
          )
//            : GestureDetector(
//                child: null,
//                onTap: () {
//                isPlaying.value = !isPlaying.value;
////                isPlaying.value ? vc.play() : vc.play();
//                },
//              ),
          ),
    );
  }
}
