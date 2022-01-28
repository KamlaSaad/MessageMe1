import 'dart:async';
import 'package:chatting/media_viewer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'file_viewer.dart';
import 'package:get/get.dart';
import 'chat_controller.dart';
import 'shared.dart';

ChatController controller = Get.put(ChatController());
ScrollController scrollController = ScrollController();

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  var msgContoller = TextEditingController(),
      msg = "".obs,
      chatData = chatController.chatData.value,
      msgKey = Key("").obs;
  String receiverId = "", online = "";

  Color chatColor = mainColor;
  double dismiss = Get.width * 0;
  Map msgData = {}, user = {};
  bool isBlocked = false,
      showReplyBox = true,
      showReactBox = true,
      isGroup = false;
  var queryMessages;
  @override
  Widget build(BuildContext context) {
    receiverId = !isGroup ? chatData['receivers'][0] : "";
    user = mainController.getUser(receiverId);
    isGroup = chatData['type'] == 'chat' ? false : true;
    chatColor = Color(chatData["mainColor"] ?? mainColor.value);
    queryMessages =
        controller.messagesRef.orderByChild("chatId").equalTo(chatData['id']);
    return Scaffold(
        backgroundColor: bodyColor.value,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: bodyColor.value,
            leading: myIcon(Icons.arrow_back, chatColor, 30, () => Get.back()),
            titleSpacing: 2,
            title: GestureDetector(
                child: Row(
                  children: [
                    ProfileImg(
                        20, "${chatData['img']}", isGroup ? "group" : "user"),
                    Space(10, 0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        txt(chatData['name'], chatColor,
                            chatData['name'].length < 15 ? 21 : 18, true),
                        subTitle()
                      ],
                    )
                  ],
                ),
                onTap: () => Get.toNamed("/chatSettings")),
            actions: [
              myIcon(Icons.phone, chatColor, 30, null),
              myIcon(Icons.video_call, chatColor, 30, null),
              Space(5, 0)
            ]),
        body: Container(
          width: Get.width,
          height: Get.height,
          child: Stack(
            children: [
              chatController.chatBackground.value.isNotEmpty
                  ? SizedBox(
                      width: Get.width,
                      height: Get.height,
                      child: Obx(() => Image.network(
                          chatController.chatBackground.value,
                          fit: BoxFit.fill)))
                  : Space(0, 0),
              ListView(
                shrinkWrap: true,
                children: [
                  Stack(
                    children: [
                      Container(
                          height: Get.height * 0.78,
                          width: Get.width,
                          padding: EdgeInsets.only(top: 10, left: 6, right: 6),
                          child: chatData['id'].isNotEmpty
                              ? Obx(
                                  () => FirebaseAnimatedList(
                                      shrinkWrap: true,
                                      key: msgKey.value,
                                      query: queryMessages,
                                      controller: scrollController,
                                      itemBuilder: (context,
                                          DataSnapshot snapshot,
                                          Animation<double> animation,
                                          int i) {
                                        print(
                                            "msg key ${chatController.msgKey.value}");
                                        var snap = snapshot.value;
                                        msgData = {
                                          "id": "${snapshot.key}",
                                          "text": "${snap["text"]}",
                                          "url": "${snap["mediaUrl"]}",
                                          "type": "${snap["type"]}",
                                          "status": "${snap["status"]}",
                                          "date": snap["date"],
                                          "time": mainController
                                              .msgDate("${snap["date"]}"),
                                          "reply": snap['reply'] ?? {},
                                          "react": snap['react'] ?? [],
                                          "sender": snap["senderId"],
                                          "isSender": myId == snap["senderId"]
                                        };
                                        Timer.periodic(
                                            Duration(seconds: 1),
                                            (Timer t) => msgData['time'] =
                                                mainController.msgDate(
                                                    "${snap["date"]}"));
//                                  print("msg id ${msgData['id']}");
                                        var senderData = mainController
                                            .getUser(snap["senderId"]);
                                        String txtT = snap["type"] == 'hint'
                                            ? (msgData['isSender']
                                                ? "I"
                                                : senderData['username']
                                                    .toString())
                                            : "";
                                        msgData['text'] =
                                            "$txtT ${msgData['text']}";
                                        controller.isSender.value =
                                            msgData["isSender"];
                                        return Message(
                                            msgData, chatData['type']);
//
                                      }),
                                )
                              : Space(0, 0)),
                      Positioned(
                          bottom: controller.showReplyBox.isTrue
                              ? Get.height * 0.1
                              : Get.height * 0.01,
                          right: 10,
                          child: Column(
                            children: [
                              scrollBtn(Icons.arrow_upward),
                              Space(0, 5),
                              scrollBtn(Icons.arrow_downward),
                            ],
                          ))
                    ],
                  ),
                  Container(
                    height: Get.height * 0.1,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        myIcon(Icons.add_box_sharp, chatColor, 38,
                            () async => await uploadMsg()),
                        Container(
                            width: Get.width * 0.7,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: boxColor.value,
                            ),
                            child: TextFormField(
                              style: TextStyle(
                                  color: txtColor.value, fontSize: 22),
                              controller: msgContoller,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                hintText: "type".tr,
                                hintStyle: TextStyle(
                                    color: txtColor.value, fontSize: 22),
//                                suffixIcon: Icon(
//                                  Icons.face,
//                                  color: txtColor.value ,
//                                ),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide.none),
                              ),
                            )),
                        circleIcon(mainColor, Colors.white, Icons.send, 25, "",
                            () async {
                          msg.value = msgContoller.text;
//                            await chatController.removerReact();
                          if (msg.value.isNotEmpty) {
                            if (chatData['id'].isEmpty) {
                              msgContoller.clear();
                              List friend = chatData['receivers'];
                              String id = await controller.addChat("",
                                  mainColor, "", "", "chat", [myId, friend[0]]);
                              print(id);
                              if (id.isNotEmpty) {
                                chatController.chatData.value['id'] = id;
                                setState(() {
                                  chatData['id'] = id;
                                  queryMessages = controller.messagesRef
                                      .orderByChild("chatId")
                                      .equalTo(chatData['id']);
                                });
                                addMsg(chatData['id']);
                                msgKey.value = Key(randomString(5));
                                mainController.newChat.value =
                                    !mainController.newChat.value;
                              }
                            } else {
                              addMsg(chatData['id']);
                              msgContoller.clear();
                            }
                          }
                        }),
                      ],
                    ),
                  )
                ],
              ),
              Obx(() => controller.showReplyBox.isTrue
                  ? Positioned(
                      left: 0,
                      bottom: Get.height * 0.1,
                      child: Container(
                        color: boxColor.value,
                        width: Get.width,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Stack(
                          children: [
                            replyBox(controller.replyMsg.value,
                                controller.isSender.value, true),
                            Positioned(
                              top: 0,
                              right: 3,
                              child: myIcon(Icons.close, Colors.grey, 25, () {
                                chatController.toggleReply(false, {}, false);
                              }),
                            )
                          ],
                        ),
                      ))
                  : Space(0, 0)),
              Obx(() => reactsBox())
            ],
          ),
        ));
  }

  Widget subTitle() {
    bool show = user['connected'] == true || isGroup;
    String online = (user['connected'] ?? false) ? "online" : "";
    return show
        ? txt(!isGroup ? "$online".tr : "${chatData['users'].length} members",
            txtColor.value.withOpacity(0.8), 17, false)
        : Space(0, 0);
  }

  void addMsg(String chatId) async {
    await controller.addMsg(
        msg.value, "", "text", chatId, chatData['receivers']);
  }

  Widget scrollBtn(IconData icon) {
    return CircleAvatar(
      backgroundColor: boxColor.value,
      radius: 20,
      child: myIcon(
          icon,
          txtColor.value,
          26,
          () => icon == Icons.arrow_downward
              ? controller.scrollToBottom(scrollController)
              : controller.scrollToTop(scrollController)),
    );
  }
}

