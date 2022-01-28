import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shared.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool locked = true;
  @override
  build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: bodyColor.value,
          appBar: AppBar(
            backgroundColor: bodyColor.value,
            leading:
                myIcon(Icons.arrow_back, Colors.grey, 22, () => Get.back()),
            title: txt("settings".tr, mainColor, 24, true),
          ),
          body: ListView(
            padding: EdgeInsets.all(10),
            children: [
              ListItem(
                  Icons.nightlight_round,
                  txtColor.value.withOpacity(0.8),
                  "mood".tr,
                  mainController.dark.value ? "on".tr : "off".tr,
                  Switch(
                      value: mainController.dark.value,
                      onChanged: (val) {
                        mainController.initController();
                        mainController.storageBox.write("darkVal", val);
                        mainController.dark.value = !mainController.dark.value;
                        mainController.toggleDark();
                      }),
                  () {}),
              ListItem(
                  Icons.notifications_active,
                  mainColor,
                  "status".tr,
                  "",
                  Switch(
                      value: mainController.activeStatus.value,
                      onChanged: (val) async {
                        mainController.initController();
                        mainController.activeStatus.value = val;
                        mainController.storageBox.write("activeStatus", val);
                        await mainController.editField(
                            "status", val ? "online" : "", false);
                      }),
                  () {}),
              ListItem(
                  Icons.lock,
                  txtColor.value,
                  "Lock Screen".tr,
                  "",
                  Switch(
                      value: mainController.locked.value,
                      onChanged: (val) {
                        mainController.locked.value = val;
                        if (mainController.locked.value) {
                          List options = ['pattern', 'PIN'];
                          var groupVal = "${mainController.lockType.value}".obs;
                          confirmBox(
                              "Lock Screen".tr,
                              Container(
                                  child: Obx(() => GroupedRadio(
                                          groupVal.value, options, (val) {
                                        groupVal.value = val;
                                      }))),
                              "confirm".tr, () async {
                            Get.back();
                            groupVal.value == "pattern"
                                ? Get.toNamed("/setPattern")
                                : Get.toNamed("/setPass");
                          }, () => Get.back());
                        } else {
                          confirmBox(
                              "Cancel Lock Screen",
                              "Are you sure to cancel lock screen?\n You can set new one later",
                              "Sure", () {
                            Get.back();
                            String val = mainController.lockType.value;
                            val == "pattern"
                                ? Get.toNamed("/checkPattern", arguments: true)
                                : Get.toNamed("/checkPass", arguments: true);
                          }, () {
                            mainController.locked.value = true;
                            Get.back();
                          });
                        }
                      }),
                  () {}),
              ListItem(Icons.language, Colors.blue, "lang".tr, "", null, () {
                List options = ['en', 'ar'];
                var groupVal = "${mainController.lang.value}".obs;
                confirmBox(
                    "lang".tr,
                    Container(
                        child: Obx(
                            () => GroupedRadio(groupVal.value, options, (val) {
                                  print("val $val");
                                  groupVal.value = val;
                                }))),
                    "confirm".tr, () async {
                  mainController.lang.value = groupVal.value;
                  mainController.storageBox.write("lang", groupVal.value);
                  Get.updateLocale(Locale(groupVal.value));
                  print(groupVal.value);
                  print(Get.locale);
                  Get.back();
                }, () => Get.back());
              }),
              ListItem(
                  Icons.person, txtColor.value, "accountPrivacy".tr, "", null,
                  () {
                List options = ['public', 'contacts'];
                var groupVal = "${mainController.accountPrivacy.value}".obs;
                confirmBox(
                    "whoSeeProfile".tr,
                    Container(
                        child: Obx(
                            () => GroupedRadio(groupVal.value, options, (val) {
                                  groupVal.value = val;
                                }))),
                    "confirm".tr, () async {
                  mainController.accountPrivacy.value = groupVal.value;
                  mainController.storageBox.write("accountPrivacy", groupVal);
                  await mainController.editField(
                      "accountPrivacy", groupVal.value, false);
                  Get.back();
                }, () => Get.back());
              }),
              ListItem(
                  Icons.photo, Colors.deepPurple, "profilePicture".tr, "", null,
                  () {
                List options = ['public', 'contacts'];
                var groupVal = "${mainController.imgPrivacy.value}".obs;
                confirmBox(
                    "whoSeePhoto".tr,
                    Container(
                        child: Obx(
                            () => GroupedRadio(groupVal.value, options, (val) {
                                  groupVal.value = val;
                                }))),
                    "confirm".tr, () async {
                  mainController.imgPrivacy.value = groupVal.value;
                  await mainController.editField(
                      "imgPrivacy", groupVal.value, false);
                  Get.back();
                }, () => Get.back());
              }),
              ListItem(Icons.phone, Colors.green, "phone".tr,
                  mainController.accountPrivacy.value.tr, null, () {
                List options = ['public', 'contacts'];
                var groupVal = "${mainController.phonePrivacy.value}".obs;
                confirmBox(
                    "whoSeePhone".tr,
                    Container(
                        child: Obx(
                            () => GroupedRadio(groupVal.value, options, (val) {
                                  groupVal.value = val;
                                }))),
                    "confirm".tr, () async {
                  mainController.phonePrivacy.value = groupVal.value;
                  print("groupVal ${groupVal.value}");
                  Get.back();
//                  await mainController.editField(
//                      "phonePrivacy", groupVal, false);
                }, () => Get.back());
              }),
              ListItem(Icons.amp_stories, mainColor, "storyPrivacy".tr,
                  mainController.storyPrivacy.value.tr, null, () {
                List options = [];
                var aP = mainController.accountPrivacy.value,
                    groupVal = "${mainController.storyPrivacy.value}".obs;

                options = aP == "public"
                    ? ['public', 'contacts', 'contactsExcept']
                    : ['contacts', 'contactsExcept'];

                confirmBox(
                    "whoSeeStory".tr,
                    Container(
                        child: Obx(
                            () => GroupedRadio(groupVal.value, options, (val) {
                                  groupVal.value = val;
                                }))),
                    "confirm".tr, () async {
                  mainController.storyPrivacy.value = groupVal.value;
                  if (groupVal.value == 'contacts except..') {
                    Get.back();
                    Timer(
                        const Duration(milliseconds: 200),
                        () => Get.toNamed("/filterPeople",
                            arguments: ['Story Privacy']));
                  } else {
                    mainController.storageBox.write("storyPrivacy", groupVal);
                    Get.back();
                    await mainController.editField(
                        "storyPrivacy", groupVal.value, false);
                  }
                }, () => Get.back());
              }),
              ListItem(Icons.people, Colors.brown, "displayedAccounts".tr,
                  mainController.displayedAccounts.value.tr, null, () {
                List options = ["public".tr, 'contacts'.tr];
                var groupVal = "${mainController.displayedAccounts.value}".obs;
                confirmBox(
                    "whoISee".tr,
                    Container(
                        child: Obx(
                            () => GroupedRadio(groupVal.value, options, (val) {
                                  groupVal.value = val;
                                }))),
                    "confirm".tr, () {
                  mainController.displayedAccounts.value = groupVal.value;
                  mainController.storageBox
                      .write("displayedAccounts", groupVal.value);
                  Get.back();
                }, () => Get.back());
              }),
              ListItem(
                  Icons.block,
                  Colors.redAccent,
                  "blockedPeople".tr,
                  "${mainController.blockedUsers.length} ${'block'.tr}",
                  null,
                  () => Get.toNamed("/blockedPeople")),
              ListItem(
                  Icons.logout, Colors.deepPurpleAccent, "logout".tr, "", null,
                  () {
                confirmBox("logout".tr, "logoutDec".tr, "confirm".tr, () async {
                  await mainController.auth.signOut();
                  Get.offAllNamed("/verify");
                }, () => Get.back());
              }),
            ],
          ),
        ));
  }

  Widget ListItem(
      IconData icon, Color color, String title, String sub, var trail, tap) {
    double p = mainController.lang.value == "en" ? 3 : 0;
    return ListTile(
      leading: myIcon(icon, color, 35, () {}),
      title: txt(title, txtColor.value, 20, false), minVerticalPadding: 1,
//      subtitle: sub.isNotEmpty
//          ? Padding(
//              padding: EdgeInsets.only(top: p),
//              child: txt(sub, Colors.grey, 18, false),
//            )
//          : null,
      trailing: trail,
      onTap: tap, contentPadding: const EdgeInsets.symmetric(vertical: 0),
//      minVerticalPadding: 0,
    );
  }
}
