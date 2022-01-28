import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:pattern_lock/pattern_lock.dart';
//import 'package:audioplayer/audioplayer.dart';
import 'record_msg.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:random_string/random_string.dart';
import 'package:video_player/video_player.dart';
//import 'package:audioplayers/audioplayers.dart';
//import 'package:get_storage/get_storage.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'main_controller.dart';
import 'chat_controller.dart';
import 'zoom_media.dart';

var mainController = Get.put(MainController()),
    chatController = Get.put(ChatController());

//String myId = "${mainController.user?.uid}";
String myId = "EdUxxQttAVPf5FQZ9XvJauPA2Dk1";
//colors
Color mainColor = Colors.pink;
var txtColor = Colors.white.obs,
    bodyColor = Colors.black.obs,
    boxColor = Color(0xff232323).obs;
//var tbodyColor.value = Colors.black.obs;
//var storage = GetStorage();
Widget Direction(Widget child) {
  return Directionality(
    child: child,
    textDirection: mainController.lang.value == "en"
        ? TextDirection.ltr
        : TextDirection.rtl,
  );
}

Widget backCircle(double h) {
  return Transform.scale(
    scale: 1.5,
    child: Container(
      width: Get.width,
      height: h,
      decoration: BoxDecoration(
          color: mainColor,
          borderRadius: BorderRadius.circular(Get.height * 0.35)),
    ),
  );
}

Widget txt(String txt, Color color, double size, bool bold) {
  return Text(
    txt,
    style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal),
  );
}

Widget largeTxt(String txt, Color color, double size) {
  return RichText(
      text:
          TextSpan(text: txt, style: TextStyle(color: color, fontSize: size)));
}

Widget loadingMsg(String text) {
  return Center(child: txt(text, txtColor.value, 22, true));
}

Widget ProfileImg(double r, String src, String type) {
  var img = src.isNotEmpty ? NetworkImage(src) : AssetImage("imgs/$type.jpg");
  return Padding(
    padding: const EdgeInsets.all(4),
    child: CircleAvatar(
        radius: r,
        backgroundColor: mainColor,
        backgroundImage: img as ImageProvider),
  );
}

Widget myIcon(IconData icon, Color color, double s, click) {
  return IconButton(
      icon: Icon(
        icon,
        size: s,
        color: color,
      ),
      onPressed: click);
}

Widget circleIcon(
    Color backC, Color iconC, IconData icon, double r, String t, click) {
  return GestureDetector(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: r,
          backgroundColor: backC,
          child: Icon(
            icon,
            color: iconC,
            size: 26,
          ),
        ),
        t.isNotEmpty ? txt(t, txtColor.value, 21, false) : Space(0, 0)
      ],
    ),
    onTap: click,
  );
}

DialogMsg(String title, String body) {
  Get.defaultDialog(
    title: title,
    barrierDismissible: true,
    titleStyle: TextStyle(color: mainColor),
    content: txt(body, txtColor.value, 19, false),
    backgroundColor: boxColor.value,
  );
}

snackMsg(String title, String body) {
  Get.snackbar(
    "",
    "",
    duration: Duration(seconds: 4),
    titleText: txt(title, mainColor, 20, false),
    messageText: txt(body, txtColor.value, 18, false),
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: boxColor.value,
  );
}

Widget TxtInput(String lbl, String hint, String val, bool focus,
    TextInputType type, Color borderColor, Color fillColor, change) {
  var border = (Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: color, width: 1.5));
  return TextFormField(
//    controller: null,
    initialValue: val,
    autofocus: focus,
    keyboardType: type,
    style: TextStyle(color: txtColor.value, fontSize: 20),
    decoration: InputDecoration(
        fillColor: fillColor,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        hintText: val,
        hintStyle: TextStyle(color: txtColor.value, fontSize: 20),
        label: txt(lbl, txtColor.value, 19, true),
        enabledBorder: border(borderColor),
        focusedBorder: border(borderColor),
        errorBorder: border(Colors.red)),
    onChanged: change,
  );
}

