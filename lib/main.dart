import 'package:citizen/Models/InfoWindowModel.dart';
import 'package:citizen/Services/Authentication.dart';
import 'package:citizen/Views/AuthView.dart';
import 'package:citizen/Views/Drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Services/ThemeManager.dart';
import 'package:flash/flash.dart';
import 'Services/flash_helper.dart';
import 'Models/InfoWindowModel.dart';

int responsecode;
int fakeResponecode = 200;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  SharedPreferences.getInstance().then((prefs) async {
    var darkModeOn = prefs.getBool('darkMode') ?? true;
    var token = prefs.getString("usertoken");
    var res = await Authentication().checkToken(token);
    responsecode = res.responseCode;
    print("responsecode -- ${res.responseCode}");
    runApp(ChangeNotifierProvider(
        create: (context) => InfoWindowModel(),
        child: EasyLocalization(
          supportedLocales: [Locale('en', 'UK'), Locale('fi', 'FI')],
          path: 'Assets/Locales',
          child: ChangeNotifierProvider<ThemeNotifier>(
            create: (_) => ThemeNotifier(darkModeOn ? darkTheme : lightTheme),
            child: MyApp(),
          ),
        )));
  });
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SpinManager().configLoading();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: themeNotifier.getTheme(),
      builder: EasyLoading.init(),
      initialRoute: responsecode == 200 ? "drawer" : "login",
      //initialRoute: fakeResponecode == 200 ? "drawer" : "login",
      routes: {
        'drawer': (context) => DrawerView(),
        'login': (context) => AuthView()
      },
    );
  }
}
