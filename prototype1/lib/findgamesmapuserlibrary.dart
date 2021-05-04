import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'gameutil.dart';
import 'package:location/location.dart';
import 'game.dart';
import 'task.dart';

class FindGamesMapUserLibrary extends StatefulWidget {
  Gameutil _gameutil;
  FindGamesMapUserLibrary(this._gameutil);
  @override
  _FindGamesMapUserLibrary createState() => _FindGamesMapUserLibrary(_gameutil);
}

class _FindGamesMapUserLibrary extends State<FindGamesMapUserLibrary> {
  _FindGamesMapUserLibrary(this._gameutil);
  Gameutil _gameutil;
  Completer<GoogleMapController> _controller = Completer();

// This is the variable that stores 
// the position where the camera will go
  static LatLng _userlocation;
// For now we are assuming our user has location services turned on 
  bool locationservices = true;
  double deleteButtonOpacity = 0.0;

// Get user location with functionality from
// geolocator
  void _getUserLocation() async {
      _userlocation = null;

      if(locationservices) {
        Position position = await Geolocator()
         .getCurrentPosition();
        setState(() {
          _userlocation = LatLng(position.latitude, position.longitude);
        });
      }
  }

  //LatLng cameraPos;
  // For geolocation
  final Map<String, Marker> _markers = {};
  List<Marker> _markerList = [];
  int _markersCounter = 0;
  String _selectedRoute = '';


  CameraPosition cameraPos = _whitworthLoc;


  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

    static final CameraPosition _whitworthLoc = CameraPosition(
    target: LatLng(47.754941, -117.417856),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);


  // Gets a list of all the routes in the database.
  Future<List<String>> _getRouteNames() async{
    List<String> dbData;
    dbData = await _gameutil.db.getAllUserLibraryRoutes();
    return dbData;
  }

  Future<List<Game>> _getAllRouteGames() async {
    List<Game> games = List();
    games = await _gameutil.db.getUserLibraryGameRoutes();
    return games;
  }

  Future<void> _placeAllGameMarkers() async {
    List<Game> games = await _getAllRouteGames();
    for(Game g in games){
      // Get first task in game.
      Task tempTask = g.tasklist[0] != null ? g.tasklist[0] : null;
      if(tempTask != null){
        // Create marker using first task in Game
        setState(() {
          _markers['$_markersCounter'] = Marker(
            markerId: MarkerId('${tempTask.taskname} + $_markersCounter'),
            position: LatLng(tempTask.lat, tempTask.long),
            infoWindow: InfoWindow(title: 'Route: ${g.gameid}',
            snippet: g.difficulty),
            onTap: (){ 
              g.isEdit = true;
              _gameutil.gameInfo = g;
              _selectedRoute = g.gameid;
              setState(() {
                deleteButtonOpacity = 1.0;
              });

            }
          );
          _markersCounter++;
        });
      }
    }
    setState(() {
      _markers;
    });
  }

  void selectionDone(){
    if(_selectedRoute != ''){
      _gameutil.tempSelectedRoute = _selectedRoute;
      _gameutil.userLibraryRoute = true;
      Navigator.popUntil(context, (route) => route.isFirst);
    }else{
      // Nothing Selected
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
                  new Text("No Route Selected",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontStyle: FontStyle.normal
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      new Future.delayed(new Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
    
  }

  // Pans the camera to the fit all the markers in view.
  Future<void> _panToMarkerBounds() async {
    final GoogleMapController controller = await _controller.future;

    if(_markers.length > 0){

      List<Marker> markers = _markers.values.toList();

      var highestLat = markers[0].position.latitude,
          lowestLat = markers[0].position.latitude,
          highestLng = markers[0].position.longitude,
          lowestLng = markers[0].position.longitude;

      for(Marker x in markers){
        if(highestLat < x.position.latitude){
          highestLat = x.position.latitude;
        }
        if(lowestLat > x.position.latitude){
          lowestLat = x.position.latitude;
        }
        if(highestLng < x.position.longitude){
          highestLng = x.position.longitude;
        }
        if(lowestLng > x.position.longitude){
          lowestLng = x.position.longitude;
        }
      }

      LatLng southwest;
      LatLng northeast;

      // If statement for when longitude is positive or negative because it affects the southwest/northeast values.
      if(lowestLng < 0){
        southwest = LatLng(lowestLat, lowestLng);
        northeast = LatLng(highestLat, highestLng);
      } else{
        southwest = LatLng(lowestLat, highestLng);
        northeast = LatLng(highestLat, lowestLng);
      }


      LatLngBounds bounds = LatLngBounds(southwest: southwest, northeast: northeast);


      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 1)).whenComplete(
        () =>  Future.delayed(const Duration(milliseconds: 1250), 
                  () => controller.animateCamera(CameraUpdate.zoomBy(-0.5))
        )
      );
    }
  }

  // Deletes the current route the user has selected from their library.
  void _deleteSelectedPath() async{

    await _gameutil.db.deleteGameInUserLibrary(_selectedRoute);
    setState(() {
      deleteButtonOpacity = 0.0;
      print("ChangedBGColor to transparent");
    });
    
    print("Deleted Path.");
    _selectedRoute = null;
    _markers.clear();
    _placeAllGameMarkers();
  
  }

  @override

  void initState() {
    super.initState();
  // Get the user location on the first build.
  // This will be used to set the initial camera position.
    _getUserLocation();
    _placeAllGameMarkers();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      // While we are waiting for user location to load, return a loading screen
      body: _userlocation == null ? Container(
        child: Center(child: Text("Loading Find Games Screen..."),)
      ) : GoogleMap(
        mapType: MapType.hybrid,
        zoomControlsEnabled: false,
        onCameraMove: (campos) => (cameraPos = campos),
        initialCameraPosition: CameraPosition(target: _userlocation, 
        zoom: 11.0),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onTap: (f){
          setState(() {
            deleteButtonOpacity = 0.0;
            print("ChangedBGColor to transparent");
          });
        },
        markers: _markers.values.toSet(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Opacity(opacity: deleteButtonOpacity,
            child: FloatingActionButton(           
              child: Icon(Icons.remove_circle),
              onPressed: _deleteSelectedPath,
              heroTag: null,
              backgroundColor: Colors.red,
            )
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(           
            child: Icon(Icons.crop_free),
            onPressed: _panToMarkerBounds,
            heroTag: null,
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(           
            child: Icon(Icons.check),
            onPressed: selectionDone,
            heroTag: null,
          ),
          SizedBox(
            height: 60,
          ),
        ],
      ),
    );
        

  }
}