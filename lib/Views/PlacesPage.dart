import 'package:citizen/Services/flash_helper.dart';
import 'package:citizen/Views/DetailsPage.dart';
import 'package:citizen/Views/DialogInteresPage.dart';
import 'package:citizen/Views/PlanPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/MyHelsinkiPlaces.dart';
import '../Models/MyHelsinkiPlacesItem.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class PlacesPage extends StatefulWidget {
  @override
  _PlacesPage createState() => _PlacesPage();
}

class _PlacesPage extends State<PlacesPage> {
  var _searchView = new TextEditingController();
  bool _firstSearch = true;
  String _query = '';

  var itemlist = [];
  var filteredList = [];
  List<String> favoritePlaceList = [];
  var removeIndex;
  var removePindex;
  var distanceToPlace;

  List distanceList = [];

  List<String> planList = [];
  bool plan = false;

  bool pressed = false;

  final f = new DateFormat('dd.MM.yyyy');
  final i = new DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    _loadFavPlaces();
    _loadPlan();
    super.initState();
    _loadTime();
    _getPlacesList();
  }

  _PlacesPage() {
    _searchView.addListener(() {
      if (_searchView.text.isEmpty) {
        setState(() {
          _firstSearch = true;
          _query = '';
        });
      } else {
        setState(() {
          _firstSearch = false;
          _query = _searchView.text;
        });
      }
    });
  }

  Future<void> _loadPlan() async {
    print("Loading plan..");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getStringList('planList');
    if (result != null) {
      planList = result;
      print("Plan:: $planList");
    }
  }

  Future<void> _saveToPlan(String id) async {
    await _loadPlan();
    setState(() {
      planList.add(id);
    });
    var filtered = planList.toSet().toList();
    print("saving plan : $filtered");
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList('planList', filtered);
  }

  Future<void> _removeFromPlan(int ind) async {
    setState(() {
      planList.removeAt(ind);
    });
    var filtered = planList.toSet().toList();
    print("saving plan : $filtered");
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList('planList', filtered);
  }

  Future<void> _loadFavPlaces() async {
    print("Loading favorites..");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getStringList('favoriteList');
    if (result != null) {
      favoritePlaceList = result;
      print("Favorites:: $favoritePlaceList");
    }
  }

  Future<void> _saveFavorites(String favoriteID) async {
    setState(() {
      favoritePlaceList.add(favoriteID);
    });
    var filtered = favoritePlaceList.toSet().toList();
    print("saving favorites : $filtered");
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList("favoriteList", filtered);
  }

  Future<void> _removeFavorite(int ind) async {
    setState(() {
      favoritePlaceList.removeAt(ind);
    });
    var filtered = favoritePlaceList.toSet().toList();
    print("saving favorites : $filtered");
    var prefs = await SharedPreferences.getInstance();
    List<String> strList = filtered.map((i) => i.toString()).toList();
    prefs.setStringList("favoriteList", strList);
  }

  Future<List> _loadTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var range = prefs.getStringList('rangevalues');
    return range;
  }

