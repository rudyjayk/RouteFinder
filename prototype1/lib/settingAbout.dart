import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


class AboutSetting extends StatefulWidget{
  AboutSetting({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _AboutSettingState createState() => _AboutSettingState();
}

//Main About setting for app
class _AboutSettingState extends State<AboutSetting>{

  //Method to launch a URL in phones primary web browser
  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: true,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget build(BuildContext context){
    return Scaffold(
            appBar: AppBar(
        title: Text('About'),
        actions: <Widget>[
          Icon(Icons.info),
        ],
      ),
      //List of subsetting beneath the About tab: Terms of use, Application Description, Flutter Packages Used
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text('Application Description'),
              trailing: Icon(Icons.arrow_right),
              //Creates an alert that displays the description of app
              onTap: () => Alert(
                context: context,
                title: 'APPLICATION DESCRIPTION',
                content: Text("Our Application utilizes location services, and user moderation in order to create an exploration/ physical activity app. We used the google maps API to help us track location and pinpoint specific areas on the map. This application will allow the user to choose from either a pre-set made exploration or they will be able to create their own. While creating their own exploration the user will create their own task's by pinpointing specific locations they visited or want to visit and add it to an exploration. Choose an exploration and follow the steps to discover new findings in new areas.",
                          textAlign: TextAlign.center,)
              ).show(),
            )
          ),

          Padding(padding: EdgeInsets.all(10)),

          Card(
            child: ListTile(
              title: Text('Flutter Packages Used'),
              trailing: Icon(Icons.arrow_right),
              //Creates an alert that allows user to select a flutter package they want to see 
              onTap: () => Alert(
                context: context,
                title: 'SELECT FROM BELOW',
                content: Column(
                  //Depending on user choice, app opens web browser and displays the flutter package home screen
                  children: <Widget>[
                     ListTile(
                        title: Text('CLOUD_FIRESTORE'),
                        onTap: () => _launchInBrowser('https://pub.dev/packages/cloud_firestore'),
                      ),
                      ListTile(
                        title: Text('DEVICE_INFO'),
                        onTap: () => _launchInBrowser('https://pub.dev/packages/device_info'),
                      ),
                      ListTile(
                        title: Text('FLUTTER_FORM_BUILDER'),
                        onTap: () => _launchInBrowser('https://pub.dev/packages/flutter_form_builder'),
                      ),
                      ListTile(
                        title: Text('GEOLOCATOR'),
                        onTap: () => _launchInBrowser('https://pub.dev/packages/geolocator'),
                      ),
                      ListTile(
                        title: Text('GOOGLE_MAPS_FLUTTER'),
                        onTap: () => _launchInBrowser('https://pub.dev/packages/google_maps_flutter'),
                      ),
                      ListTile(
                        title: Text('LOCATION'),
                        onTap: () => _launchInBrowser('https://pub.dev/packages/location'),
                      ),
                      ListTile(
                        title: Text('LOCATION_PERMISSIONS'),
                        onTap: () => _launchInBrowser('https://pub.dev/packages/location_permissions'),
                      ),
                      ListTile(
                        title: Text('RFLUTTER_ALERT'),
                        onTap: () => _launchInBrowser('https://pub.dev/packages/rflutter_alert'),
                      ),
                      ListTile(
                        title: Text('URL_LAUNCHER'),
                        onTap: () => _launchInBrowser('https://pub.dev/packages/url_launcher'),
                      ),

                  ]
                )
              ).show(),
            ),
          )
        ],
      )
    );
  }

  
}