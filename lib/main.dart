// @dart=2.8
import 'package:chatting/signup.dart';
import 'package:chatting/my_profile.dart';
import 'package:chatting/story.dart';
import 'package:chatting/story_view.dart';
import 'package:chatting/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'contacts.dart';
import 'chat.dart';
import 'chat_settings.dart';
import 'verify.dart';
import 'new_chat.dart';
import 'add_group.dart';
import 'settings.dart';
import 'recorder.dart';
import 'filter_people.dart';
import 'blocke_people.dart';
import 'shared.dart';
import 'translate.dart';
import 'audio_call.dart';
import 'video_call.dart';
import 'set_pattern.dart';
import 'set_pass.dart';
import 'check_pass.dart';
import 'check_pattern.dart';
import 'home.dart';
import 'test_call.dart';

bool hasPermissions = false;
void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
//  await Permission.microphone.request();
//  await Permission.storage.request();
//  await Permission.manageExternalStorage.request();
//  hasPermissions = await FlutterAudioRecorder.hasPermissions;
  await GetStorage.init();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    chatController.listenNotifications();
    super.initState();
  }

  @override
  build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: Translate(),
      locale: Locale(mainController.lang.value),
      home: DefaultPage(),
      getPages: [
        GetPage(name: "/verify", page: () => VerifyUser()),
        GetPage(name: "/signup", page: () => SignUp()),
        GetPage(name: "/home", page: () => Home()),
        GetPage(name: "/contacts", page: () => Contacts()),
        GetPage(name: "/stories", page: () => Story()),
//        GetPage(name: "/storyViewer", page: () => StoryViewer()),
        GetPage(name: "/userProfile", page: () => UserProfile()),
        GetPage(name: "/myProfile", page: () => MyProfile()),
        GetPage(name: "/chat", page: () => Chat()),
        GetPage(name: "/chatSettings", page: () => ChatSettings()),
        GetPage(name: "/newChat", page: () => NewChat()),
        GetPage(name: "/newGroup", page: () => AddGroup()),
        GetPage(name: "/settings", page: () => Settings()),
        GetPage(name: "/filterPeople", page: () => FilterPeople()),
        GetPage(name: "/blockedPeople", page: () => BlockedPeople()),
        GetPage(name: "/recorder", page: () => Recorder()),
        GetPage(name: "/audioCall", page: () => AudioCallScreen()),
        GetPage(name: "/videoCall", page: () => VideoCall()),
        GetPage(name: "/setPattern", page: () => SetPattern()),
        GetPage(name: "/setPass", page: () => SetPass()),
        GetPage(name: "/checkPass", page: () => CheckPass()),
        GetPage(name: "/checkPattern", page: () => CheckPattern()),
//        GetPage(name: "/testCall", page: () => MyHomePage()),
      ],
    );
  }

  Widget DefaultPage() {
    if (mainController.user != null) {
      return Direction(VerifyUser());
    } else if (mainController.locked.value) {
      return mainController.lockPattern.isNotEmpty
          ? Direction(CheckPattern())
          : Direction(CheckPass());
    } else {
      return Direction(Home());
    }
  }
}
