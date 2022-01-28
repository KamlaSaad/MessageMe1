import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'shared.dart';

class ChatController extends GetxController {
  ScrollController scrollController = ScrollController();
  CollectionReference chats = FirebaseFirestore.instance.collection("chats"),
      users = FirebaseFirestore.instance.collection("users");
  var isListReady = false.obs, isDataChanged = false.obs;
  final DatabaseReference messagesRef =
          FirebaseDatabase.instance.reference().child('messages'),
      reactRef = FirebaseDatabase.instance.reference().child('reacts');
  File imgFile = File(""), videoFile = File("");
  var msgKey = Key("").obs,
      replyMsg = {}.obs,
      showReplyBox = false.obs,
      showReactBox = false.obs,
      isSender = false.obs,
      chatKey = Key("list").obs,
      imgName,
      videoName,
      data = [],
      chatData = {}.obs,
      chatBackground = "".obs,
      chatColor = mainColor.obs,
      chatPhotos = [].obs,
      chatVideos = [].obs,
      Masseges = [].obs,
      msgReacts = [].obs;

  //date time.................
  String date = "";
  dateTimeVal(int val) {
    return val < 10 ? "0$val" : "$val";
  }

  var h, m;

  void updateDateTime() {
    var now = DateTime.now();
    h = dateTimeVal(now.hour);
    m = dateTimeVal(now.minute);
    date = DateFormat('dd/MM/yyyy').format(now);
  }

  String msgDate(String mDate, String mTime) {
    var now = DateTime.now();
    String result = "", today = DateFormat('dd/MM/yyyy').format(now);
    DateTime msgDate = DateFormat('dd/MM/yyyy').parse(mDate),
        currentDate = DateFormat('dd/MM/yyyy').parse(today);
    var compare = currentDate.difference(msgDate).inDays;
    return compare == 0 ? mTime : (compare == 1 ? "Yesterday" : mDate);
  }

  @override
  void onInit() async {
    isListReady.value = scrollController.hasClients;
    ever(isListReady, (_) {
      print(isListReady.value);
      isListReady.value = !isListReady.value;
      print(isListReady.value);
    });
    super.onInit();
  }

  void toggleReply(bool show, Map reply, bool sender) {
    showReplyBox.value = show;
    replyMsg.value = reply;
    isSender.value = sender;
  }

  Map defaultChatData(String userName, String img, List receivers) {
    Map defaultChat = {
      'id': "",
      'name': userName,
      'img': img,
      'receivers': receivers,
      'mainColor': mainColor.value,
      'background': "",
      'type': 'chat'
    };
    return defaultChat;
  }

  getContactChatData(List users) async {
    var chat;
    bool isCurrentUser = users[0] == mainController.userData['id'];
    var chatUsers = isCurrentUser ? users : users.reversed.toList();
    await chats.where("users", isEqualTo: chatUsers).get().then((value) {
      if (value.docs.length == 1) {
        var data = value.docs[0];
        chat = {
          "id": data.id,
          "background": data['background'],
          "mainColor": data['mainColor'],
          "users": data['users'],
          "type": data['type'],
        };
      }
    });
    return chat;
  }

  deleteChat(String id) async {
    await mainController.chats.doc(id).delete();
    mainController.userChats.value
        .removeWhere((element) => element['id'] == id);
//    mainController.changeHomeKey();
    Get.back();
    Get.back();
    Get.back();
  }

  updateChatData() async {
    chatData.clear();
    chatBackground.value = "";
    chatColor.value = mainColor;
    var data = await getContactChatData(
        [mainController.userData['id'], mainController.receiverData['id']]);
    if (data != null) {
      var color = chatData.value[0]['mainColor'],
          back = chatData.value[0]['background'];
      chatBackground.value = back;
      chatColor.value = color != null ? color : mainColor;
    }
  }

  getMsgsLength(String chatId) async {
    int l = 0;
    Map chat = mainController.userChats
        .singleWhere((it) => it['id'] == chatId, orElse: () => {});
    if (chat.isNotEmpty) {
      await messagesRef
          .orderByChild("chatId")
          .equalTo(chatId)
          .once()
          .then((data) {
        if (data.value != null) {
          l = data.value['type'] != "hint" ? data.value.length : 0;
        }
      });
    }
    return l;
  }

  getMessages(String chatId) async {
    List msgs = [];
    await messagesRef
        .orderByChild("chatId")
        .equalTo(chatId)
        .once()
        .then((data) {
      if (data.value != null) {
        data.value.forEach((key, val) {
          val['id'] = key;
          msgs.add(val);
        });
      }
    });
    return msgs;
  }

  getMessageById(String id) async {
    var msg;
    await messagesRef.orderByKey().equalTo(id).once().then((data) {
      if (data.value != null) {
        data.value.forEach((key, values) {
          values['id'] = key;
          msg = values;
          print(msg);
        });
      }
    });
    return msg;
  }