Widget mainBtn(Color color, bool border, bool insideSnack, String text, click) {
  return GestureDetector(
      child: Container(
        width: insideSnack ? Get.width * 0.28 : Get.width * 0.9,
        height: insideSnack ? Get.height * 0.06 : Get.height * 0.075,
        decoration: BoxDecoration(
            border: Border.all(color: mainColor, width: border ? 2 : 0),
            color: color,
            borderRadius: BorderRadius.circular(15)),
        child: Center(
          child: txt(
              text,
              border
                  ? mainColor
                  : (color == mainColor ? Colors.white : txtColor.value),
              21,
              false),
        ),
      ),
      onTap: click);
}

Widget BottomIcon(String lbl, IconData icon, Color color, var page) {
  return GestureDetector(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
          size: page == null ? 34 : 30,
        ),
        txt(lbl, color, page == null ? 22 : 20, true),
      ],
    ),
    onTap: () {
      color = color == txtColor.value ? mainColor : txtColor.value;
      page == null ? null : Get.offNamed(page);
    },
  );
}

Widget ImageBox(Widget img, click) {
  return SizedBox(
    width: Get.width * 0.52,
    height: Get.height * 0.22,
    child: Stack(
      children: [
        img,
        Positioned(
            bottom: 10,
            right: 27,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: mainColor,
              child: myIcon(Icons.camera_alt, txtColor.value, 30, click),
            ))
      ],
    ),
  );
}

Widget Message(Map msgD, String chatType) {
  Map msgData = msgD;
  bool isSender = msgData['sender'] == myId,
      showName = isSender == false && chatType == "group";
  String date = mainController.msgDate(msgData['date']);
  double horiz = 10;
  Map reply = msgData['reply'];
  var displayDate = false.obs,
      msg = null,
      crossAxis = CrossAxisAlignment.center,
      friendData = mainController.getUser(msgData['sender']),
      friendImg = mainController.getFriendImg(friendData['imgUrl']),
      friendName = "${friendData['name']}".isEmpty
          ? "${friendData['username']}"
          : "${friendData['name']}",
      margin = EdgeInsets.symmetric(horizontal: horiz, vertical: 8);
  Color backBgColor = isSender ? boxColor.value : mainColor,
      textColor = backBgColor == mainColor ? Colors.white : txtColor.value;
  var msgK = Key("");
  switch (msgData['type']) {
    case "hint":
      msg = txt(msgData['text'], textColor, 20, false);
      crossAxis = CrossAxisAlignment.center;
      break;
    case "img":
      msg = MediaMsg(true, msgData['url'], msgData['text'], isSender);
      crossAxis = CrossAxisAlignment.end;
      break;
    case "video":
      msg = MediaMsg(false, msgData['url'], msgData['text'], isSender);
      crossAxis = CrossAxisAlignment.end;
      break;
    case "audio":
      msg = RecordMsg(int.parse(msgData['text']), msgData['url']);
      break;
    case "file":
      msg = FileMsg(msgData['text']);
      break;
    default:
      msg = RichText(
        text: TextSpan(
            text: msgData['text'],
            style: TextStyle(color: Colors.white, fontSize: 22)),
      );
  }
  return Row(
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: crossAxis,
    mainAxisAlignment: msgData['type'] == 'hint'
        ? MainAxisAlignment.center
        : (isSender ? MainAxisAlignment.end : MainAxisAlignment.start),
    children: [
//      isSender ? Space(0, 0) : ProfileImg(26, friendImg, "user"),
      Stack(children: [
        GestureDetector(
          child: Padding(
            padding: margin,
            child: Column(
              crossAxisAlignment: msgData['type'] == 'hint'
                  ? CrossAxisAlignment.center
                  : isSender
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                showName
                    ? txt(friendData['name'], txtColor.value.withOpacity(0.8),
                        16, false)
                    : Space(0, 0),
                Space(0, 3),
                Container(
                    key: msgK,
                    padding: margin,
                    constraints:
                        BoxConstraints(minWidth: 30, maxWidth: Get.width * 0.6),
                    decoration: BoxDecoration(
                        color: backBgColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: reply.isNotEmpty
                        ? Column(
                            children: [replyBox(reply, isSender, false), msg],
                          )
                        : msg),
                Space(0, 5),
                Obx(() => displayDate.value
                    ? txt(date, txtColor.value.withOpacity(0.7), 16, false)
                    : Space(0, 0))
              ],
            ),
          ),
          onTap: () => displayDate.value = !displayDate.value,
          onDoubleTap: () {
            if (msgData['type'] != "hint") {
              showMsgOptions(msgData);
            }
          },
        ),
        Obx(() => FutureBuilder(
            key: chatController.msgKey.value,
            future: chatController.getReacts(msgData['id']),
            builder: (context, AsyncSnapshot snap) {
              return snap.hasData
                  ? snap.data.length > 0
                      ? (isSender
                          ? Positioned(
                              bottom: 5,
                              left: 0,
                              child:
                                  reactIcon(backBgColor, isSender, snap.data))
                          : Positioned(
                              bottom: 0,
                              right: 0,
                              child:
                                  reactIcon(backBgColor, isSender, snap.data)))
                      : Space(0, 0)
                  : Space(0, 0);
            }))
      ])
    ],
  );
}

