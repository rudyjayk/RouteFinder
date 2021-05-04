import 'package:TreasureHunt/createscreen.dart';
import 'package:TreasureHunt/findgames.dart';
import 'package:TreasureHunt/game.dart';
import 'package:flutter/material.dart';
import 'gameutil.dart';
import 'map.dart';
import 'database.dart';
import 'settingScreen.dart';
import 'findgames.dart';
import 'findgamesUserLibrary.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


//Database instance = new Database();

class Treasurehunt extends StatefulWidget {
  Treasurehunt({Key key}) : super(key: key);

  @override
  _TreasurehuntState createState() => _TreasurehuntState();
}

// The Calculator contains an ALU that is
// constructed only one time on build.
class _TreasurehuntState extends State<Treasurehunt> {
  //var backgroundColor = Colors.black84;
  bool _firstBuild = true;
  Gameutil _gameutil;
  var _map;


  //TEST DATA DELETE LATER
  var routeID = 1;
  List lat = ['3.14', '3.13', '3.12'];
  List long = ['4.14', '4.13', '4.12'];
  // END TEST DATA

  void callback() {
    setState(() {});
  }

  Widget build(BuildContext context) {
    if (_firstBuild) {
      _firstBuild = false;
      //_gameutil = Gameutil(update: callback);
      _gameutil = Gameutil(update: callback);
      _map = UserMap(_gameutil);
      // Was used to test the database connection. On first build we created a test user
      // instance.firestore_db.collection('Users').document().setData({'Test' : 'test'});
      //_gameutil.db.createRecord("TestManagerID");
    }

    return Scaffold(
        //appBar: AppBar(title: Text("Treasure Hunt")),
        body: Stack(children: <Widget>[
          // GOOGLE MAPS
          SizedBox.expand(
            child: _map,
          ),
        ] // JOIN AND CREATE BUTTONS
            ),
        bottomSheet: //SETTINGS BUTTON
            Container(
                color: Colors.blue,
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // Create screen button
                    FlatButton(
                      color: Colors.white,
                      textColor: Colors.black,
                      disabledColor: Colors.grey,
                      disabledTextColor: Colors.black,
                      padding: EdgeInsets.fromLTRB(6.0, 12.0, 6.0, 12.0),
                      splashColor: Colors.blueAccent,
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateScreen(_gameutil))
                          ),
                      child: Text(
                        "Create",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),

                    // Find game button
                    FlatButton(
                      color: Colors.white,
                      textColor: Colors.black,
                      disabledColor: Colors.grey,
                      disabledTextColor: Colors.black,
                      padding: EdgeInsets.fromLTRB(6.0, 12.0, 6.0, 12.0),
                      splashColor: Colors.blueAccent,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FindGames(_gameutil))
                        ),
                      child: Text(
                        "Explore",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),

                    // Find game button
                    FlatButton(
                      color: Colors.white,
                      textColor: Colors.black,
                      disabledColor: Colors.grey,
                      disabledTextColor: Colors.black,
                      padding: EdgeInsets.fromLTRB(6.0, 12.0, 6.0, 12.0),
                      splashColor: Colors.blueAccent,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FindGamesUserLibrary(_gameutil))
                        ),
                      child: Text(
                        "My",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),

                    // Settings Button
                    FlatButton(
                      color: Colors.white,
                      textColor: Colors.black,
                      disabledColor: Colors.grey,
                      disabledTextColor: Colors.black,
                      padding: EdgeInsets.fromLTRB(6.0, 12.0, 6.0, 12.0),
                      splashColor: Colors.blueAccent,
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingScreen(_gameutil))
                          ),
                      child: Icon(Icons.settings),
                    ),
                  ],
                )
            )
      );
  }
}
