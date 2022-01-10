import 'dart:convert';

import 'package:citizen/Components/SelectableItem.dart';
import 'package:citizen/Components/TagList.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InterestsPage extends StatefulWidget {
  @override
  _InterestsPageState createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final controller = DragSelectGridViewController();
  var listOfAllTags = [];
  Set<int> selectedTags = {};
  Set<int> tagsWithZero = {};
  bool gridHidden;

  @override
  void initState() {
    gridHidden = false;
    listOfAllTags = Taglist().listofTags;
    loadData();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DragSelectGridView(
        gridController: controller,
        padding: const EdgeInsets.all(8),
        itemCount: listOfAllTags.length,
        itemBuilder: (context, index, selected) {
          if (index == listOfAllTags.length - 1) {
            _hideGrid(true);
          } else {
            _hideGrid(false);
          }
          return Offstage(
              offstage: gridHidden,
              child: SelectableItem(
                index: index,
                color: Colors.blue,
                selected: selected,
              ));
        },
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
      ),
    );
  }

  void scheduleRebuild() => setState(() {
        selectedTags = controller.value.selectedIndexes;
        saveData();
      });

  // save sharedpreferences
  Future<void> saveData() async {
    List<String> strList = selectedTags.map((i) => i.toString()).toList();

    var temptag = listOfAllTags.length-1;
    print("removing temp tag # $temptag");

    strList.remove(temptag.toString());
    print("saving tags $strList");
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList("selectedTags", strList);
  }

  // load sharedpreferences
  void loadData() async {
    print("loading data..");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var stringValue = prefs.getStringList('selectedTags');
    List<int> intProductList = stringValue.map((i) => int.parse(i)).toList();
    selectedTags = intProductList.toSet();
    var temptag = listOfAllTags.length-1;

    selectedTags.add(temptag);

    print("adding temp tag # $temptag");

    controller.value = Selection(selectedTags);
  }

  // clean sharedpreferences
  Future<void> annulateData() async {
    selectedTags = {};
    List<String> strList = selectedTags.map((i) => i.toString()).toList();
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList("selectedTags", strList);
  }
}