uploadMsg() {
  Get.snackbar("", "",
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(minutes: 2),
      backgroundColor: boxColor.value,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      messageText: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              circleIcon(mainColor, Colors.white, Icons.image, 30, "photo".tr,
                  () async {
                List filesData = await mainController
                    .uploadFile(true, ['jpg', 'png', 'jpeg', 'jif']);
                if (filesData.isNotEmpty) {
                  Get.to(MediaViewer("msg", "imgs", filesData));
                }
              }),
              circleIcon(
                  Colors.purple, Colors.white, Icons.videocam, 30, "video".tr,
                  () async {
                List filesData = await mainController.uploadFile(true, ['mp4']);
                if (filesData.isNotEmpty) {
                  Get.to(MediaViewer("msg", "videos", filesData));
                }
              }),
              circleIcon(Colors.deepOrangeAccent, Colors.white, Icons.headset,
                  30, "voice".tr, () async {
                List filesData = await mainController.uploadFile(true, ['mp3']);
                if (filesData.isNotEmpty) {
                  Get.to(FileViewer("audios", filesData));
                }
              })
            ],
          ),
          Space(0, 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              circleIcon(Colors.deepPurpleAccent, Colors.white,
                  Icons.settings_voice, 30, "record".tr, () {
                Get.back();
                Get.toNamed("/recorder");
              }),
              circleIcon(Colors.deepPurpleAccent, Colors.white,
                  Icons.settings_voice, 30, "file".tr, () async {
                List filesData = await mainController
                    .uploadFile(true, ['pdf', 'docs', 'html']);
                if (filesData.isNotEmpty) {
                  Get.to(FileViewer("files", filesData));
                }
              }),
              circleIcon(Colors.green, Colors.white, Icons.location_on, 30,
                  "location".tr, () async {
                List filesData = await mainController
                    .uploadFile(true, ['pdf', 'docs', 'html']);
                if (filesData.isNotEmpty) {
                  Get.to(FileViewer("files", filesData));
                }
              }),
            ],
          )
        ],
      ));
}
