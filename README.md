# My Kuopio - a smart city application


An application for real-time activity planning made with Flutter & Dart. Compatible with both Android and iOS.

This project was offered and co-supervised by Metropolia and Nokia.

## APK

[Link to APK](https://drive.google.com/file/d/1-L5h-JzCURzs3Qsq82h3qFUNPflWcjTQ/view?usp=sharing)

## Running the application

**Step 1:**

Download or clone this repo by using the link below:

```
https://gitlab.com/kirillar/citizen.git
```

**Step 2:**

Go to project root and execute the following command in console to get the required dependencies:

```
flutter pub get 
```

**Step 3:**
You will need to create a file Keys/Keys.dart into the project folder and provide your own Google Maps API and OpenWeathermap API keys:

```
class Keys {
  final googleKey = 'YOUR API KEY HERE';
  final openWeatherKey = 'YOUR API KEY HERE';
}
```

## Features
* Splash
* Login & Register
* Home
* Current Weather
* Real-time Activities
* Map & Current Location
* Distance Calculation
* Tag List
* List of Places & Events
* Activity Linkage
* Favorites
* FI & ENG Localization
* Light & Dark Theme Support

## APIs
[OpenWeather API](https://openweathermap.org/api)
  * Current Weather Data

[Google Maps API](https://developers.google.com/maps)
  * Cloud Functions API
  * Directions API
  * Distance Matrix API
  * Maps SDK for Android
  * Maps SDK for iOS

## Screenshots

![Home Dark Mode](https://media.discordapp.net/attachments/595486914946138146/839080328962113546/Screenshot_20210504-1257281.png?width=144&height=300)
![Plan](https://media.discordapp.net/attachments/595486914946138146/839080670407688202/Screenshot_20210504-1257511.png?width=144&height=300)
![Places](https://media.discordapp.net/attachments/595486914946138146/839080827488829451/Screenshot_20210504-1257451.png?width=144&height=300)
![Home](https://media.discordapp.net/attachments/595486914946138146/839079998852956220/Screenshot_20210504-1258331.png?width=144&height=300)
![Info](https://media.discordapp.net/attachments/595486914946138146/839079909879840788/Screenshot_20210504-1258491.png?width=144&height=300)
![Routes](https://media.discordapp.net/attachments/595486914946138146/839079816594456586/Screenshot_20210504-1259491.png?width=144&height=300)

## Dependencies
```
environment:
  sdk: ">=2.7.0 <3.0.0"

dependencies:
  firebase_core: ^1.0.2
  firebase_auth: ^1.0.1
  day_night_switch: ^0.0.2+1
  provider: ^5.0.0
  shared_preferences: ^2.0.5
  day_night_switcher: ^0.2.0+1
  flutter_pw_validator: ^1.0.1
  google_maps_flutter: ^2.0.1
  geolocator: ^7.0.1
  sliding_up_panel: ^1.0.2
  flutter_easyloading: ^3.0.0
  firebase_database: ^6.1.1
  font_awesome_flutter: ^9.0.0
  http: ^0.13.1
  strings: ^0.2.1
  location: ^4.1.1
  flutter_svg: ^0.21.0+1
  drag_select_grid_view: ^0.4.0
  latlong: ^0.6.1
  webview_flutter: ^2.0.2
  intl: ^0.17.0
  expansion_card: ^0.1.0
  google_fonts: ^2.0.0
  flutter_slidable: ^0.6.0
  polyline: ^1.0.2
  flutter_polyline_points: ^0.2.6
  show_up_animation: ^1.0.2
  easy_localization: ^3.0.0
  auto_size_text: ^2.1.0
  flash: ^1.5.1
  data_connection_checker: ^0.3.4
  clippy_flutter: ^1.1.1
  location_permissions: ^3.0.0
  app_settings: ^4.1.0

  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_native_splash: ^1.1.7+1
```
