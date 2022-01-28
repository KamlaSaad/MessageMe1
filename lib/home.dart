import 'package:chatting/profile_img.dart';
import 'package:chatting/set_pattern.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'check_pattern.dart';
import 'shared.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var selectedIndex = 0.obs, btnAngle = 1.0.obs;
  var displayIcons = false.obs;
  int endTime = 0;
  @override
  build(BuildContext context) {
    var state;
    return Obx(() => Scaffold(
          backgroundColor: bodyColor.value,
          key: scaffoldKey,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: bodyColor.value,
            leading: GestureDetector(
              child: ProfileImg(25, "${mainController.userImg.value}", "user"),
              onTap: () => mainController.goToProfile(),
            ),
            title: txt("logo".tr, mainColor, 26, true),
            actions: [
              myIcon(Icons.search, Colors.white70, 28,
                  () => Get.toNamed("/newChat", arguments: "searchBy".tr)),
              myIcon(Icons.more_vert, txtColor.value, 28,
                  () => Get.toNamed("/settings")),
              Space(5, 0)
            ],
          ),
          body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              width: Get.width,
              height: Get.height,
              child: Column(
                children: [
//                  OnlineList(),
//                  Space(0, 10),
                  Stack(children: [
                    Container(
                        key: mainController.homeKey.value,
                        padding:
                            EdgeInsets.only(top: 10, bottom: Get.height * 0.06),
                        height: Get.height * 0.85,
                        child: mainController.userChats.isEmpty
                            ? FutureBuilder(
                                future: mainController.getChats(),
                                builder: (context, AsyncSnapshot snap) {
                                  state = snap.connectionState;
                                  switch (snap.connectionState) {
                                    case ConnectionState.none:
                                      return Center(
                                          child: txt("noNet".tr, txtColor.value,
                                              22, true));
                                    case ConnectionState.active:
                                    case ConnectionState.waiting:
                                      return Center(
                                          child: txt("load".tr, txtColor.value,
                                              22, true));
                                    case ConnectionState.done:
                                      if (snap.hasError) {
                                        print(
                                            "Errooooooooooooooooooooooooooooooooooooooooooor");
                                        print(snap.error);
                                        print(
                                            "Errooooooooooooooooooooooooooooooooooooooooooor");
                                      }
                                      return snap.hasData
                                          ? snap.data.length > 0
                                              ? Chats(snap.data)
                                              : loadingMsg(
                                                  "no".tr + " chats".tr)
                                          : loadingMsg("Something went wronf");
                                  }
                                })
                            : Chats(mainController.userChats.value)),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: Get.width,
                        height: Get.height * 0.12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BottomIcon("chats".tr, Icons.messenger_outlined,
                                mainColor, null),
                            BottomIcon("people".tr, Icons.people_alt_sharp,
                                txtColor.value, "/contacts"),
                            BottomIcon("stories".tr, Icons.amp_stories,
                                txtColor.value, "/stories")
                          ],
                        ),
                      ),
                    ),
                    mainController.lang == 'en'
                        ? Positioned(
                            right: 5,
                            bottom: Get.height * 0.13,
                            child: SideIcons())
                        : Positioned(
                            left: 5,
                            bottom: Get.height * 0.13,
                            child: SideIcons())
                  ]),
                ],
              )),
        ));
  }

  SideIcons() {
    return Column(
      children: [
        displayIcons.isTrue
            ? Column(
                children: [
                  circleIcon(
                      mainColor, Colors.white, Icons.messenger_outlined, 28, "",
                      () async {
//                    Get.to(CheckPattern());
//                    var data = await mainController.getOnlineUsers();
//                    print(data);
//                    Get.toNamed("/testCall");
//                    await chatmainController.notify();
//                    CallController caller = CallController();
//                    await caller.addCallDoc(
//                        "testCall", "video", 844874, "dgcfei28gddbhdfjqwcw");
//                    print(await FirebaseAuth.instance.currentUser
//                        ?.getIdToken(false));
//                    print("==============================");
////                    print(await FirebaseMessaging.instance.getToken());
                  }),
                  Space(0, 7),
                  circleIcon(
                      mainColor, Colors.white, Icons.people_alt_sharp, 28, "",
                      () {
                    mainController.resetSelectedUsers();
                    Get.toNamed("/newGroup", arguments: ["addGroup".tr, {}]);
                  }),
                ],
              )
            : Space(0, 0),
        Space(0, 7),
        circleIcon(
            mainColor,
            Colors.white,
            displayIcons.isTrue ? Icons.close : Icons.add,
            28,
            "",
            () => displayIcons.value = !displayIcons.value),
      ],
    );
  }
}

Widget Chats(List list) {
  List data = [];
  for (int i = 0; i < list.length; i++) {
    if (list[i]['lastMsgType'].isNotEmpty && list[i]['name'] != "null") {
      data.add(list[i]);
    }
  }
  return data.length > 0
      ? ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            data = mainController.sortByDate(data, true);
            var chat = data[index], msg, date = "${chat['lastMsgDate']}".obs;
            bool isGroup = chat['type'] == "group";
            if (chat['lastMsgType'].isNotEmpty) {
              msg = Padding(
                padding: const EdgeInsets.only(top: 3),
                child: chat['lastMsgType'] == "text" ||
                        chat['lastMsgType'] == "hint"
                    ? txt("${chat['lastMsgSender']}: ${chat['lastMsg']}",
                        txtColor.value.withOpacity(0.6), 17, false)
                    : FileIcon(chat['lastMsg'], chat['lastMsgType'],
                        chat['lastMsgSender']),
              );
            }
            Timer.periodic(
                Duration(minutes: 1),
                (Timer t) =>
                    date.value = mainController.convertDate(chat['date']));
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 3),
              horizontalTitleGap: 2,
              leading: GestureDetector(
                  child:
                      ProfileImg(28, chat['img'], isGroup ? "group" : "user"),
                  onTap: () {
                    if (chat['img'].isNotEmpty) {
                      Get.to(ProfileImgViewer(
                          false, chat['name'], chat['img'], () {}));
                    }
                  }),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  txt(chat['name'], txtColor.value, 18, false),
                  Obx(() => txt(
                      date.value, txtColor.value.withOpacity(0.5), 16, false)),
                ],
              ),
              subtitle: msg,
              onTap: () {
                chatController.chatData.value = chat;
                Get.toNamed("/chat");
              },
            );
          },
        )
      : !mainController.connected.value
          ? loadingMsg("no".tr + " " + "internet".tr)
          : loadingMsg("no".tr + "chats".tr);
}

Widget OnlineList() {
  return FutureBuilder(
      future: mainController.getOnlineUsers(),
      builder: (context, AsyncSnapshot snap) {
        switch (snap.connectionState) {
          case ConnectionState.none:
            return loadingMsg("no".tr + " " + "internet".tr);
          case ConnectionState.active:
          case ConnectionState.waiting:
            return loadingMsg("Loading...");
          case ConnectionState.done:
            if (snap.hasError) print("error ${snap.error}");
            return snap.data.length > 0
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snap.data.length,
                    itemBuilder: (BuildContext context, int i) {
                      var user = snap.data[i];
                      return Container(
                        height: Get.height * 0.1,
                        padding: EdgeInsets.all(8.0),
                        child: GestureDetector(
                          child: ProfileImg(28, user['img'], "user"),
                          onTap: () =>
                              Get.toNamed("/userProfile", arguments: user),
                        ),
                      );
                    })
                : Space(0, 0);
        }
      });
}
