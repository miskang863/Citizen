import 'dart:io';

import 'package:citizen/Keys/Keys.dart';
import 'package:citizen/Models/InfoWindowModel.dart';
import 'package:citizen/Services/DistanceAPI.dart';
import 'package:clippy_flutter/triangle.dart';
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

class RoutePage extends StatefulWidget {
  final activityObject;

  RoutePage({Key key, @required this.activityObject}) : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState(activityObject);
}

class _RoutePageState extends State<RoutePage> {
  final activityObject;

  _RoutePageState(this.activityObject);

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

  List travelTimes = List();
  String distance = '';
  String duration = '';
  String timeAfterTravel = '';
  String timeLeave = '';
  String timeArriveBack = '';
  String startLocation = 'route_loading'.tr();

  Location location;
  var providerObject;

  @override
  void initState() {
    super.initState();
    this.getTravelTimes();
    this.getStartLocationAddress();
    var provider = Provider.of<InfoWindowModel>(context, listen: false);
    providerObject = provider;
    providerObject.updateVisibility(false);
    setCustomMarker();
  }

  void _getPolyline(
      LatLng start, LatLng destination, TravelMode travelMode) async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      keys.googleKey,
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: travelMode,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print('ERROR!!!! : ${result.errorMessage}');
    }
    _addPolyLine(polylineCoordinates);
  }

  _addPolyLine(List<LatLng> polylineCoordinates) {
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

  void _createActivityRoute(activity) async {
    if (activity != null) {
      LatLng startCoordinates = await locatePosition();
      LatLng destinationCoordinates = LatLng(activity.lat, activity.lon);

      print('2 $startCoordinates');
      print('3 $destinationCoordinates');

// Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId('$destinationCoordinates'),
        position: destinationCoordinates,
        icon: mapMarker,
        onTap: () {
          providerObject.updateInfoWindow(
              context, mapController, destinationCoordinates, 250.0, 170.0);
          providerObject.updateActivityObject(activity);
          providerObject.updateVisibility(true);
          providerObject.rebuildInfoWindow();
        },
      );

      setState(() {
        _markers.add(destinationMarker);
        if (walk) {
          _getPolyline(
              startCoordinates, destinationCoordinates, TravelMode.walking);
        } else if (bicycle) {
          _getPolyline(
              startCoordinates, destinationCoordinates, TravelMode.bicycling);
        } else if (transit) {
          _getPolyline(
              startCoordinates, destinationCoordinates, TravelMode.transit);
        }
      });
    } else {
      print("createActivityRoute error");
    }
  }

  locatePosition() async {
    LatLng latLngPosition;
    var location;

    if (!Platform.isIOS) {
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

  getTravelTimes() async {
    var list = new List();
    list.add(activityObject);
    List walkTimes = await DistanceAPIForRoute().getTravelTime(list, 'walking');
    List bicyclingTimes =
    await DistanceAPIForRoute().getTravelTime(list, 'bicycling');
    List transitTimes =
    await DistanceAPIForRoute().getTravelTime(list, 'transit');

    setState(() {
      travelTimes.add(walkTimes[0]);
      travelTimes.add(bicyclingTimes[0]);
      travelTimes.add(transitTimes[0]);
    });
  }

  getStartLocationAddress() async {
    var list = new List();
    list.add(activityObject);
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
    _createActivityRoute(activityObject);
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
        topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0));
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    isDarkModeEnabled = (themeNotifier.getTheme() == darkTheme);

    DateTime now = DateTime.now();
    String timeNow = DateFormat('kk:mm').format(now);

    void formatLongTime(int tm) {
      distance = travelTimes[tm]['distance']['text'];
      duration = travelTimes[tm]['duration']['text'];
      var d = travelTimes[tm]['duration']['text']
          .toString()
          .replaceAll('hours', '|')
          .replaceAll('min', '|');
      var list = d.split('|').toList();

      var minutes = int.parse(list[1]);
      var hours = int.parse(list[0]);

      //Time when travelled to destination...
      var time = now.add(Duration(minutes: minutes, hours: hours));
      timeAfterTravel = DateFormat('kk:mm').format(time).toString();

      // Time after spending time in destination
      var time2 = time.add(Duration(minutes: 15));
      timeLeave = DateFormat('kk:mm').format(time2).toString();

      //Time when arrived back to start
      var time3 = time2.add(Duration(minutes: minutes, hours: hours));
      timeArriveBack = DateFormat('kk:mm').format(time3).toString();
    }

    void formatShortTime(int tm) {
      distance = travelTimes[tm]['distance']['text'];
      duration = travelTimes[tm]['duration']['text'];

      DateTime travel = new DateFormat("mm").parse(duration);

      var time = now.add(Duration(minutes: travel.minute));
      timeAfterTravel = DateFormat('kk:mm').format(time).toString();

      // Time after spending time in destination
      var time2 = time.add(Duration(minutes: 15));
      timeLeave = DateFormat('kk:mm').format(time2).toString();

      //Time when arrived back to start
      var time3 = time2.add(Duration(minutes: travel.minute));
      timeArriveBack = DateFormat('kk:mm').format(time3).toString();
    }

    Widget getInfoWindowImage(List imageList) {
      if (imageList.isNotEmpty) {
        return Image.network(imageList[0]['url']);
      } else {
        return Image.network(
            'https://images.pexels.com/photos/2292953/pexels-photo-2292953.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=750&w=1260');
      }
    }

    if (walk && travelTimes.isNotEmpty) {
      if (travelTimes[0]['duration']['text'].toString().length > 8) {
        formatLongTime(0);
      } else {
        formatShortTime(0);
      }
    } else if (bicycle && travelTimes.isNotEmpty) {
      if (travelTimes[1]['duration']['text'].toString().length > 8) {
        formatLongTime(1);
      } else {
        formatShortTime(1);
      }
    } else if (transit && travelTimes.isNotEmpty) {
      if (travelTimes[2]['duration']['text'].toString().length > 8) {
        formatLongTime(2);
      } else {
        formatShortTime(2);
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
                    Column(
                      children: <Widget>[
                        dots(),
                        Padding(
                          padding: EdgeInsets.only(left: 20, top: 2, bottom: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: 15,
                                width: 46,
                                padding: EdgeInsets.only(right: 14),
                                child: Text(timeNow,
                                    style: TextStyle(fontSize: 12.5)),
                              ),
                              Icon(Icons.adjust_outlined),
                              Expanded(child:                               Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text('route_travel'.tr() + '$duration'),
                              ),)
                            ],
                          ),
                        ),
                        dots(),
                        Padding(
                          padding: EdgeInsets.only(left: 20, top: 2, bottom: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: 15,
                                width: 46,
                                padding: EdgeInsets.only(right: 14),
                                child: Text(timeAfterTravel,
                                    style: TextStyle(fontSize: 12.5)),
                              ),
                              Icon(Icons.adjust_outlined),
                              Container(
                                  constraints: BoxConstraints(maxWidth: 270),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: Text('route_arrive'.tr() +
                                        '${activityObject.name}'),
                                  )),
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            dots(),
                            Padding(
                              padding: EdgeInsets.only(left: 35),
                              child: Text("route_spend".tr()),
                            ),
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 5)),
                        dots(),
                        Padding(
                          padding: EdgeInsets.only(left: 20, top: 2, bottom: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: 15,
                                width: 46,
                                padding: EdgeInsets.only(right: 14),
                                child: Text(timeLeave,
                                    style: TextStyle(fontSize: 12.5)),
                              ),
                              Icon(Icons.adjust_outlined),
                              Expanded(child:                               Padding(
                                  padding: EdgeInsets.only(left: 30),
                                  child: Text(
                                      'route_travelb'.tr() + '$startLocation')
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    dots(),
                    Padding(
                        padding: EdgeInsets.only(left: 20, top: 10, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 15,
                              width: 46,
                              padding: EdgeInsets.only(right: 14),
                              child: Text(
                                timeArriveBack,
                                style: TextStyle(fontSize: 12.5),
                              ),
                            ),
                            Icon(Icons.pin_drop_rounded),
                            Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text('route_finished'.tr())),
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

                        _createActivityRoute(activityObject);
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
                                  travelTimes.isNotEmpty
                                      ? travelTimes[0]['duration']['text']
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

                        _createActivityRoute(activityObject);
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
                                    travelTimes.isNotEmpty
                                        ? travelTimes[1]['duration']['text']
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

                        _createActivityRoute(activityObject);
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
                                    travelTimes.isNotEmpty
                                        ? travelTimes[2]['duration']['text']
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
                  child: Text(distance != '' ? distance : 'route_loading'.tr())),
            ),
          ),
        ],
      ),
    );
  }

  Widget titleOpen() {
    return Container(
      height: 70,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: 35, left: 50, bottom: 0),
                  child: Icon(Icons.my_location_rounded)
              ),
              Expanded(child: Padding(
                  padding: EdgeInsets.only(top: 35, left: 30, bottom: 0),
                  child: Text(startLocation)
              )),
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
              Container(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 35, left: 20, bottom: 5),
                          child: Text(startLocation))
                    ],
                  )
              ),
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
                  constraints: BoxConstraints(maxWidth: 200),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 10, left: 20),
                          child: Text(activityObject.address['street_address']))
                    ],
                  )
              ),
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
