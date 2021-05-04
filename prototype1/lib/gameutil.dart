import 'database.dart';
import 'game.dart';


class Gameutil {

  final Database db = new Database();
  // Define a callback function member to notify
  // parent of a change.
  
  Game gameInfo;

  // Temp variables to be used between navigation screens.
  var tempLat;
  var tempLong;
  var tempLoc;
  var tempSelectedRoute;
  bool userLibraryRoute = false;

  void Function() update;

  Gameutil({this.update});


}
