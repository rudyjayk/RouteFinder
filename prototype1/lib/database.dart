import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'task.dart';
import 'game.dart';

// Database class that will be used to reference our firestore db
class Database {
  final firestore_db = Firestore.instance;
  var userID;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // Default constructor
  Database(){
    getuserID();
  }

  Future getuserID() async {
    if(Platform.isAndroid){
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      userID = androidInfo.id;
    } else if(Platform.isIOS){
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      userID = iosInfo.identifierForVendor;
    } else {
      NullThrownError();
    }
  }

  // Returns list of all routes from DB.
  Future<List<String>> getAllRoutes() async{
    QuerySnapshot data;
    var document = firestore_db.collection('Routes');
    await document.getDocuments().then((QuerySnapshot) =>
      data = (QuerySnapshot)
    );
    List<DocumentSnapshot> routes = data.documents;
    List<String> routeNames = [];
    
    for(DocumentSnapshot x in routes){
      routeNames.add(x.documentID);
    }

    return routeNames;
  }

  // Returns list of all user libarary routes from DB.
  Future<List<String>> getAllUserLibraryRoutes() async{
    if(userID != null)
      await getuserID();
    QuerySnapshot data;
    var document = firestore_db.collection('Users').document('$userID').collection('UserRoutes');
    await document.getDocuments().then((QuerySnapshot) =>
      data = (QuerySnapshot)
    );
    List<DocumentSnapshot> routes = data.documents;
    List<String> routeNames = [];
    
    for(DocumentSnapshot x in routes){
      routeNames.add(x.documentID);
    }

    return routeNames;
  }

  // Returns true if route exists in main route library.
  Future<bool> routeExists(String routeName) async{
    List<String> routeNames = await getAllRoutes();
    for(String x in routeNames)
      if(x == routeName)
        return true;
    return false;
  }

  // Adds game object to users own library (Device Specific)
  void addGameToUserLibrary(Game g) async {

  if(userID != null)
    await getuserID();

  var jsonBody = {};
  var jsonFull = {};
  for(int i = 0; i < g.tasklist.length; i++){
    jsonBody['taskid'] = g.tasklist[i].taskid;
    jsonBody['taskname'] = g.tasklist[i].taskname;
    jsonBody['lat'] = g.tasklist[i].lat;
    jsonBody['long'] = g.tasklist[i].long;
    jsonBody['description'] = g.tasklist[i].description;
    jsonBody['imgLink'] = g.tasklist[i].imgLink;
    jsonFull['$i'] = json.encode(jsonBody);
    jsonBody.clear();
  }

  String str = json.encode(jsonFull);
  print(str);

  await firestore_db.collection('Users').document('$userID').collection('UserRoutes').document('${g.gameid}')
    .setData({
      "difficulty" : g.difficulty,
      "data" : str
      });

  }

  // Deletes game object from users library (Device Specific)
  void deleteGameInUserLibrary(String gameID) async {

  if(userID != null)
    await getuserID();

  await firestore_db.collection('Users')
                    .document('$userID')
                    .collection('UserRoutes')
                    .document('$gameID').delete();
  
  }

  // Adds game object to main route library.
  void createRouteUsingGame(Game g) async {
    var jsonBody = {};
    var jsonFull = {};
    for(int i = 0; i < g.tasklist.length; i++){
      jsonBody['taskid'] = g.tasklist[i].taskid;
      jsonBody['taskname'] = g.tasklist[i].taskname;
      jsonBody['lat'] = g.tasklist[i].lat;
      jsonBody['long'] = g.tasklist[i].long;
      jsonBody['description'] = g.tasklist[i].description;
      jsonBody['imgLink'] = g.tasklist[i].imgLink;
      jsonFull['$i'] = json.encode(jsonBody);
      jsonBody.clear();
    }

    String str = json.encode(jsonFull);
    print(str);

    await firestore_db.collection('Routes')
      .document('${g.gameid}')
      .setData({
        "difficulty" : g.difficulty,
        "data" : str
        });

  }