  getChatMedia(String type) async {
    var media = [];
    String id = "${chatData.value['id']}";
    await messagesRef.orderByChild('chatId').equalTo(id).once().then((data) {
      if (data.value != null) {
        data.value.forEach((key, values) {
          if (values['type'] == type) {
            media.add({
              "url": values['mediaUrl'],
              "caption": values['text'],
              "sender": values['senderId']
            });
          }
        });
      }
    });
    return media;
  }

  removerMsg(String id) async {
    await messagesRef.child(id).remove();
  }

  removerReact() async {
//    await reactRef.reference().remove();
    await reactRef
        .orderByChild("msgId")
        .equalTo("-MqW9_W6XsY9Fzb_2xdI")
        .reference()
        .remove();
  }

  editMsg(String id, String txt) async {
    await messagesRef.child(id).update({"text": txt});
  }

  removeAllMessages() {
    messagesRef.reference().remove();
  }

  getReacts(String msgId) async {
    List reacts = [];
    await reactRef.orderByChild("msgId").equalTo(msgId).once().then((data) {
      if (data.value != null) {
        data.value.forEach((key, val) {
          val['id'] = key;
          reacts.add(val);
        });
      }
    });
//    Timer(Duration(seconds: 1), () => null);
    return reacts;
  }

  reactMsg(String msgId, String reactTxt) async {
    var now = DateTime.now(),
        react = {
          "msgId": msgId,
          "person": myId,
          "react": reactTxt,
          "time": now.toString()
        };
    var allReacts = await getReacts(msgId);
    Map oldReact =
        allReacts.singleWhere((it) => it["person"] == myId, orElse: () => {});
    if (oldReact.isEmpty) {
      reactRef.push().set(react).asStream();
    } else {
      reactRef.child(oldReact['id']).update({"react": reactTxt});
    }
    msgKey.value = Key(randomString(5));
  }

  getLastMsg(String chatId) async {
    var msg;
    await messagesRef
        .orderByChild("chatId")
        .equalTo(chatId)
        .limitToLast(1)
        .once()
        .then((data) {
      if (data.value != null) {
        data.value.forEach((key, values) {
          values['id'] = key;
          msg = values;
        });
      }
    });
    return msg;
  }

  addMsg(String text, String url, String type, String chatId,
      var receivers) async {
    var now = DateTime.now().toString(),
        msg = {
          "text": text,
          "mediaUrl": url,
          "type": type,
          "status": "notSent",
//          "senderId": "cvRpM64y9PSddzFlv2Nx",
          "senderId": myId,
          "reply": replyMsg.value,
          "receivers": chatData.value['receivers'],
          "chatId": chatData.value['id'],
          "date": now,
          "react": []
        };
    print(msg["reply"]);
    if (chatId.isNotEmpty) {
      await messagesRef.push().set(msg).asStream();
      toggleReply(false, {}, false);
      mainController.userChats.value = await mainController.getChats();
      mainController.changeHomeKey();
    }
  }

  listenNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notification Message: ${message.data['id']}');
      if (message.notification != null) {
        print(
            'Message also contained a notification: ${message.notification?.body}');
      }
    });
  }

  notify() async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.requestPermission(
      sound: false,
      badge: false,
      alert: false,
      provisional: false,
    );
    var dTime = DateTime.now();
    String time = mainController.msgDate(dTime.toString());
    String serverToken =
        "AAAAMSVmjMc:APA91bHsstboG1bIbEbnm1vf8Yyz6gbFfc7Iw70QF32TzRcmNMUH8e-NepM9OFHIdbu5eIaH2W97bNfhXH5JpsTJlXfBEQ4zgT_WffVx3LElnKZjFwJwIhITWNZYL8mqACXBKkskCton";
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'title': 'Firebase ',
              'body': 'Hello kamla',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': await FirebaseMessaging.instance.getToken()
          },
        ),
      );
      print("done");
    } catch (e) {
      print("error $e");
    }
  }

  addChat(
    String background,
    Color color,
    String name,
    String img,
    String type,
    users,
  ) async {
    DocumentReference chat = await chats.add({
      "background": background,
      "mainColor": color.value,
      "name": name,
      "img": img,
      "type": type,
      "users": users,
      "creator": myId
    });
    if (chat.id.isNotEmpty) {
      mainController.userChats.value = await mainController.getChats();
      mainController.changeHomeKey();
    }
    return chat.id;
  }

  changeChatData(String field, val) async {
    await chats
        .doc(chatData.value['id'])
        .set({field: val}, SetOptions(merge: true));
  }

  void scrollToBottom(ScrollController scrollC) {
    final position = scrollC.position.maxScrollExtent;
    scrollC.jumpTo(position);
  }

  void scrollToTop(ScrollController scrollC) {
    final position = scrollC.position.minScrollExtent;
    scrollC.jumpTo(position);
  }

  void changeChatKey() {
    chatKey.value = Key(randomString(5));
  }
}
