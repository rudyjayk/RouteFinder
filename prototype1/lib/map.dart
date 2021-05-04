import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'gameutil.dart';
import 'game.dart';
import 'task.dart';
import 'dart:ui';

class UserMap extends StatefulWidget {
  Gameutil _gameutil;

  UserMap(_gameutil){this._gameutil = _gameutil;}

  @override
  State<UserMap> createState() => UserMapState(_gameutil);
}

class UserMapState extends State<UserMap> {
  Gameutil _gameutil;
  UserMapState(_gameutil){this._gameutil = _gameutil;}
  Completer<GoogleMapController> _controller = Completer();

  //LatLng cameraPos;
  // For geolocation
  final Map<String, Marker> _markers = {};
  List<Marker> _markerList = [];
  int _markersCounter = 0;
  String _selectedRoute;


  CameraPosition cameraPos = _whitworthLoc;

  // This is the variable that stores 
  // the position where the camera will go
  static LatLng _userlocation;
  // For now we are assuming our user has location services turned on 
  bool locationservices = true;


// Get user location with functionality from
// geolocator pub.dev/packages/geolocator
  void _getUserLocation() async {
    if(locationservices) {
      Position position = await Geolocator().getCurrentPosition();
      setState(() {
        _userlocation = LatLng(position.latitude, position.longitude);
      });
    }
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

    static final CameraPosition _whitworthLoc = CameraPosition(
    target: LatLng(47.754941, -117.417856),
    zoom: 14.4746,
  );


  @override
   void initState() {
    super.initState();
  // Get the user location on the first build.
  // This will be used to set the initial camera position.
    _getUserLocation();
  }
  Widget build(BuildContext context) {
    if(_gameutil.tempSelectedRoute != null){
      _getRouteUsingSelectedRoute();
      _gameutil.tempSelectedRoute = null;
    }
    return Scaffold( 
      // Same loading strategy as other pages, 
      // Griffen used in his software engineering project
      // and was able  to apply it to this one as well
      body: _userlocation == null ? Container(
        child: Center(child: Text("Loading current route page..."),)
      ) : GoogleMap(
        mapType: MapType.hybrid,
        zoomControlsEnabled: false,
        onCameraMove: (campos) => (cameraPos = campos),
        onLongPress: (loc) => (_addLongPressMarker(loc)),
        initialCameraPosition: CameraPosition(target: _userlocation, 
        zoom: 11.0),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers.values.toSet(),
        myLocationEnabled: true,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(           
            child: Icon(Icons.crop_free),
            onPressed: _panToMarkerBounds,
            heroTag: null,
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(           
            child: Icon(Icons.sync),
            onPressed: _getRouteUsingSelectedRoute,
            heroTag: null,
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(           
            child: Icon(Icons.clear),
            onPressed: _clearMarkers,
            heroTag: null,
          ),
          SizedBox(
            height: 60,
          ),
        ],
      ),
        
        );

  }


  Future<void> _getRouteUsingSelectedRoute() async {
    // Get route from user temp select variable set from selection screen.
    Game g;
    if(_gameutil.userLibraryRoute){
      g = await _gameutil.db.getUserLibraryRouteUsingGameID(_gameutil.tempSelectedRoute);
      _gameutil.userLibraryRoute = false;
    }else{
      g = await _gameutil.db.getRouteUsingGameID(_gameutil.tempSelectedRoute);
    }

    // Reset user picked choice after retrieving from db.
    _gameutil.tempSelectedRoute = null;
    // Adds game to user's library.
    _gameutil.db.addGameToUserLibrary(g);

    // Add tasks to map
    _clearMarkers();
    for(Task g in g.tasklist){
      // Get first task in game.
      Task tempTask = g;
      if(tempTask != null){
        // Create marker using first task in Game
        setState(() {
          _markers['$_markersCounter'] = Marker(
            markerId: MarkerId('${tempTask.taskname} + $_markersCounter'),
            position: LatLng(tempTask.lat, tempTask.long),
            infoWindow: InfoWindow(title: 'Task: ${tempTask.description}',
            onTap: (){
              _showAlert(context, tempTask.description);
            }),
            onTap: (){

            },
          );
          _markersCounter++;
        });

      }
    }
    setState(() {
      _markers;
    });
    _panToMarkerBounds();
  }


  // Show full task message when pressed.
  void _showAlert(BuildContext context, String passedText) {

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
        title: Text('Task:'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child:
                Text('$passedText'),
              ),
            ],
        ),
        actions:[
          FlatButton(
            child: Text("Ok"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      )
    );
  }


  // Code to show route select dialog. *NO LONGER IN USE*
  void _showSelectRouteAlert(BuildContext context, List<String> routeList) {
    if(_selectedRoute == null && routeList.length > 0){
      _selectedRoute = routeList[0];
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
        title: Text('Select Route'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child:
                  DropdownButton(
                    isExpanded: true,
                    hint: Text('Select a route.'),
                    value: _selectedRoute,
                    onChanged: (newValue) {
                      setState(() {
                        print(_selectedRoute);
                        _selectedRoute = newValue;
                        // Work around because showDialog creates new stateful widget so selected value doesn't get updated.
                        // https://stackoverflow.com/questions/51271061/flutter-why-slider-doesnt-update-in-alertdialog
                        Navigator.of(context).pop();
                        _showSelectRouteAlert(context, routeList);
                      });
                    },
                    items: routeList.map((route) {
                      return DropdownMenuItem(
                        child: new Text(route),
                        value: route,
                      );
                    }).toList(),
                  ),
              ),
            ],
        ),
        actions:[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text("Select"),
            onPressed: () {
              //_downloadRoute();
              Navigator.pop(context);
            },
          ),
        ],
      )
    );
  }

  // Called to show route select *NO LONGER IN USE*
  void _routeSelectAlertInit() async {

    // Shows loading icon.
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
                new CircularProgressIndicator(),
                new Text("Loading",
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

    // Gets the routes from the database and destroys loading dialog when done.
    List<String> routes = await _getRoutes().whenComplete(
      () {
        Navigator.pop(context);
      }
    );

    // Shows the dialog for the routes retrieved from database.
    _showSelectRouteAlert(context, routes);
  }

  // Gets user's geolocation and displays it as a marker on the map.
  Future<void> _getLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    setState(() {
      _markers.clear();
      final marker = Marker(
          markerId: MarkerId('curr_loc'),
          position: LatLng(currentLocation.latitude, currentLocation.longitude),
          infoWindow: InfoWindow(title: 'Your Location'),
      );
      _markers["Current Location"] = marker;
      _panToMarker(marker);
    });
  }

  // Ads marker to map.
  Future<void> _addLongPressMarker(LatLng loc) async{

    setState(() {
      final marker = Marker(
        markerId: MarkerId('camPos $_markersCounter'),
        position: LatLng(loc.latitude, loc.longitude),
        infoWindow: InfoWindow(title: 'CamPos'),
      );
      _markers["Current Camera Location$_markersCounter"] = marker;
      _markerList.add(marker);
      _markersCounter++;
    });

  }

  // Gets a list of all the routes in the database.
  Future<List<String>> _getRoutes() async{
    List<String> dbData;
    dbData = await _gameutil.db.getAllRoutes();
    return dbData;
  }

  // Erases all the markers and the _selectedRoute
  Future<void> _clearMarkers() async {
    setState(() {
      _markers.clear();
    });
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

  // Pans the camera to the marker given.
  Future<void> _panToMarker(Marker loc) async{
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
      target: LatLng(loc.position.latitude, loc.position.longitude),
      zoom: 15)
    ));
  }

}