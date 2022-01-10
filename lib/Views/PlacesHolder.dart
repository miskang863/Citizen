import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'EventsPage.dart';
import 'PlacesPage.dart';
import 'PlanPage.dart';

class PlacesHolder extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: 'places_places'.tr()),
                Tab(text: 'places_events'.tr()),
                Tab(text: 'places_plan'.tr()),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [PlacesPage(), EventsPage(), PlanPage()],
        ),
      ),
    );
  }
}