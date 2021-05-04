import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'createscreen.dart';
import 'mapLocationUtil.dart';
import 'gameutil.dart';
import 'game.dart';
import 'task.dart';

// This class will help us add new tasks to a game.
class TaskScreen extends StatefulWidget {
  final Game currentgame;
  final Gameutil _gameutil;
  // Track the list index so we can delete the proper task if the
  // user wants to delete it.

  // Constructor for task screen so that we can use the current game information
  TaskScreen(this.currentgame, this._gameutil);
  @override
  _TaskScreenState createState() => _TaskScreenState(_gameutil, currentgame);
}

class _TaskScreenState extends State<TaskScreen> {
  final Gameutil _gameutil;
  final Game currentgame;
  _TaskScreenState(this._gameutil, this.currentgame);
  // Assistance from // https://flutter.dev/docs/cookbook/forms/retrieve-input
  // Controller that will store the address the user inputs. We may have
  // to change this once we incorporate the Google Places API.
  final myTaskAddressController = TextEditingController();
  // Controller that will store the description the user inputs for the specific task
  final myTaskDescriptionController = TextEditingController();
  final myTaskNameController = TextEditingController();
  

  var lat;
  var long;

  @override
  void dispose() {
    // Clean up the controller after the widget is dispoed
    myTaskAddressController.dispose();
    myTaskDescriptionController.dispose();
    myTaskNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Tasks'),
        ),
        body: Column(
          children: <Widget>[
            FormBuilder(
              key: _fbKey,
              initialValue: {
                'date': DateTime.now(),
                'accept_terms': false,
              },
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                    attribute: "taskname",
                    controller: myTaskNameController,
                    decoration: InputDecoration(labelText: "Name of Task"),
                    validators: [
                      FormBuilderValidators.required(),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 10,),
                      Icon(
                        Icons.add_location,
                        color: Colors.blue,
                        size: 24.0
                      ),
                      SizedBox(width: 5,),
                      FlatButton(
                        onPressed: () => openMap(),
                        child: SizedBox(child: Text("Add location"),
                        ),
                      ),
                    ],
                  ),
                  FormBuilderTextField(
                    attribute: "taskdescription",
                    controller: myTaskDescriptionController,
                    decoration:
                        InputDecoration(labelText: "Description of Task"),
                    validators: [
                      FormBuilderValidators.required(),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                MaterialButton(
                  child: Text("Add Task"),
                  onPressed: () {
                    // Add a new task to the tasklist inside the current game object
                    if(_gameutil.tempLat != null){
                    widget.currentgame.tasklist.add(new Task(
                        taskname: myTaskNameController.text,
                        description: myTaskDescriptionController.text,
                        taskid: widget.currentgame.tasklist.length.toString(),
                        // Still working on location functionality
                        lat: _gameutil.tempLat,
                        long: _gameutil.tempLong));
                        _gameutil.tempLat = null;
                        _gameutil.tempLong = null;

                        if (currentgame.isEdit == true){
                          _gameutil.db.addGameToUserLibrary(currentgame);
                        }

                        Navigator.pop(context);
                    }else{
                      showErrorDialog("No Location Chosen.");
                    }
                  },
                ),
                MaterialButton(
                  child: Text("Clear"),
                  onPressed: () {
                    _fbKey.currentState.reset();
                  },
                ),
              ],
            )
          ],
        ));
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

  void openMap(){
    // Open map and give location information.
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserInputMap(_gameutil)));
  }



}

// This class represents the screen that will be
// displayed when the user goes to edit a task.
class EditTaskScreen extends StatefulWidget {
  // https://stackoverflow.com/questions/50287995/passing-data-to-statefulwidget-and-accessing-it-in-its-state-in-flutter
  // Received help from the link above on how to pass data from one screen to another.
  // https://www.youtube.com/watch?v=PqeeMy1fQys also helped.
  // We are passing our current game in to edit.
  final Game currentgame;
  // Track the list index so we can delete/edit the proper task if the
  // user wants to edit it.
  final int listindex;
  // Constructor that allows us to use this passed in data
  final Gameutil _gameutil;
  EditTaskScreen(this.currentgame, this.listindex, this._gameutil);
  @override
  _EditTaskScreenState createState() => _EditTaskScreenState(_gameutil);
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  _EditTaskScreenState(this._gameutil);
  final Gameutil _gameutil;
  TextEditingController editaddresscontroller;
  TextEditingController editdescriptioncontroller;
  TextEditingController editnamecontroller;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers to display the values that are already in the task
    // currently being edited
    editnamecontroller = TextEditingController(
        text: widget.currentgame.tasklist.elementAt(widget.listindex).taskname);
    editdescriptioncontroller = TextEditingController(
        text: widget.currentgame.tasklist
            .elementAt(widget.listindex)
            .description);
    // TODO: Definie initial address controller once we get address functionaliy working
  }

  void dispose() {
    // Clean up the controller after the widget is dispoed
    editaddresscontroller.dispose();
    editdescriptioncontroller.dispose();
    editnamecontroller.dispose();
    super.dispose();
  }
// Here we will be passing in the task that we are editing.
// Once we get the custom task class defined we will be passing
// a task into this screen.

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Current Task'),
        ),
        body: Column(
          children: <Widget>[
            FormBuilder(
              key: _fbKey,
              initialValue: {
                'date': DateTime.now(),
                'accept_terms': false,
              },
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                    attribute: "routename",
                    controller: editnamecontroller,
                    decoration: InputDecoration(labelText: "Name of Route"),
                    validators: [
                      // Make this field required
                      FormBuilderValidators.required(),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 10,),
                      Icon(
                        Icons.add_location,
                        color: Colors.blue,
                        size: 24.0
                      ),
                      SizedBox(width: 5,),
                      FlatButton(
                        onPressed: () => openMap(),
                        child: SizedBox(child: Text("Add location"),
                        ),
                      ),
                    ],
                  ),
                  FormBuilderTextField(
                    attribute: "taskdescription",
                    controller: editdescriptioncontroller,
                    decoration:
                        InputDecoration(labelText: "Description of Task"),
                    validators: [
                      FormBuilderValidators.required(),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                MaterialButton(
                  child: Text("Save Changes"),
                  onPressed: () {
                    // Update the values and save any changes to the task
                    widget.currentgame.tasklist
                        .elementAt(widget.listindex)
                        .taskname = editnamecontroller.text;
                    widget.currentgame.tasklist
                        .elementAt(widget.listindex)
                        .description = editdescriptioncontroller.text;
                    _gameutil.db.addGameToUserLibrary(widget.currentgame);
                    // TODO: Implement address editing functionality
                    //  widget.currentgame.tasklist.elementAt(widget.listindex).location= editaddresscontroller.text;
                    // GO back to the create game screen
                    Navigator.pop(context);
                  },
                ),
                MaterialButton(
                  child: Text("Delete Task"),
                  onPressed: () {
                    //  Remove the task being edited from the list.
                    widget.currentgame.tasklist.remove(widget
                        .currentgame.tasklist
                        .elementAt(widget.listindex));

                    _gameutil.db.addGameToUserLibrary(widget.currentgame);
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          ],
        ));
  }


  void openMap(){
    // Open map and give location information.
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserInputMap(_gameutil)));
  }

}

final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
