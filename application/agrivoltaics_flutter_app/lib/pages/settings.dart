import 'package:agrivoltaics_flutter_app/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Setting()
          ],
        ),
      ),
    );
  }
}

class Setting extends StatefulWidget {
  const Setting({
    super.key,
  });

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    Map<String, tz.Location> locations = tz.timeZoneDatabase.locations;
    tz.Location dropdownValue = appState.timezone;

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Timezone:'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton(
              items: [
                for (var location in locations.values)...[
                  DropdownMenuItem(
                    value: location,
                    child: Text(location.toString())
                  )
                ]
              ],
              onChanged: (value) {
                appState.timezone = value!;
                setState(() {
                  dropdownValue = value;
                });
              },
              value: dropdownValue
            )
          )
        ],
      ),
    );
  }
}