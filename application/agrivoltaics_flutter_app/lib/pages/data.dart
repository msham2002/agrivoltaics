// import 'package:easy_web_view/easy_web_view.dart' as EasyWebView;
import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io' show Platform;

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DataDashboard extends StatefulWidget {
  const DataDashboard({super.key});

  @override
  State<DataDashboard> createState() => _DataDashboardState();
}

class _DataDashboardState extends State<DataDashboard> {
  // late final WebViewController _controller;
  String embedPath = '<iframe src="https://10.0.2.2:3000/dashboard-solo/new?gettingstarted&orgId=1&panelId=2" width=100% height=100% frameborder="0"></iframe>';
  // @override
  // void initState() {
  //   super.initState();
  //   controller = WebViewController()..loadRequest(Uri('google.com'))
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(

          // DO NORMAL WEBVIEW FOR IOS AND ANDROID

          // child: (Platform.isIOS || Platform.isAndroid)
          //     ? WebView(
          //         initialUrl: Uri.dataFromString(embedPath, mimeType: 'text/html').toString(),
          //         javascriptMode: JavascriptMode.unrestricted,
          //         onWebViewCreated: (WebViewController controller) {
          //           _controller = controller;
          //         })
          //     : EasyWebView.EasyWebView(
          //         src:
          //             'https://play.grafana.org/d/000000016/1-time-series-graphs?orgId=1&viewPanel=1')),

          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: Uri.dataFromString(embedPath, mimeType: 'text/html')
            ),
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              print(challenge);
              return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
            },
          )


      )
    );
  }
}
