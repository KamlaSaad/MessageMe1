import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shared.dart';

class Contacts extends StatelessWidget {
  var usersBtnBorder = false.obs,
      contactsBtnBorder = true.obs,
      name = "username".obs;
//  var data = mainController.getAllUsers().obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bodyColor.value,
        leading: GestureDetector(
          child: Obx(
              () => ProfileImg(20, "${mainController.userImg.value}", "user")),
          onTap: () => mainController.goToProfile(),
        ),
        title: txt("logo".tr, mainColor, 25, true),
        actions: [
          myIcon(Icons.search, Colors.white70, 28, () => null),
          Space(10, 0)
        ],
      ),
      body: Container(
          padding: const EdgeInsets.only(
            bottom: 5,
          ),
          width: Get.width,
          height: Get.height,
          child: Stack(
            children: [
              Column(
                children: [
                  Space(0, 15),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Btn(
                              usersBtnBorder.value
                                  ? bodyColor.value
                                  : mainColor,
                              Get.width * 0.36,
                              40,
                              txt(
                                  "allUsers".tr,
                                  usersBtnBorder.value
                                      ? txtColor.value
                                      : Colors.white,
                                  20,
                                  false),
                              usersBtnBorder.value, () {
                            name.value = "username";
                            usersBtnBorder.value = false;
                            contactsBtnBorder.value = true;
                          }),
                          Btn(
                              contactsBtnBorder.value
                                  ? bodyColor.value
                                  : mainColor,
                              Get.width * 0.36,
                              40,
                              txt(
                                  "contacts".tr,
                                  contactsBtnBorder.value
                                      ? txtColor.value
                                      : Colors.white,
                                  20,
                                  false),
                              contactsBtnBorder.value, () async {
                            var newContacts =
                                await mainController.getContacts();
                            usersBtnBorder.value = true;
                            contactsBtnBorder.value = false;
                            await mainController.updateContacts(newContacts);
                          }),
                        ],
                      )),
                  Space(0, 12),
                  Obx(() => SizedBox(
                      height: Get.height * 0.65,
                      child: FutureBuilder(
                          future: contactsBtnBorder.value
                              ? mainController.getFriends()
                              : mainController.getUserContacts(),
                          builder: (context, AsyncSnapshot snap) {
                            switch (snap.connectionState) {
                              case ConnectionState.none:
                                return Center(
                                    child: txt(
                                        "noNet".tr, txtColor.value, 22, true));
                              case ConnectionState.active:
                              case ConnectionState.waiting:
                                return Center(
                                    child: txt(
                                        "load".tr, txtColor.value, 22, true));
                              case ConnectionState.done:
                                if (snap.hasError) {
                                  print(snap.error);
                                }
                                var data = snap.data;
                                if (usersBtnBorder.value) {
                                  mainController.userContacts.value = data;
                                }
                                return data.length > 0
                                    ? ListView.builder(
                                        itemCount: data.length,
                                        itemBuilder: (context, i) {
                                          var user = data[i],
                                              img = mainController
                                                  .getFriendImg(user['imgUrl']),
                                              contact = mainController
                                                  .isContact(user['phone']),
                                              subT = contact.isEmpty
                                                  ? user['email']
                                                  : user['phone'];
                                          return UsersListItem(
                                            img,
                                            "user",
                                            user['name'].isEmpty
                                                ? user['username']
                                                : user['name'],
                                            subT,
                                            null,
                                            () async {
                                              Get.toNamed("/userProfile",
                                                  arguments: user);
                                              await chatController.notify();
                                            },
                                          );
                                        })
                                    : !mainController.connected.value
                                        ? loadingMsg(
                                            "no".tr + " " + "internet".tr)
                                        : (usersBtnBorder.value
                                            ? loadingMsg(
                                                "no".tr + " " + "contacts".tr)
                                            : loadingMsg(
                                                "no".tr + " " + "users".tr));
                            }
                          }))),
                ],
              ),
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
                          txtColor.value, "/home"),
                      BottomIcon(
                          "people".tr, Icons.people_alt_sharp, mainColor, null),
                      BottomIcon("stories".tr, Icons.amp_stories,
                          txtColor.value, "/stories")
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
