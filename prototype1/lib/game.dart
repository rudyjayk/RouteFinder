import 'database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task.dart';

// This is the route class that will represent each
// "gameified route". The route is holding data
// such as the difficulty of the route and a list of
// tasks that the users of the game wil have to complete.
class Game {
  String gameid;
  String difficulty;
  // We could also look at using a map instead of a list
  List<Task> tasklist;

  //Bool statemenet to identify if user has access to editing the route
  bool isEdit = false;

  // Default constructor
  Game({this.gameid, this.difficulty, this.tasklist, this.isEdit});
}
