import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shared.dart';
import 'call_controller.dart';

class IncomingCall extends StatefulWidget {
  @override
  _IncomingCallState createState() => _IncomingCallState();
}

class _IncomingCallState extends State<IncomingCall> {
  CallController callController = Get.put(CallController());
  String type = Get.arguments;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor.value,
      body: Column(
        children: [
          txt("$type Call", txtColor.value, 20, false),
          txt("Caller name", mainColor, 20, false),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              circleIcon(Colors.redAccent, Colors.white, Icons.close, 30,
                  "Reject", () => callController.leaveCall()),
              circleIcon(Colors.green, Colors.white, Icons.phone, 30, "Accept",
                  () {
                Get.toNamed(type == "Audio" ? "/audioCall" : "/videoCall",
                    arguments: false);
              }),
            ],
          )
        ],
      ),
    );
  }
}
