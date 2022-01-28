//import 'package:chatting/contacts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'shared.dart';
import 'profile_img.dart';

class ChatSettings extends StatefulWidget {
  @override
  _ChatSettingsState createState() => _ChatSettingsState();
}

class _ChatSettingsState extends State<ChatSettings> {
  var chatData = chatController.chatData.value;
  Color favColor = mainColor;
//  int msgsLength = Get.arguments;
  bool isGroup = false;

  @override
  Widget build(BuildContext context) {
    isGroup = chatData['type'] != "chat";
    favColor = Color(chatData["mainColor"]);
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: bodyColor.value,
          leading: myIcon(Icons.arrow_back, favColor, 30, () => Get.back())),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 14),
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: Get.height * 0.24,
                  width: Get.width * 0.65,
                  child: Stack(
                    children: [
                      !isGroup
                          ? Positioned(
                              right: 0,
                              bottom: 0,
                              child: ProfileImg(Get.width * 0.17,
                                  mainController.userImg.value, "user"))
                          : Space(0, 0),
                      Positioned(
                          left: isGroup ? Get.width * 0.11 : Get.width * 0.05,
                          bottom: -5,
                          child: CircleAvatar(
                              radius: Get.width * 0.2,
                              backgroundColor: bodyColor.value,
                              child: ProfileImg(80, chatData['img'],
                                  isGroup ? "group" : "user"))),
                    ],
                  ),
                ),
                Space(0, 12),
                txt(chatController.chatData.value['name'], txtColor.value, 25,
                    true),
                Space(0, 6),
                FutureBuilder(
                    key: mainController.homeKey.value,
                    future: chatController.getMsgsLength(chatData['id']),
                    builder: (context, AsyncSnapshot snap) {
                      print(snap.data);
                      var text;
                      if (snap.hasData) {
                        int l = snap.data;
                        text = l > 0
                            ? txt(l == 1 ? "1 Message" : "$l Messages",
                                favColor, 20, false)
                            : Space(0, 6);
                      } else {
                        text = Space(0, 0);
                      }
                      return text;
                    }),
              ],
            ),
          ),
          //Chat Settings
          Space(0, 20),
          txt("settings".tr, favColor, 18, false),
          Space(0, 15),
          ListItem(Icons.photo, "change".tr + "" + "backImg".tr, () async {
            List fileData =
                await mainController.uploadFile(false, ['jpg', 'png', 'jpeg']);
            if (fileData.isNotEmpty) {
              Get.to(ProfileImgViewer(
                  true, "upload".tr + "" + "photo".tr, fileData, () async {
                Get.back();

                String url = await mainController.storeFile(
                    "imgs", fileData[0]['name'], fileData[0]['file']);
                if (url.isNotEmpty) {
                  chatController.chatData.value['background'] = url;
                  print(chatController.chatData.value['background']);
                  await chatController.changeChatData("background", url);
//                  await chatController.updateChatData();
                }
              }));
            }
          }),
          ListItem(Icons.color_lens_sharp, "Change FavColor",
              () => showColorPicker()),
          ListItem(Icons.delete, "delete".tr + "" + "chat".tr,
              () async => deleteChat()),

          //Chat media
          Space(0, 12),
          txt("photos".tr, favColor, 20, false),
          MediaBuilder("img"),
          txt("videos".tr, favColor, 20, false),
          MediaBuilder("video"),
//          VideosBuilder(),
          isGroup ? txt("Members", favColor, 20, false) : Space(0, 0),
          Space(0, 12),
          isGroup ? Members() : Space(0, 0),
          //members
        ],
      ),
    );
  }

  Members() {
    List users = chatData['users'];
    List<Widget> list = [];
    for (int i = 0; i < users.length; i++) {
      var userData = mainController.getUser(users[i]);
      String img = mainController.getFriendImg(userData['imgUrl']),
          contactN = mainController.isContact(userData['phone']),
          name = contactN.isEmpty ? "${userData['username']}" : contactN;

      bool isAdmin = users[i] == chatData['creator'], isMe = users[i] == myId;
      String subT = contactN.isEmpty
          ? (isMe ? userData['phone'] : userData['email'])
          : userData['phone'];
      list.add(ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 3),
        horizontalTitleGap: 2,
        leading: ProfileImg(26, img, "user"),
        title: txt(name, txtColor.value, 20, false),
        subtitle: Container(
          padding: EdgeInsets.only(top: 3),
          width: Get.width * 0.68,
          child: largeTxt("$subT", Colors.grey, 19),
        ),
        trailing: isAdmin ? txt("Admin", mainColor, 19, false) : Space(0, 0),
        onTap: () {
          if (isMe) {
            Get.toNamed("/myProfile");
          } else {
            print(users[i]);
            Get.toNamed("/userProfile", arguments: users[i]);
          }
        },
      ));
    }
    return Column(
      children: list,
    );
  }

  Widget MediaBuilder(String type) {
    var media = [].obs;
    VideoPlayerController vpc;
    return Obx(() => FutureBuilder(
//        key: mainController.homeKey.value,
        future: chatController.getChatMedia(type),
        builder: (context, AsyncSnapshot snap) {
          var data = snap.data;
          if (snap.hasData) {
            media.value = data;
          }
          return media.length > 0
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    height: 90,
                    child: ListView.builder(
                        itemCount: media.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext ctx, int i) {
//                          String type = media[i]['type'];
                          vpc = VideoPlayerController.network(
                              media[i]['url'] ?? "");
                          return Container(
                              color: boxColor.value,
                              padding: EdgeInsets.all(3),
                              width: 90,
                              height: 90,
                              child: type == "img"
                                  ? Image.network(
                                      media[i]['url'] ?? "",
                                      fit: BoxFit.fill,
                                    )
                                  : VideoPlayer(vpc));
                        }),
                  ),
                )
              : Space(0, 90);
        }));
  }

  Widget VideosBuilder() {
    VideoPlayerController vpc;
    List videos = chatController.chatVideos.value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: videos.length > 0 ? 90 : 10,
        child: ListView.builder(
          itemCount: videos.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext ctx, int i) {
            vpc = VideoPlayerController.network(videos[i]['url'] ?? "")
              ..initialize();
            return Container(
                color: boxColor.value,
                padding: EdgeInsets.all(3),
                width: 90,
                height: 90,
                child: VideoPlayer(vpc));
          },
        ),
      ),
    );
  }

  Widget ListItem(IconData icon, String title, tap) {
    return GestureDetector(
      child: Row(
        children: [
          myIcon(icon, favColor, 30, () => null),
          txt(title, txtColor.value, 21, false),
        ],
      ),
      onTap: tap,
    );
  }

  showColorPicker() {
    Color pColor = favColor;
    Get.defaultDialog(
        backgroundColor: boxColor.value,
        title: "mainColor".tr,
        titleStyle: TextStyle(color: mainColor),
        content: Center(
          child: ColorPicker(
              pickerColor: pColor, onColorChanged: (color) => pColor = color),
        ),
        confirm: mainBtn(mainColor, false, true, "Confirm", () async {
          setState(() => favColor = pColor);
          print(pColor);
          Get.back();
          chatController.chatData.value["mainColor"] = pColor.value;
          await chatController.changeChatData("mainColor", pColor.value);
        }),
        cancel: mainBtn(mainColor, false, true, "Confirm", () => Get.back()));
  }

  deleteChat() {
    confirmBox("delete".tr + "" + "chat".tr, "confirmDel".tr, "delete".tr,
        () async {
      await chatController.deleteChat(chatData['id']);
    }, () => Get.back());
  }
}
