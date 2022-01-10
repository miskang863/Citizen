import 'dart:ffi';
import 'dart:io';

import 'package:citizen/Keys/Keys.dart';
import 'package:citizen/Models/InfoWindowModel.dart';
import 'package:citizen/Models/MyHelsinkiPlacesItem.dart';
import 'package:citizen/Services/DirectionsAPI.dart';
import 'package:citizen/Services/DistanceAPI.dart';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../Services/ThemeManager.dart';
import '../map_styles/map_styles.dart';
import 'package:citizen/Services/ThemeManager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';

Keys keys = Keys();

class RoutePagePlan extends StatefulWidget {
  final objectList;
  RoutePagePlan({Key key, @required this.objectList}) : super(key: key);

  @override
  _RoutePagePlanState createState() => _RoutePagePlanState(objectList);
}

class _RoutePagePlanState extends State<RoutePagePlan> {
  List<MyHelsinkiPlacesItem> objectList;
  _RoutePagePlanState(this.objectList);

  bool _isExpanded = false;
  bool isDarkModeEnabled;

  GoogleMapController mapController;
  Set<Marker> _markers = {};

  final startAddressController = TextEditingController();

  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();

  bool walk = true;
  bool bicycle = false;
  bool transit = false;

  String walkTime = '';
  String bikeTime = '';
  String transitTime = '';
  String timeAfterRoute;

  var hoursToAdd;
  var minutesToAdd;

  var polys = [];
  var polysForBike = [];
  var polysForTransit = [];

  var wTime;
  var bTime;
  var durations;
  var durationBike;

  String distance = '';
  String startLocation = 'route_loading'.tr();

  String routeDistance;
  Set<Polyline> line = {};

  var providerObject;

  @override
  void initState() {
    super.initState();
    this.getStartLocationAddress();
    var provider = Provider.of<InfoWindowModel>(context, listen: false);
    providerObject = provider;
    providerObject.updateVisibility(false);
    setCustomMarker();
  }

  BitmapDescriptor mapMarker;

