import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'LoginPage.dart';
import 'RegisterPage.dart';

class AuthView extends StatelessWidget{
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
                    child: Tab(text: 'login_login'.tr())),
                Semantics(
                    label: 'semantics_tab'.tr(),
                    child: Tab(text: 'login_register'.tr())),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [LoginPage(), RegisterView()],
        ),
      ),
    );
  }

}