import 'package:flutter/material.dart';
// import 'dart:io' show Platform;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DataDashboard extends StatefulWidget {
  const DataDashboard({super.key});

  @override
  State<DataDashboard> createState() => _DataDashboardState();
}

class _DataDashboardState extends State<DataDashboard> {
  // localhost = 10.0.2.2 on Android (don't need to check for iOS since we are using localhost for dev purposes)
  // width=100%, height=100%
  String embedPath =
    '<iframe src="https://10.0.2.2:3000/d-solo/iTY2S2JVz/new-dashboard?orgId=1&theme=dark&panelId=2" width=100% height=100% frameborder="0"></iframe>';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: OrientationBuilder(builder: (context, orientation) {
        return Center(
          // TODO: Log into Grafana via headless webview, then persist session into headful webview

          child: InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.dataFromString(embedPath, mimeType: 'text/html')),
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
            },
          )
        );
      })
    );
  }
}