  // Fetches route/game using gameID.
  Future<Game> getRouteUsingGameID(var gameID) async {
    DocumentSnapshot data;
    var document = firestore_db.collection('Routes').document('$gameID');
    await document.get().then((DocumentSnapshot) =>
      data = (DocumentSnapshot)
    );
    // str is tasklist in json form.
    var str = json.decode(data.data['data']);
    var jsonBodyTemp;
    bool inputtingData = true;
    int iter = 0;
    List<Task> tasklist = List();
    
    // Turns str with tasklist data into task object list for the game object.
    do{

      if(str['$iter'] != null){
        jsonBodyTemp = json.decode(str['$iter']);
        print(jsonBodyTemp);
        var taskid;
        jsonBodyTemp['taskid'] != 'null' ? taskid = jsonBodyTemp['taskid'] : taskid = null;
        var taskname;
        jsonBodyTemp['taskname'] != 'null' ? taskname = jsonBodyTemp['taskname'] : taskname = null;
        var lat;
        jsonBodyTemp['lat'] != 'null' ? lat = jsonBodyTemp['lat'] : lat = null;
        var long;
        jsonBodyTemp['long'] != 'null' ? long = jsonBodyTemp['long'] : long = null;
        var description;
        jsonBodyTemp['description'] != 'null' ? description = jsonBodyTemp['description'] : description = null;
        var imglink;
        jsonBodyTemp['imgLink'] != 'null' ? imglink = jsonBodyTemp['imgLink'] : imglink = null;
        
        tasklist.add(Task(taskid: taskid, taskname: taskname, lat: lat, long: long, description: description, imgLink: imglink));
        
      }else{
        inputtingData = false;
      }
      iter++;
    }while(inputtingData);

    return Game(gameid: data.documentID, difficulty: data.data['difficulty'], tasklist: tasklist);
  }

  // Fetches route/game using gameID.
  Future<Game> getUserLibraryRouteUsingGameID(var gameID) async {
    if(userID != null)
      await getuserID();
    DocumentSnapshot data;
    var document = firestore_db.collection('Users').document('$userID').collection('UserRoutes').document('$gameID');
    await document.get().then((DocumentSnapshot) =>
      data = (DocumentSnapshot)
    );
    // str is tasklist in json form.
    var str = json.decode(data.data['data']);
    var jsonBodyTemp;
    bool inputtingData = true;
    int iter = 0;
    List<Task> tasklist = List();
    
    // Turns str with tasklist data into task object list for the game object.
    do{

      if(str['$iter'] != null){
        jsonBodyTemp = json.decode(str['$iter']);
        print(jsonBodyTemp);
        var taskid;
        jsonBodyTemp['taskid'] != 'null' ? taskid = jsonBodyTemp['taskid'] : taskid = null;
        var taskname;
        jsonBodyTemp['taskname'] != 'null' ? taskname = jsonBodyTemp['taskname'] : taskname = null;
        var lat;
        jsonBodyTemp['lat'] != 'null' ? lat = jsonBodyTemp['lat'] : lat = null;
        var long;
        jsonBodyTemp['long'] != 'null' ? long = jsonBodyTemp['long'] : long = null;
        var description;
        jsonBodyTemp['description'] != 'null' ? description = jsonBodyTemp['description'] : description = null;
        var imglink;
        jsonBodyTemp['imgLink'] != 'null' ? imglink = jsonBodyTemp['imgLink'] : imglink = null;
        
        tasklist.add(Task(taskid: taskid, taskname: taskname, lat: lat, long: long, description: description, imgLink: imglink));
        
      }else{
        inputtingData = false;
      }
      iter++;
    }while(inputtingData);

    return Game(gameid: data.documentID, difficulty: data.data['difficulty'], tasklist: tasklist);
  }

