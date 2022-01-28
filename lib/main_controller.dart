import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'shared.dart';
import 'dart:io';

class MainController extends GetxController {
  final storageBox = GetStorage();
  var user = FirebaseAuth.instance.currentUser,
      token,
      auth = FirebaseAuth.instance,
      homeKey = Key(randomString(5)).obs,
      connected = false.obs,
      phone = "".obs,
      userData = {}.obs,
      userImg = "".obs,
      friendImg = "",
      friendData = {}.obs,
      receiverData = {}.obs,
      imgName = "".obs,
      videoName = "".obs,
      listContacts = [].obs,
      allUsers = [].obs,
      userFriends = [].obs,
      newChat = false.obs,
      userChats = [].obs,
      userContacts = [].obs,
      blockedUsers = [].obs,
      dark = false.obs,
      locked = false.obs,
      lang = 'en'.obs,
      lockType = "".obs,
      lockPattern = [].obs,
      lockPIN = "".obs,
      activeStatus = true.obs,
      accountPrivacy = "public".obs,
      storyPrivacy = "public".obs,
      imgPrivacy = "public".obs,
      phonePrivacy = "public".obs,
      displayedAccounts = "allUsers".obs,
      storyExceptions = [].obs,
      chats = FirebaseFirestore.instance.collection("chats"),
      users = FirebaseFirestore.instance.collection("users"),
      imgFile = File("").obs,
      videoFile = File("").obs,
      displayIcons = false.obs;

  void toggleDisplayIcons() {
    displayIcons.value != displayIcons.value;
    update();
  }

  @override
  void onInit() async {
    toggleDark();
    lang.value = storageBox.read("lang") ?? "en";
    locked.value = storageBox.read("locked") ?? false;
    lockType.value = storageBox.read("lockType") ?? "";
    lockPIN.value = storageBox.read("lockPIN") ?? "";
    lockPattern.value = storageBox.read("lockPattern") ?? [];
    activeStatus.value = storageBox.read("activeStatus") ?? true;
    accountPrivacy.value = storageBox.read("accountPrivacy") ?? "public";
    storyPrivacy.value = storageBox.read("storyPrivacy") ?? "public";
    displayedAccounts.value =
        storageBox.read("displayedAccounts") ?? "all Users";
    Timer.periodic(Duration(seconds: 60), (timer) async {
      bool online = await mainController.checkConnection();
      print("Online $online");
      if (connected.value != online) {
        print("not equal");
        connected.value = online;
        await editField("online", online ? "online" : "offline", false);
        print("updated");
      }
    });
    token = await auth.currentUser?.getIdToken().then((value) => value);
    print("token $token");
    allUsers.value = await getAllUsers();
    blockedUsers.value = await getBlockedUsers(myId);
    userData.value = getUser(myId);
    storyExceptions.value = userData['storyExceptions'];
    userImg.value = getFriendImg(userData.value['imgUrl']);
    userChats.value = await getChats();
    ever(userData, (callback) async => userData.value = getUser(myId));
    ever(blockedUsers,
        (callback) async => blockedUsers.value = await getBlockedUsers(myId));
    ever(newChat, (callback) async => userChats.value = await getChats());
    super.onInit();
//    await [Permission.contacts].request();
  }

  initController() {
    if (isClosed) {
      mainController.onInit();
    }
  }

  void changePatternVals(String type, String pin, List pattern, bool lock) {
    lockType.value = type;
    lockPIN.value = pin;
    lockPattern.value = pattern;
    locked.value = lock;
    storageBox.write("lockType", type);
    storageBox.write("lockPIN", pin);
    storageBox.write("lockPattern", pattern);
    storageBox.write("locked", lock);
  }

  String getFriendImg(var imgs) {
    int length = imgs != null ? imgs.length : 0;
    String img = length > 0 ? imgs[length - 1] : "";
    return img;
  }

  getAllUsers() async {
    var data = [];
    await users.get().then((value) {
      for (var i = 0; i < value.docs.length; i++) {
        String id = value.docs[i].id,
            contactN = isContact(value.docs[i]['phone']),
            name = contactN.isNotEmpty ? contactN : value.docs[i]['username'];
        data.add(value.docs[i].data());
        data[i]["id"] = id;
        data[i]["name"] = name;
        data[i]["selected"] = false;
      }
    });
    return data;
  }

