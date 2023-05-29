import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

import '../app_constants.dart';
import '../app_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TimezoneDropdown(),
              const SizedBox(height: 16.0),
              ToggleButton(),
              const SizedBox(height: 16.0),
              Setting(),
            ],
          ),
        ),
      ),
    );
  }
}

class TimezoneDropdown extends StatelessWidget {
  TimezoneDropdown({super.key});
  late AppState appState;
  late tz.Location dropdownValue;

  @override
  Widget build(BuildContext context) {
    Map<String, tz.Location> locations = tz.timeZoneDatabase.locations;
    dropdownValue = context.read<AppState>().timezone;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Timezone:'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<tz.Location>(
            items: locations.values.map((location) {
              return DropdownMenuItem<tz.Location>(
                value: location,
                child: Text(location.toString()),
              );
            }).toList(),
            onChanged: (value) {
              appState.timezone = value!;
                dropdownValue = value;
                appState.finalizeState();
            },
            value: dropdownValue,
          ),
        ),
      ],
    );
  }
}

class ToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Single Graph:'),
        Switch(
          value: appState.singleGraphToggle,
          onChanged: (newValue) {
            appState.setSingleGraphToggle(newValue);
          },
        ),
      ],
    );
  }
}

class Setting extends StatelessWidget {
  const Setting({super.key});

  

  // void renameSite(int siteIndex) {
  //   final TextEditingController controller = TextEditingController(
  //     text: appState.sites[siteIndex].name,
  //   );

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Rename Site'),
  //         content: TextField(
  //           controller: controller,
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Save'),
  //             onPressed: () {
  //               setState(() {
  //                 appState.sites[siteIndex].name = controller.text;
  //                 appState.notifyListeners();
  //               });
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void renameZone(int siteIndex, int zoneIndex) {
  //   final TextEditingController controller = TextEditingController(
  //     text: .sites[siteIndex].zones[zoneIndex].name,
  //   );

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Rename Zone'),
  //         content: TextField(
  //           controller: controller,
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Save'),
  //             onPressed: () {
  //               setState(() {
  //                 context .sites[siteIndex].zones[zoneIndex].name = controller.text;
  //                 appState.notifyListeners();
  //               });
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    Map<SensorMeasurement, String> measurementNames = {
      SensorMeasurement.humidity: 'Humidity',
      SensorMeasurement.temperature: 'Temperature',
      SensorMeasurement.light: 'Light',
      SensorMeasurement.rain: 'Rain',
      SensorMeasurement.frost: 'Frost',
      SensorMeasurement.soil: 'Soil',
    };

    

    return Container(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: context.read<AppState>().sites.length,
            itemBuilder: (BuildContext context, int siteIndex) {
              Site site = context.read<AppState>().sites[siteIndex];

              return Card(
                elevation: 0.0,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        site.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      leading: Checkbox(
                        value: site.checked,
                        onChanged: (_) => context.read<AppState>().toggleSiteChecked(siteIndex),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => context.read<AppState>().removeSite(siteIndex),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: site.zones.length,
                      itemBuilder: (BuildContext context, int zoneIndex) {
                        Zone zone = site.zones[zoneIndex];

                        return ListTile(
                          title: Text(zone.name),
                          leading: Checkbox(
                            value: zone.checked,
                            onChanged: (_) => context.read<AppState>().toggleZoneChecked(siteIndex, zoneIndex),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => context.read<AppState>().removeZone(siteIndex, zoneIndex),
                              ),
                            ],
                          ),
                          subtitle: Wrap(
                            spacing: 8.0,
                            children: measurementNames.entries.map((entry) {
                              SensorMeasurement measurement = entry.key;
                              String name = entry.value;

                              return FilterChip(
                                label: Text(name),
                                onSelected: (_) =>
                                    context.read<AppState>().toggleMeasurementChecked(siteIndex, zoneIndex, measurement),
                                selected: zone.fields[measurement]!,
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Add Zone'),
                      onTap: () => context.read<AppState>().addZone(siteIndex),
                    ),
                  ],
                ),
              );
            },
          ),
          ElevatedButton(
            child: const Text('Add Site'),
            onPressed: context.read<AppState>().addSite,
          ),
        ],
      ),
    );
  }
}