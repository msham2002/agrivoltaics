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
          scrollDirection: Axis.vertical, // Set scroll direction to vertical 
          child: Padding(
            padding: const EdgeInsets.all(65.0), // Add padding for blank space on the right to embrace touch capatability
            child: Column(
              children: [
                TimezoneDropdown(),
                const SizedBox(height: 16.0),
                ToggleButtonGroup(),
                const SizedBox(height: 16.0),
                ToggleButton(),
                const SizedBox(height: 16.0),
                Setting(),
              ],
            ),
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

class ToggleButtonGroup extends StatelessWidget {
  ToggleButtonGroup({super.key});
  late AppState appState;
  late int _selectedIndex;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    if (appState.returnDataValue == 'min') {
      _selectedIndex = 0;
    } else if (appState.returnDataValue == 'max') {
      _selectedIndex = 1;
    } else if (appState.returnDataValue == 'mean') {
     _selectedIndex = 2;
    }
    
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          const Text(
            'Return Data Filter',
          ),
          const SizedBox(height: 10),
          Center(
            child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ToggleButtonSingleSelect(
                  index: 0,
                  selectedIndex: _selectedIndex,
                  onPressed: _handleButtonPressed,
                  name: 'Min',
                ),
                ToggleButtonSingleSelect(
                  index: 1,
                  selectedIndex: _selectedIndex,
                  onPressed: _handleButtonPressed,
                  name: 'Max',
                ),
                ToggleButtonSingleSelect(
                  index: 2,
                  selectedIndex: _selectedIndex,
                  onPressed: _handleButtonPressed,
                  name: 'Mean',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleButtonPressed(int index, AppState appState) {
      if (index == 0) {
        appState.returnDataValue = 'min';
      } else if (index == 1) {
        appState.returnDataValue = 'max';
      } else if (index == 2) {
        appState.returnDataValue = 'mean';
      }

      appState.finalizeState();
  }
}

class ToggleButtonSingleSelect extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final Function(int, AppState) onPressed;
  final String name;

  ToggleButtonSingleSelect({super.key, 
    required this.index,
    required this.selectedIndex,
    required this.onPressed,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final bool isSelected = index == selectedIndex;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      
      child: ElevatedButton(
        onPressed: () => onPressed(index, appState),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
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
    TextEditingController _SiteNameEditingController = TextEditingController();
    TextEditingController _ZoneNameEditingController = TextEditingController();
    String siteName;
    String zoneName;

    void renameSite(int siteIndex) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String newName = context.read<AppState>().sites[siteIndex].nickName;
         _SiteNameEditingController.text = newName;
          return AlertDialog(
            title: const Text('Rename Site'),
            content: TextField(
              controller: _SiteNameEditingController,
              onChanged: (value) {
                newName = value;
              },
              decoration: const InputDecoration(
                labelText: 'New Name',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                    context.read<AppState>().sites[siteIndex].nickName = newName;
                    context.read<AppState>().finalizeState();
                  Navigator.of(context).pop();
                },
                child: const Text('Rename'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }

    void renameZone(int siteIndex, int zoneIndex) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String newName = context.read<AppState>().sites[siteIndex].zones[zoneIndex].nickName;
          _ZoneNameEditingController.text = newName;

          return AlertDialog(
            title: const Text('Rename Zone'),
            content: TextField(
              controller: _ZoneNameEditingController,
              onChanged: (value) {
                newName = value;
              },
              decoration: const InputDecoration(
                labelText: 'New Name',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                    context.read<AppState>().sites[siteIndex].zones[zoneIndex].nickName = newName;
                    context.read<AppState>().finalizeState();
                  Navigator.of(context).pop();
                },
                child: const Text('Rename'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }

    return Container(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: context.read<AppState>().sites.length,
            itemBuilder: (BuildContext context, int siteIndex) {
              Site site = context.read<AppState>().sites[siteIndex];
            if (site.nickName == '') {
              siteName = site.name;
            } else {
              siteName = '(${site.name}) ${site.nickName}';
            }
              return Card(
                elevation: 0.0,
                
                child: Column(
                  
                  children: [
                    
                    ListTile(
                      title: Text(
                        siteName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      leading: Checkbox(
                        value: site.checked,
                        onChanged: (_) => context.read<AppState>().toggleSiteChecked(siteIndex),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),  // Adjusted padding here
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => renameSite(siteIndex),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),  // Adjusted padding here
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => context.read<AppState>().removeSite(siteIndex),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: site.zones.length,
                      itemBuilder: (BuildContext context, int zoneIndex) {
                        Zone zone = site.zones[zoneIndex];
                        if (zone.nickName == '') {
                          zoneName = zone.name;
                        } else {
                          zoneName = '(${zone.name}) ${zone.nickName}';
                        }
                        
                        return ListTile(
                          title: Text(zoneName),
                          leading: Checkbox(
                            value: zone.checked,
                            onChanged: (_) => context.read<AppState>().toggleZoneChecked(siteIndex, zoneIndex),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),  // Adjusted padding here
                                child: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => renameZone(siteIndex, zoneIndex),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),  // Adjusted padding here
                                child: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => context.read<AppState>().removeZone(siteIndex, zoneIndex),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Wrap(
                            spacing: 8.0,
                            children: measurementNames.entries.map((entry) {
                              SensorMeasurement measurement = entry.key;
                              String name = entry.value;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FilterChip(
                                    label: Text(name),
                                    onSelected: (_) =>
                                        context.read<AppState>().toggleMeasurementChecked(siteIndex, zoneIndex, measurement),
                                    selected: zone.fields[measurement]!,
                                  ),
                                  SizedBox(height: 16.0), // controls spacing between settings buttons when resizing settings page
                                ],
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust the alignment as needed
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: context.read<AppState>().addSite,
                    child: const Text('Add Site'),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    toggleAllSensors(context.read<AppState>(), true);
                  },
                  child: const Text('Sensors On'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    toggleAllSensors(context.read<AppState>(), false);
                  },
                  child: const Text('Sensors Off'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AppState>().updateSettingsInDB();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardPage(),
                        maintainState: false,
                      ),
                    );
                  },
                  child: const Text('Save & View'),
                ),
              ),
            ],
          ),
        ),
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