  getOnlineUsers() async {
    var data = [];
    await users.where("connected", isEqualTo: true).get().then((value) {
      List newList = exceptPeople(value.docs);
      for (var i = 0; i < newList.length; i++) {
        String contactN = isContact(newList[i]['phone']),
            name = contactN.isNotEmpty ? contactN : newList[i]['username'];
        data.add(newList[i].data());
        data[i]["id"] = newList[i].id;
        data[i]["name"] = name;
        data[i]["img"] = getFriendImg(newList[i]["imgUrl"]);
      }
    });
    return data;
  }

  exceptPeople(List list) {
    List data = [];
    int l = list != null ? list.length : 0;
    for (int i = 0; i < l; i++) {
      String id = list[i]['id'], accountP = list[i]['accountPrivacy'];
      bool private = accountP == "contacts";
      print(accountP);
      if (!(isBlocked(id) ||
          blocked(list[i]['blocked']) ||
          myId == id ||
          private)) {
        data.add(list[i]);
      }
    }
    return data;
  }

  getFriends() async {
    List data = [];
    var list = allUsers.length > 0 ? allUsers.value : await getAllUsers();
    data = exceptPeople(list);
    return data;
  }

  searchUsers(String name) async {
    await users.startAt([name]).get().then((value) {
          print(value.docs);
        });
  }

  void resetSelectedUsers() {
    for (int i = 0; i < allUsers.length; i++) {
      allUsers[i]['selected'] = false;
    }
  }

  getUser(String id) {
    var userData =
        allUsers.singleWhere((it) => it['id'] == id, orElse: () => {});
    return userData;
  }

  getBlockedUsers(String id) async {
    var blocked = [];
    await users.doc(id).get().then((value) {
      if (value != null) {
        blocked = value['blocked'];
      }
    });
    return blocked;
  }

  isBlocked(String id) {
    bool blocked = false;
    for (int i = 0; i < blockedUsers.length; i++) {
      blocked = blockedUsers.value[i] == id;
    }
    return blocked;
  }

  meBlocked(String id) async {
    bool blocked = false;
    List bUsers = await getBlockedUsers(id);
    print(bUsers);
    for (int i = 0; i < bUsers.length; i++) {
      if (bUsers[i].trim() == myId) {
        blocked = true;
      }
    }
    return blocked;
  }

  blocked(List list) {
    bool blocked = false;
    for (int i = 0; i < list.length; i++) {
      if (list[i].trim() == myId) {
        blocked = true;
      }
    }
    return blocked;
  }

  block(String id) async {
    await users.doc(myId).set({
      "blocked": FieldValue.arrayUnion([id])
    }, SetOptions(merge: true));
    blockedUsers.add(id);
    allUsers.value = await getAllUsers();
  }

  unBlock(String id) async {
    blockedUsers.remove(id);
    await users
        .doc(myId)
        .set({"blocked": blockedUsers.value}, SetOptions(merge: true));
  }

