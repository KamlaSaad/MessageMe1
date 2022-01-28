import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shared.dart';

class AddGroup extends StatefulWidget {
  @override
  _AddGroupState createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  var groupName = "", users = [], checkIcon = Icons.check_box_outline_blank;
  bool checked = false, isGroup = false;
  String title = Get.arguments[0] ?? "";
  var data = mainController.exceptPeople(mainController.allUsers);
  @override
  Widget build(BuildContext context) {
    isGroup = title == "addGroup".tr;
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
        backgroundColor: bodyColor.value,
        leading: myIcon(Icons.arrow_back, mainColor, 24, () => Get.back()),
        title: txt(title, txtColor.value, 22, false),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            isGroup
                ? ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    leading: ProfileImg(28, "", "group"),
                    title: TxtInput(
                      "groupName".tr,
                      "",
                      "",
                      false,
                      TextInputType.text,
                      mainColor,
                      Colors.transparent,
                      (val) => setState(() => groupName = val),
                    ),
                  )
                : Space(0, 0),
            SizedBox(
                height: Get.height * 0.7,
                child: data.length > 0
                    ? ListView.builder(
                        padding: EdgeInsets.only(top: 10),
                        itemCount: data.length,
                        itemBuilder: (context, i) {
                          var user = data[i];
                          String name = user['name'].toString().isEmpty
                              ? user['username']
                              : user['name'];
                          String img =
                              mainController.getFriendImg(user['imgUrl']);
                          return ListTile(
                            leading: ProfileImg(26, img, "user"),
                            title: txt(name, txtColor.value, 22, false),
                            subtitle: isGroup
                                ? txt(user['email'], Colors.grey, 19, false)
                                : Space(0, 0),
                            trailing: myIcon(
                                user['selected']
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                mainColor,
                                30,
                                () => selectUser(user)),
                            selected: user['selected'],
                            onTap: () {
                              selectUser(user);
                            },
                          );
                        })
                    : (txt('Something went wrong', txtColor.value, 20, true))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainColor,
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () async {
          if (!isGroup) {
            Map msg = Get.arguments[1];
            for (int i = 0; i < users.length; i++) {
              Map chat = mainController.getChatByUsers(users[i]);
              if (chat.isNotEmpty) {
                chatController.addMsg(msg['text'], msg['url'], msg['type'],
                    chat['id'], [users[i]]);
              } else {
//                loadBox();
                String id = await chatController
                    .addChat("", mainColor, "", "", "chat", [myId, users[i]]);
                if (id.isNotEmpty) {
                  chatController.addMsg(
                      msg['text'], msg['url'], msg['type'], id, [users[i]]);
                } else {
                  snackMsg('err1', "err2");
                }
              }
            }
            Get.back();
          } else {
            Map check = mainController.userChats
                .singleWhere((it) => it['name'] == groupName, orElse: () => {});

            if (groupName.isEmpty)
              snackMsg('err1', "enter".tr + " " + "groupName".tr.toLowerCase());
            else if (check.isNotEmpty) {
              snackMsg('err1', "nameExist".tr);
            } else if (users.length < 2)
              snackMsg('err1', "group Contain".tr);
            else {
              loadBox();
              users.insert(0, myId);
              String id = await chatController.addChat(
                  "", mainColor, groupName, "", "group", users);
              print("id $id");
              if (id.isEmpty) {
                Get.back();
                snackMsg('err1', "err2");
              } else {
                Get.back();
                Map chat = mainController.getChatById(id);
                print(chat);
                users.remove(myId);
                await chatController.addMsg(
                    "created this group", "url", "hint", id, users);
                chat['name'] = groupName;
                chatController.chatData.value = chat;
                setState(() {
                  groupName = "";
                  users = [];
                });
                mainController.changeHomeKey();
                Get.offNamed("/chat");
              }
            }
          }
        },
      ),
    );
  }

  void selectUser(var list) {
    setState(() {
      list['selected'] = !list['selected'];
      list['selected'] ? users.add(list['id']) : users.remove(list['id']);
    });
    print(users.length);
  }
}
