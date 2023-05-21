import 'package:agrivoltaics_flutter_app/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Setting(),
            ],
          ),
        ),
      ),
    );
  }
}

class Setting extends StatefulWidget {
  const Setting({
    Key? key,
  });

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late AppState appState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appState = context.watch<AppState>();
  }

  void addSite() {
    setState(() {
      appState.sites.add(
        Site(name: 'Site ${appState.sites.length + 1}', zones: [], checked: true),
      );
      appState.finalizeState();
    });
  }

  void removeSite(int index) {
    setState(() {
      appState.sites.removeAt(index);
      appState.finalizeState();
    });
  }

  void addZone(int siteIndex) {
    setState(() {
      appState.sites[siteIndex].zones.add(
        Zone(name: 'Zone ${appState.sites[siteIndex].zones.length + 1}', measurements: List.filled(6, true), checked: true),
      );
      appState.finalizeState();
    });
  }

  void removeZone(int siteIndex, int zoneIndex) {
    setState(() {
      appState.sites[siteIndex].zones.removeAt(zoneIndex);
      appState.finalizeState();
    });
  }

  void toggleSiteChecked(int siteIndex) {
    setState(() {
      appState.sites[siteIndex].checked = !appState.sites[siteIndex].checked;
      appState.finalizeState();
    });
  }

  void toggleZoneChecked(int siteIndex, int zoneIndex) {
    setState(() {
      appState.sites[siteIndex].zones[zoneIndex].checked = !appState.sites[siteIndex].zones[zoneIndex].checked;
      appState.finalizeState();
    });
  }

  void toggleMeasurementChecked(int siteIndex, int zoneIndex, int measurementIndex) {
    setState(() {
      appState.sites[siteIndex].zones[zoneIndex].measurements[measurementIndex] =
          !appState.sites[siteIndex].zones[zoneIndex].measurements[measurementIndex];
      appState.finalizeState();
    });
  }

  void renameSite(int siteIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName = appState.sites[siteIndex].name;

        return AlertDialog(
          title: const Text('Rename Site'),
          content: TextField(
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
                setState(() {
                  appState.sites[siteIndex].name = newName;
                  appState.finalizeState();
                });
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
        String newName = appState.sites[siteIndex].zones[zoneIndex].name;

        return AlertDialog(
          title: const Text('Rename Zone'),
          content: TextField(
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
                setState(() {
                  appState.sites[siteIndex].zones[zoneIndex].name = newName;
                  appState.finalizeState();
                });
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

  @override
  Widget build(BuildContext context) {
    Map<String, tz.Location> locations = tz.timeZoneDatabase.locations;
    tz.Location dropdownValue = appState.timezone;

    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Timezone:'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton(
                  items: [
                    for (var location in locations.values)...[
                      DropdownMenuItem(
                        value: location,
                        child: Text(location.toString()),
                      )
                    ]
                  ],
                  onChanged: (value) {
                    appState.timezone = value!;
                    setState(() {
                      dropdownValue = value;
                      appState.finalizeState();
                    });
                  },
                  value: dropdownValue,
                ),
              ),
            ],
          ),

          if (appState.sites.isNotEmpty)
            Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appState.sites.length,
                  itemBuilder: (context, siteIndex) {
                    Site site = appState.sites[siteIndex];
                    return Column(
                      children: [
                        ListTile(
                          title: Row(
                            children: [
                              Checkbox(
                                value: site.checked,
                                onChanged: (_) => toggleSiteChecked(siteIndex),
                              ),
                              Text(site.name),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => renameSite(siteIndex),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => removeSite(siteIndex),
                              ),
                            ],
                          ),
                        ),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: site.zones.length,
                          itemBuilder: (context, zoneIndex) {
                            Zone zone = site.zones[zoneIndex];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Checkbox(
                                          value: zone.checked,
                                          onChanged: (_) => toggleZoneChecked(siteIndex, zoneIndex),
                                        ),
                                        Text(zone.name),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => renameZone(siteIndex, zoneIndex),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () => removeZone(siteIndex, zoneIndex),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 36.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            for (int i = 0; i < zone.measurements.length; i++)
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Checkbox(
                                                    value: zone.measurements[i],
                                                    onChanged: (_) =>
                                                        toggleMeasurementChecked(siteIndex, zoneIndex, i),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 8),
                                                    child: Text(
                                                      _getMeasurementName(i),
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        ElevatedButton(
                          onPressed: () => addZone(siteIndex),
                          child: const Text('Add Zone'),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ],
            ),

          ElevatedButton(
            onPressed: addSite,
            child: const Text('Add Site'),
          ),
        ],
      ),
    );
  }

  String _getMeasurementName(int index) {
    switch (index) {
      case 0:
        return 'Humidity';
      case 1:
        return 'Temperature';
      case 2:
        return 'Light';
      case 3:
        return 'Rain';
      case 4:
        return 'Frost';
      case 5:
        return 'Soil';
      default:
        return '';
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const SettingsPage(),
    ),
  ));
}