  deleteAllChats() async {
    var snapshots = await chats.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  getChats() async {
    var myChats = [];
    await chats.where("users", arrayContains: myId).get().then((data) async {
      for (var i = 0; i < data.docs.length; i++) {
        List chatReceivers = [];
        var lastMsg = await chatController.getLastMsg(data.docs[i].id),
            item = data.docs[i].data(),
            users = item['users'];

        for (int j = 0; j < users.length; j++) {
          if (users[j].toString() != myId) {
            chatReceivers.add(users[j]);
          }
        }
        String msgTxt = "",
            msgDate = "",
            msgType = "",
            dt = "",
            msgSenderName = "";
        var msgSenderData;
        if (lastMsg != null) {
          msgDate = lastMsg['date'];
          msgType = lastMsg['type'];
          dt = convertDate(lastMsg['date']);
          msgSenderData = getUser(lastMsg['senderId']);
          msgSenderName =
              lastMsg['senderId'] == myId ? "Me" : msgSenderData['name'];
          msgTxt = "${lastMsg['text']}".length > 16
              ? "${lastMsg['text']}".substring(0, 16) + " ..."
              : "${lastMsg['text']}";
        }
        var receiverId = chatReceivers[0],
            receiverData = getUser(receiverId),
            contactName = isContact(receiverData["phone"]),
            name = item['type'] == "group"
                ? item['name']
                : contactName.isNotEmpty
                    ? contactName
                    : receiverData['username'],
            chatImg = item['type'] == "chat"
                ? getFriendImg(receiverData['imgUrl'])
                : item['img'];
        print("contactName $contactName");
        item['id'] = data.docs[i].id;
        item['name'] = name.toString();
        item['img'] = chatImg;
        item['date'] = msgDate;
        item['receivers'] = chatReceivers;
        item['lastMsg'] = msgTxt;
        item['lastMsgDate'] = dt;
        item['lastMsgType'] = msgType;
        item['lastMsgSender'] = msgSenderName;
        myChats.add(item);
      }
    });
    userChats.value = myChats;
    return myChats;
  }

  getChatById(String id) {
    Map chat = userChats.singleWhere((it) => it['id'] == id, orElse: () => {});
    return chat;
  }

  getChatByUsers(String id) {
    var chat = {};
    List users = [myId, id], usersR = [id, myId];
    for (int i = 0; i < userChats.length; i++) {
      List item = userChats.value[i]['users'];
      if (listEquals(item, users) || listEquals(item, usersR)) {
        chat = userChats.value[i];
      }
    }
    return chat;
  }

  isContact(String phone) {
    String name = "";
    for (var i = 0; i < listContacts.length; i++) {
      if (listContacts[i]['phone'] == phone) {
        name = listContacts[i]['name'];
      }
    }
    return name;
  }

  hasAccount(String phone) {
    var person = {};
    for (int i = 0; i < allUsers.value.length; i++) {
      if (allUsers.value[i]['phone'] == phone) person = allUsers.value[i];
    }
    return person;
  }

  Future<bool> checkConnection() async {
    bool result = false;
    try {
      final response = await InternetAddress.lookup('www.google.com');
      if (response.isNotEmpty && response[0].rawAddress.isNotEmpty) {
        result = true;
      }
    } catch (e) {
      print('eeror $e');
      result = false;
    }
    return result;
  }

  getUserContacts() async {
    var contacts = [];
    for (var x = 0; x < listContacts.length; x++) {
      Map val = hasAccount(listContacts[x]['phone']);
      if (val.isNotEmpty) {
        contacts.add(val);
        contacts[x]["name"] = listContacts[x]['name'];
      }
    }
    return contacts;
  }

  getContacts() async {
    final PermissionStatus permissionStatus = await Permission.contacts.status;
    if (permissionStatus == PermissionStatus.granted) {
      listContacts.clear();
      Contacts.streamContacts().forEach((contact) {
        listContacts.add(
            {"name": contact.displayName, "phone": contact.phones[0].value});
      });
    } else {
      snackMsg("Error", "Please allow access to your contacts");
    }
  }

  editField(String name, var val, bool array) async {
    await users.doc(myId).set({
      name: array ? FieldValue.arrayUnion([val]) : val
    }, SetOptions(merge: true));
    allUsers.value = await getAllUsers();
    userData.value = getUser(myId);
    print(userData.value);
  }

  updateContacts(List newList) async {
    List contacts = [];
    if (newList.length != userContacts.length) {
      if (userContacts.length > 0) {
        userContacts.value.forEach((element) {
          contacts.add(element['id']);
        });
        await editField("contacts", contacts, false);
      }
    }
  }

  addField() async {
    await users.doc(myId).set({
      "contacts": [
        "1vkf1MmKFpAvJ01RhSdU",
        "jVt4SxEaVojo7qrVqQzo",
        "YoD7NfC1I31WAKSUTkBf",
        "cvRpM64y9PSddzFlv2Nx",
        "GKe568MWaeFTFXIZxl0z",
      ]
    }, SetOptions(merge: true));
  }

  updateProfileImg(String url) async {
    await users.doc(user?.uid).set({
      "imgUrl": FieldValue.arrayUnion([url])
    }, SetOptions(merge: true));
  }

  uploadFile(bool multiFiles, ex) async {
    List filesData = [];

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: multiFiles,
        type: FileType.custom,
        allowedExtensions: ex);
    if (result != null) {
      int l = result.files.length;
      for (var i = 0; i < l; i++) {
        filesData.add({
          "name": result.files[i].name,
          "size": result.files[i].size,
          "file": File(result.files[i].path ?? "")
        });
      }
    }
    return filesData;
  }

