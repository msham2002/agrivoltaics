// import 'package:agrivoltaics_flutter_app/app_constants.dart';
// import 'package:agrivoltaics_flutter_app/pages/dashboard/dashboard.dart';
// import 'package:agrivoltaics_flutter_app/pages/sensors.dart';
// import 'package:flutter/material.dart';

// class SitesPage extends StatelessWidget {
//   SitesPage({super.key, required this.destination});
//   SiteRoute destination;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             // crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               for (int site = 1; site <= AppConstants.numSites; site++)...[
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ElevatedButton(
//                     child: Text('Site ${site}'),
//                     onPressed: () => {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                               this.destination == SiteRoute.dashboard ? DashboardPage(site: site)
//                               : SensorsPage(site: site)
//                           )
//                         )
//                     },
//                   ),
//                 )
//               ]
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }