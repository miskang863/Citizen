import 'dart:async';

import 'package:citizen/Components/LimitationsList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:citizen/Components/CardItem.dart';
import 'package:citizen/Components/StackContainer.dart';
import 'LanguageDialog.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool deleteEnabled = false;
  List<String> selectedLimitations = [];

  //bool isDarkModeEnabled = false;

  void deleteAccount() {
    print("not implemented");
  }

  showDeleteDialog(BuildContext context) {
    var textStyle = TextStyle(color: Colors.transparent);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Timer(Duration(seconds: 1), () {
              setState(() {
                textStyle =
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
                deleteEnabled = true;
              });
            });
            return AlertDialog(
              title: Text("alert_askdelete".tr()),
              content: Text("alert_confirmation".tr()),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Semantics(
                      button: true,
                      label: "semantics_button".tr(),
                      hint: "semantics_cancel".tr(),
                      child: Text("alert_cancel".tr())),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      deleteAccount();
                    });
                  },
                  child: Semantics(
                    button: true,
                    label: "semantics_button".tr(),
                    hint: "semantics_deleteacc".tr(),
                    child: Text(
                      "alert_delete".tr(),
                      style: textStyle,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void selectLimitation(String limitation) {
    var isSelected = selectedLimitations.contains(limitation);
    setState(() {
      isSelected
          ? selectedLimitations.remove(limitation)
          : selectedLimitations.add(limitation);
      print(isSelected);
    });
  }

  showLimitationsDialog(BuildContext context) {
    List limitationsList = LimitationsList().listOfLimitations;
    Map limitationIcons = LimitationsList().mapOfLimitationIcons;
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                title: Semantics(
                    hint: 'semantics_listlimitations'.tr(),
                    child: Text("settings_limitations".tr())),
                content: Container(
                  height: 180,
                  width: 260,
                  child: ListView(
                    children: limitationsList.map((limitation) {
                      final isSelected =
                          selectedLimitations.contains(limitation);
                      return Semantics(
                        label: 'semantics_checkbox'.tr(),
                        hint: 'semantics_limitationhint'.tr(),
                        checked: false,
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedLimitations.remove(limitation);
                              } else {
                                selectedLimitations.add(limitation);
                              }
                            });
                          },
                          leading: isSelected
                              ? Icon(
                                  limitationIcons[limitation],
                                  color: Colors.blueAccent,
                                )
                              : Icon(limitationIcons[limitation]),
                          title: Text(
                            limitation,
                            style: isSelected
                                ? TextStyle(color: Colors.blueAccent)
                                : TextStyle(color: Colors.grey),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_box_outlined,
                                  color: Colors.greenAccent.shade400)
                              : Icon(Icons.check_box_outline_blank),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                actions: <Widget>[
                  MaterialButton(
                      elevation: 5.0,
                      child: Semantics(
                          button: true,
                          label: "semantics_button".tr(),
                          hint: 'semantics_closehint'.tr(),
                          child: Text('dialogue_close'.tr())),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ]);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          StackContainer(),
          Semantics(
            button: true,
            label: "semantics_button".tr(),
            child: CardItem(
                text: "settings_limitations".tr(),
                icon: "Assets/Icons/options.svg",
                press: () => {showLimitationsDialog(context)}),
          ),
          Semantics(
            button: true,
            label: "semantics_button".tr(),
            child: CardItem(
                text: "settings_language".tr(),
                icon: "Assets/Icons/language.svg",
                press: () => {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return LanguageDialog();
                          })
                    }),
          ),
          Semantics(
            button: true,
            label: "semantics_button".tr(),
            child: CardItem(
                text: "settings_delete".tr(),
                icon: "Assets/Icons/delete.svg",
                press: () => showDeleteDialog(context)),
          ),
        ]),
      ),
    );
  }
}