  storeFile(String folder, String fileName, File f) async {
    var ref = FirebaseStorage.instance.ref("$folder/$fileName");
    await ref.putFile(f);
    String url = await ref.getDownloadURL();
    return url;
  }

  goToProfile() {
    if (userData.isNotEmpty && connected.value) {
      Get.toNamed("/myProfile");
    }
//    else {
//      snackMsg("Network Error", "No internet connection");
//    }
  }

  convertDate(String d) {
    String dateTime = "";
    var time = '', date = '';
    if (d.isNotEmpty) {
      DateTime dt = DateTime.parse(d), now = DateTime.now();
      String currentHour = DateFormat.Hm().format(now),
          t = DateFormat.Hm().format(dt);
      time = currentHour == t ? "now" : t;
      date = DateFormat.yMd().format(dt);
      dateTime = now.difference(dt).inDays == 0 ? time : date;
//      print("days ${now.difference(dt).inDays}");
    }
    return dateTime;
  }

  msgDate(String d) {
    String dateTime = "", time = "", date = '';
    DateTime dt = DateTime.parse(d), now = DateTime.now();
    if (d.isNotEmpty) {
      String currentHour = DateFormat.Hm().format(now),
          tt = DateFormat.Hm().format(dt),
          dd = DateFormat.yMd().format(dt);
      time = currentHour == tt ? "now" : tt;
      date = now.difference(dt).inDays == 0
          ? ""
          : (now.difference(dt).inDays == 1 ? "yesterday".tr : dd);
      dateTime = "$date $time";
    }
    return dateTime;
  }

  sortByDate(List list, bool desc) {
    var newList = [];
    list.sort((a, b) {
      DateTime date1 = DateTime.now(), date2 = DateTime.now();
      if (a["date"] != null && b["date"] != null) {
        date1 = DateTime.parse(a["date"]);
        date2 = DateTime.parse(b["date"]);
      }
      return desc ? date2.compareTo(date1) : date1.compareTo(date2);
    });
    return list;
  }

  void changeHomeKey() {
    homeKey.value = Key(randomString(5));
  }

  updatePhone(String phone, var loading) async {
    var credential;
    String code = "";
//    loading.value = true;
    FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: Duration(seconds: 100),
      verificationCompleted: (AuthCredential crl) async {
//        loading.value = false;
      },
      verificationFailed: (exception) {
//        loading.value = false;
        snackMsg("Process Failed", "Please try again later");
      },
      codeSent: (String verificationId, [int? forceResendingToken]) {
//        loading.value = false;
        Get.back();
        Timer(Duration(milliseconds: 400), () async {
          credential = PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: code);
          await user?.updatePhoneNumber(credential);
          print("credential $credential");
          await editField("phone", phone, false);
          EditBox("Verification Code", "", (val) => code = val, () async {
            await user?.updatePhoneNumber(credential);
            await editField("phone", phone, false);
            for (int i = 0; i < userChats.length; i++) {
              await chatController.addMsg("changed phone number", "", "hint",
                  userChats[i]['id'], userChats[i]['receivers']);
            }
          });
        });
      },
      codeAutoRetrievalTimeout: (s) {
        loading.value = false;
        Get.back();
        snackMsg("Failed", "Please try again later");
      },
    );
  }

  toggleDark() {
    dark.value = storageBox.read("darkVal") ?? false;
    if (dark.value) {
      txtColor.value = Colors.white;
      bodyColor.value = Colors.black;
      boxColor.value = Color(0xff232323);
    } else {
      txtColor.value = Colors.black;
      bodyColor.value = Colors.white;
      boxColor.value = Color(0xffdddddd);
    }
  }
}
