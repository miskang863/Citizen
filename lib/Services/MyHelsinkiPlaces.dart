import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Components/TagList.dart';

class MyHelsinkiPlaces {
  var listOfPlaces = [];

  Future<List> getPlaces() async {
/*     Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
 */
    String tagString = await loadData();

    //     var url = Uri.parse(
    //    "https://open-api.myhelsinki.fi/v1/places/?tags_search=$tagString&distance_filter=${position.latitude},${position.longitude},1");

    var url = Uri.parse(
        "https://open-api.myhelsinki.fi/v1/places/?tags_search=$tagString");
    http.Response response = await http.get(url);
    var results = utf8.decode(response.bodyBytes);
    var results2 = jsonDecode(results);

    this.listOfPlaces = results2['data'];

    return listOfPlaces;
  }

  // All favorite places by id for favorites
  Future getFavoritePlaces(List favList) async {
    var listOfFavPlaces = [];

    print("started loading favorites ...");
    return Future.wait(favList.map((item) => http
            .get(Uri.parse('https://open-api.myhelsinki.fi/v1/place/$item'))
            .then((response) {
          print("loading item $item");

          var results = utf8.decode(response.bodyBytes);
          listOfFavPlaces.add(json.decode(results));
          return listOfFavPlaces;
        })));
  }

  // All favorite places by id for favorites
  Future getFavoriteEvents(List favList) async {
    var listOfFavPlaces = [];

    print("started loading favorites ...");
    return Future.wait(favList.map((item) => http
            .get(Uri.parse('https://open-api.myhelsinki.fi/v1/event/$item'))
            .then((response) {
          print("loading item $item");

          var results = utf8.decode(response.bodyBytes);
          listOfFavPlaces.add(json.decode(results));
          return listOfFavPlaces;
        })));
  }

  Future<String> loadData() async {
    print("loading tags..");
    String tagsString = '';
    List allTagsList = Taglist().listofTagsFormatted;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var stringValue = prefs.getStringList('selectedTags');
    if (stringValue != null) {
      print("retrieved tags:: ${stringValue.toSet()}");

      stringValue.forEach((tagId) {
        //Fetch the tag strings with the tagIDs
        tagsString += allTagsList[int.parse(tagId)] + ',';
      });
    }
    return tagsString;
  }
}

class MyHelsinkiEvents {
  var listOfEvents = [];

  Future getEvents(uri) async {
    var url = Uri.parse(uri);
    http.Response response = await http.get(url);
    var results = jsonDecode(response.body);
    this.listOfEvents = results['data'];

    return listOfEvents;
  }

  Future getEventsWithTag() async {
    // Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);

    String tagString = await MyHelsinkiPlaces().loadData();
    print("tagstring : $tagString");

    var url = Uri.parse(
        "http://open-api.myhelsinki.fi/v1/events/?tags_search=$tagString");

    http.Response response = await http.get(url);

    var results = utf8.decode(response.bodyBytes);
    var results2 = jsonDecode(results);

    this.listOfEvents = results2['data'];

    return listOfEvents;
  }
}
