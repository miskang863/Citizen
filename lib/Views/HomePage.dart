import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:citizen/Components/CustomClipper.dart';
import 'package:citizen/Components/EventCard.dart';
import 'package:citizen/Components/EventCard2.dart';
import 'package:citizen/Components/SpecialOfferCard.dart';
import 'package:citizen/Keys/Keys.dart';
import 'package:citizen/Models/EventItem.dart';
import 'package:citizen/Models/SpecialOfferItem.dart';
import 'package:citizen/Services/MyHelsinkiPlaces.dart';
import 'package:citizen/Services/ThemeManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:strings/strings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:location_permissions/location_permissions.dart';

Keys keys = Keys();

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomePage> {
  List<dynamic> eventList = [];
  List events = [];
  List specialOffersList = [];

  bool isDarkModeEnabled = false;
  var onlyFree = false;
  var all = true;
  final List allSpecialOffers = [
    SpecialOfferItem(
        'All Nike trainers -50%!',
        [
          {
            'url':
                'https://cdn.pixabay.com/photo/2016/11/19/18/06/feet-1840619_960_720.jpg'
          }
        ],
        'https://cdn.pixabay.com/photo/2016/11/19/18/06/feet-1840619_960_720.jpg',
        '19.04.2021',
        '05.06.2021',
        'Stadium Forum',
        60.168405515257064,
        24.940162981007592,
        9,
        {'street_address': 'Mannerheimintie 14'}),
    SpecialOfferItem(
        'Kids clothes now -30%!',
        [
          {
            'url':
                'https://cdn.pixabay.com/photo/2017/02/08/02/56/booties-2047596_960_720.jpg'
          }
        ],
        'https://cdn.pixabay.com/photo/2017/02/08/02/56/booties-2047596_960_720.jpg',
        '19.04.2021',
        '21.05.2021',
        'Pinkomo',
        60.1672819070192,
        24.934795603893637,
        9,
        {'street_address': 'Eerikinkatu 9'}),
    SpecialOfferItem(
        'Latte for only 3 eur!',
        [
          {
            'url':
                'https://cdn.pixabay.com/photo/2015/10/12/14/54/coffee-983955_960_720.jpg'
          }
        ],
        'https://cdn.pixabay.com/photo/2015/10/12/14/54/coffee-983955_960_720.jpg',
        '19.04.2021',
        '30.04.2021',
        'Konditoria Café Briossi',
        60.16744799693274,
        24.937890130999616,
        2,
        {'street_address': 'Kalevankatu 9'})
  ];

  void getSpecialOffers() async {
    specialOffersList = [];
    var tags = await loadSelectedTags();

    allSpecialOffers.forEach((offer) {
      if (tags.contains(offer.tag)) {
        setState(() {
          specialOffersList.add(offer);
        });
      }
    });
  }

  Future<List> loadSelectedTags() async {
    print("loading data..");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var stringValue = prefs.getStringList('selectedTags');
    if (stringValue != null) {
      List<int> intProductList = stringValue.map((i) => int.parse(i)).toList();
      return intProductList;
    } else {
      return [9, 2];
    }
  }

  void getEvents() async {
    eventList = [];
    EasyLoading.show(status: 'easyloading_loading'.tr());
    if (all)
      events = await MyHelsinkiEvents().getEvents(
          "https://api.hel.fi/linkedevents/v1/event/?format=json&start=now");
    else if (onlyFree)
      events = await MyHelsinkiEvents().getEvents(
          "https://api.hel.fi/linkedevents/v1/event/?format=json&start=now&is_free=true");

    final f = new DateFormat('dd.MM.yyyy');
    final i = new DateFormat('yyyy-MM-dd');

    setState(() {
      events.forEach((ev) {
        eventList.add(EventItem(
          ev['name'] == '' || ev['name'] == null ? '' : ev['name']['fi'],
          //ev['short_description']['fi'],
          ev['images'].isEmpty || ev['images'] == null
              ? ''
              : ev['images'][0]['url'],
          ev['info_url'] != null ? ev['info_url']['fi'] : '',
          ev['start_time'] != null
              ? f.format(i.parse(ev['start_time'])).toString()
              : '',
          ev['end_time'] != null
              ? f.format(i.parse(ev['end_time'])).toString()
              : '',
          ev['provider'] != null ? ev['provider']['fi'] : '',
          ev['location']['@id'] != null ? ev['location']['@id'] : '',
        ));
      });
      EasyLoading.dismiss();
    });
  }

  double temp;
  var description;
  var currently;
  var humidity;
  int weatherId;
  double windSpeed;
  String city;

  Future getWeather() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    var url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=${keys.openWeatherKey}");
    http.Response response = await http.get(url);
    var results = jsonDecode(response.body);
    setState(() {
      if (results != null) {
        this.temp = double.parse((results['main']['temp']).toStringAsFixed(1));
        this.description = results['weather'][0]['description'];
        this.currently = results['weather'][0]['main'];
        this.humidity = results['main']['humidity'];
        this.windSpeed =
            double.parse((results['wind']['speed']).toStringAsFixed(1));
        this.city = results['name'];
        this.weatherId = results['weather'][0]['id'];
      }
    });
  }

  showAlertDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Location services are not enabled'),
      content: Text('Open settings and allow location.'),
      actions: [
        FlatButton(
          child: Text("Open"),
          onPressed: () {
            AppSettings.openLocationSettings();
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'))
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void locationPermission() async {
    final PermissionStatus permission = await _getLocationPermission();
    if (permission == PermissionStatus.granted) {
      print('permission granted');
      getWeather();
    }
  }

  Future<PermissionStatus> _getLocationPermission() async {
    final PermissionStatus permission = await LocationPermissions()
        .checkPermissionStatus(level: LocationPermissionLevel.location);

    if (permission != PermissionStatus.granted) {
      PermissionStatus permissionStatus = await LocationPermissions()
          .requestPermissions(
              permissionLevel: LocationPermissionLevel.location);

      if (permissionStatus == PermissionStatus.denied) {
        showAlertDialog(context);
      }

      return permissionStatus;
    } else {
      return permission;
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      locationPermission();
    }
    if (Platform.isAndroid) {
      this.getWeather();
    }
    this.getEvents();
    this.getSpecialOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              weatherCard(),
              Container(
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                //height: MediaQuery.of(context).size.height / 5,
                child: Card(
                  color: isDarkModeEnabled
                      ? Colors.deepOrangeAccent.withOpacity(0.8)
                      : Colors.orangeAccent,
                  child: Column(
                    children: <Widget>[
                      ExpansionTile(
                        leading: Icon(
                          Icons.warning_rounded,
                          color: Colors.white,
                        ),
                        title: Semantics(
                          label: 'semantics_warning'.tr(),
                          hint: 'semantics_pressread'.tr(),
                          child: Text(
                            'homepage_warning'.tr(),
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        children: <Widget>[
                          ListTile(
                            title: Text('Covid-19'),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('warning_cases'.tr()),
                                Text(''),
                                Text('warning_emergency'.tr()),
                                ListTile(
                                    leading: CircleAvatar(
                                      radius: 4.0,
                                      backgroundColor: isDarkModeEnabled
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    title: Text('warning_mask'.tr())),
                                ListTile(
                                    leading: CircleAvatar(
                                      radius: 4.0,
                                      backgroundColor: isDarkModeEnabled
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    title: Text('warning_stay'.tr())),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 18.0),
                                  child: ListTile(
                                      leading: CircleAvatar(
                                        radius: 4.0,
                                        backgroundColor: isDarkModeEnabled
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      title: Text('warning_maintain'.tr())),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 5.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Container(
                            padding: EdgeInsets.only(right: 10),
                            child: Text(
                              'homepage_offers'.tr(),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            )),
                      ),
                    ]),
              ),
              SizedBox(
                height: 220,
                child: PageView.builder(
                    physics: BouncingScrollPhysics(),
                    controller: PageController(viewportFraction: 0.7),
                    itemCount: specialOffersList != null
                        ? specialOffersList.length
                        : 0,
                    itemBuilder: (context, i) {
                      var item = specialOffersList[i];
                      return SpecialOfferCard(
                          text: item.txt,
                          imageUrlList: item.imageUrlList,
                          startTime: item.startTime,
                          endTime: item.endTime,
                          header: item.name,
                          infoUrl: item.infoUrl,
                          lat: item.lat,
                          lon: item.lon,
                          tag: item.tag,
                          address: item.address);
                    }),
              ),
              Container(
                padding: EdgeInsets.only(right: 5.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(13.0),
                          child: Text(
                            'homepage_latestevents'.tr(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 30),
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                all = true;
                                onlyFree = false;
                                getEvents();
                              });
                            },
                            child: Semantics(
                                button: true,
                                label: "semantics_button".tr(),
                                hint: 'semantics_allpress'.tr(),
                                child: Text('homepage_all'.tr())),
                          )),
                      Container(
                          padding: EdgeInsets.only(left: 10),
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                all = false;
                                onlyFree = true;
                                getEvents();
                              });
                            },
                            child: Semantics(
                                button: true,
                                label: "semantics_button".tr(),
                                hint: 'semantics_freepress'.tr(),
                                child: Text('homepage_free'.tr())),
                          )),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: SizedBox(
                  height: 250,
                  child: PageView.builder(
                      physics: BouncingScrollPhysics(),
                      controller: PageController(viewportFraction: 0.7),
                      itemCount: eventList != null ? eventList.length : 0,
                      itemBuilder: (context, i) {
                        var item = eventList[i];
                        return EventCard2(
                          text: item.name,
                          url: item.imageUrl,
                          startTime: item.startTime,
                          endTime: item.endTime,
                          header: item.provider,
                          infoUrl: item.infoUrl,
                        );
                      }),
                ),
              ),
            ],
          ),
        ));
  }

  Image getWeatherIcon(int id) {
    if (id != null) {
      if (id >= 0 && id < 300) {
        //Thunderstrom
        return Image.network('https://openweathermap.org/img/wn/11d@2x.png');
      } else if (id >= 300 && id < 500) {
        //Drizzle
        return Image.network('https://openweathermap.org/img/wn/09d@2x.png');
      } else if (id >= 500 && id <= 504) {
        //Rain
        return Image.network('https://openweathermap.org/img/wn/10d@2x.png');
      } else if (id == 511) {
        //Freezing Rain
        return Image.network('https://openweathermap.org/img/wn/13d@2x.png');
      } else if (id >= 520 && id <= 531) {
        //Rain 2
        return Image.network('https://openweathermap.org/img/wn/09d@2x.png');
      } else if (id >= 600 && id < 700) {
        //Snow
        return Image.network('https://openweathermap.org/img/wn/13d@2x.png');
      } else if (id >= 700 && id < 800) {
        //Atmosphere
        return Image.network('https://openweathermap.org/img/wn/50d@2x.png');
      } else if (id == 800) {
        //Clear
        return Image.network('https://openweathermap.org/img/wn/01d@2x.png');
      } else if (id == 801) {
        //Clouds
        return Image.network('https://openweathermap.org/img/wn/02d@2x.png');
      } else if (id == 802) {
        //Scattered clouds
        return Image.network('https://openweathermap.org/img/wn/03d@2x.png');
      } else if (id >= 803) {
        //Broken clouds
        return Image.network('https://openweathermap.org/img/wn/04d@2x.png');
      }
    }
    return Image.network('https://openweathermap.org/img/wn/13d@2x.png');
  }

  Widget weatherCard() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    isDarkModeEnabled = (themeNotifier.getTheme() == darkTheme);

    return Container(
      height: 250.0,
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: MyCustomClipper(),
            child: Container(
              //Doesn't change with the theme
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                  colors: isDarkModeEnabled
                      ? ([Colors.black38, Color(0xFF2B3A58)])
                      : ([Colors.blue[600], Colors.cyan]),
                ),
              ),
            ),
          ),
          Align(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 30.0),
                    height: 190,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: <Widget>[
                        Container(
                          // height: MediaQuery.of(context).size.height / 3,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: Semantics(
                                  label: "weather_city".tr(),
                                  child: Text(
                                    city != null
                                        ? city.toString()
                                        : "route_loading".tr(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              Semantics(
                                label: "weather_temperature".tr(),
                                child: Text(
                                  temp != null
                                      ? temp.toString() + " \u00B0c"
                                      : "route_loading".tr(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 35.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              getWeatherIcon(weatherId),
                              Semantics(
                                label: "weather_weather".tr(),
                                child: Text(
                                  currently != null
                                      ? currently.toString()
                                      : "route_loading".tr(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 3,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                              padding: EdgeInsets.all(15.0),
                              child: ListView(
                                children: <Widget>[
                                  ListTile(
                                    leading: FaIcon(FontAwesomeIcons.wind),
                                    title: Text(
                                      "weather_wind".tr(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: Text(
                                      windSpeed != null
                                          ? windSpeed.toString() + " m/s"
                                          : "route_loading".tr(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  ListTile(
                                    leading: FaIcon(FontAwesomeIcons.cloud),
                                    title: Text(
                                      "weather_weather".tr(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: Text(
                                      description != null
                                          ? capitalize(description.toString())
                                          : "route_loading".tr(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.wash),
                                    title: Text(
                                      "weather_humidity".tr(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: Text(
                                      humidity != null
                                          ? humidity.toString() + "%"
                                          : "route_loading".tr(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
