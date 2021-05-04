import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


//HelpSetting screen for the main Help Setting
//Stateful because it uses the url_launcher package
class HelpSetting extends StatefulWidget{
  @override
  _HelpSettingState createState() => _HelpSettingState();
}


class _HelpSettingState extends State<HelpSetting>{
 
 //Used to hold the text of a TextField widget, The text being held is the problem the user wants to report
  String problem;

  //ASYNC function to launch phones primary email app to send an email including problems of app
  //Also used to email help authorities
  //This method is a work in progress and should be improved later
  Future<void> _launchEmail(String body, String sub) async {
    String url = 'mailto:helpxplorewu@gmail.com?subject=' + sub + '&body=' + body;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  //Method to launch the phone app and call help authorities
  Future<void> _launchCall() async{
    String url = 'tel:8083727182'; 
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  //Method to launch the messaging app and message help authorities
  Future<void> _launchSms() async{
    String url = 'sms:8083727182'; 
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  //Basic build function
  Widget build(BuildContext context){
    return Scaffold(
            appBar: AppBar(
        title: Text('Help'),
        actions: <Widget>[
          Icon(Icons.help),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text('Report a Problem'),
              trailing: Icon(Icons.arrow_right),
              //Pops up a alert used to report a problem
              //When SEND is pressed it will launch the email app with the body and subject filled in
              //  User presses send and presses back arrow to return back to app
              onTap: () => Alert(
                context: context, 
                title: 'REPORT PROBLEM BELOW',
                content: TextField(
                  decoration: InputDecoration(
                    labelText: 'Enter Problem',
                    border: InputBorder.none,
                  ),
                  onChanged: (String str) => problem = str,
                  
                ),
                buttons: [
                  DialogButton(
                    child: Text('SEND',
                    style: TextStyle(fontSize: 24, color: Colors.white)),
                    onPressed: () => {
                      _launchEmail(problem, 'PROBLEM'),
                      Navigator.pop(context),}
                  )
                ]
                ).show(),
            )
          ),

          Padding(padding: EdgeInsets.all(10)),

          Card(
            child: ListTile(
              title: Text('Contact Help Center'),
              trailing: Icon(Icons.arrow_right),
              //Creates an alert that has 3 Icon buttons
              //Each button cooresponds to the Icon
              //Uses the methods that are defined above
              onTap: () => Alert(
                context: context, 
                title: 'SELECT CHOICE OF COMMUNICATION',
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: <Widget>[
                    IconButton(
                      color: Colors.blue,
                      onPressed: () => _launchCall(),
                      icon: Icon(Icons.call),
                      iconSize: 35,
                    ),

                    IconButton(
                      color: Colors.blue,
                      onPressed: () => _launchSms(),
                      icon: Icon(Icons.sms),
                      iconSize: 35,
                    ),

                    IconButton(
                      color: Colors.blue,
                      onPressed: () =>  _launchEmail('', 'CONTACT'),
                      icon: Icon(Icons.email),
                      iconSize: 35,
                    )
                  ],
                ),
                ).show(),
            ),
          )
        ],
      )
    );
  }
}