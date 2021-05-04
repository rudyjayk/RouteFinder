import 'package:TreasureHunt/settingAbout.dart';
import 'package:TreasureHunt/settingHelp.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'gameutil.dart';
import 'settingExplore.dart';


//Setting screen
class SettingScreen extends StatelessWidget {

  Gameutil _gameutil;

  SettingScreen(this._gameutil);

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      backgroundColor: Colors.white,
      body: 
      //List of Cards with main settings and description
      ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          
          Card(
            color: Colors.white,
            child: ListTile(
              leading: Icon(Icons.location_city),
              title: Text('Explore Settings'),
              subtitle: Text('Adjust the settings of your exploration'),
              isThreeLine: true,
              trailing: Icon(Icons.arrow_right),
              // One line conditional that only allows user access to the route settings if they are in a route
              onTap: () => _gameutil.gameInfo != null ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ExploreSetting(_gameutil))
                          ) : Alert(context: context,title: 'PLEASE JOIN AN EXPLORATION FIRST').show(),
            ),
          ),

          Padding(padding: EdgeInsets.only(top: 10)),

          Card(
            color: Colors.white,
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text('Permissions'),
              subtitle: Text('Controls privacy services and location data collection'),
              isThreeLine: true,
              trailing: Icon(Icons.arrow_right),
              onTap: () => LocationPermissions().openAppSettings(),//Opens app setting within phone itself to access permissions  //Navigator.pushNamedAndRemoveUntil(context, '/settingPrivacy', (r) => false),
            ),
          ),

          Padding(padding: EdgeInsets.only(top: 10)),

          Card(
            color: Colors.white,
            child: ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              subtitle: Text('Decide how you want us to contact you'),
              isThreeLine: true,
              trailing: Icon(Icons.arrow_right),
              onTap: () => LocationPermissions().openAppSettings(), //Opens app setting within phone itself to access notifications //Navigator.pushNamedAndRemoveUntil(context, '/settingNotification', (r) => false),
            ),
          ),

          Padding(padding: EdgeInsets.only(top: 10)),

          Card(
            color: Colors.white,
            child: ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
              subtitle: Text('Report problems and if in need of assistance'),
              isThreeLine: true,
              trailing: Icon(Icons.arrow_right),
              onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HelpSetting())
                          ),
            ),
          ),

          Padding(padding: EdgeInsets.only(top: 10)),

          Card(
            color: Colors.white,
            child: ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              subtitle: Text('Learn about the services and terms of use'),
              isThreeLine: true,
              trailing: Icon(Icons.arrow_right),
              onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AboutSetting())
                          ),
            ),
          ),

        ],
      )     
    );  
  }
}


