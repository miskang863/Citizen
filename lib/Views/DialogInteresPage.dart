import 'package:citizen/Services/ThemeManager.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Components/SelectableItem.dart';
import '../Components/TagList.dart';
import 'package:easy_localization/easy_localization.dart';

class DialogInterestPage extends StatefulWidget {
  @override
  DialogInterestPageState createState() => DialogInterestPageState();
}

class DialogInterestPageState extends State<DialogInterestPage> {
  final controller = DragSelectGridViewController();
  var listOfAllTags = [];
  Set<int> selectedTags = {};
  Set<int> tagsWithZero = {};
  bool gridHidden;
  List<String> rangeValues = [];
  bool isDarkModeEnabled;

  RangeValues _currentRangeValues = const RangeValues(15, 30);

  @override
  void initState() {
    gridHidden = false;
    listOfAllTags = Taglist().listofTags;
    loadSelectedTags();
    super.initState();
    loadRangeValues();
    controller.addListener(scheduleRebuild);
  }

  @override
  void dispose() {
    controller.removeListener(scheduleRebuild);
    super.dispose();
  }

  // hides grid
  void _hideGrid(bool isHidden) {
    gridHidden = isHidden;
  }

  void scheduleRebuild() => setState(() {
        selectedTags = controller.value.selectedIndexes;
        saveSelectedTags();
      });
  // save sharedpreferences
  Future<void> saveSelectedTags() async {
    List<String> strList = selectedTags.map((i) => i.toString()).toList();
    var temptag = listOfAllTags.length - 1;
    print("removing temp tag # $temptag");
    strList.remove(temptag.toString());
    print("saving tags $strList");
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList("selectedTags", strList);
  }

  // load sharedpreferences
  void loadSelectedTags() async {
    print("loading data..");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var stringValue = prefs.getStringList('selectedTags');
    if (stringValue != null) {
      List<int> intProductList = stringValue.map((i) => int.parse(i)).toList();
      selectedTags = intProductList.toSet();
    }
    var temptag = listOfAllTags.length - 1;

    selectedTags.add(temptag);

    print("adding temp tag # $temptag");

    controller.value = Selection(selectedTags);
  }

  Future<void> saveRangeValues() async {
    rangeValues = [
      _currentRangeValues.start.toString(),
      _currentRangeValues.end.toString()
    ];
    print("saving range values");

    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList("rangevalues", rangeValues);
  }

  Future<void> loadRangeValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var range = prefs.getStringList('rangevalues');

    if (range != null) {
      _currentRangeValues =
          RangeValues(double.parse(range[0]), double.parse(range[1]));
    } else {
      _currentRangeValues = RangeValues(1.0, 100.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    isDarkModeEnabled = (themeNotifier.getTheme() == darkTheme);

    return Dialog(
      elevation: 0,
      child: contentBox(context),
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0)),
    );
  }

  contentBox(context) {
    return Column(
      children: <Widget>[
        Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Semantics(
                  label: "semantics_time".tr(),
                  child: RichText(
                    text: TextSpan(
                      text: "dialogue_one".tr(),
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                      text: "${_currentRangeValues.start.round().toString()}",
                      children: <TextSpan>[
                        TextSpan(
                          text: "dialogue_and".tr(),
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Theme.of(context).accentColor),
                        ),
                        TextSpan(
                            text:
                                "${_currentRangeValues.end.round().toString()}",
                            style:
                                TextStyle(color: Colors.blue, fontSize: 20.0)),
                      ],
                      style: TextStyle(color: Colors.blue, fontSize: 18)),
                ),
                Semantics(
                  hint: "semantics_timehint".tr(),
                  child: RichText(
                    text: TextSpan(
                      text: "dialogue_minutes".tr(),
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    rangeValueIndicatorShape:
                        PaddleRangeSliderValueIndicatorShape(),
                    activeTrackColor: Colors.blue[700],
                    inactiveTrackColor: Colors.blue[100],
                    trackShape: RoundedRectSliderTrackShape(),
                    trackHeight: 5.0,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 30.0),
                    thumbColor: Colors.blueAccent,
                    overlayColor: Colors.blue.withAlpha(32),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 30.0),
                    tickMarkShape: RoundSliderTickMarkShape(),
                    activeTickMarkColor: Colors.blue[700],
                    inactiveTickMarkColor: Colors.blue[100],
                    valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                    valueIndicatorColor: Colors.blueAccent,
                    valueIndicatorTextStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  child: RangeSlider(
                    min: 0,
                    max: 120,
                    divisions: 6,
                    labels: RangeLabels(
                      _currentRangeValues.start.round().toString(),
                      _currentRangeValues.end.round().toString(),
                    ),
                    values: _currentRangeValues,
                    onChanged: (RangeValues values) {
                      setState(() {
                        _currentRangeValues = values;
                        saveRangeValues();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        new Expanded(
          child: DragSelectGridView(
            shrinkWrap: true,
            gridController: controller,
            padding: const EdgeInsets.all(8),
            itemCount: listOfAllTags.length,
            itemBuilder: (context, index, selected) {
              if (index == listOfAllTags.length - 1) {
                _hideGrid(true);
              } else {
                _hideGrid(false);
              }
              return Semantics(
                button: true,
                label: "semantics_category".tr(),
                hint: "semantics_categoryhint".tr(),
                child: Offstage(
                    offstage: gridHidden,
                    child: Semantics(
                      label: "semantics_selected".tr(),
                      selected: true,
                      child: SelectableItem(
                        index: index,
                        color: Colors.blue,
                        selected: selected,
                      ),
                    )),
              );
            },
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 100,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
          ),
        ),
        Padding(
          // Close
          padding:
              const EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 20),
          child: Container(
            alignment: Alignment.bottomRight,
            height: 40,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  primary: isDarkModeEnabled
                      ? Colors.deepOrange[900].withOpacity(0.9)
                      : Colors.orangeAccent,
                  onPrimary: Colors.white,
                  // foreground
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Semantics(
                      button: true,
                      label: "semantics_button".tr(),
                      hint: "semantics_closethint".tr(),
                      child: Text(
                        'dialogue_close'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          //fontWeight: FontWeight.w700,
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
    );
  }
}
