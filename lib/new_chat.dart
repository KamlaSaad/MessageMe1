import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main_controller.dart';
import 'shared.dart';

var c = TextEditingController();

class NewChat extends StatefulWidget {
  @override
  _NewChatState createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  var search = false.obs, startSearch = false.obs;
  var allPersons = mainController.allUsers, searchResults = [];
  String title = Get.arguments, text = "";
  Iterable newPersons = [];
  @override
  build(BuildContext context) {
    return Obx(() => Scaffold(
        backgroundColor: bodyColor.value,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: bodyColor.value,
          leading:
              myIcon(Icons.arrow_back, txtColor.value, 26, () => Get.back()),
          title: search.isTrue
              ? TxtInput("", "", "", search.value, TextInputType.text,
                  Colors.transparent, Colors.transparent, (val) {
                  setState(() {
                    startSearch.value = val != "" ? false : true;
                    text = val;
                  });
                })
              : GestureDetector(
                  child: txt(title, txtColor.value.withOpacity(0.8), 20, false),
                  onTap: () => search.value = true),
//          actions: [
//            myIcon(Icons.search, txtColor.value, 26,
//                () => search.value = !search.value),
//          ],
        ),
        body: FutureBuilder(
            future: mainController.getFriends(),
            builder: (context, AsyncSnapshot snap) {
              switch (snap.connectionState) {
                case ConnectionState.none:
                  return Center(
                      child: txt("No Internet", txtColor.value, 22, true));
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Center(
                      child: txt("Loading...", txtColor.value, 22, true));
                case ConnectionState.done:
                  if (snap.hasError) {
                    print(snap.error);
                  }
                  List data = snap.data;
                  bool isEmail = text.isEmail;
                  var searchResult = data.where((element) =>
                          element[isEmail ? 'email' : 'username']
                              .toString()
                              .toLowerCase()
                              .startsWith(text.toLowerCase())),
                      finalData = text.isNotEmpty ? searchResult : data;
                  return finalData.length > 0
                      ? ListView.builder(
                          itemCount: finalData.length,
                          itemBuilder: (context, i) {
                            var user = finalData.toList()[i],
                                img =
                                    mainController.getFriendImg(user['imgUrl']),
                                contact =
                                    mainController.isContact(user['phone']),
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
                                null, () {
                              Get.toNamed(
                                  title == "Chat with"
                                      ? "/chat"
                                      : "/userProfile",
                                  arguments: user);
                            });
                          })
                      : (text.isEmpty
                          ? loadingMsg("No Users")
                          : loadingMsg("No search results"));
              }
            })));
  }
}
