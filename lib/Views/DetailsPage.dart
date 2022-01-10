import 'package:citizen/Views/WebViewPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:citizen/Views/RoutePage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:citizen/Services/ThemeManager.dart';
import 'package:provider/provider.dart';

class DetailsPage extends StatefulWidget {
  final activityItem;

  DetailsPage(this.activityItem);

  @override
  _DetailsPage createState() => _DetailsPage(activityItem);
}

class _DetailsPage extends State<DetailsPage> {
  final activityItem;
  bool isDarkModeEnabled;

  _DetailsPage(this.activityItem);

  String distanceToPlace;

  final f = new DateFormat('HH:mm');
  final i = new DateFormat('HH:mm:ss');

  @override
  void initState() {
    super.initState();
    _getPlaceDistance();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int weekDay = now.weekday - 1;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    isDarkModeEnabled = (themeNotifier.getTheme() == darkTheme);

    return Scaffold(
      appBar: AppBar(
        title: Text(activityItem.name),
      ),
      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                  image: true,
                  label: "semantics_activityimage".tr(),
                  child: getPlacesImage()),
              Container(
                padding: const EdgeInsets.only(
                    left: 16.0, top: 32.0, right: 16.0, bottom: 10.0),
                child: Semantics(
                  label: "semantics_title".tr(),
                  child: Text(
                    activityItem.name,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24.0),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 15.0),
                child: ElevatedButton(
                  child: Semantics(
                    button: true,
                    label: "semantics_button".tr(),
                    hint: "semantics_detailsgohint".tr(),
                    child: Text('details_go'.tr(),
                        style: TextStyle(color: Colors.white)),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    primary: isDarkModeEnabled
                        ? Colors.deepOrange[900].withOpacity(0.9)
                        : Colors.orangeAccent,
                    onPrimary: Colors.white, // foreground
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RoutePage(activityObject: activityItem),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Semantics(
                  label: "semantics_description".tr(),
                  child: Text(activityItem.desc,
                      style:
                          GoogleFonts.lato(textStyle: TextStyle(fontSize: 14.0))),
                ),
              ),
              const Divider(
                  height: 30,
                  thickness: 1,
                  endIndent: 20,
                  indent: 20,
                  color: Colors.black26),
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 4.0),
                child: Row(
                  children: [
                    Text(
                      'details_distance',
                      style: TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 15.0),
                    ).tr(),
                    Container(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          '${distanceToPlace != null ? distanceToPlace : ''}',
                          style: TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 15.0),
                        )),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 5.0, 12.0, 4.0),
                child: Row(
                  children: [
                    Text('details_address',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15.0))
                        .tr(),
                    Container(
                        padding: EdgeInsets.only(left: 5),
                        constraints: BoxConstraints(maxWidth: 280),
                        child: Text('${activityItem.address['street_address']}',
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 15.0))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 20.0, 12.0, 4.0),
                child: Row(
                  children: [
                    Text(
                        activityItem.openingHours[1]['opens'] != null
                            ? 'details_opent'.tr()
                            : 'details_open'.tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 15.0)),
                    Text(
                        activityItem.openingHours[1]['opens'] != null
                            ? '${f.format(i.parse(activityItem.openingHours[weekDay]['opens']))}-${f.format(i.parse(activityItem.openingHours[weekDay]['closes']))} '
                            : 'details_open'.tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 15.0)),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 15.0, bottom: 4.0, top: 5.0),
                child: ElevatedButton(
                  child: Semantics(
                    button: true,
                    label: "semantics_button".tr(),
                    hint: "semantics_ohhint".tr(),
                    child: Text('details_oh'.tr(),
                        style: TextStyle(color: Colors.white)),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    primary: isDarkModeEnabled
                        ? Colors.deepOrange[900].withOpacity(0.9)
                        : Colors.orangeAccent,
                    onPrimary: Colors.white, // foreground
                  ),
                  onPressed: () {
                    creatOpeningHoursAlert(context);
                  },
                ),
              ),
              Container(
                  padding: const EdgeInsets.only(bottom: 20, top: 20),
                  alignment: Alignment.center,
                  child: activityItem.infoUrl != ''
                      ? new OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        WebViewPage(activityItem.infoUrl)));
                          },
                          child: Container(
                              width: 100,
                              child: Row(children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.globe,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                ),
                                Semantics(
                                    button: true,
                                    label: "semantics_button".tr(),
                                    hint: "semantics_websitehint".tr(),
                                    child: Text(
                                      'details_web'.tr(),
                                    ))
                              ])),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )
                      : Text('')),
            ]),
      ),
    );
  }

  Image getPlacesImage() {
    if (activityItem.imageUrlList.length != 0) {
      return Image.network(activityItem.imageUrlList[0]['url']);
    } else {
      return Image.network(
          'https://images.pexels.com/photos/2292953/pexels-photo-2292953.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=750&w=1260');
    }
  }

  Future _getPlaceDistance() async {
    final Distance distance = new Distance();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final double meter = distance(
        new LatLng(position.latitude, position.longitude),
        new LatLng(activityItem.lat, activityItem.lon));

    setState(() {
      distanceToPlace = '${meter.toStringAsFixed(0)}' + 'details_meters'.tr();
    });
  }

  creatOpeningHoursAlert(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Semantics(
                  label: "semantics_title".tr(),
                  child: Text("details_oh".tr())),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        activityItem.openingHours[0]['opens'] != null
                            ? 'details_mon'.tr() +
                                '${f.format(i.parse(activityItem.openingHours[0]['opens']))}-${f.format(i.parse(activityItem.openingHours[0]['closes']))} '
                            : 'details_monc'.tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 15.0)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      activityItem.openingHours[1]['opens'] != null
                          ? 'details_tue'.tr() +
                              '${f.format(i.parse(activityItem.openingHours[1]['opens']))}-${f.format(i.parse(activityItem.openingHours[1]['closes']))} '
                          : 'details_tuec'.tr(),
                      style: TextStyle(
                          fontWeight: FontWeight.w300, fontSize: 15.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        activityItem.openingHours[2]['opens'] != null
                            ? 'details_wed'.tr() +
                                '${f.format(i.parse(activityItem.openingHours[2]['opens']))}-${f.format(i.parse(activityItem.openingHours[2]['closes']))} '
                            : 'details_wedc'.tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 15.0)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        activityItem.openingHours[3]['opens'] != null
                            ? 'details_thu'.tr() +
                                '${f.format(i.parse(activityItem.openingHours[3]['opens']))}-${f.format(i.parse(activityItem.openingHours[3]['closes']))} '
                            : 'details_thuc'.tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 15.0)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        activityItem.openingHours[4]['opens'] != null
                            ? 'details_fri'.tr() +
                                '${f.format(i.parse(activityItem.openingHours[4]['opens']))}-${f.format(i.parse(activityItem.openingHours[4]['closes']))} '
                            : 'details_fric'.tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 15.0)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        activityItem.openingHours[5]['opens'] != null
                            ? 'details_sat'.tr() +
                                '${f.format(i.parse(activityItem.openingHours[5]['opens']))}-${f.format(i.parse(activityItem.openingHours[5]['closes']))} '
                            : 'details_satc'.tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 15.0)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        activityItem.openingHours[6]['opens'] != null
                            ? 'details_su'.tr() +
                                '${f.format(i.parse(activityItem.openingHours[6]['opens']))}-${f.format(i.parse(activityItem.openingHours[6]['closes']))} '
                            : 'details_sunc'.tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 15.0)),
                  ),
                ],
              ),
              actions: <Widget>[
                MaterialButton(
                    elevation: 5.0,
                    child: Semantics(
                        button: true,
                        label: "semantics_button".tr(),
                        hint: "semantics_closeohhint".tr(),
                        child: Text('dialogue_close'.tr())),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }
}