reactIcon(Color color, bool isSender, var data) {
  String emogy = data[data.length - 1]['react'];
  print("react $emogy");
  return GestureDetector(
      child: CircleAvatar(
          radius: 15,
          backgroundColor: color,
          child: Center(child: txt(emogy, txtColor.value, 20, false))),
      onTap: () {
        if (isSender) {
          chatController.msgReacts.value = data;
          chatController.showReactBox.value = true;
        }
      });
//        myIcon(Icons.face, color == mainColor ? txtColor.value : mainColor, 24,
}

Widget replyBox(Map reply, bool isSender, bool close) {
  var user = mainController.getUser(reply['sender'] ?? "");
  VideoPlayerController? vc = reply['type'] == "video"
      ? VideoPlayerController.network(reply['url'])
      : null;
  var msg = (IconData icon, String text) => Row(
            children: [
              myIcon(icon, Colors.grey, 26, () => null),
              txt(text, txtColor.value, 20, false),
            ],
          ),
      leftMsg,
      rightMsg;
//  if()
  switch (reply['type']) {
    case 'img':
      leftMsg = msg(Icons.photo, "photo".tr);
      rightMsg = GestureDetector(
        child: Image.network(
          reply['url'],
          width: 60,
          height: 60,
        ),
      );
      break;
    case 'video':
      leftMsg = msg(Icons.videocam, "video".tr);
      rightMsg = VideoPlayer(vc!);
      break;
    case 'voice':
      leftMsg = msg(Icons.keyboard_voice, "voice".tr);
      break;
    case 'file':
      leftMsg = msg(Icons.insert_drive_file, "file".tr);
      break;
    default:
      leftMsg = largeTxt(
          reply['text'], txtColor.value.withOpacity(0.65), close ? 19 : 17);
  }
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              reply['sender'] == myId
                  ? txt("me".tr, txtColor.value, 21, false)
                  : txt(
                      user['name'] ?? "",
                      isSender ? mainColor : txtColor.value.withOpacity(0.85),
                      20,
                      false),
            ],
          ),
          Space(0, 3),
          leftMsg
        ],
      ),
      rightMsg ?? Space(0, 0)
    ],
  );
}

Widget reactMsgIcon(String icon, String msgId, var reacts) {
  var size = 32.0.obs;
  return GestureDetector(
      child: Obx(() => txt(icon, txtColor.value, size.value, true)),
      onTap: () async {
        print(icon);
        Get.back();
        await chatController.reactMsg(msgId, icon);
      });
}

