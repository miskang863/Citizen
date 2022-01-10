import 'package:citizen/Models/SpecialOfferItem.dart';
import 'package:citizen/Views/RoutePage.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';


class SpecialOfferCard extends StatelessWidget {
  const SpecialOfferCard({
    Key key,
    @required this.text,
    @required this.imageUrlList,
    @required this.infoUrl,
    @required this.startTime,
    @required this.endTime,
    @required this.header,
    @required this.lat,
    @required this.lon,
    @required this.tag,
    @required this.address,
    this.press,
  }) : super(key: key);

  final String text;
  final List imageUrlList;
  final String startTime;
  final String endTime;
  final String header;
  final String infoUrl;
  final double lat;
  final double lon;
  final int tag;
  final address;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    var item = SpecialOfferItem(text, imageUrlList, infoUrl, startTime, endTime,
        header, lat, lon, tag, address);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(
          children: [
            Semantics(
              //label: 'semantics_offerimage'.tr(),
              image: true,
              child: Ink.image(
                  image: NetworkImage(imageUrlList[0]['url']),
                  height: 140,
                  fit: BoxFit.cover),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              left: 16,
              child: Semantics(
                label: 'semantics_offerplace'.tr(),
                child: Text(
                  header ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrangeAccent,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(left: 10.0, top: 8.0),
            child: Semantics(
              label: "homepage_offer".tr(),
              child: AutoSizeText(
                text ?? 'homepage_offer'.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 10.0),
                child: Semantics(
                  label: "semantics_offerdate".tr(),
                  child: AutoSizeText(
                    '$startTime - $endTime',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                    maxLines: 1,
                    minFontSize: 0,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutePage(activityObject: item),
                    ),
                  );
                },
                child: Semantics(
                    button: true,
                    label: 'semantics_button'.tr(),
                    hint: 'semantics_offerhint'.tr(),
                    child: Text('homepage_offergo', style: TextStyle(color: Colors.blue),).tr()),
              )
            ]),
      ]),
    );
  }
}
