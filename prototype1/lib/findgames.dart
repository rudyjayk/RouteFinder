import 'package:flutter/material.dart';
import 'gameutil.dart';
import 'findgamesmap.dart';
import 'createscreen.dart';
import 'findgamesUserLibrary.dart';
import 'settingScreen.dart';

class FindGames extends StatefulWidget {
  Gameutil _gameutil;
  FindGames(this._gameutil);
  @override
  _FindGamesState createState() => _FindGamesState(_gameutil);
}

class _FindGamesState extends State<FindGames> {
  _FindGamesState(this._gameutil);
  bool _firstBuild = true;
  Gameutil _gameutil;
  var _map;


  Widget build(BuildContext context) {
    if(_firstBuild) {
      _firstBuild = false;
      _map = FindGamesMap(_gameutil); 
    }
    return Scaffold(
      appBar: AppBar(title: Text("Find Games Near Me")),

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
                height: 65,
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
                ),
              ),
    );
  }
}