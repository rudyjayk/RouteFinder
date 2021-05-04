import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'taskscreen.dart';
import 'gameutil.dart';
import 'game.dart';
import 'task.dart';

// This is the CreateScreen class. This is where
// the user will be able to create their custom games
// and submit them to be published to the global list of games.
class CreateScreen extends StatefulWidget {
  Gameutil _gameutil;
  CreateScreen(this._gameutil);
  @override
  _CreateScreenState createState() => _CreateScreenState(_gameutil);
}

class _CreateScreenState extends State<CreateScreen> {
  _CreateScreenState(this._gameutil);
  Gameutil _gameutil;
  Game creategame = Game(gameid: '', difficulty: '', tasklist: List<Task>(), isEdit: false);
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Custom Game'),
      ),
      body: Column(
        children: <Widget>[
          // Initialize the FormBuilder which uses the formbuilder plugin
        
          // Credit to this link for documentation on how to create forms
          // https://pub.dev/packages/flutter_form_builder
          FormBuilder(
            key: _fbKey,
            // TODO: Change this to be more relevant for our form
            initialValue: {
              'date': DateTime.now(),
              'accept_terms': false,
            },
            autovalidate: true,
            child: Column(
              children: <Widget>[
                // Text field to store the name the user inputs for the route
                FormBuilderTextField(
                  attribute: "routename",
                  decoration: InputDecoration(labelText: "Name of Route"),
                  validators: [
                    // Make this field required
                    FormBuilderValidators.required(),
                  ],
                  onChanged: (val) => creategame.gameid = val,
                ),
                // Drop down box for user to specify route difficulty
                FormBuilderDropdown(
                  attribute: "difficulty",
                  decoration:
                      InputDecoration(labelText: "Estimated Difficulty"),
                  hint: Text('Select estimated difficulty of route'),
                  validators: [FormBuilderValidators.required()],
                  items: ['Low', 'Medium', 'High']
                      .map((difficulty) => DropdownMenuItem(
                          value: difficulty, child: Text("$difficulty")))
                      .toList(),
                  onChanged: (val) => creategame.difficulty = val,
                ),
              ],
            ),
          ),
          Row(
            // Button to add a task
            children: <Widget>[
              MaterialButton(
                child: Text("Add Task"),
                onPressed: () {
                  _gameutil.tempLat = null;
                  _gameutil.tempLong = null;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TaskScreen(creategame, _gameutil)));
                },
              ),
            ],
          ),
          // Create listview with an expanded tag so it will not overflow at the bottom of the screen
          Expanded(
            child: ListView.builder(
                // Get the task list for the specific game object
                itemCount: creategame.tasklist.length,
                // https://stackoverflow.com/questions/51809451/how-to-solve-renderbox-was-not-laid-out-in-flutter-in-a-card-widget
                // Learned to do shrinkwrap true from the link above to make the list work.
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return new Card(
                    child: ListTile(
                      leading:
                          Icon(Icons.pin_drop, color: Colors.red, size: 35),
                      // Display the name of the specific task as the title
                      title:
                          Text(creategame.tasklist.elementAt(index).taskname),
                      subtitle: Text(
                          // Display the description of the specific task as a subtitle
                          creategame.tasklist.elementAt(index).description),
                      trailing: RaisedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            // Pass over the current task we want to edit to the EditTaskScreen
                            // Help from this link: https://flutter.dev/docs/cookbook/navigation/passing-data
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditTaskScreen(creategame, index, _gameutil),
                            ),
                          );
                        },
                        child: Text("Edit"),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGame,
        label: Text("Create Game"),
        icon: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _addGame() async {
    // Add game to database.
    print('Trying to add game...');
    bool testName = await _gameutil.db.routeExists(creategame.gameid);
    if(testName){
      print("Name error");
      showErrorDialog("Route Name Already In Use.");
    }else if(creategame.tasklist.length == 0){
      print("Task not added error");
      showErrorDialog("No Tasks Added");
    }else{
      _gameutil.db.createRouteUsingGame(creategame);
      Navigator.pop(context);
    }
    
  }

  void showErrorDialog(var error) async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Material(
            type: MaterialType.transparency,
            child: Center(
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  new Text("$error",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                      fontStyle: FontStyle.normal
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      new Future.delayed(new Duration(seconds: 2), () {
        Navigator.pop(context);
      });
  }
  

}

// Needed for the formbuilder
// https://pub.dev/packages/flutter_form_builder
final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
