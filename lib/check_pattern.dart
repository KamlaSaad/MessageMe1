import 'package:chatting/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shared.dart';

class CheckPattern extends StatelessWidget {
  bool cancel = Get.arguments ?? false;
  var wrong = false.obs;
  @override
  Widget build(BuildContext context) {
    List pattern = mainController.lockPattern.value;
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
        backgroundColor: bodyColor.value,
        leading: myIcon(Icons.arrow_back, mainColor, 25, () => Get.back()),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Flexible(child: txt("Draw Your pattern", txtColor.value, 26, true)),
          Pattern((List<int> input) {
            print(mainController.lockPattern.value);
            print(input);
            if (listEquals(input, pattern)) {
              print(pattern);
              if (cancel) {
                mainController.changePatternVals("", "", [], false);
                Get.back();
              } else {
                Get.offAllNamed("/home");
              }
            } else {
              wrong.value = true;
              snackMsg("Wrong Pattern", "Please try again");
            }
          }),
          cancel
              ? Space(0, 0)
              : Obx(
                  () => lockBtn(wrong.value ? mainColor : Colors.transparent)),
        ],
      ),
    );
  }
}
