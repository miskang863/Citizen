
import 'package:citizen/Models/MyHelsinkiPlacesItem.dart';
import 'package:citizen/Services/MyHelsinkiPlaces.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citizen/Services//flash_helper.dart';
import '../Services/MyHelsinkiPlaces.dart';
import 'package:easy_localization/easy_localization.dart';

import 'DetailsPage.dart';


class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List favPlaceItemList = [];
  List<int> favoritePlaceList = [];
  MyHelsinkiPlacesItem deletedItem;
  int deletedItemID;
  bool isConnected = false;
  var tags = [];
  List<String> planList = [];
  var removePindex;
  @override
  void initState() {
    _loadFavPlaces();
    _loadPlan();
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
    var result = prefs.getStringList('favoriteList');
    if (result.length > 0) {
      EasyLoading.show(status: 'easyloading_loading'.tr());
      print("favorites id t:: $result");
      favoritePlaceList = result.map((i) => int.parse(i)).toList();
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
    prefs.setStringList("favoriteList", strList);
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
    List favplacelist = await MyHelsinkiPlaces().getFavoritePlaces(favlist);
    setState(() {
      favplacelist[0].forEach((element) {
        favPlaceItemList.add(MyHelsinkiPlacesItem(
          element['name']['fi'],
          element['location']['lat'],
          element['location']['lon'],
          element['description']['body'],
          element['description']['images'],
          element['info_url'],
          element['location']['address'],
          element['tags'],
          element['opening_hours']['hours'],
          300,
          element['id'],
        ));
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
    prefs.setStringList("favoriteList", strList);
  }

  Future<void> _loadPlan() async {
    print("Loading plan..");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getStringList('planList');
    if (result != null) {
      planList = result;
      print("Plan:: $planList");
    }
  }

  Future<void> _saveToPlan(String id) async {
    await _loadPlan();
    setState(() {
      planList.add(id);
    });
    var filtered = planList.toSet().toList();
    print("saving plan : $filtered");
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList('planList', filtered);
  }

  // remove from plan
  Future<void> _removeFromPlan(int ind) async {
    setState(() {
      planList.removeAt(ind);
    });
    var filtered = planList.toSet().toList();
    print("saving plan : $filtered");
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList('planList', filtered);
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
                        builder: (context) => DetailsPage(favPlaceItemList[index])),
                  );
                },
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          constraints: BoxConstraints(maxWidth: 260),
                          padding: EdgeInsets.only(
                              top: 10, bottom: 5, left: 5, right: 5),
                          child: Semantics(
                            label: "semantics_title".tr(),
                            child: Text("${favPlaceItemList[index].name}",
                                style: TextStyle(fontSize: 20.0)),
                          )),
                      Wrap(
                          spacing: -10.0,
                          children: <Widget> [
                            TextButton(
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size(10, 10)),
                              onPressed: () {
                                if (planList.contains(favPlaceItemList[index].itemID)) {
                                  // remove form planlist
                                  planList.forEach((element) {
                                    if (element == favPlaceItemList[index].itemID) {
                                      removePindex = planList.indexOf(element);
                                      print(removePindex);
                                    }
                                  });
                                  _removeFromPlan(removePindex);
                                  FlashHelper.actionBar(context,
                                      message: 'planList_delete'.tr(),
                                      primaryAction:
                                          (context, controller, setState) {});
                                } else {
                                  _saveToPlan(favPlaceItemList[index].itemID);
                                  FlashHelper.actionBar(context,
                                      message: 'planList_add'.tr(),
                                      primaryAction:
                                          (context, controller, setState) {});
                                }
                              },
                              child: Semantics(
                                button: true,
                                label: "semantics_plusicon".tr(),
                                hint: "semantics_plus".tr(),
                                child: Icon(
                                  planList
                                      .contains(favPlaceItemList[index].itemID)
                                      ? Icons.check_circle_rounded
                                      : Icons.add_circle_outline_rounded,
                                  color:
                                  planList
                                      .contains(favPlaceItemList[index].itemID)
                                      ? Colors.green
                                      : Colors.blue,
                                ),
                              ),
                            ),
                            TextButton(
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(10, 10)),
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
                          ]
                      )
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