Widget MsgOptionItem(IconData icon, String title, Map msg) {
  String id = msg['id'], text = msg['text'], newTxt = "";
  return ListTile(
    contentPadding: EdgeInsets.all(0),
    leading: myIcon(icon, mainColor, 32, () {}),
    title: txt(title, txtColor.value, 22, false),
    onTap: () async {
      if (title == "Reply") {
        chatController.toggleReply(true, msg, msg['isSender']);
      } else if (title == "Forward") {
        Get.back();
        Timer(Duration(milliseconds: 500), () {
          Get.toNamed("/newGroup", arguments: ["Send to", msg]);
        });
//
      } else if (title == "Edit") {
        Timer(Duration(milliseconds: 500), () {
          if (text.isNotEmpty) {
            EditBox("Message", text, (val) => newTxt = val, () async {
              Get.back();
              print(newTxt);
              if (newTxt != text) {
                print(id);
                await chatController.editMsg(id, newTxt);
              }
            });
          } else {
//            DialogMsg("rrr", "Only text can be edited");
          }
        });
      } else {
        await chatController.removerMsg(id);
      }
      Get.back();
//      chatController.changeChatKey();
      mainController.changeHomeKey();
    },
  );
}

void showMsgOptions(Map msgData) {
  String id = msgData['id'], msgTxt = msgData['text'];
  bool isSender = msgData['isSender'];
  var react = msgData['react'];
  Get.defaultDialog(
      backgroundColor: boxColor.value,
      title: "Make Action",
      titleStyle: TextStyle(color: boxColor.value, height: 0),
      content: Column(
        children: [
          MsgOptionItem(Icons.reply, "reply".tr, msgData),
          MsgOptionItem(Icons.forward, "forward".tr, msgData),
          isSender && msgTxt != " "
              ? MsgOptionItem(Icons.edit, "edit".tr, msgData)
              : Space(0, 0),
          MsgOptionItem(Icons.delete, "delete".tr, msgData),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              reactMsgIcon("❤", id, react),
              reactMsgIcon("😂", id, react),
              reactMsgIcon("😮", id, react),
              reactMsgIcon("😢", id, react),
              reactMsgIcon("☹", id, react),
            ],
          )
        ],
      ));
}

String duration(int sec) {
  Duration d = Duration(seconds: sec);
  String dur = d.toString().substring(2, 7);
  return dur;
}

Widget FileMsg(String name) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      myIcon(Icons.insert_drive_file, txtColor.value, 30, null),
      txt(name, txtColor.value, 22, false)
    ],
  );
}

Widget MediaMsg(bool img, String url, String caption, bool isSender) {
  VideoPlayerController _controller = VideoPlayerController.network(url)
    ..initialize();
  bool playing = _controller.value.isPlaying;
  return GestureDetector(
    onDoubleTap: () => Get.to(ZoomMedia("img", url)),
    child: Column(
      children: [
        SizedBox(
          width: Get.width * 0.45,
          height: Get.height * 0.25,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: img
                  ? Image.network(
                      url,
                      fit: BoxFit.fill,
                    )
                  : VideoPlayer(_controller)),
        ),
        caption == " "
            ? Space(0, 0)
            : Padding(
                padding: const EdgeInsets.only(top: 5),
                child: txt(caption, txtColor.value, 18, false),
              )

//          caption.isNotEmpty ? CaptionBox(caption, isSender) : Space(0, 0)
      ],
    ),
  );
}

Widget CaptionBox(String caption, bool isSender) {
  const r = Radius.circular(12);
  return Transform.translate(
    offset: Offset(0, -6),
    child: Container(
      width: Get.width * 0.45,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
      decoration: BoxDecoration(
          color: isSender ? boxColor.value.withOpacity(0.7) : mainColor,
          borderRadius: BorderRadius.only(bottomLeft: r, bottomRight: r)),
      child: txt(caption, txtColor.value, 20, false),
    ),
  );
}

