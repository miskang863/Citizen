import 'package:citizen/Models/MyHelsinkiPlacesItem.dart';
import 'package:citizen/Services/MyHelsinkiPlaces.dart';
import 'package:citizen/Services/ThemeManager.dart';
import 'package:citizen/Views/DetailsPage.dart';
import 'package:citizen/Views/RoutePagePlan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citizen/Services//flash_helper.dart';
import '../Services/MyHelsinkiPlaces.dart';
import 'package:easy_localization/easy_localization.dart';

class PlanPage extends StatefulWidget {
  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  List<MyHelsinkiPlacesItem> planItemList = [];
  List<int> planPlaceList = [];
  MyHelsinkiPlacesItem deletedItem;
  int deletedItemID;
  bool isDarkModeEnabled;

  @override
  void initState() {
    _loadPlan();
    super.initState();
  }

  @override
  void dispose() {
    FlashHelper.dispose();
    super.dispose();
  }

  // Remove plan item
  Future<void> _removePlan(int index) async {
    setState(() {
      print("index :: $index");
      deletedItemID = planPlaceList[index];
      planItemList.removeAt(index);
      planPlaceList.removeAt(index);
    });
    var filtered = planPlaceList.toSet().toList();
    print("saving plan : $filtered");
    var prefs = await SharedPreferences.getInstance();
    List<String> strList = filtered.map((i) => i.toString()).toList();
    prefs.setStringList("planList", strList);
  }

  // Load favorite places' id
  Future<void> _loadPlan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getStringList('planList');
    print("plan result: $result");
    if (result.isNotEmpty) {
      EasyLoading.show(status: 'easyloading_loading'.tr());
      planPlaceList = result.map((i) => int.parse(i)).toList();
      _getPlanPlaces(planPlaceList);
    }
  }

  // Load favorite places items
  void _getPlanPlaces(plist) async {
    List planPlacelist = await MyHelsinkiPlaces().getFavoritePlaces(plist);
    setState(() {
      planPlacelist[0].forEach((place) {
        planItemList.add(MyHelsinkiPlacesItem(
          place['name']['fi'],
          place['location']['lat'],
          place['location']['lon'],
          place['description']['body'],
          place['description']['images'],
          place['info_url'],
          place['location']['address'],
          place['tags'],
          place['opening_hours']['hours'],
          0,
          place['id'],
        ));
      });
    });
    EasyLoading.dismiss();
    print(planPlaceList.length);
  }

  Future<void> undoRemove(int index) async {
    print("undo");
    setState(() {
      planItemList.insert(index, deletedItem);
    });
    planPlaceList.add(deletedItemID);
    var filtered = planPlaceList.toSet().toList();
    print("saving plan : $filtered");
    var prefs = await SharedPreferences.getInstance();
    List<String> strList = filtered.map((i) => i.toString()).toList();
    prefs.setStringList("planList", strList);
  }

  //Get images
  String getPlacesImage(index) {
    if (planItemList[index].imageUrlList.length != 0) {
      return (planItemList[index].imageUrlList[0]['url']);
    } else {
      return 'https://images.pexels.com/photos/2292953/pexels-photo-2292953.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=750&w=1260';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    isDarkModeEnabled = (themeNotifier.getTheme() == darkTheme);

    if (planPlaceList.length > 0) {
      return Container(
          child: Column(children: <Widget>[
        Align(
            alignment: Alignment.topRight,
            child: Padding(
                padding: EdgeInsets.only(bottom: 3, right: 10.0, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('routes_current',
                              style: TextStyle(fontSize: 20.0))
                          .tr(),
                    ),
                    Container(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          primary: isDarkModeEnabled
                              ? Colors.deepOrangeAccent.withOpacity(0.8)
                              : Colors.orangeAccent,
                          onPrimary: Colors.white,
                          // foreground
                        ),
                        onPressed: () {
                          print('List : $planItemList');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RoutePagePlan(objectList: planItemList),
                            ),
                          );
                        },
                        child: Semantics(
                          label: "semantics_button".tr(),
                          hint: "semantics_go".tr(),
                          child: Text(
                            'plan_go'.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              //fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ))),
        Expanded(
            child: ListView.builder(
          itemCount: planItemList.length,
          padding: EdgeInsets.only(left: 5.0, right: 5.0),
          itemBuilder: (context, index) {
            return Card(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              child: ListTile(
                leading: Semantics(
                  image: true,
                  label: "semantics_activityimage".tr(),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(getPlacesImage(index)),
                    radius: 35,
                  ),
                ),
                contentPadding: EdgeInsets.all(10.0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailsPage(planItemList[index])),
                  );
                },
                title: Padding(
                    padding:
                        EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Semantics(
                                label: "semantics_plan".tr(),
                                child: Text('${(index + 1).toString()}.  ',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w300)),
                              )),
                          Expanded(
                            child: Container(
                                constraints: BoxConstraints(maxWidth: 250),
                                child: Text(
                                  '${planItemList[index].name}',
                                  style: TextStyle(fontSize: 18.0),
                                  textAlign: TextAlign.start,
                                )),
                          ),
                        ])),
                trailing: IconButton(
                  icon: Semantics(
                    label: "semantics_remove".tr(),
                    hint: "semantics_removehint".tr(),
                    child: Icon(
                      Icons.remove_circle_outline_rounded,
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      //planItemList.remove(planItemList[index]);
                      _removePlan(index);
                    });
                  },
                ),
              ),
            );
          },
        ))
      ]));
    } else {
      return Container(
        padding: EdgeInsets.only(top: 80),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: [
            TextSpan(
                text: 'places_empty'.tr(),
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.grey,
                    fontFamily: 'JosefinSans')),
            WidgetSpan(
              child: Icon(Icons.add_circle_outline_rounded,
                  size: 32, color: Colors.grey.shade700),
            ),
            TextSpan(
                text: 'places_empty2'.tr(),
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.grey,
                    fontFamily: 'JosefinSans')),
          ]),
        ),
      );
    }
  }
}
