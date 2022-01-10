import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageDialog extends StatefulWidget {
  @override
  LanguageDialogState createState() => LanguageDialogState();
}

class LanguageDialogState extends State<LanguageDialog> {
  static const languages = ["Finnish", "English"];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    //  localizationsDelegates: context.localizationDelegates,

      locale: context.locale,

      home:Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 200,
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(15),
                //   color: Theme.of(context).backgroundColor,
                // ),
                child: GridView.count(
                  physics: new NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        print("Language:: Eng");
                        context.locale = Locale('en', 'UK');
                        Navigator.pop(context);
                      },
                      child: Semantics(
                        label: 'semantics_engflag'.tr(),
                        hint: 'semantics_enghint'.tr(),
                        child: Image(
                            image: AssetImage(
                                'Assets/Pictures/18166.jpg'
                            )
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("Language:: Fin");
                        context.locale = Locale('fi', 'FI');
                        Navigator.pop(context);
                      },
                      child: Semantics(
                          label: 'semantics_fiflag'.tr(),
                          hint: 'semantics_fihint'.tr(),
                        child: Image(
                            image: AssetImage(
                                'Assets/Pictures/27108.jpg'
                            )
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
      ) ,
    );

  }
}
