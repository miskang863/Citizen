
import 'package:citizen/Keys/Keys.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

Keys keys = Keys();

class DistanceAPI {
  //DO NOT USE LIKE THIS
  /*
  Future<List> getTravelTime(List destinationItems) async {
    List timeList = [];
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var coordsString = '';
    var chunks = [];
    var url;

    if (destinationItems.isNotEmpty) {
      if (destinationItems.length >= 24) {
        for (var i = 0; i < destinationItems.length; i += 24) {
          chunks.add(destinationItems.sublist(
              i,
              i + 24 > destinationItems.length
                  ? destinationItems.length
                  : i + 24));
        }
        for (var element in chunks) {
          coordsString = '';
          element.forEach((item) {
            coordsString +=
                "${item['location']['lat']},${item['location']['lon']}|";
          });

          var lat = 60.16656424979516;
          var lon = 24.933901542838093;
          url = Uri.parse(
              'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&mode=walking&origins=$lat,$lon&destinations=$coordsString&key=${keys.googleKey}');
          //url = Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&mode=walking&origins=${position.latitude},${position.longitude}&destinations=$coordsString&key=${keys.googleKey}');
          http.Response response = await http.get(url);
          var results = jsonDecode(response.body);
          //print(url);
          if (results != null) {
            //print(results);
            timeList += results['rows'][0]['elements'];
          }
        }
        return timeList;
      } else {
        destinationItems.forEach((item) {
          coordsString +=
              "${item['location']['lat']},${item['location']['lon']}|";
        });

        url = Uri.parse(
            'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&mode=walking&origins=${position.latitude},${position.longitude}&destinations=$coordsString&key=${keys.googleKey}');

        http.Response response = await http.get(url);
        var results = jsonDecode(response.body);
        if (results['rows'][0]['elements'] != null) {
          timeList = results['rows'][0]['elements'];
        }
        return timeList;
      }
    }
  }
  */
}

class DistanceAPIForRoute {
  Future<List> getTravelTime(List destinationItems, String travelMode) async {
    List timeList = [];
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var coordsString = '';
    var url;

    destinationItems.forEach((item) {
      coordsString += "${item.lat},${item.lon}|";
    });

    url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&mode=$travelMode&origins=${position.latitude},${position.longitude}&destinations=$coordsString&key=${keys.googleKey}');

    http.Response response = await http.get(url);
    var results = jsonDecode(response.body);
    if (results['rows'][0]['elements'] != null) {
      timeList = results['rows'][0]['elements'];
    }
    return timeList;
  }
}

class DistanceAPIForAddress {
  Future<String> getTravelTime(List destinationItems) async {
    String address = '';
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var coordsString = '';
    var url;

    destinationItems.forEach((item) {
      coordsString += "${item.lat},${item.lon}|";
    });

    url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&mode=walking&origins=${position.latitude},${position.longitude}&destinations=$coordsString&key=${keys.googleKey}');

    http.Response response = await http.get(url);
    var results = jsonDecode(response.body);
    if (results['origin_addresses'][0] != null) {
      var s = results['origin_addresses'][0].toString().split(", ");
      address = s[0];
    }
    return address;
  }
}