//Get places from Helsinki API
  void _getPlacesList() async {
    EasyLoading.show(status: 'easyloading_loading'.tr());

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final Distance distance = new Distance();

    List list = await MyHelsinkiPlaces().getPlaces();
    itemlist = [];
    distanceList = [];
    var timeRange = await _loadTime();
    double minTime;
    double maxTime;

    if (timeRange != null) {
      minTime = double.parse(timeRange[0]) * 60; //users min time in seconds
      maxTime = double.parse(timeRange[1]) *
          60; //users max time in seconds/ extra 0 for spoof / but why? extra spoof removed for now
    } else {
      minTime = 1.0 * 60;
      maxTime = 100.0 * 600;
    }

    if (list != null && this.mounted) {
      setState(() {
        list.forEach((place) {
          double distanceMeters = distance(
              new LatLng(position.latitude, position.longitude),
              new LatLng(place['location']['lat'], place['location']['lon']));

          double travelTime = distanceMeters /
              1.4; //traveltime placeholder = distance / walkingspeed
          final timeRequired =
              travelTime + 900; //timereq placeholder = traveltime + 15min

          DateTime now = DateTime.now();
          final DateFormat formatter = DateFormat('yyyy-MM-dd');
          final String formatted = formatter.format(now);
          int weekDay = now.weekday - 1;
          var placeOpenCheck = false;

          // print(place['opening_hours']);
          // print(place['opening_hours']['hours']);
          if (place['opening_hours']['hours'] != null) {
            if (place['opening_hours']['hours'][weekDay]['open24h']) {
              //check if its open 24h
              placeOpenCheck = true;
            }
            if (place['opening_hours']['hours'][weekDay]['opens'] != null &&
                place['opening_hours']['hours'][weekDay]['closes'] != null) {
              //check if its open right now
              DateTime opensTime = DateTime.parse(
                  '$formatted ${place['opening_hours']['hours'][weekDay]['opens']}');
              DateTime closesTime = DateTime.parse(
                  '$formatted ${place['opening_hours']['hours'][weekDay]['closes']}');

              if (opensTime.isBefore(now) && closesTime.isAfter(now)) {
                placeOpenCheck = true;
              }
            }
          }
          if (timeRequired > minTime &&
              timeRequired < maxTime &&
              placeOpenCheck) {
            itemlist.add(MyHelsinkiPlacesItem(
              place['name']['fi'],
              place['location']['lat'],
              place['location']['lon'],
              place['description']['body'],
              place['description']['images'],
              place['info_url'],
              place['location']['address'],
              place['tags'],
              place['opening_hours']['hours'],
              travelTime.round(),
              place['id'],
            ));

            if (distanceMeters >= 1000) {
              distanceMeters = distanceMeters / 1000;
              distanceList.add('${distanceMeters.toStringAsFixed(3)} km');
            } else {
              distanceList.add('${distanceMeters.toStringAsFixed(0)}' +
                  'details_meters'.tr());
            }
          }
        });
      });
    }
    EasyLoading.dismiss();
  }