var Space = (double w, double h) => SizedBox(width: w, height: h);
var Divide = () => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: txtColor.value.withOpacity(0.3),
    );
Widget Btn(Color color, double w, double h, Widget child, bool border, f) {
  return GestureDetector(
      child: Container(
          width: w,
          height: h,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color,
              border: Border.all(color: mainColor, width: border ? 2 : 0)),
          child: Center(child: child)),
      onTap: f);
}

Widget SliderIcon(IconData icon, double dimension, func) {
  return GestureDetector(
    child: Container(
        width: dimension,
        height: dimension,
        color: bodyColor.value.withOpacity(0.6),
        child: Icon(icon, color: txtColor.value, size: 30)),
    onTap: func,
  );
}

void EditBox(String title, String val, change, action) {
//  String result="";
  Get.defaultDialog(
//    contentPadding: EdgeInsets.only(bottom: 0),
    title: "edit".tr + " $title",
    titleStyle: TextStyle(color: mainColor, height: 2, fontSize: 22),
    barrierDismissible: true,
    content: Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TxtInput("", "", val, false, TextInputType.text, txtColor.value,
              Colors.transparent, change),
          Space(0, 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Btn(
                  Colors.transparent,
                  120,
                  38,
                  txt("cancel".tr, mainColor, 20, false),
                  true,
                  () => Get.back()),
              Btn(mainColor, 120, 38,
                  txt("confirm".tr, Colors.white, 20, false), false, action)
            ],
          )
        ],
      ),
    ),
    backgroundColor: boxColor.value,
  );
}

void loadBox() {
  Get.defaultDialog(
      backgroundColor: boxColor.value,
      title: "wait".tr,
      titleStyle: TextStyle(color: txtColor.value, fontSize: 22),
      content: CircularProgressIndicator(
        color: mainColor,
      ));
}

Widget reactsBox() {
  var data = chatController.msgReacts.value;
  String text =
      data.length == 1 ? "1 " + "react".tr : "${data.length} " + "reacts".tr;
  return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      bottom: chatController.showReactBox.isTrue ? 0 : -(Get.height * 0.7),
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: radiusBox(bodyColor.value),
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(8),
                width: Get.width,
                decoration: radiusBox(mainColor),
                child: ListTile(
                  leading: txt(text, Colors.white, 22, true),
                  trailing: myIcon(
                    Icons.close,
                    Colors.grey,
                    26,
                    () => chatController.showReactBox.value = false,
                  ),
                )),
            data.length > 0
                ? Container(
                    constraints: BoxConstraints(
                        minHeight: 10, maxHeight: Get.height * 0.35),
                    child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, int i) {
                          var user = mainController.getUser(data[i]['person']);
                          String img =
                              mainController.getFriendImg(user['imgUrl']);
                          var date = mainController.msgDate(data[i]['time']);
                          return ListTile(
                            leading: ProfileImg(25, img, "user"),
                            title: txt(user['name'], txtColor.value, 22, false),
                            subtitle: txt(date, Colors.grey, 19, false),
                            trailing:
                                txt(data[i]['react'], Colors.grey, 26, false),
                          );
                        }))
                : Space(0, 0)
          ],
        ),
      ));
}

radiusBox(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(15), topRight: Radius.circular(13)),
  );
}

void confirmBox(
    String title, var body, String confirmTxt, confirmAction, cancelAction) {
  var type = body.runtimeType;
//  print("type $type");
  Get.defaultDialog(
    backgroundColor: boxColor.value,
    title: title,
    titleStyle: TextStyle(color: mainColor),
    content: type == String
        ? txt(body, txtColor.value.withOpacity(0.8), 20, false)
        : body,
    confirm: Btn(mainColor, 90, 36, txt(confirmTxt, txtColor.value, 20, false),
        false, confirmAction),
    cancel: Btn(Colors.transparent, 90, 36,
        txt("cancel".tr, mainColor, 20, false), true, cancelAction),
  );
}

