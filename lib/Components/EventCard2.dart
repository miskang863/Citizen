import 'package:auto_size_text/auto_size_text.dart';
import 'package:citizen/Views/WebViewPage.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EventCard2 extends StatelessWidget {
  const EventCard2({
    Key key,
    @required this.text,
    @required this.url,
    @required this.infoUrl,
    @required this.startTime,
    @required this.endTime,
    @required this.header,
    this.press,
  }) : super(key: key);

  final String text;
  final String url;
  final String startTime;
  final String endTime;
  final String header;
  final String infoUrl;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'semantics_eventcard'.tr(),
      hint: 'semantics_eventhint'.tr(),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(
            children: [
              Semantics(
                  hint: 'semantics_eventimage'.tr(),
                  image: true,
                  child: Ink.image(image: NetworkImage(url), height: 150, fit: BoxFit.cover)),
              Positioned(
                bottom: 16,
                right: 16,
                left: 16,
                child: Semantics(
                  label: 'semantics_eventplace'.tr(),
                  child: Text(
                    header ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0, bottom: 0.0, top: 8.0),
              child: Semantics(
                label: 'semantics_eventtitle'.tr(),
                child: AutoSizeText(
                  text ?? 'places_event'.tr(),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
              Widget>[
            Container(
              padding: EdgeInsets.only(left: 10.0, bottom: 15, top: 15.0),
              child: Semantics(
                label: 'semantics_date'.tr(),
                child: Text(
                  '$startTime - $endTime',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.only(right: 15.0),
                child: infoUrl != ''
                    ? Semantics(
                  button: true,
                  label: 'semantics_button'.tr(),
                      hint: 'semantics_websitehint'.tr(),
                      child: new OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewPage(infoUrl)),
                            );
                          },
                          child: Icon(FontAwesomeIcons.globe),
                          style: ButtonStyle(
                            shape:
                                MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                    )
                    : Text(''))
          ])
        ]),
      ),
    );
  }
}
