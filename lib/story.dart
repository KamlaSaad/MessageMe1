import 'dart:async';

import 'package:chatting/add_story.dart';
import 'package:chatting/media_viewer.dart';
import 'package:chatting/story_view.dart';
import "package:collection/collection.dart";
import 'package:grouped_list/grouped_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'story_controller.dart';
import 'add_story.dart';
import 'shared.dart';

StoryController storyController = Get.put(StoryController());

class Story extends StatelessWidget {
  var displayIcons = false.obs, data = [].obs, latestStories = [];
  List<Widget> grid = [];
  int l = 0;
  @override
  Widget build(BuildContext context) {
    grid = [];
    latestStories = [];
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bodyColor.value,
        leading: GestureDetector(
          child: Obx(
              () => ProfileImg(35, "${mainController.userImg.value}", "user")),
          onTap: () => mainController.goToProfile(),
        ),
        title: txt("logo".tr, mainColor, 26, true),
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: Get.height * 0.02,
          left: 15,
          right: 15,
        ),
        width: Get.width,
        height: Get.height,
        child: Stack(
          children: [
            Container(
                padding: EdgeInsets.only(bottom: Get.height * 0.12),
                child: Stories()),
            Positioned(
                right: 5,
                bottom: Get.height * 0.13,
                child: Obx(() => Column(
                      children: [
                        displayIcons.isTrue
                            ? Column(
                                children: [
                                  circleIcon(
                                      mainColor,
                                      Colors.white,
                                      Icons.edit,
                                      28,
                                      "",
                                      () => Get.to(AddStory("text", []))),
                                  Space(0, 7),
                                  circleIcon(mainColor, Colors.white,
                                      Icons.photo, 28, "", () async {
                                    List data = await mainController.uploadFile(
                                        false, ['jpg', 'png', 'jpeg', 'jif']);
                                    if (data.isNotEmpty) {
                                      Get.to(
                                          MediaViewer("story", "imgs", data));
                                    }
                                  }),
                                  Space(0, 7),
                                  circleIcon(mainColor, Colors.white,
                                      Icons.videocam, 28, "", () async {
                                    List data = await mainController
                                        .uploadFile(false, ['mp4']);
                                    if (data.isNotEmpty) {
                                      Get.to(
                                          MediaViewer("story", "videos", data));
                                    }
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
                            "", () async {
                          await mainController.addField();
                          displayIcons.value = !displayIcons.value;
                        }),
                      ],
                    ))),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                color: bodyColor.value,
                width: Get.width,
                height: Get.height * 0.12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BottomIcon("chats".tr, Icons.messenger_outlined,
                        txtColor.value, "/home"),
                    BottomIcon("people".tr, Icons.people_alt_sharp,
                        txtColor.value, "/contacts"),
                    BottomIcon("stories".tr, Icons.amp_stories, mainColor, null)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget StoryBox(String type, String name, String profileImg, int textColor,
      int backColor, String backImg, String text, int length) {
    VideoPlayerController vc = VideoPlayerController.network(backImg);
    double w = Get.width * 0.4, h = 200;
    return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: type == "text" ? Color(backColor) : boxColor.value,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            type != "text"
                ? Container(
                    constraints: const BoxConstraints(
                        minHeight: double.infinity, minWidth: double.infinity),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: type == "img"
                            ? Image.network(backImg, fit: BoxFit.fill)
                            : VideoPlayer(vc)),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: largeTxt(text, Color(textColor), 16)),
                  ),
            Positioned(
                top: 10, right: 10, child: txt("$length", mainColor, 20, true)),
            Positioned(
                top: 10,
                left: 10,
                child: CircleAvatar(
                    radius: 26,
                    backgroundColor: mainColor,
                    child: ProfileImg(24, profileImg, "user"))),
            Positioned(
                bottom: 10, left: 10, child: txt(name, mainColor, 20, true)),
          ],
        ));
  }

  void handleData(var data) {
    if (data.length > 0) {
//      Timer.periodic(Duration(minutes: 1), (Timer t) {
//        for (int i = 0; i < data.length; i++) {
//          if (storyController.timeFinish(data[i]['date'])) {
//            storyController.deleteStory(data[i]['id']);
//            handleData(data);
//          }
//        }
//      });
      latestStories = [];
      data.forEach((id, List list) {
//        print(list[0]['date']);
        var newList = mainController.sortByDate(list, true);
//        print(newList[0]['date']);
        bool isMyStory = myId == id.toString();
        int l = list.length;
        var type = newList[l - 1]['type'].toString(),
            text = newList[l - 1]['text'],
            name = newList[l - 1]['name'],
            dName = isMyStory ? "Me" : "$name",
            img = newList[l - 1]['img'],
            date = newList[l - 1]['date'],
            time = mainController.convertDate(date),
            backgroundImg = newList[l - 1]['mediaUrl'],
            textColor = newList[l - 1]['textColor'],
            backgroundColor = newList[l - 1]['backgroundColor'];
        Map all = {
          "type": type,
          "time": time,
          "name": dName,
          "img": "$img",
          "textColor": textColor,
          "backgroundColor": backgroundColor,
          "backgroundImg": backgroundImg,
          "text": "$text",
          "length": list.length,
          "list": newList,
          "my": isMyStory,
          "sender": id
        };
        latestStories.add(all);
      });

//      var stories = mainController.sortByDate(latestStories);
      for (int i = 0; i < latestStories.length; i++) {
        if (latestStories[i]['my']) {
          var me = latestStories[i];
          latestStories.remove(me);
          latestStories.insert(0, me);
        }
      }
    }
  }

  Stories() {
    return Obx(() => FutureBuilder(
        key: storyController.storyKey.value,
        future: storyController.getAllStories(),
        builder: (context, AsyncSnapshot snap) {
          if (snap.hasData) {
            handleData(snap.data);
          }
          switch (snap.connectionState) {
            case ConnectionState.none:
              return loadingMsg("no".tr + " " + "internet".tr);
            case ConnectionState.active:
            case ConnectionState.waiting:
              return loadingMsg("Loading...");
            case ConnectionState.done:
              return snap.hasError
                  ? loadingMsg("${snap.error}")
                  : !mainController.connected.value
                      ? loadingMsg("no".tr + " " + "internet".tr)
                      : gridWidget();
          }
        }));
  }

  Widget gridWidget() {
    return GridView.builder(
        itemCount: latestStories.length,
        gridDelegate: delegate,
        itemBuilder: (BuildContext context, int i) {
          var element = latestStories[i],
              user = mainController.getUser(element['sender']);
          print("exception ${storyController.exceptStory(user)}");
          return GestureDetector(
            child: StoryBox(
              element['type'],
              element['name'],
              element['img'],
              element['textColor'] ?? txtColor.value,
              element['backgroundColor'] ?? bodyColor.value.value,
              "${element["backgroundImg"]}",
              element['text'],
              element['length'],
            ),
            onTap: () {
              Get.to(StoryViewer(element['list'], element['my']));
            },
          );
        });
  }

  var delegate = SliverGridDelegateWithFixedCrossAxisCount(
      mainAxisExtent: 210,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      crossAxisCount: 2);
}
