import 'dart:convert';
import 'dart:html';

import 'package:agrivoltaics_flutter_app/pages/home/notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

import '../app_constants.dart';
import '../app_state.dart';
import 'dashboard/dashboard.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
        context.read<AppState>().updateSettingsInDB();
        Navigator.pop(context);
      },
    ),
  ),
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
                  dropdownValue = value;
                  appState.finalizeState();
              },
              value: dropdownValue
            )
          )
        ],
      ),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0), 
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: context.read<AppState>().addSite,
                      child: const Text('Add Site'),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    toggleAllSensors(context.read<AppState>(), true);
                  },
                  child: const Text('Sensors On'),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    toggleAllSensors(context.read<AppState>(), false);
                  },
                  child: const Text('Sensors Off'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<AppState>().updateSettingsInDB();
                    Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                              DashboardPage(), 
                              maintainState: false // This allows the graph to update after adjusting date and time interval
                      )
                    ); 
                  },
                  child: const Text('View Data'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

void toggleAllSensors(AppState appState, bool toggleOn) {
  for (int i = 0; i < appState.sites.length; i++) {
    for (int j = 0; j < appState.sites[i].zones.length; j++) {
      appState.sites[i].zones[j].fields[SensorMeasurement.humidity] = toggleOn;
      appState.sites[i].zones[j].fields[SensorMeasurement.frost] = toggleOn;
      appState.sites[i].zones[j].fields[SensorMeasurement.light] = toggleOn;
      appState.sites[i].zones[j].fields[SensorMeasurement.rain] = toggleOn;
      appState.sites[i].zones[j].fields[SensorMeasurement.soil] = toggleOn;
      appState.sites[i].zones[j].fields[SensorMeasurement.temperature] = toggleOn;
    }
  }
  appState.finalizeState();
}