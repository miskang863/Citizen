import 'package:citizen/Services/Authentication.dart';
import 'package:citizen/Services/ThemeManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:citizen/Components/BackgroundPainter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Models/AuthModel.dart';
import '../Services/SharedPrefs.dart';
import 'Drawer.dart';

class RegisterView extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterView> {
  bool isDarkModeEnabled = false;

  // register details
  var login = "";
  var password = "";
  var email = "";
  var username = "";

  // save usermode to shared prefs
  User userSave = User();
  SharedPref userPreffs = SharedPref();

  // Validation bools
  bool hasUsername;
  bool strongPassword;
  bool correctEmail;
  bool passwordMatch;
  bool hideValidator;

  // Bool for enabling/disabling register button
  bool _enabled;

  // controllers
  final TextEditingController controller = new TextEditingController();
  final _controller = ScrollController();

  // inits
  @override
  void initState() {
    _enabled = false;
    strongPassword = false;
    correctEmail = false;
    passwordMatch = false;
    hideValidator = true;
    hasUsername = false;
    super.initState();
  }

  // Change visibility of password validator
  void _hideValidator(bool invisible) {
    setState(() {
      hideValidator = invisible;
    });
  }

  // Enable / disable register button
  void _buttonEnabler() {
    if (strongPassword && correctEmail && passwordMatch && hasUsername) {
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
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    isDarkModeEnabled = (themeNotifier.getTheme() == darkTheme);

    // Onpress register button
    var _onPressed;
    if (_enabled) {
      _onPressed = () async {
        EasyLoading.show(status: 'login_create'.tr());
        print(
            "Registering account with usename $username email: $email password: $password");

        var response = await Authentication().register(email, username, password);
        if (response.responseCode == 200) {
          var prefs = await SharedPreferences.getInstance();
          print("response code 200 -- ok");
          print("Loggin in with email: $email password: $password");
          var loginRes = await Authentication().login(email, password);
          if (loginRes.responseCode == 200) {
            print("email : ${loginRes.responseEmail}");
            EasyLoading.dismiss();
            userSave.userName = loginRes.responeUsername;
            userSave.userEmail = loginRes.responseEmail;
            userSave.userExpiration = loginRes.expiration;
            userSave.userRoles = loginRes.responseRoles;
            print("userSave userName : ${userSave.userName}");
            print("userSave userEmail : ${userSave.userEmail}");
            print("userSave userExpiration : ${userSave.userExpiration}");
            print("userSave userRoles : ${userSave.userRoles}");

            userPreffs.save("user", userSave);
            prefs.setString("usertoken", loginRes.responseToken);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => DrawerView()));
          } else {
            EasyLoading.showError(loginRes.errorMsg);
          }
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
              padding: const EdgeInsets.only(top: 130, left: 50, right: 50),
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
            // USERNAME
            Column(
              children: <Widget>[
                Row(children: <Widget>[]),
                //username
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
                  child: Container(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Semantics(
                      textField: true,
                      label: 'semantics_textfield'.tr(),
                      hint: 'semantics_usernamehint'.tr(),
                      child: TextFormField(
                        onTap: () {
                          _hideValidator(true);
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) {
                          username = val;
                          hasUsername =
                              RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username);

                          if (!hasUsername) {
                            return "login_invalidusr".tr();
                          }
                          return null;
                        },
                        onChanged: (val) {
                          username = val;
                          hasUsername =
                              RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username);
                          _buttonEnabler();
                        },
                        style: TextStyle(
                            color: isDarkModeEnabled
                                ? Colors.white
                                : Colors.black54,
                            fontSize: 20),
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          helperText: ' ',
                          fillColor: isDarkModeEnabled
                              ? Color(0xFF2B3A58).withOpacity(0.6)
                              : Colors.white.withOpacity(0.5),
                          filled: true,
                          border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(20.0))),
                          hintText: 'login_username'.tr(),
                          suffixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                  ),
                ),
                // EMAIL
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 50, right: 50),
                  child: Container(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Semantics(
                      textField: true,
                      label: 'semantics_textfield'.tr(),
                      hint: 'semantics_emailhint'.tr(),
                      child: TextFormField(
                        onTap: () {
                          _hideValidator(true);
                        },
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
                            color: isDarkModeEnabled
                                ? Colors.white
                                : Colors.black54,
                            fontSize: 20),
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          helperText: ' ',
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
                  // PASSWORD 1
                  padding: const EdgeInsets.only(top: 5, left: 50, right: 50),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Semantics(
                                textField: true,
                                label: 'semantics_textfield'.tr(),
                                hint: 'semantics_passwordhint'.tr(),
                                child: TextField(
                                  onTap: () {
                                    _hideValidator(false);
                                    _controller.jumpTo(
                                        _controller.position.maxScrollExtent);
                                    print("visibility");
                                  },
                                  controller: controller,
                                  onChanged: (val) {
                                    password = val;
                                  },
                                  style: TextStyle(
                                      color: isDarkModeEnabled
                                          ? Colors.white
                                          : Colors.black54,
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
                              Offstage(
                                offstage: hideValidator,
                                child: FlutterPwValidator(
                                  controller: controller,
                                  minLength: 8,
                                  uppercaseCharCount: 2,
                                  numericCharCount: 3,
                                  specialCharCount: 1,
                                  width: 400,
                                  height: 100,
                                  defaultColor: Colors.transparent,
                                  onSuccess: () {
                                    _controller.jumpTo(
                                        _controller.position.maxScrollExtent);
                                    strongPassword = true;
                                  },
                                ),
                              )
                            ],
                          )
                        ],
                      )),
                ),
                // PASSWORD 2
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 50, right: 50),
                  child: Container(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Semantics(
                      textField: true,
                      label: 'semantics_textfield'.tr(),
                      hint: 'semantics_passwordrhint'.tr(),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onTap: () {
                          _controller
                              .jumpTo(_controller.position.maxScrollExtent);
                          _hideValidator(true);
                        },
                        validator: (val) {
                          if (val == password) {
                            passwordMatch = true;
                          } else {
                            return "login_notmatch".tr();
                          }
                          return null;
                        },
                        onChanged: (val) {
                          if (val == password) {
                            passwordMatch = true;
                          } else {
                            passwordMatch = false;
                          }
                          _buttonEnabler();
                        },
                        style: TextStyle(
                            color: isDarkModeEnabled
                                ? Colors.white
                                : Colors.black54,
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
                          hintText: 'login_repeat'.tr(),
                          suffixIcon: Icon(Icons.lock_rounded),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  // REGISTER BUTTON
                  padding:
                      const EdgeInsets.only(top: 10, right: 100, left: 100),
                  child: Container(
                    alignment: Alignment.bottomRight,
                    height: 80,
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
                              label: 'semantics_button'.tr(),
                              hint: 'semantics_registerhint'.tr(),
                              child: Text(
                                'login_register'.tr(),
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
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