  // Fetches list of all routes and returns them as Game objects.
  Future<List<Game>> getAllGameRoutes() async {
    List<Game> games = List();
    QuerySnapshot docs;
    var document = firestore_db.collection('Routes');
    await document.getDocuments().then((QuerySnapshot) => 
        docs = (QuerySnapshot)
    );

    List<DocumentSnapshot> docsList = docs.documents;

    for(DocumentSnapshot data in docsList){
      // str is tasklist in json form.
      var str = json.decode(data.data['data']);
      var jsonBodyTemp;
      bool inputtingData = true;
      int iter = 0;
      List<Task> tasklist = List();
      
      // Turns str with tasklist data into task object list for the game object.
      do{

        if(str['$iter'] != null){
          jsonBodyTemp = json.decode(str['$iter']);
          //print(jsonBodyTemp);
          var taskid;
          jsonBodyTemp['taskid'] != 'null' ? taskid = jsonBodyTemp['taskid'] : taskid = null;
          var taskname;
          jsonBodyTemp['taskname'] != 'null' ? taskname = jsonBodyTemp['taskname'] : taskname = null;
          var lat;
          jsonBodyTemp['lat'] != 'null' ? lat = jsonBodyTemp['lat'] : lat = null;
          var long;
          jsonBodyTemp['long'] != 'null' ? long = jsonBodyTemp['long'] : long = null;
          var description;
          jsonBodyTemp['description'] != 'null' ? description = jsonBodyTemp['description'] : description = null;
          var imglink;
          jsonBodyTemp['imgLink'] != 'null' ? imglink = jsonBodyTemp['imgLink'] : imglink = null;
          
          tasklist.add(Task(taskid: taskid, taskname: taskname, lat: lat, long: long, description: description, imgLink: imglink));
          
        }else{
          inputtingData = false;
        }
        iter++;
      }while(inputtingData);

      games.add(Game(gameid: data.documentID, difficulty: data.data['difficulty'], tasklist: tasklist));
    }
    return games;
  }

  // Fetches list of all Routes in user's library.
  Future<List<Game>> getUserLibraryGameRoutes() async {

    if(userID != null)
      await getuserID();

    List<Game> games = List();
    QuerySnapshot docs;
    var document = firestore_db.collection('Users').document('$userID').collection('UserRoutes');
    await document.getDocuments().then((QuerySnapshot) => 
        docs = (QuerySnapshot)
    );

    List<DocumentSnapshot> docsList = docs.documents;

    for(DocumentSnapshot data in docsList){
      // str is tasklist in json form.
      var str = json.decode(data.data['data']);
      var jsonBodyTemp;
      bool inputtingData = true;
      int iter = 0;
      List<Task> tasklist = List();
      
      // Turns str with tasklist data into task object list for the game object.
      do{

        if(str['$iter'] != null){
          jsonBodyTemp = json.decode(str['$iter']);
          //print(jsonBodyTemp);
          var taskid;
          jsonBodyTemp['taskid'] != 'null' ? taskid = jsonBodyTemp['taskid'] : taskid = null;
          var taskname;
          jsonBodyTemp['taskname'] != 'null' ? taskname = jsonBodyTemp['taskname'] : taskname = null;
          var lat;
          jsonBodyTemp['lat'] != 'null' ? lat = jsonBodyTemp['lat'] : lat = null;
          var long;
          jsonBodyTemp['long'] != 'null' ? long = jsonBodyTemp['long'] : long = null;
          var description;
          jsonBodyTemp['description'] != 'null' ? description = jsonBodyTemp['description'] : description = null;
          var imglink;
          jsonBodyTemp['imgLink'] != 'null' ? imglink = jsonBodyTemp['imgLink'] : imglink = null;
          
          tasklist.add(Task(taskid: taskid, taskname: taskname, lat: lat, long: long, description: description, imgLink: imglink));
          
        }else{
          inputtingData = false;
        }
        iter++;
      }while(inputtingData);

      games.add(Game(gameid: data.documentID, difficulty: data.data['difficulty'], tasklist: tasklist));
    }
    return games;
  }

}