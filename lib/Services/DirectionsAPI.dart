import 'package:citizen/Keys/Keys.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Keys keys = Keys();

class DirectionsAPI {
  Future<List> getPlanRoute(List waypoints, String travelMode) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String waypointsString = '';
    waypoints.forEach((waypoint) {
      waypointsString +=
          waypoint.lat.toString() + ',' + waypoint.lon.toString() + '|';
    });

    print(waypointsString);

    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${position.latitude},${position.longitude}&destination=${position.latitude},${position.longitude}&waypoints=optimize:true|$waypointsString&mode=$travelMode&key=${keys.googleKey}');

    http.Response response = await http.get(url);
    var results = jsonDecode(response.body);
    print(results);

    print(results['routes'][0]['legs']);
    return results['routes'][0]['legs'];
  }
}