Widget UsersListItem(
    String img, String imgType, String title, String subT, var trail, tap) {
  return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      leading: ProfileImg(36, "$img", imgType),
      title: txt(title, txtColor.value, 18, false),
      horizontalTitleGap: 0,
      minVerticalPadding: 2,
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: txt(subT, txtColor.value.withOpacity(0.6), 17, false),
      ),
      trailing: trail,
      onTap: tap);
}

Widget GroupedRadio(String groupVal, List options, change) {
  List<Widget> radios = [];
  for (int i = 0; i < options.length; i++) {
    var row = Row(
      children: [
        Radio(
            activeColor: mainColor,
            value: options[i].toLowerCase(),
            groupValue: groupVal,
            onChanged: change),
        Space(6, 0),
        txt("${options[i]}".tr, txtColor.value, 18, false),
      ],
    );
    radios.add(row);
  }
  return Column(
    children: radios,
  );
}

Widget FileIcon(String text, String type, String sender) {
  IconData icon = Icons.photo;
  String fileName = "";
  switch (type) {
    case "img":
      icon = Icons.photo;
      fileName = text.isNotEmpty ? text : "photo".tr;
      break;
    case "file":
      icon = Icons.insert_drive_file;
      fileName = text.isNotEmpty ? text : "file".tr;
      break;
    case "audio":
      icon = Icons.settings_voice_sharp;
      fileName = duration(int.parse(text));
      break;
    case "video":
      icon = Icons.videocam;
      fileName = text.isNotEmpty ? text : "video".tr;
      break;
  }
  return Row(
    mainAxisSize: MainAxisSize.min,
    textDirection:
        mainController.lang == 'en' ? TextDirection.ltr : TextDirection.rtl,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      txt("$sender :", txtColor.value.withOpacity(0.7), 18, false),
      SizedBox(height: 30, child: myIcon(icon, mainColor, 20, () {})),
      txt(fileName, txtColor.value.withOpacity(0.7), 18, false)
    ],
  );
}

Widget lockBtn(Color color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: Get.width * 0.2),
        child: Btn(
            color,
            Get.width * 0.4,
            45,
            txt("Forget Pattern".tr, txtColor.value, 22, false),
            false, () async {
          mainController.changePatternVals("", "", [], false);
          await mainController.auth.signOut();
          Get.offAllNamed("/verify");
        }),
      ),
    ],
  );
}

Widget Pattern(click) {
  return Flexible(
      child: PatternLock(
          selectedColor: mainColor,
          notSelectedColor: txtColor.value,
          pointRadius: 9,
          dimension: 4,
          showInput: true,
          onInputComplete: click));
}

Widget Pass(String title, action, ver) {
  return Padding(
    padding: EdgeInsets.only(top: Get.height * 0.04),
    child: PasscodeScreen(
      backgroundColor: bodyColor.value,
      title: txt("$title".tr, txtColor.value, 25, true),
      passwordEnteredCallback: action,
      cancelButton: txt("cancel".tr, txtColor.value, 22, false),
      deleteButton: txt("delete".tr, txtColor.value, 22, false),
      shouldTriggerVerification: ver,
      circleUIConfig: CircleUIConfig(
          borderWidth: 2,
          borderColor: txtColor.value,
          fillColor: txtColor.value,
          circleSize: 16),
      keyboardUIConfig: KeyboardUIConfig(
        digitBorderWidth: 2,
        keyboardRowMargin: EdgeInsets.symmetric(vertical: 14),
        keyboardSize: Size(Get.width * 0.7, Get.height * 0.65),
        digitTextStyle: TextStyle(
            color: txtColor.value, fontSize: 27, fontWeight: FontWeight.w600),
        deleteButtonTextStyle: TextStyle(color: txtColor.value),
      ),
      cancelCallback: () => Get.back(),
    ),
  );
}
