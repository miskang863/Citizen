
import 'package:citizen/Services/ThemeManager.dart';
import 'package:citizen/Views/AuthView.dart';
import 'package:citizen/Views/HomePage.dart';
import 'package:citizen/Views/MapPage.dart';
import 'package:citizen/Views/SettingsPage.dart';
import 'package:day_night_switch/day_night_switch.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Models/AuthModel.dart';
import '../Services/SharedPrefs.dart';
import 'FavoriteView.dart';

class DrawerView extends StatefulWidget {
  @override
  DraverState createState() => DraverState();
}

var email = "";
User userLoad = User();
class DraverState extends State<DrawerView> {
  bool isDarkModeEnabled = false;
  SharedPref userPreffs = SharedPref();
  PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    loadSharedPrefs();
    super.initState();
  }

  Future<void> _logOut()  async {
    SharedPreferences.getInstance().then((prefs) async {
      userPreffs.remove("user");
      prefs.clear();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthView()));
    }
    );
  }

  loadSharedPrefs() async {
    try {
      User user = User.fromJson(await userPreffs.read("user"));
      print("user load email::  ${userLoad.userEmail}");
      print("user load name:: ${userLoad.userName}");
      setState(() {
        userLoad = user;
      });
    } catch (Excepetion) {
      print("userload error :: $Excepetion");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    isDarkModeEnabled = (themeNotifier.getTheme() == darkTheme);
    return new Scaffold(
        appBar: new AppBar(
          title: Semantics(
            label: 'semantics_title'.tr(),
            child: new Text(
                'drawer_myKuopio'.tr()
            ),
          ),
          elevation:
          defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        ),
        drawer: new Drawer(
          child: ListView(
            padding: const EdgeInsets.all(0.0),
            children: <Widget>[
              new UserAccountsDrawerHeader(
                currentAccountPicture: Container(
                    child: Semantics(
                        hint: 'semantics_logo'.tr(),
                        image: true,
                        child: Image.asset("Assets/Icons/citizen_icon.png"))),
                accountName: Semantics(
                    label: 'login_username'.tr(),
                    child: Text(" ${userLoad.userName}")),
                accountEmail: Semantics(
                    label: 'login_email'.tr(),
                    child: Text(" ${userLoad.userEmail}")),
              ),
              Semantics(
                button: true,
                label: "semantics_button".tr(),
                hint: 'semantics_presshome'.tr(),
                child: new ListTile(
                  title: new Text(
                      'drawer_home'.tr()
                  ),
                  leading: new Icon(
                    Icons.home,
                  ),
                  onTap: () {
                    _controller.jumpToPage(0);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Semantics(
                button: true,
                label: "semantics_button".tr(),
                hint: 'semantics_pressmap'.tr(),
                child: new ListTile(
                  title: new Text(
                      'drawer_map'.tr()
                  ),
                  leading: new Icon(
                    Icons.map,
                  ),
                  onTap: () {
                    _controller.jumpToPage(1);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Semantics(
                button: true,
                label: "semantics_button".tr(),
                hint: 'semantics_pressfavorites'.tr(),
                child: new ListTile(
                  title: new Text(
                      'drawer_favorites'.tr()
                  ),
                  leading: new Icon(
                    Icons.favorite,
                  ),
                  onTap: () {
                    _controller.jumpToPage(2);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Semantics(
                button: true,
                label: "semantics_button".tr(),
                hint: 'semantics_presssettings'.tr(),
                child: new ListTile(
                  title: new Text(
                      'drawer_settings'.tr()
                  ),
                  leading: new Icon(
                    Icons.settings,
                  ),
                  onTap: () {
                    _controller.jumpToPage(3);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Divider(
                color: Theme.of(context).accentColor ,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 10, right: 25),
                      child: DayNightSwitcherIcon(
                        isDarkModeEnabled: isDarkModeEnabled,
                        onStateChanged: (val) {
                          setState(() {
                            print(val.toString());
                            isDarkModeEnabled = val;
                          });
                          onThemeChanged(val, themeNotifier);
                        },
                      )),
                  Semantics(
                    label: 'semantics_switch'.tr(),
                    hint: 'semantics_pressswitch',
                    child: Text(
                      (isDarkModeEnabled ? 'drawer_darkmode'.tr() : 'drawer_lightmode'.tr()),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.4,
                    child: DayNightSwitch(
                      value: isDarkModeEnabled,
                      onChanged: (val) {
                        setState(() {
                          print(val.toString());
                          isDarkModeEnabled = val;
                        });
                        onThemeChanged(val, themeNotifier);
                      },
                    ),
                  ),
                ],
              ),
              Semantics(
                button: true,
                label: "semantics_button".tr(),
                hint: 'semantics_presslogout'.tr(),
                child: new ListTile(
                    title: new Text(
                        'drawer_logout'.tr()
                    ),
                    leading: new Icon(
                      Icons.logout,
                    ),
                    onTap: () => _logOut()),
              ),
            ],
          ),
        ),
        body: PageView(
          controller: _controller,
          children: [
            HomePage(),
            MapPage(activityObject: null,),
            FavoriteView(),
            SettingsPage()
          ],
          physics: NeverScrollableScrollPhysics(),
        ));
  }

  void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }
}
