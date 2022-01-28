import 'dart:async';
import 'package:chatting/shared.dart';
import 'package:chatting/test_call.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'call_controller.dart';
import 'profile_img.dart';

class UserProfile extends StatelessWidget {
  CallController callController = Get.put(CallController());
  String userName = "", img = "", contactN = "";
  var user = Get.arguments;
  @override
  Widget build(BuildContext context) {
    contactN = mainController.isContact(user['phone']);
    img = mainController.getFriendImg(user['imgUrl']);
    userName = contactN.isNotEmpty ? contactN : user['username'];
    return Scaffold(
        backgroundColor: bodyColor.value,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: bodyColor.value,
          leading: myIcon(Icons.arrow_back, mainColor, 30, () => Get.back()),
        ),
        body: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    child: ProfileImg(76, img, "user"),
                    onTap: () async {
                      var imgs = user['imgUrl'];
                      if (imgs.length > 0) {
//                        print(imgs);
                        Get.to(ProfileImgViewer(false, userName, imgs, () {}));
                      }
                    },
                  ),
                  Space(0, 10),
                  txt(userName, mainColor, 28, true),
                  Space(0, 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      circleIcon(boxColor.value, txtColor.value,
                          Icons.messenger_outlined, 24, "", () async {
                        Map defaultChat = chatController
                                .defaultChatData(userName, img, [user['id']]),
                            chat = mainController.getChatByUsers(user['id']);
                        chatController.chatData.value =
                            chat.isEmpty ? defaultChat : chat;
                        print(user['id']);
                        Get.toNamed("/chat");
                      }),
                      Space(10, 0),
                      circleIcon(
                          boxColor.value, txtColor.value, Icons.phone, 24, "",
                          () async {
//                        await callController.addCallDoc(
//                            "channel", "audio", 7675774, user['id']);
                        Map call = {"type": "audio", "receiverId": user['id']};
                        Get.toNamed("/audioCall", arguments: [true, call]);
                      }),
                      Space(10, 0),
                      circleIcon(boxColor.value, txtColor.value,
                          Icons.video_call, 24, "", () async {
//                        Get.to(CallPage());
                        var camStatus = Permission.camera.status,
                            micStatus = Permission.microphone.status;
                        if (camStatus != PermissionStatus.granted ||
                            micStatus != PermissionStatus.granted) {
                          await [Permission.microphone, Permission.camera]
                              .request();
                        }
                        Map call = {"type": "video", "receiverId": user['id']};
                        Get.toNamed("/videoCall", arguments: [true, call]);
                      }),
                      Space(10, 0),
                      circleIcon(boxColor.value, txtColor.value, Icons.block,
                          24, "", () => block()),
                    ],
                  )
                ],
              ),
            ),
            Space(0, 15),
            ListItem(Icons.person, "name".tr, user['username']),
            ListItem(Icons.email, "email".tr, user["email"]),
            ListItem(Icons.phone, "phone".tr,
                contactN.isEmpty ? "hidden" : user["phone"]),
            ListItem(Icons.access_time_sharp, "join".tr,
                user["joined"] ?? "12/12/2021"),
          ],
        ));
  }

  Widget ListItem(
    IconData icon,
    String title,
    String val,
  ) {
    return ListTile(
      leading: Icon(icon, size: 34, color: mainColor),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: txt(title, txtColor.value.withOpacity(0.6), 17, false),
      ),
      subtitle: txt(val, txtColor.value, 20, false),
    );
  }

  void block() {
    String name = user['name'];
    confirmBox("${'block'.tr} $name", 'blockDec'.tr, 'block'.tr, () async {
      await mainController.block(user['id']);
      mainController.blockedUsers.remove(user['id']);
      Get.back();
      Get.back();
      Timer(Duration(seconds: 1),
          () => snackMsg("done".tr, "youBlocked".tr + " $name"));
    }, () => Get.back());
  }
}
