import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';


class WebViewPage extends StatefulWidget {
  final url;
  WebViewPage(this.url);

  @override
  WebViewPageState createState() => WebViewPageState(url);
}

class WebViewPageState extends State<WebViewPage> {
  final url;
  var isLoading = true;
  WebViewPageState(this.url);

  @override
  void initState() {
    super.initState();
    if (isLoading) EasyLoading.show(status: 'Loading');
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              EasyLoading.dismiss();
              Navigator.of(context).pop();
            }),
        title: Semantics(
            label: 'semantics_title'.tr(),
            child: Text('drawer_myKuopio').tr()),
      ),
      body: Container(
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: url,
          onPageFinished: (finish) {
            setState(() {
              isLoading = false;
              EasyLoading.showSuccess('');
              EasyLoading.dismiss();
            });
          },
        ),
      ),
    );
  }
}
