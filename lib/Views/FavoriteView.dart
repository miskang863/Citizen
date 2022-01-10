import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';


import 'FavEventPage.dart';
import 'FavoritesPage.dart';

class FavoriteView extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            bottom: TabBar(
              tabs: [
                Semantics(
                    label: 'semantics_tab'.tr(),
                    child: Tab(text: 'places_places'.tr())),
                Semantics(
                    label: 'semantics_tab'.tr(),
                    child: Tab(text: 'places_events'.tr())),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [FavoritesPage(), FavoritesEventPage()],
        ),
      ),
    );
  }
}