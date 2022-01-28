import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shared.dart';

class CheckPass extends StatelessWidget {
  final StreamController<bool> verNotifier = StreamController<bool>.broadcast();
  var wrong = false.obs;
  bool cancel = Get.arguments ?? false;
  String pass = mainController.lockPIN.value;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
        backgroundColor: bodyColor.value,
        leading: myIcon(Icons.arrow_back, mainColor, 25, () => Get.back()),
        actions: [
          myIcon(Icons.more_vert, txtColor.value, 24, () {
            confirmBox("Forget Password", "", "Forget", () async {
              mainController.changePatternVals("", "", [], false);
              await mainController.auth.signOut();
              Get.offAllNamed("/verify");
            }, () => Get.back());
          })
        ],
      ),
      body: Pass("Enter Password", (val) {
        print("val $val");
        verNotifier.add(pass == val);
        if (pass == val) {
          if (cancel) {
            //cancel lock
            mainController.changePatternVals("", "", [], false);
            Get.back();
          } else {
            Get.offAllNamed("/home");
          }
        } else {
          wrong.value = true;
          snackMsg("Password doesn't match", "");
        }
      }, verNotifier.stream),
    );
  }
}
