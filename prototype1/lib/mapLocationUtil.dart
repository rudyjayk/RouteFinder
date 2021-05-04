import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'gameutil.dart';
import 'dart:math';

// Api key for Google places.
const kGoogleApiKey = "AIzaSyDRPy7Tp6vBSRGN8hNCyjq1oxDNt0gcyW0";

// To get lat and long of place.
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

// Google places
final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();

class UserInputMap extends StatefulWidget {
  Gameutil _gameutil;

  UserInputMap(this._gameutil);

  @override
  State<UserInputMap> createState() => UserInputMapState(_gameutil);
}

class UserInputMapState extends State<UserInputMap> {
  Gameutil _gameutil;
  UserInputMapState(_gameutil){this._gameutil = _gameutil;}

  // Google maps
  Completer<GoogleMapController> _controller = Completer();
  //LatLng cameraPos;
  // For geolocation
  final Map<String, Marker> _markers = {};
  int _markersCounter = 0;


  // Google places
  Mode _mode = Mode.overlay;
  
  // Maps camera position.
  CameraPosition cameraPos = _whitworthLoc;

    static final CameraPosition _whitworthLoc = CameraPosition(
    target: LatLng(47.754941, -117.417856),
    zoom: 14.4746,
  );

// This is the variable that stores 
// the position where the camera will go
  static LatLng _userlocation;
// For now we are assuming our user has location services turned on 
  bool locationservices = true;


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



  @override
     void initState() {
    super.initState();
  // Get the user location on the first build.
  // This will be used to set the initial camera position.
    _getUserLocation();
  }
  Widget build(BuildContext context) {
    if(_gameutil.tempLoc != null){
      //
      _updateMarker();
      _gameutil.tempLoc = null;
    }
    return new Scaffold(
      key:homeScaffoldKey,

     body: _userlocation == null ? Container(
        child: Center(child: Text("Loading map..."),)
      ) : GoogleMap(
        zoomControlsEnabled: false,
        onCameraMove: (campos) => (cameraPos = campos),
        onLongPress: (loc) => (_addMarker(loc)),
        initialCameraPosition: CameraPosition(target: _userlocation, 
        zoom: 11.0),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers.values.toSet(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(           
            child: Icon(Icons.done),
            onPressed: _doneSelecting,
            heroTag: null,
          ),
          SizedBox(height: 10,width: 0,),
          FloatingActionButton(           
            child: Icon(Icons.search),
            onPressed: _openSearch,
            heroTag: null,
          ),
          SizedBox(height: 10,width: 0,),
          FloatingActionButton(           
            child: Icon(Icons.sync),
            onPressed: _updateMarker,
            heroTag: null,
          ),
        ],
      ),
    );
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
  Future<void> _addMarker(LatLng loc) async{

    setState(() {
      final marker = Marker(
        markerId: MarkerId('camPos $_markersCounter'),
        position: LatLng(loc.latitude, loc.longitude),
        infoWindow: InfoWindow(title: 'CamPos'),
      );
      _markers.clear();
      _markers['0'] = marker;
    });

  }

  // For when user is done selecting location.
  _doneSelecting(){
    //Set lat and long.
    //print(_markers['0']);
    _gameutil.tempLat = _markers['0'].position.latitude;
    _gameutil.tempLong = _markers['0'].position.longitude;
    Navigator.pop(context);

  }

  // Erases all the markers.
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


  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  Future<void> _handlePressButton() async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: _mode,
      language: "en",
      components: [Component(Component.country, "us")],
    );

    displayPrediction(p, homeScaffoldKey.currentState, _gameutil);
  }

  void _openSearch(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => CustomSearchScaffold(_gameutil)));
  }

  void _updateMarker() async {
    if(_gameutil.tempLat != null){
      LatLng m = LatLng(_gameutil.tempLat, _gameutil.tempLong);
      _addMarker(m);
      print("Added marker $m");
      _panToMarker(_markers['0']);
    }
  }

  // Might need to be used if calling immediately causes issues.
  void _delayUpdateMarkerTest() async {
    Future.delayed(const Duration(seconds: 2), () {
      _updateMarker();
    });
  }
}



Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold, Gameutil g) async {
  if (p != null) {
    // get detail (lat/lng)
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;
    g.tempLat = detail.result.geometry.location.lat;
    g.tempLong = detail.result.geometry.location.lng;
    g.tempLoc = 'Loc Selected';
    //print(lat);
    //print(lng);
    scaffold.showSnackBar(
      SnackBar(content: Text("${p.description} - $lat/$lng")),
    );
  }
}

// custom scaffold that handle search
// basically your widget need to extends [GooglePlacesAutocompleteWidget]
// and your state [GooglePlacesAutocompleteState]
class CustomSearchScaffold extends PlacesAutocompleteWidget {
  Gameutil _gameutil;
  CustomSearchScaffold(this._gameutil)
      : super(
          apiKey: kGoogleApiKey,
          sessionToken: Uuid().generateV4(),
          language: "en",
          components: [Component(Component.country, "us")],
        );

  @override
  _CustomSearchScaffoldState createState() => _CustomSearchScaffoldState(_gameutil);
}

class _CustomSearchScaffoldState extends PlacesAutocompleteState {
  Gameutil _gameutil;
  _CustomSearchScaffoldState(this._gameutil);
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: AppBarPlacesAutoCompleteTextField());
    final body = PlacesAutocompleteResult(
      onTap: (p) {
        displayPrediction(p, searchScaffoldKey.currentState, _gameutil);
        Navigator.pop(context);
      },
    );
    return Scaffold(key: searchScaffoldKey, appBar: appBar, body: body);
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
    searchScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  @override
  void onResponse(PlacesAutocompleteResponse response) {
    super.onResponse(response);
    /*
    if (response != null && response.predictions.isNotEmpty) {
      searchScaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Got answer")),
      );
    }
    */
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}