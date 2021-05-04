
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/material.dart';

import 'gameutil.dart';
import 'taskscreen.dart';
import 'task.dart';


//Main Explore setting screen
class ExploreSetting extends StatelessWidget{

Gameutil _gameutil;

ExploreSetting(this._gameutil);

  Widget build(BuildContext context){
    return Scaffold(
            appBar: AppBar(
        title: Text('Explore Setting'),
        actions: <Widget>[
          Icon(Icons.location_city),
        ],
      ),
      //List of subsettings beneath Explore Settings
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text('Route Information'),
              trailing: Icon(Icons.arrow_right),
              onTap: ()  => _explorationInfo(context).show(), 
            )
          ),

          Padding(padding: EdgeInsets.all(10)),

          Card(
            child: ListTile(
              title: Text('Change Name'),
              trailing: Icon(Icons.arrow_right),
              onTap: ()  =>   _gameutil.gameInfo.isEdit ? _changeName(context).show() : _noAccessMsg(context).show(),
            )
          ),

          Padding(padding: EdgeInsets.all(10)),

          Card(
            child: ListTile(
              title: Text('Change Difficulty'),
              trailing: Icon(Icons.arrow_right),
              onTap: () =>  _gameutil.gameInfo.isEdit ? _difficultyChange(context).show() : _noAccessMsg(context).show()
            )
          ),

          Padding(padding: EdgeInsets.all(10)),

          Card(
            child: ListTile(
              title: Text('Add/Create New Tasks'),
              trailing: Icon(Icons.arrow_right),
              //Opens the Task Screen so Task could be added from the settings menu as well
              onTap: () => _gameutil.gameInfo.isEdit ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TaskScreen(_gameutil.gameInfo, _gameutil))) : _noAccessMsg(context).show(),

              ),
          )
        ],
      )
    );
  }

  //Returns an alert that displays route information
  //Route inforomation include: route name, route difficulty, and tasks
  Alert _explorationInfo(BuildContext context){

    String gameid = _gameutil.gameInfo.gameid;
    String difficulty = _gameutil.gameInfo.difficulty;

    return Alert(
    context: context, 
    title: 'ROUTE INFORMATION',
    content: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

      children: <Widget>[
        Text('Route Name:', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
        Text('$gameid', textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),),
        Padding(padding: EdgeInsets.all(5),),
        Text('Route Difficulty:', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
        Text('$difficulty', textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),),
        Padding(padding: EdgeInsets.all(5),),
        _printTasks(_gameutil.gameInfo.tasklist, context),
          
      ]  
    ),
    );
  }

  //Returns a column of List tiles
  //Function is called within an alert widget
  //List tile holds information on each task that is on the route
  //  Each task can be pressed so that it can be edited
  //  Task can only be edited if user was the one who created the route
  Column _printTasks(List<Task> strLst, BuildContext context){
    
    List<Widget> list = new List<Widget>();
    list.add(Text('Tasks:', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),);

    for (int i = 0; i < strLst.length; i++){
      list.add(ListTile(title: Text(strLst[i].taskname, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),),
                subtitle: Text(strLst[i].description, textAlign:  TextAlign.center,),
                onTap: () => _gameutil.gameInfo.isEdit ? {
                          Navigator.pop(context),
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditTaskScreen(_gameutil.gameInfo, i, _gameutil))
                          )} : _noAccessMsg(context).show()));
    }
    return Column(mainAxisAlignment: MainAxisAlignment.center ,children: list);
  }

  //Creates an Alert that prompts user to choose a difficulty
  //Choose between Low, Medium, High
  //When button is pressed alert is popped off and database is updated
  Alert _difficultyChange(BuildContext context, ){
    
    return Alert(context: context,
    title: 'CHOOSE DIFFICULTY!!',
    buttons: [
      DialogButton(child: Text('LOW'),
      onPressed:() => {
        _gameutil.gameInfo.difficulty = 'Low',
        _gameutil.db.addGameToUserLibrary(_gameutil.gameInfo),
        Navigator.pop(context)}),

      DialogButton(child: Text('MEDIUM'),
      onPressed: () => {
        _gameutil.gameInfo.difficulty = 'Medium',
        _gameutil.db.addGameToUserLibrary(_gameutil.gameInfo),
        Navigator.pop(context)}),

      DialogButton(child: Text('HIGH'),
      onPressed: () => {
        _gameutil.gameInfo.difficulty = 'High',
        _gameutil.db.addGameToUserLibrary(_gameutil.gameInfo),
        Navigator.pop(context)})
    ]);
  }

  Alert _changeName(BuildContext context){
    String name;
    return Alert(
        context: context,
        title: 'CHANGE NAME:',
        content: TextField(
              decoration: InputDecoration(
                labelText: 'Enter New Name',
                border: InputBorder.none,
              ),
              onChanged: (String str) => name = str,
              
            ),
            buttons: [
                  DialogButton(
                    child: Text('SUBMIT',
                    style: TextStyle(fontSize: 24, color: Colors.white)),
                    onPressed: () => name != null ? {
                      
                      _gameutil.db.deleteGameInUserLibrary(_gameutil.gameInfo.gameid),
                      
                      _gameutil.gameInfo.gameid = name,
                      _gameutil.db.addGameToUserLibrary(_gameutil.gameInfo),
                      Navigator.pop(context),} : Navigator.pop(context)
                  )
                ],
                );
    
  }

  //Returns an alert that tells the user they cannot change a route they did not create 
  Alert _noAccessMsg(BuildContext context) {
    return Alert(context: context, title: 'TO EDIT A ROUTE, YOU MUST JOIN THE ROUTE VIA THE \'MY\' TAB!!');
  }
}