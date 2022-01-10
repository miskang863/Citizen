import 'package:citizen/Keys/Keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Services/ThemeManager.dart';
import '../map_styles/map_styles.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'PlacesHolder.dart';
import 'PlacesPage.dart';
import 'package:citizen/Components/BackgroundPainter.dart';
import 'package:citizen/Services/ThemeManager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';

Keys keys = Keys();

class MapPage extends StatefulWidget {
  final activityObject;
  MapPage({Key key, @required this.activityObject}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState(activityObject);
}

class _MapPageState extends State<MapPage> {
  final activityObject;
  _MapPageState(this.activityObject);

  GoogleMapController mapController;
  Set<Marker> _markers = {};

  bool isDarkModeEnabled;

  final startAddressController = TextEditingController();

  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();

  void _getPolyline(LatLng start, LatLng destination) async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      keys.googleKey,
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.walking,
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

  void _createActivityRoute(activity) async {
    if (activity != null) {
      LatLng startCoordinates = await locatePosition();
      LatLng destinationCoordinates = LatLng(activity.lat, activity.lon);

// Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId('$destinationCoordinates'),
        position: destinationCoordinates,
        infoWindow: InfoWindow(
          title: activity.name,
          snippet: activity.address['street_address'],
        ),
        icon: BitmapDescriptor.defaultMarker,
      );



      setState(() {
        _markers.add(destinationMarker);
        _getPolyline(startCoordinates, destinationCoordinates);
      });
    } else {
      print("createActivityRoute error");
    }
  }

  locatePosition() async {
    LatLng latLngPosition;

    var location = await _locationTracker.getLocation();

    latLngPosition = LatLng(location.latitude, location.longitude);

    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }

    _locationSubscription =
        _locationTracker.onLocationChanged.listen((newLocalData) {});

    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          new CameraPosition(
              target: LatLng(location.latitude, location.longitude),
              tilt: 0,
              zoom: 15.00)));
    }
    return latLngPosition;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (isDarkModeEnabled) {
      mapController.setMapStyle(MapStyles.mapDarkStyle);
    } else {
      mapController.setMapStyle(MapStyles.mapStyle);
    }

    locatePosition();
    _createActivityRoute(activityObject);
  }

  PanelController _panelController = new PanelController();

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
        topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0));
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    isDarkModeEnabled = (themeNotifier.getTheme() == darkTheme);

    if (isDarkModeEnabled && mapController != null) {
      mapController.setMapStyle(MapStyles.mapDarkStyle);
    } else if (isDarkModeEnabled == false && mapController != null) {
      mapController.setMapStyle(MapStyles.mapStyle);
    }

    return Scaffold(
      body: SlidingUpPanel(
        minHeight: 60,
        maxHeight: MediaQuery.of(context).size.height / 1.3,
        borderRadius: radius,
        color: isDarkModeEnabled ? (Color(0xFF2B3A58)) : (Colors.blue[600]),
        panel: slidingPanel(),
        collapsed: Scaffold(
          backgroundColor: Colors.white.withOpacity(0),
          body: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              gradient: new LinearGradient(
                colors: isDarkModeEnabled
                    ? ([Colors.black38, Color(0xFF2B3A58)])
                    : ([Colors.blue[600], Colors.cyan]),
              ),
            ),
            child: Row(
                children: <Widget>[
                  Text('map_pullup'.tr(),
                      style: TextStyle(fontSize: 18.0, color: Colors.white)),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, bottom: 100),
                  ),
                  Icon(Icons.arrow_upward_rounded, color: Colors.white),
                ],
                mainAxisAlignment:
                    MainAxisAlignment.center //Center Row contents horizontally,
                ),
          ),
        ),
        body: GoogleMap(
          polylines: Set<Polyline>.of(polylines.values),
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          onMapCreated: _onMapCreated,
          markers: _markers,
          initialCameraPosition: CameraPosition(
              target: LatLng(60.22465437727238, 24.951920578976313), zoom: 15),
        ),
      ),
    );
  }
}

Widget slidingPanel() {
  return Container(
      margin: const EdgeInsets.only(top: 60.0), child: PlacesHolder());
}

/*Widget slidingCollapsed() {

  return Scaffold(
      body: CustomPaint(
      painter: isDarkModeEnabled ? BackgroundPainterDark() : BackgroundPainter(),
        child: Row(
          children: <Widget> [
            Text('Places nearby',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,)
            ),
            Padding(
              padding: EdgeInsets.only(left: 15.0, bottom: 100),
            ),
            Icon(Icons.arrow_upward_rounded, color: Colors.white),
          ],
            mainAxisAlignment: MainAxisAlignment.center //Center Row contents horizontally,
        ),
      ),
  );
}*/
