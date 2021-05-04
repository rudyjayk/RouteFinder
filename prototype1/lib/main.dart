import 'package:TreasureHunt/gameutil.dart';
import 'package:flutter/material.dart';
import 'treasurehuntmain.dart';
import 'settingScreen.dart';
import 'settingHelp.dart';
import 'settingExplore.dart';
import 'createscreen.dart';
import 'taskscreen.dart';
import 'settingAbout.dart';
import 'mapLocationUtil.dart';
import 'gameutil.dart';
import 'findgames.dart';

void main() {
  // The MaterialApp Widget is top

  runApp(MaterialApp(
    title: "Treasure Hunt",
    // A Column widget is the child 
  home: Treasurehunt(),
  initialRoute: '/',
  routes: {
    '/setting': (context) => SettingScreen(null),
    '/CreateScreen' : (context) => CreateScreen(null),
    '/CreateScreen/TaskScreen' : (context) => TaskScreen(null, null),
    '/CreateScreen/EditTaskScreen' : (context) => EditTaskScreen(null, null, null),
    '/settingExplore': (context) => ExploreSetting(null),
    //'/settingPrivacy': (context) => PrivacySetting(),
    //'/settingNotification': (context) => NotificationSetting(),
    '/settingHelp': (context) => HelpSetting(),
    '/settingAbout': (context) => AboutSetting(),
    '/locationSet' : (context) => UserInputMap(null),
    //'/findgames' : (context) => FindGames(null)
  },
  // https://stackoverflow.com/questions/52663445/flutter-show-bottomsheet-transparency
   theme: ThemeData(
bottomSheetTheme: BottomSheetThemeData(
  backgroundColor: Colors.black.withOpacity(0)
),
  ), )
);
}