//Set-up the list images
  Image getPlacesImage(index) {
    if (_firstSearch == false) {
      if (filteredList[index].imageUrlList.length != 0) {
        return Image.network(filteredList[index].imageUrlList[0]['url']);
      } else {
        return null;
      }
    } else {
      if (itemlist[index].imageUrlList.length != 0) {
        return Image.network(itemlist[index].imageUrlList[0]['url']);
      } else {
        return null;
      }
    }
  }

  List getTagsList(index) {
    List tagsList = [];
    if (_firstSearch == false) {
      if (filteredList[index].tags.length > 0) {
        tagsList.add(filteredList[index].tags[0]['name']);
      }
      if (filteredList[index].tags.length > 1) {
        tagsList.add(filteredList[index].tags[1]['name']);
      }
      if (filteredList[index].tags.length > 2) {
        tagsList.add(filteredList[index].tags[2]['name']);
      }
      return tagsList;
    } else {
      if (itemlist[index].tags.length > 0) {
        tagsList.add(itemlist[index].tags[0]['name']);
      }
      if (itemlist[index].tags.length > 1) {
        tagsList.add(itemlist[index].tags[1]['name']);
      }
      if (itemlist[index].tags.length > 2) {
        tagsList.add(itemlist[index].tags[2]['name']);
      }
      return tagsList;
    }
  }

  List getOpeningHours(index) {
    List openingHours = [];
    if (itemlist[index].openingHours != null) {
      itemlist[index].openingHours.forEach((day) {
        openingHours.add(day);
      });
    }
    return openingHours;
  }

  String getDesc(index) {
    String descString = '';

    if (_firstSearch == false) {
      if (filteredList[index].desc.length >= 150) {
        descString = filteredList[index].desc.replaceRange(150, null, '...');
      } else {
        descString = filteredList[index].desc;
      }
      return descString;
    } else {
      if (itemlist[index].desc.length >= 150) {
        descString = itemlist[index].desc.replaceRange(150, null, '...');
      } else {
        descString = itemlist[index].desc;
      }
      return descString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: plan
          ? Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          setState(() {
                            plan = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                PlanPage(),
              ],
            )
          : Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width / 1.2,
                      padding: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0, bottom: 5.0),
                      child: Semantics(
                        textField: true,
                        label: "semantics_textfield".tr(),
                        hint: "semantics_search".tr(),
                        child: TextField(
                          maxLines: 1,
                          controller: _searchView,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 15.0),
                            hintText: 'places_search'.tr(),
                            border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                    const Radius.circular(20.0))),
                            suffixIcon: Semantics(
                                label: "semantics_searchicon".tr(),
                                hint: "semantics_search".tr(),
                                child: Icon(Icons.search)),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10.0),
                      child: IconButton(
                          icon: Semantics(
                              label: "semantics_setimage".tr(),
                              hint: "semantics_set".tr(),
                              child: Icon(Icons.settings, color: Colors.grey)),
                          iconSize: 32,
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return DialogInterestPage();
                                }).then((_) => setState(() {
                                  _getPlacesList();
                                }));
                          }),
                    ),
                  ],
                ),
                itemlist.length > 0
                    ? Expanded(
                        child:
                            _firstSearch ? _createListView() : _performSearch(),
                      )
                    : Container(
                        padding: EdgeInsets.only(top: 100),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            TextSpan(
                                text: 'places_select'.tr(),
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.grey,
                                    fontFamily: 'JosefinSans')),
                            WidgetSpan(
                              child: Icon(Icons.settings,
                                  size: 32, color: Colors.grey.shade700),
                            ),
                            TextSpan(
                                text: 'places_select2'.tr(),
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.grey,
                                    fontFamily: 'JosefinSans')),
                          ]),
                        ),
                      ),
              ],
            ),
    );
  }

  Widget _createListView() {
    return new ListView.builder(
      itemCount: itemlist.length,
      padding: EdgeInsets.only(left: 5.0, right: 5.0),
      itemBuilder: (context, index) {
        var tags = getTagsList(index);
        return Card(
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          child: ListTile(
            contentPadding: EdgeInsets.all(10.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailsPage(itemlist[index])),
              );
            },
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    constraints: BoxConstraints(maxWidth: 260),
                    padding:
                        EdgeInsets.only(top: 10, bottom: 5, left: 5, right: 5),
                    child: Text('${itemlist[index].name}',
                        style: TextStyle(fontSize: 20.0))),
                Wrap(spacing: -10.0, children: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, minimumSize: Size(10, 10)),
                    onPressed: () {
                      if (planList.contains(itemlist[index].itemID)) {
                        // remove form planlist
                        planList.forEach((element) {
                          if (element == itemlist[index].itemID) {
                            removePindex = planList.indexOf(element);
                            print(removePindex);
                          }
                        });
                        _removeFromPlan(removePindex);
                        FlashHelper.actionBar(context,
                            message: 'planList_delete'.tr(),
                            primaryAction: (context, controller, setState) {});
                      } else {
                        _saveToPlan(itemlist[index].itemID);
                        FlashHelper.actionBar(context,
                            message: 'planList_add'.tr(),
                            primaryAction: (context, controller, setState) {});
                      }
                    },
                    child: Semantics(
                      button: true,
                      label: "semantics_plusicon".tr(),
                      hint: "semantics_plus".tr(),
                      child: Icon(
                        planList.contains(itemlist[index].itemID)
                            ? Icons.check_circle_rounded
                            : Icons.add_circle_outline_rounded,
                        color: planList.contains(itemlist[index].itemID)
                            ? Colors.green
                            : Colors.blue,
                      ),
                    ),
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, minimumSize: Size(10, 10)),
                      onPressed: () => {
                            if (favoritePlaceList
                                .contains(itemlist[index].itemID))
                              {
                                // Remove item from favorite list
                                favoritePlaceList.forEach((element) {
                                  if (element == itemlist[index].itemID) {
                                    removeIndex =
                                        favoritePlaceList.indexOf(element);
                                    print(removeIndex);
                                  }
                                }),
                                _removeFavorite(removeIndex),
                                FlashHelper.actionBar(context,
                                    message: 'favorites_deleted'.tr(),
                                    primaryAction:
                                        (context, controller, setState) {}),
                              }
                            else
                              {
                                // Add item to favorite list
                                _saveFavorites(itemlist[index].itemID),
                                FlashHelper.actionBar(context,
                                    message: 'favorites_added'.tr(),
                                    primaryAction:
                                        (context, controller, setState) {}),
                              }
                          },
                      child: Semantics(
                        button: true,
                        label: "semantics_hearticon".tr(),
                        hint: "semantics_heart".tr(),
                        child: Icon(
                          favoritePlaceList.contains(itemlist[index].itemID)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                      )),
                ])
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
                    child: Semantics(
                        label: "semantics_activityimage".tr(),
                        child: getPlacesImage(index)),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(5),
                    child: Semantics(
                      label: "semantics_description".tr(),
                      child: Text('${getDesc(index)}',
                          style: GoogleFonts.lato(
                              textStyle: TextStyle(fontSize: 13.0))),
                    )),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                            'details_distance'.tr() + distanceList[index],
                            style: GoogleFonts.lato(
                                textStyle: TextStyle(fontSize: 13.0))),
                      ),
                    ),
                    Column(
                      children: [],
                    )
                  ],
                ),
                const Divider(
                  height: 20,
                  thickness: 1,
                  color: Colors.black26,
                  endIndent: 5,
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: GridView.builder(
                    itemCount: tags.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return OutlinedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                          ),
                          child: Semantics(
                            label: "semantics_tag".tr(),
                            child: Text(
                              tags[index].toString().toLowerCase(),
                              style: TextStyle(fontSize: 11.0),
                            ),
                          ));
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 3,
                      childAspectRatio: 4,
                    ),
                  ),

                  //child: Text('${getTags(index)}',style: TextStyle(fontSize: 13.0)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _performSearch() {
    filteredList = new List();
    for (int i = 0; i < itemlist.length; i++) {
      var item = itemlist[i];
      if (item.name.toString().toLowerCase().contains(_query.toLowerCase())) {
        filteredList.add(item);
      }
    }
    return _createFilteredListView();
  }

  Widget _createFilteredListView() {
    return new ListView.builder(
      itemCount: filteredList.length,
      padding: EdgeInsets.only(left: 5.0, right: 5.0),
      itemBuilder: (context, index) {
        var tags = getTagsList(index);
        return Card(
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          child: ListTile(
            contentPadding: EdgeInsets.all(10.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailsPage(filteredList[index])),
              );
            },
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    constraints: BoxConstraints(maxWidth: 260),
                    padding:
                        EdgeInsets.only(top: 10, bottom: 5, left: 5, right: 5),
                    child: Text('${filteredList[index].name}',
                        style: TextStyle(fontSize: 20.0))),
                Wrap(spacing: -10.0, children: <Widget>[
                  TextButton(
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, minimumSize: Size(10, 10)),
                      onPressed: () {
                        if (planList.contains(itemlist[index].itemID)) {
                          // remove form planlist
                          planList.forEach((element) {
                            if (element == itemlist[index].itemID) {
                              removePindex = planList.indexOf(element);
                              print(removePindex);
                            }
                          });
                          _removeFromPlan(removePindex);
                          FlashHelper.actionBar(context,
                              message: 'planList_delete'.tr(),
                              primaryAction:
                                  (context, controller, setState) {});
                        } else {
                          _saveToPlan(itemlist[index].itemID);
                          FlashHelper.actionBar(context,
                              message: 'planList_add'.tr(),
                              primaryAction:
                                  (context, controller, setState) {});
                        }
                      },
                      child: Semantics(
                        button: true,
                        label: "semantics_hearticon".tr(),
                        hint: "semantics_heart".tr(),
                        child: Icon(
                          planList.contains(itemlist[index].itemID)
                              ? Icons.check_circle_rounded
                              : Icons.add_circle_outline_rounded,
                          color: planList.contains(itemlist[index].itemID)
                              ? Colors.green
                              : Colors.blue,
                        ),
                      )),
                  TextButton(
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, minimumSize: Size(10, 10)),
                      onPressed: () => {
                            if (favoritePlaceList
                                .contains(filteredList[index].itemID))
                              {
                                // Remove item from favorite list
                                favoritePlaceList.forEach((element) {
                                  if (element == filteredList[index].itemID) {
                                    removeIndex =
                                        favoritePlaceList.indexOf(element);
                                    print(removeIndex);
                                  }
                                }),
                                _removeFavorite(removeIndex),
                                FlashHelper.actionBar(context,
                                    message: 'favorites_deleted'.tr(),
                                    primaryAction:
                                        (context, controller, setState) {}),
                              }
                            else
                              {
                                // Add item to favorite list
                                _saveFavorites(filteredList[index].itemID),
                                FlashHelper.actionBar(context,
                                    message: 'favorites_added'.tr(),
                                    primaryAction:
                                        (context, controller, setState) {}),
                              }
                          },
                      child: Icon(
                        favoritePlaceList.contains(filteredList[index].itemID)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      )),
                ]),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(),
                  child: getPlacesImage(index),
                ),
                Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('${getDesc(index)}',
                        style: GoogleFonts.lato(
                            textStyle: TextStyle(fontSize: 13.0)))),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Text('details_distance'.tr() + distanceList[index],
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(fontSize: 13.0))),
                ),
                const Divider(
                  height: 20,
                  thickness: 1,
                  color: Colors.black26,
                  endIndent: 5,
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: GridView.builder(
                    itemCount: tags.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return OutlinedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                          ),
                          child: Text(
                            tags[index].toString().toLowerCase(),
                            style: TextStyle(fontSize: 11.0),
                          ));
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 3,
                      childAspectRatio: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
