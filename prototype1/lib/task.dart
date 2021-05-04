import 'database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// This class will represent an individual task along a route.
// Location, description, etc. will be stored here.
// Tasks will be stored in tasklists along routes
class Task {
  final String taskid;
  String taskname;
  //GeoPoint location; // Adds unnecessary complexity. 
  double lat;
  double long;
  String description;
  String imgLink;

// Default constructor
  Task({this.taskid, this.taskname, this.lat, this.long, this.description, this.imgLink});
}
