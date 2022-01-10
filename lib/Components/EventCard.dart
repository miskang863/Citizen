import 'package:citizen/Views/WebViewPage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class EventCard extends StatelessWidget {
  const EventCard({
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
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Card(
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
                constraints: BoxConstraints.tightFor(width: 100.0),
                child: url != ''
                    ? Image.network(
                  url,
                  fit: BoxFit.fitHeight,
                )
                    : Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Icon(Icons.error_outline),
                    )),
            Padding(
              padding: EdgeInsets.only(top:15.0, left: 15.0, right: 15.0),
              child: Text(
                text ?? 'Event',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                      constraints: BoxConstraints.tightFor(width: 250.0),
                      child: Text(
                        header ?? '',
                        style: GoogleFonts.lato(
                            textStyle: TextStyle(fontSize: 15.0)),
                      )),
                  Container(
                      padding: EdgeInsets.only(right: 15.0),
                      child: infoUrl != ''
                          ? new OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    WebViewPage(infoUrl)),
                          );
                        },
                        child: Icon(FontAwesomeIcons.globe),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<
                              RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      )
                          : Text('')),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15.0, bottom: 15, top: 5.0),
              child: Text(
                '$startTime - $endTime',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
