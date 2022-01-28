import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shared.dart';

class BlockedPeople extends StatefulWidget {
  @override
  _BlockedPeopleState createState() => _BlockedPeopleState();
}

class _BlockedPeopleState extends State<BlockedPeople> {
  var data = mainController.blockedUsers.value;

  @override
  Widget build(BuildContext context) {
    print("data $data");
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
        backgroundColor: bodyColor.value,
        leading: myIcon(Icons.arrow_back, mainColor, 24, () => Get.back()),
        title: txt("blockedPeople".tr, txtColor.value, 22, false),
      ),
      body: Container(
        child: data.length > 0
            ? ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, i) {
                  var user = mainController.getUser(data[i]);
                  String img = mainController.getFriendImg(user['imgUrl']),
                      contactName = mainController.isContact(user['phone']),
                      name =
                          contactName.isNotEmpty ? contactName : user['name'],
                      subT = contactName.isNotEmpty
                          ? user['email']
                          : user['phone'];
                  return UsersListItem("img", "user", name, subT, null, () {
                    confirmBox("Unblock $name", "Are you sure to unblock $name",
                        "UnBlock", () async {
                      Get.back();
                      mainController.blockedUsers.remove(user['id']);
                      setState(() => data = mainController.blockedUsers.value);
                      await mainController.unBlock(user['id']);
                    }, () => Get.back());
                  });
                })
            : loadingMsg("No blocked people"),
      ),
    );
  }
}
