import 'package:citizen/Services/Authentication.dart';
import 'package:citizen/Services/ThemeManager.dart';
import 'package:citizen/Views/Drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:citizen/Components/BackgroundPainter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Models/AuthModel.dart';
import '../Services/SharedPrefs.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController controller = new TextEditingController();

  bool isDarkModeEnabled = false;
  final _controller = ScrollController();
  bool correctEmail;
  bool strongPassword;

  SharedPref userPreffs = SharedPref();

  User userSave = User();

  // Login details
  var email = "";
  var password = "";

  // Enable/disable button
  bool _enabled;

  void _buttonEnabler() {
    if (correctEmail && strongPassword) {
      setState(() {
        _enabled = true;
      });
    } else {
      setState(() {
        _enabled = false;
      });
    }
  }

  @override
  void initState() {
    strongPassword = false;
    correctEmail = false;
    _enabled = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    isDarkModeEnabled = (themeNotifier.getTheme() == darkTheme);

    var _onPressed;
    if (_enabled) {
      _onPressed = () async {
        EasyLoading.show(status: 'easyloading_sign'.tr());
        print("Loggin in with email: $email password: $password");

        var response = await Authentication().login(email, password);
        if (response.responseCode == 200) {
          print("email : ${response.responseEmail}");
          EasyLoading.dismiss();
          userSave.userName = response.responeUsername;
          userSave.userEmail = response.responseEmail;
          print("mail : ${userSave.userEmail}");
          userSave.userExpiration = response.expiration;
          userSave.userRoles = response.responseRoles;
          userPreffs.save("user", userSave);

          var prefs = await SharedPreferences.getInstance();
          prefs.setString("usertoken", response.responseToken);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => DrawerView()));
        } else {
          EasyLoading.showError(response.errorMsg);
        }
      };
    }
    return Scaffold(
      body: CustomPaint(
        painter:
            isDarkModeEnabled ? BackgroundPainterDark() : BackgroundPainter(),
        child: ListView(
          controller: _controller,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 140, left: 50, right: 50),
              child: Semantics(
                label: 'semantics_title'.tr(),
                child: Text(
                  'drawer_myKuopio'.tr(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    fontSize: 40.0,
                    color: Colors.white,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
                  child: SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Semantics(
                      textField: true,
                      label: 'semantics_textfield'.tr(),
                      hint: 'semantics_emailhint'.tr(),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) {
                          email = val;
                          correctEmail = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(email);
                          if (!correctEmail) {
                            return "login_notvalid".tr();
                          }

                          return null;
                        },
                        onChanged: (val) {
                          email = val;
                          correctEmail = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(email);
                          _buttonEnabler();
                        },
                        style: TextStyle(
                            color:
                                isDarkModeEnabled ? Colors.white : Colors.black54,
                            fontSize: 20),
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          helperText: '',
                          fillColor: isDarkModeEnabled
                              ? Color(0xFF2B3A58).withOpacity(0.6)
                              : Colors.white.withOpacity(0.5),
                          filled: true,
                          border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(20.0))),
                          hintText: 'login_email'.tr(),
                          suffixIcon: Icon(Icons.email_rounded),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 50, right: 50),
                  child: Container(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Semantics(
                      textField: true,
                      label: 'semantics_textfield'.tr(),
                      hint: 'semantics_passwordhint'.tr(),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) {
                          if (val.isEmpty) {
                            return "login_enterpassword".tr();
                          }
                          return null;
                        },
                        onTap: () {
                          _controller
                              .jumpTo(_controller.position.maxScrollExtent);
                        },
                        onChanged: (val) {
                          password = val;
                          if (password.length > 3) {
                            strongPassword = true;
                          } else {
                            strongPassword = false;
                          }
                          _buttonEnabler();
                        },
                        style: TextStyle(
                            color:
                                isDarkModeEnabled ? Colors.white : Colors.black54,
                            fontSize: 20),
                        obscureText: true,
                        decoration: InputDecoration(
                          helperText: ' ',
                          fillColor: isDarkModeEnabled
                              ? Color(0xFF2B3A58).withOpacity(0.6)
                              : Colors.white.withOpacity(0.5),
                          filled: true,
                          border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(20.0))),
                          hintText: 'login_password'.tr(),
                          suffixIcon: Icon(Icons.lock_rounded),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 60, right: 130, left: 130),
                  child: Container(
                    alignment: Alignment.bottomRight,
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: ElevatedButton(
                        onPressed: _onPressed,
                        style: ElevatedButton.styleFrom(
                          primary: Colors.orange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                        ),
                        //color: Colors.white,
                        //shape: RoundedRectangleBorder(
                        // borderRadius: BorderRadius.circular(30.0)),
                        //disabledColor: Colors.black54,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Semantics(
                              button: true,
                              label: "semantics_button".tr(),
                              hint: 'semantics_loginhint'.tr(),
                              child: Text(
                                'login_login'.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
