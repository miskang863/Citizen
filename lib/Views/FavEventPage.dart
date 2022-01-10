
import 'package:citizen/Models/MyHelsinkiEventsItem.dart';

import 'package:citizen/Services/MyHelsinkiPlaces.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citizen/Services//flash_helper.dart';
import '../Services/MyHelsinkiPlaces.dart';
import 'package:easy_localization/easy_localization.dart';

import 'DetailsEvents.dart';

class FavoritesEventPage extends StatefulWidget {
  @override
  _FavoritesEventPageState createState() => _FavoritesEventPageState();
}

class _FavoritesEventPageState extends State<FavoritesEventPage> {
  List favPlaceItemList = [];
  List<String> favoritePlaceList = [];
  MyHelsinkiEventsItem deletedItem;
  String deletedItemID;
  bool isConnected = false;
  var tags = [];
  final f = new DateFormat('dd.MM.yyyy');
  final i = new DateFormat('yyyy-MM-dd');


  @override
  void initState() {
    _loadFavPlaces();
    super.initState();
  }

  @override
  void dispose() {
    FlashHelper.dispose();
    super.dispose();
  }

  // Load favorite places' id
  Future<void> _loadFavPlaces() async {
    print("loadingfavs");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getStringList('favoriteItemList');
    if (result.length > 0) {
      EasyLoading.show(status: 'easyloading_loading'.tr());
      print("favorites id t:: $result");
      favoritePlaceList = result;
      _getFavPlaces(favoritePlaceList);
    }
  }

  // Remove favorite item
  Future<void> _removeFavorite(int index) async {
    setState(() {
      print("index :: $index");
      deletedItemID = favoritePlaceList[index];
      favPlaceItemList.removeAt(index);
      favoritePlaceList.removeAt(index);
    });
    var filtered = favoritePlaceList.toSet().toList();
    print("saving favorites : $filtered");
    var prefs = await SharedPreferences.getInstance();
    List<String> strList = filtered.map((i) => i.toString()).toList();
    prefs.setStringList("favoriteItemList", strList);
  }

  List getTagsList(index) {
    List tagsList = [];

    if (favPlaceItemList[index].tags.length > 0) {
      tagsList.add(favPlaceItemList[index].tags[0]['name']);
    }
    if (favPlaceItemList[index].tags.length > 1) {
      tagsList.add(favPlaceItemList[index].tags[1]['name']);
    }
    if (favPlaceItemList[index].tags.length > 2) {
      tagsList.add(favPlaceItemList[index].tags[2]['name']);
    }
    return tagsList;

  }

  // Load favorite places items
  void _getFavPlaces(favlist) async {
    List favplacelist = await MyHelsinkiPlaces().getFavoriteEvents(favlist);
    setState(() {
      favplacelist[0].forEach((element) {
        favPlaceItemList.add(MyHelsinkiEventsItem(
            element['name']['fi'] != null
                ? element['name']['fi']
                : 'Name Unavailable',
            element['location']['lat'],
            element['location']['lon'],
            element['description']['intro'] != null
                ? element['description']['intro']
                : '',
            element['description']['body'] != null
                ? element['description']['body']
                : '',
            element['description']['images'],
            element['info_url'],
            element['location']['address'],
            element['tags'],
            element["id"],
            element['event_dates']['starting_day'] != null
                ? f
                .format(i.parse(element['event_dates']['starting_day']))
                .toString()
                : '',
            element['event_dates']['ending_day'] != null
                ? f
                .format(i.parse(element['event_dates']['ending_day']))
                .toString()
                : '',

            300));
      });
    });
    EasyLoading.dismiss();
    print(favplacelist.length);
  }

  String getDesc(index) {
    String descString = '';

    if (favPlaceItemList[index].desc.length >= 150) {
      descString = favPlaceItemList[index].desc.replaceRange(150, null, '...');
    } else {
      descString = favPlaceItemList[index].desc;
    }
    return descString;
  }

  Future<void> undoRemove(int index) async {
    print("undo");
    setState(() {
      favPlaceItemList.insert(index, deletedItem);
    });
    favoritePlaceList.add(deletedItemID);
    var filtered = favoritePlaceList.toSet().toList();
    print("saving favorites : $filtered");
    var prefs = await SharedPreferences.getInstance();
    List<String> strList = filtered.map((i) => i.toString()).toList();
    prefs.setStringList("favoriteItemList", strList);
  }

  //Get images
  Image getPlacesImage(index) {
    if (favPlaceItemList[index].imageUrlList.length != 0) {
      return Image.network(favPlaceItemList[index].imageUrlList[0]['url']);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    FlashHelper.init(context);
    if (favoritePlaceList.length > 0) {
      return ListView.builder(
        itemCount: favPlaceItemList.length,
        padding: EdgeInsets.only(left: 5.0, right: 5.0),
        itemBuilder: (context, index) {
          tags = getTagsList(index);
          return Card(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            child: ListTile(
              contentPadding: EdgeInsets.all(10.0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsEvents(favPlaceItemList[index])),
                );
              },
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        constraints: BoxConstraints(maxWidth: 280),
                        padding: EdgeInsets.only(
                            top: 10, bottom: 5, left: 5, right: 5),
                        child: Semantics(
                          label: "semantics_title".tr(),
                          child: Text("${favPlaceItemList[index].name}",
                              style: TextStyle(fontSize: 20.0)),
                        )),
                    TextButton(
                        onPressed: () => {
                          deletedItem = favPlaceItemList[index],
                          _removeFavorite(index),
                          FlashHelper.actionBar(context,
                              message: 'favorites_deleted'.tr(),
                              primaryAction:
                                  (context, controller, setState) {
                                return TextButton(
                                    child: Text('favorites_undo'.tr()),
                                    onPressed: () => undoRemove(index));
                              }),
                        },
                        child: Semantics(
                          label: "semantics_hearticon".tr(),
                          hint: "semantics_rheart".tr(),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                        )),
                  ]),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget> [
                  ConstrainedBox(
                    constraints: BoxConstraints(),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
                      child: Semantics(
                          label: "semantics_activityimage".tr(),
                          child: getPlacesImage(index)),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(5),
                      child: Semantics(
                        label: "semantics_description".tr(),
                        child: Text('${getDesc(index)}',
                            style: GoogleFonts.lato(
                                textStyle: TextStyle(fontSize: 13.0))),
                      )),
                  const Divider(
                    height: 20,
                    thickness: 1,
                    color: Colors.black26,
                    endIndent: 5,
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: GridView.builder(
                      itemBuilder: (context, index){
                        return OutlinedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10.0))),
                            ),
                            child: Semantics(
                              label: "semantics_tag".tr(),
                              child: Text(
                                tags[index].toString().toLowerCase(),
                                style: TextStyle(fontSize: 11.0),
                              ),
                            ));
                      },
                      itemCount: tags.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                        childAspectRatio: 4,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    } else {
      return Scaffold(
        body: Center(
          child: Text(
            "favorites_no",
            textAlign: TextAlign.center,
          ).tr(),
        ),
      );
    }
  }
}