  void setCustomMarker() async {
    if (Platform.isIOS) {
      mapMarker = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5),
          'Assets/Icons/location.png');
    } else if (Platform.isAndroid) {
      mapMarker = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5),
          'Assets/Icons/locationA.png');
    }
  }

  void _getPolyline(List destinations) async {
    List<LatLng> polylineCoordinates = [];
    List finalPointsList = [];

    List<PointLatLng> pointsList;
    destinations.forEach((poly) {
      pointsList = polylinePoints.decodePolyline(poly);
      pointsList.forEach((poly) {
        finalPointsList.add(poly);
      });
    });
    finalPointsList.forEach((element) {
      polylineCoordinates.add(LatLng(element.latitude, element.longitude));
    });

    _addPolyLine(polylineCoordinates);
  }

  _addPolyLine(List<LatLng> polylineCoordinates) {
    // print(polylineCoordinates);
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  void _createActivityRoute(objects) async {
    List nakki = await DirectionsAPI().getPlanRoute(objects, 'walking');
    List bicyclingInfo =
    await DirectionsAPI().getPlanRoute(objects, 'bicycling');
    // List transitInfo = await DirectionsAPI().getPlanRoute(objects, 'transit');
    var destinations = [];

    //Walking
    var distances = [];
    durations = [];

    //Bicycling
    durationBike = [];
    var distanceBike = [];

    //Transit
    var durationTransit = [];
    var distanceTransit = [];

    nakki.forEach((leg) {
      distances.add(leg['distance']['text']);
      durations.add(leg['duration']['text']);
      leg['steps'].forEach((step) {
        polys.add(step['polyline']['points']);
      });
    });

    bicyclingInfo.forEach((leg) {
      durationBike.add(leg['duration']['text']);
      distanceBike.add(leg['distance']['text']);
      leg['steps'].forEach((step) {
        polysForBike.add(step['polyline']['points']);
      });
    });

    /*transitInfo.forEach((leg) {
      durationTransit.add(leg['duration']['text']);
      distanceTransit.add(leg['distance']['text']);
      leg['steps'].forEach((step) {
        polysForTransit.add(step['polyline']['points']);
      });
    });*/

    wTime = fullRouteTime(durations);
    bTime = fullRouteTime(durationBike);

    objectList.forEach((element) {
      wTime = wTime.add(Duration(minutes: 15));
      bTime = bTime.add(Duration(minutes: 15));
    });

    setState(() {
      walkTime = '${wTime.hour} hours ${wTime.minute} mins';
      bikeTime = '${bTime.hour} hours ${bTime.minute} mins';
      transitTime = '${bTime.hour} hours ${bTime.minute} mins';
      routeDistance = fullRouteDistance(distances);
    });

    if (objects != null) {
      objects.forEach((object) {
        var c = LatLng(object.lat, object.lon);
        destinations.add(c);
      });

// Destination Location Markers

      destinations.forEach((element) {
        LatLng destinationCoordinates =
        LatLng(element.latitude, element.longitude);

        var index = destinations.indexOf(element);

        var marker = Marker(
          markerId: MarkerId('$destinationCoordinates'),
          position: destinationCoordinates,
          icon: mapMarker,
          onTap: () {
            providerObject.updateInfoWindow(
                context, mapController, destinationCoordinates, 250.0, 170.0);
            providerObject.updateActivityObject(objectList[index]);
            providerObject.updateVisibility(true);
            providerObject.rebuildInfoWindow();
          },
        );

        setState(() {
          _markers.add(marker);
        });
      });

      DateTime now = DateTime.now();

      setState(() {
        if (walk) {
          _getPolyline(polys);
          minutesToAdd = wTime.minute;
          hoursToAdd = wTime.hour;
          now = now.add(Duration(hours: hoursToAdd, minutes: minutesToAdd));
          objectList.forEach((element) {
            now = now.add(Duration(minutes: 15));
          });
          timeAfterRoute = DateFormat('kk:mm').format(now);
          fullRouteTime(durations);
        } else if (bicycle) {
          _getPolyline(polysForBike);
          minutesToAdd = bTime.minute;
          hoursToAdd = bTime.hour;
          now = now.add(Duration(hours: hoursToAdd, minutes: minutesToAdd));
          objectList.forEach((element) {
            now = now.add(Duration(minutes: 15));
          });
          timeAfterRoute = DateFormat('kk:mm').format(now);
        } else if (transit) {
          _getPolyline(polysForTransit);
        }
      });
    } else {
      print("createActivityRoute error");
    }
  }

  changeTravelMode() {
    DateTime now = DateTime.now();

    setState(() {
      if (walk) {
        _getPolyline(polys);
        minutesToAdd = wTime.minute;
        hoursToAdd = wTime.hour;
        now = now.add(Duration(hours: hoursToAdd, minutes: minutesToAdd));
        timeAfterRoute = DateFormat('kk:mm').format(now);
        fullRouteTime(durations);
      } else if (bicycle) {
        _getPolyline(polysForBike);
        minutesToAdd = bTime.minute;
        hoursToAdd = bTime.hour;
        now = now.add(Duration(hours: hoursToAdd, minutes: minutesToAdd));
        timeAfterRoute = DateFormat('kk:mm').format(now);
        fullRouteTime(durationBike);
      } else if (transit) {
        // API result empty when using travel mode: transit
        // _getPolyline(polysForTransit);
      }
    });
  }

  locatePosition() async {
    LatLng latLngPosition;
    var location;

    if (Platform.isAndroid) {
      location = await _locationTracker.getLocation();
    } else if (Platform.isIOS) {
      location = await Geolocator.getCurrentPosition();
    }

    latLngPosition = LatLng(location.latitude, location.longitude);

    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }

    _locationSubscription =
        _locationTracker.onLocationChanged.listen((newLocalData) {});

    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(location.latitude, location.longitude),
              tilt: 0,
              zoom: 15.00)));
    }
    return latLngPosition;
  }

  fullRouteDistance(distances) {
    var routeD = 0.0;
    distances.forEach((d) {
      if (d.toString().contains('km')) {
        var r = d.toString().replaceAll('km', '|');
        var splittedValue = r.split('|').toList();
        print(splittedValue[0]);
        routeD += double.parse(splittedValue[0]);
      } else {
        var r = d.toString().replaceAll('m', '|');
        var splittedValue = r.split('|').toList();
        var numb = double.parse(splittedValue[0]) / 1000;
        print(numb);
        routeD += numb;
      }
    });
    print('route distance: $routeD');
    return '${routeD.toStringAsFixed(2).toString()} km';
  }

  var pd1;
  // Calculates times;
  // How long does it takes to go through the whole route and
  // at what time does the user arrive to each destination.
  fullRouteTime(routeInfo) {
    DateTime time = new DateTime(2000);
    DateTime now = DateTime.now();
    var pd = [];

    routeInfo.forEach((info) {
      if (info.toString().length > 8) {
        var d;
        if (info.contains('hours') && info.contains('mins')) {
          d = info.toString().replaceAll('hours', '|').replaceAll('mins', '|');
        } else if (info.contains('hour') && info.contains('min')) {
          d = info.toString().replaceAll('hour', '|').replaceAll('min', '|');
        } else if (info.contains('hour') && info.contains('mins')) {
          d = info.toString().replaceAll('hour', '|').replaceAll('mins', '|');
        } else if (info.contains('hours') && info.contains('min')) {
          d = info.toString().replaceAll('hour', '|').replaceAll('min', '|');
        }
        var list = d.split('|').toList();
        print(list);
        var minutes = int.parse(list[1]);
        var hours = int.parse(list[0]);

        time = time.add(Duration(hours: hours, minutes: minutes));

        // Time: how long does it take to travel to next destination
        now = now.add(Duration(hours: hours, minutes: minutes));
        if (routeInfo.indexOf(info) != 0) {
          // Add time spent in activity...
          now = now.add(Duration(minutes: 15));
        }
        pd.add(DateFormat('kk:mm').format(now));
      } else {
        var travel = new DateFormat("mm").parse(info);
        time = time.add(Duration(minutes: travel.minute));

        // Time: how long does it take to travel to next destination
        now = now.add(Duration(minutes: travel.minute));
        if (routeInfo.indexOf(info) != 0) {
          // Add time spent in activity...
          now = now.add(Duration(minutes: 15));
        }
        pd.add(DateFormat('kk:mm').format(now));
      }
    });
    setState(() {
      pd1 = pd;
    });
    return time;
  }

  getStartLocationAddress() async {
    var list = new List();
    objectList.forEach((element) {
      list.add(element);
    });

    String address = await DistanceAPIForAddress().getTravelTime(list);
    setState(() {
      startLocation = address;
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    if (isDarkModeEnabled) {
      mapController.setMapStyle(MapStyles.mapDarkStyle);
    } else {
      mapController.setMapStyle(MapStyles.mapStyle);
    }

    locatePosition();
    _createActivityRoute(objectList);
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
        topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0));
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    isDarkModeEnabled = (themeNotifier.getTheme() == darkTheme);

    Widget getInfoWindowImage(List imageList) {
      if (imageList.isNotEmpty) {
        return Image.network(imageList[0]['url']);
      } else {
        return Image.network(
            'https://images.pexels.com/photos/2292953/pexels-photo-2292953.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=750&w=1260');
      }
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Consumer<InfoWindowModel>(
            builder: (context, model, child) {
              return Stack(
                children: [
                  child,
                  Positioned(
                    left: 15,
                    top: -70,
                    child: providerObject != null
                        ? Visibility(
                      visible: providerObject.showInfoWindow,
                      child: (providerObject.activityObject == null ||
                          !providerObject.showInfoWindow)
                          ? Container()
                          : Container(
                        margin: EdgeInsets.only(
                          left: providerObject.leftMargin,
                          top: providerObject.topMargin,
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(20),
                                color: isDarkModeEnabled
                                    ? Color(0xFF2B3A58)
                                    : Colors.blue,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.25),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0,
                                        3), // changes position of shadow
                                  ),
                                ],
                              ),
                              height: 180,
                              width: 220,
                              padding: EdgeInsets.all(15),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: getInfoWindowImage(
                                        providerObject
                                            .activityObject
                                            .imageUrlList),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          providerObject
                                              .activityObject.name,
                                          textAlign:
                                          TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight:
                                              FontWeight.w600),
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(
                                              top: 3.0),
                                          child: Text(
                                            providerObject
                                                .activityObject
                                                .address[
                                            'street_address'],
                                            textAlign:
                                            TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight:
                                                FontWeight
                                                    .w300),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Triangle.isosceles(
                                edge: Edge.BOTTOM,
                                child: Container(
                                  color: isDarkModeEnabled
                                      ? Color(0xFF2B3A58)
                                      : Colors.blue,
                                  width: 15.0,
                                  height: 10.0,
                                ))
                          ],
                        ),
                      ),
                    )
                        : Container(),
                  )
                ],
              );
            },
            child: Positioned(
              child: GoogleMap(
                onTap: (position) {
                  if (providerObject.showInfoWindow) {
                    providerObject.updateVisibility(false);
                    providerObject.rebuildInfoWindow();
                  }
                },
                onCameraMove: (position) {
                  if (providerObject.activityObject != null) {
                    providerObject.updateInfoWindow(
                        context,
                        mapController,
                        LatLng(providerObject.activityObject.lat,
                            providerObject.activityObject.lon),
                        250.0,
                        170.0);
                    providerObject.rebuildInfoWindow();
                  }
                },
                padding: EdgeInsets.only(top: 200.0),
                polylines: Set<Polyline>.of(polylines.values),
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                onMapCreated: _onMapCreated,
                markers: _markers,
                initialCameraPosition: CameraPosition(
                    target: LatLng(60.22465437727238, 24.951920578976313),
                    zoom: 15),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 30, left: 5, right: 5),
              child: Card(
                color: isDarkModeEnabled
                    ? Colors.blueGrey.withOpacity(0.8)
                    : Colors.white.withOpacity(0.8),
                child: ExpansionTile(
                  onExpansionChanged: (expanded) {
                    if (expanded) {
                      setState(() {
                        _isExpanded = true;
                      });
                    } else {
                      setState(() {
                        _isExpanded = false;
                      });
                    }
                  },
                  title: _isExpanded ? titleOpen() : titleClosed(),
                  children: <Widget>[
                    dots(),
                    ListView.builder(
                        padding: EdgeInsets.only(top: 2),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: objectList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 17, top: 2, bottom: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          height: 15,
                                          width: 49,
                                          padding: EdgeInsets.only(right: 14),
                                          // Arrival time to place...
                                          child: Text(
                                              pd1 != null
                                                  ? pd1[index].toString()
                                                  : '',
                                              style: TextStyle(fontSize: 12.5)),
                                        ),
                                        Icon(Icons.adjust_outlined),
                                        Padding(
                                          padding: EdgeInsets.only(left: 30),
                                          child: Text(objectList[index].name),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            dots(),
                          ]);
                        }),
                    Padding(
                        padding: EdgeInsets.only(left: 17,top:2, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Container(
                                  height: 15,
                                  width: 50,
                                  padding: EdgeInsets.only(right: 14),
                                  child: Text(
                                    timeAfterRoute != null ? timeAfterRoute : '',
                                    style: TextStyle(fontSize: 12.5),
                                  ),
                                )),
                            Icon(Icons.pin_drop_rounded),
                            Expanded(
                              child:  Padding(
                                padding: EdgeInsets.only(left: 30,),
                                child: Text("Back in " + startLocation),
                              ),
                            )
                          ],
                        )),
                  ],
                ),
              )),
          Positioned(
            top: MediaQuery.of(context).size.height / 2,
            left: 25,
            height: MediaQuery.of(context).size.height / 2.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDarkModeEnabled
                        ? Colors.blueGrey.withOpacity(0.8)
                        : Colors.white.withOpacity(0.9),
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        walk = true;
                        transit = false;
                        bicycle = false;
                        changeTravelMode();
                      });
                    },
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Semantics(
                            image: true,
                            label: "semantics_walk".tr(),
                            hint: "semantics_walkhint".tr(),
                            child: Icon(
                              Icons.directions_walk_rounded,
                              color:
                              isDarkModeEnabled ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                        Container(
                            constraints: BoxConstraints(maxWidth: 60),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Semantics(
                                hint: "semantics_walkpress".tr(),
                                child: Text(
                                  walkTime != ''
                                      ? walkTime
                                      : 'route_loading'.tr(),
                                  style: TextStyle(
                                      color: isDarkModeEnabled
                                          ? Colors.white
                                          : Colors.grey),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDarkModeEnabled
                        ? Colors.blueGrey.withOpacity(0.8)
                        : Colors.white.withOpacity(0.9),
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        walk = false;
                        transit = false;
                        bicycle = true;

                        changeTravelMode();
                      });
                    },
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Semantics(
                            image: true,
                            label: "semantics_bike".tr(),
                            hint: "semantics_bikehint".tr(),
                            child: Icon(Icons.pedal_bike_outlined,
                                color: isDarkModeEnabled
                                    ? Colors.white
                                    : Colors.grey),
                          ),
                        ),
                        Container(
                            constraints: BoxConstraints(maxWidth: 60),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Semantics(
                                hint: "semantics_bikepress".tr(),
                                child: Text(
                                    bikeTime != ''
                                        ? bikeTime
                                        : 'route_loading'.tr(),
                                    style: TextStyle(
                                        color: isDarkModeEnabled
                                            ? Colors.white
                                            : Colors.grey)),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDarkModeEnabled
                        ? Colors.blueGrey.withOpacity(0.8)
                        : Colors.white.withOpacity(0.9),
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        walk = false;
                        transit = true;
                        bicycle = false;

                        changeTravelMode();
                      });
                    },
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Semantics(
                            image: true,
                            label: "semantics_bike".tr(),
                            hint: "semantics_bikehint".tr(),
                            child: Icon(Icons.train_rounded,
                                color: isDarkModeEnabled
                                    ? Colors.white
                                    : Colors.grey),
                          ),
                        ),
                        Container(
                            constraints: BoxConstraints(maxWidth: 60),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Semantics(
                                hint: "semantics_buspress".tr(),
                                child: Text(
                                    transitTime != ''
                                        ? transitTime
                                        : 'route_loading'.tr(),
                                    style: TextStyle(
                                        color: isDarkModeEnabled
                                            ? Colors.white
                                            : Colors.grey)),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                Container(
                    width: 70,
                    height: 70,
                    child: CircleAvatar(
                        backgroundColor: isDarkModeEnabled
                            ? Colors.deepOrange[900].withOpacity(0.9)
                            : Colors.orangeAccent,
                        radius: 20,
                        child: IconButton(
                            icon: Semantics(
                              label: "semantics_button".tr(),
                              hint: "semantics_back".tr(),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }))),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 1.25,
            right: 10,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDarkModeEnabled
                    ? Colors.blueGrey.withOpacity(0.8)
                    : Colors.white.withOpacity(0.9),
              ),
              child: Semantics(
                label: "semantics_distance".tr(),
                child: Text(
                    routeDistance != null ? routeDistance : 'route_loading'.tr()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget titleOpen() {
    DateTime now = DateTime.now();
    String timeNow = DateFormat('kk:mm').format(now);

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Container(
                    height: 15,
                    width: 46,
                    padding: EdgeInsets.only(right: 14),
                    child: Text(timeNow, style: TextStyle(fontSize: 12.5)),
                  )),
              Padding(
                padding: EdgeInsets.only(top: 35, left: 5, bottom: 0),
                child: Icon(Icons.my_location_rounded),
              ),
              Expanded(
                  child:  Padding(
                      padding: EdgeInsets.only(top: 40, left: 30,),
                      child: Text(startLocation),
                    ),
                  )
            ],
          ),
        ],
      ),
    );
  }

  Widget titleClosed() {
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 35, left: 50, bottom: 5),
                child: Icon(Icons.my_location_rounded),
              ),
              Expanded(
                child:  Padding(
                  padding: EdgeInsets.only(top: 40, left: 30,),
                  child: Text(startLocation),
                ),
              )
            ],
          ),
          Column(
            children: <Widget>[
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 54, top: 5),
                  height: 8,
                  child: VerticalDivider(
                    thickness: 2,
                    color: isDarkModeEnabled ? Colors.white : Colors.black,
                  )),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 54, top: 5),
                  height: 8,
                  child: VerticalDivider(
                    thickness: 2,
                    color: isDarkModeEnabled ? Colors.white : Colors.black,
                  )),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 54, top: 5),
                  height: 8,
                  child: VerticalDivider(
                    thickness: 2,
                    color: isDarkModeEnabled ? Colors.white : Colors.black,
                  )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: 10, left: 50),
                  child: Icon(Icons.pin_drop_rounded)),
              Container(
                  constraints: BoxConstraints(maxWidth: 225),
                  child: Padding(
                      padding: EdgeInsets.only(top: 10, left: 30),
                      child: Text('Places to visit: ${objectList.length}'))),
            ],
          )
        ],
      ),
    );
  }

  Widget dots() {
    return Column(
      children: <Widget>[
        Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 70, top: 2, bottom: 2),
            height: 8,
            child: VerticalDivider(
              thickness: 2,
              color: isDarkModeEnabled ? Colors.white : Colors.black,
            )),
        Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 70, top: 5),
            height: 8,
            child: VerticalDivider(
              thickness: 2,
              color: isDarkModeEnabled ? Colors.white : Colors.black,
            )),
      ],
    );
  }
}
