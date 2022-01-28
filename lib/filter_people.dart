import 'package:random_string/random_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shared.dart';

class FilterPeople extends StatefulWidget {
  @override
  _FilterPeopleState createState() => _FilterPeopleState();
}

class _FilterPeopleState extends State<FilterPeople> {
  String title = Get.arguments[0] ?? "";
  List users = [];
  var key = Key(randomString(4)), data = [].obs;
  @override
  Widget build(BuildContext context) {
    data.value = mainController.exceptPeople(mainController.allUsers.value);
    addExceptions();
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
            SizedBox(
                height: Get.height * 0.7,
                child: data.length > 0
                    ? ListView.builder(
                        key: key,
                        padding: EdgeInsets.only(top: 10),
                        itemCount: data.length,
                        itemBuilder: (context, i) {
                          var user = data.value[i];
                          String name = user['name'].toString().isEmpty
                              ? user['username']
                              : user['name'];
                          String img =
                              mainController.getFriendImg(user['imgUrl']);
                          return ListTile(
                            leading: ProfileImg(26, img, "user"),
                            title: txt(name, txtColor.value, 21, false),
                            subtitle:
                                txt(user['email'], Colors.grey, 19, false),
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
            color: txtColor.value,
            size: 30,
          ),
          onPressed: () async {
            print(users);
            Get.back();
            mainController.storyExceptions.value = users;
//            await mainController.editField("storyExceptions", users, false);
          }),
    );
  }

  void selectUser(var list) {
    setState(() {
      list['selected'] = !list['selected'];
      list['selected'] ? users.add(list['id']) : users.remove(list['id']);
    });
  }

  void addExceptions() {
//    users = [];
    var list = mainController.storyExceptions;
    for (int i = 0; i < list.length; i++) {
      for (int j = 0; j < data.value.length; j++) {
        if (data.value[j]['id'] == list[i]) {
//          print(data.value[j]['selected']);
          setState(() {
            data.value[j]['selected'] = true;
            users.add(data[j]['id']);
          });
        }
      }
    }
  }
}
