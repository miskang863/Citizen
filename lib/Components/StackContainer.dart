import 'package:citizen/Services/ThemeManager.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Models/AuthModel.dart';
import '../Services/SharedPrefs.dart';
import 'CustomClipper.dart';

class StackContainer extends StatefulWidget {
  @override
  StackContainerState createState() => StackContainerState();
}

User userLoad = User();

class StackContainerState extends State<StackContainer> {
  SharedPref userPreffs = SharedPref();

  loadSharedPrefs() async {
    try {
      User user = User.fromJson(await userPreffs.read("user"));
      print("user loaded ${userLoad.userEmail}");
      setState(() {
        userLoad = user;
      });
    } catch (Excepetion) {
      print("userload error :: $Excepetion");
    }
  }

  @override
  var email = "";

  void initState() {
    loadSharedPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isDarkModeEnabled = (themeNotifier.getTheme() == darkTheme);
    return Container(
      height: 250.0,
      child: Stack(
        children: <Widget>[
          Container(),
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
            alignment: Alignment(0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Semantics(
                    label: 'login_email'.tr(),
                    child: Text(
                      " ${userLoad.userEmail}",
                      style: TextStyle(fontSize: 25.0, color: Colors.white),
                    ),
                  ),
                ),
                Semantics(
                  label: 'login_username'.tr(),
                  child: Text(
                    " ${userLoad.userName}",
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
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
