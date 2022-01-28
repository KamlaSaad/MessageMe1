import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shared.dart';

class SetPass extends StatefulWidget {
  @override
  _SetPassState createState() => _SetPassState();
}

class _SetPassState extends State<SetPass> {
  final StreamController<bool> verNotifier = StreamController<bool>.broadcast();
  bool confirm = false;
  String pass = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bodyColor.value,
        appBar: AppBar(
          backgroundColor: bodyColor.value,
          leading: myIcon(Icons.arrow_back, mainColor, 25, () => Get.back()),
        ),
        body: Pass(" ${confirm ? 'Reenter' : 'Enter'} Password", (val) {
          print("val $val");
          if (confirm) {
            if (pass == val) {
              mainController.lockType.value = "PIN";
              mainController.lockPIN.value = val;
              mainController.locked.value = true;
              mainController.storageBox.write("lockType", "PIN");
              mainController.storageBox.write("lockPIN", val);
              mainController.storageBox.write("locked", true);
              print("result $val");
              Get.back();
            } else {
              verNotifier.add(false);
              mainController.locked.value = false;
              setState(() => confirm = false);
              snackMsg("Password doesn't match", "");
            }
          } else {
            mainController.locked.value = false;
            setState(() {
              pass = val;
              confirm = true;
              verNotifier.add(false);
            });
          }
        }, verNotifier.stream));
  }
}
