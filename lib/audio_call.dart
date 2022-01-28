import "package:flutter/material.dart";
import 'call_controller.dart';
import 'package:get/get.dart';
import 'shared.dart';
import 'timer.dart';
import 'dart:async';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({Key? key}) : super(key: key);

  @override
  _AudioCallScreenState createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  CallController callController = Get.put(CallController());
  late TimerController tc;
  var calling = false.obs;
  bool caller = Get.arguments[0];
  Map call = Get.arguments[1], userData = {};
  int i = 0;
  late Timer waitTimer;
  String name = "", img = "";
  @override
  void initState() {
    userData = mainController.getUser(call['receiverId']);
    name = mainController.isContact(userData['phone']);
    img = mainController.getFriendImg(userData['imgs']);
    caller
        ? callController.initCall(call['type'], call['receiverId'])
        : callController.joinCall();
    waitTimer =
        Timer.periodic(Duration(seconds: 1), (timer) => incrementWaitTimer());
    super.initState();
  }

  void incrementWaitTimer() {
    int uid = callController.remoteUid.value;
    if (uid != 0) {
      waitTimer.cancel();
      tc = Get.put(TimerController());
      tc.startTimer();
      calling.value = true;
    } else if (i < 60 && uid == 0) {
      i++;
    } else {
      waitTimer.cancel();
      callController.leaveCall();
      Get.back();
    }
  }

  @override
  void dispose() {
    callController.leaveCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
//                Space(0, Get.height * 0.15),
                ProfileImg(80, img, "user"),
                Space(0, 10),
                txt(
                    callController.remoteUid.value == 0
                        ? "Calling …"
                        : "Calling with ${call['receiverId']}",
                    mainColor,
                    22,
                    true),
                Space(0, 10),
                Obx(() => calling.value
                    ? txt(tc.result.value, txtColor.value, 22, false)
                    : Space(0, 0)),
              ],
            ),
          ),
          Positioned(
              bottom: Get.height * 0.02,
              right: Get.width * 0.1,
              child: myIcon(Icons.call_end, Colors.redAccent, 54,
                  () => callController.leaveCall())),
        ],
      ),
    );
  }
}
