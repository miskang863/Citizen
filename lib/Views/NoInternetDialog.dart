import 'package:flutter/material.dart';

class InternetDialog extends StatefulWidget {
  @override
  InternetDialogState createState() => InternetDialogState();
}

class InternetDialogState extends State<InternetDialog> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 200,

              ),
            ],
          )
      ) ,
    );
  }
}