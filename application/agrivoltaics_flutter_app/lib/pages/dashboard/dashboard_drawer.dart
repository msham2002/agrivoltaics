import 'package:agrivoltaics_flutter_app/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../app_constants.dart';
import 'dashboard_state.dart';

/*

Dashboard Drawer
- Drawer on Dashboard page that extends from right side

*/
class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var horizontalPhone = (MediaQuery.of(context).orientation == Orientation.landscape) || (MediaQuery.of(context).size.shortestSide > 600.0);

    return Drawer(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0), // Adjust padding values as needed
            child: Column(
              children: [
                DateRangePicker(
                  height: horizontalPhone ? constraints.maxHeight * 0.65 : null,
                ),
                TimeRangePicker(
                  height: horizontalPhone ? constraints.maxHeight * (0.35 / 2) : null,
                  width: constraints.maxWidth * 0.6
                ),
                SizedBox(
                  height: 40.0, // Adjust the height as needed
                  child: ElevatedButton(
                    onPressed:() {
                      appState.finalizeState();
                    },
                    child: const Text('Apply', style: TextStyle(fontSize: 18)), // Adjust font size if needed
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}

/*

Date Range Picker
- Allows user to select date range

*/
class DateRangePicker extends StatelessWidget {
  double? width;
  double? height;
  
  DateRangePicker({
    super.key,
    this.width,
    this.height
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    
    return SizedBox(
      width: this.width,
      height: this.height,
      child: Center(
        child: SfDateRangePicker(
          onSelectionChanged: (args) {
            appState.dateRangeSelection = args.value;
          },
          initialSelectedRange: appState.dateRangeSelection,
          selectionMode: DateRangePickerSelectionMode.extendableRange
        )
      ),
    );
  }
}

/*

Time Range Picker
- Allows user to select time interval (every 1 minute, 2 hours, 3 days, etc.)

*/
class TimeRangePicker extends StatefulWidget {
  double? width;
  double? height;

  TimeRangePicker({
    super.key,
    this.width,
    this.height
  });

  @override
  State<TimeRangePicker> createState() => _TimeRangePickerState();
}

class _TimeRangePickerState extends State<TimeRangePicker> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    TimeUnit dropdownValue = appState.timeInterval.unit;

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80, // Adjust width here
                  child: Center(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      onChanged: (value) {
                        appState.timeInterval.value = int.parse(value);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Interval',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5), // Add some space between TextField and label
            Text(
              'Note: Maximum 2 digit interval',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 5), // Add some space between label and DropdownButton
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton(
                items: const [
                  DropdownMenuItem(
                    value: TimeUnit.minute,
                    child: Text('15 minutes'),
                  ),
                  DropdownMenuItem(
                    value: TimeUnit.hour,
                    child: Text('hours'),
                  ),
                  DropdownMenuItem(
                    value: TimeUnit.day,
                    child: Text('days'),
                  ),
                  DropdownMenuItem(
                    value: TimeUnit.week,
                    child: Text('weeks'),
                  ),
                  DropdownMenuItem(
                    value: TimeUnit.month,
                    child: Text('months'),
                  )
                ],
                onChanged: (value) {
                  appState.timeInterval.unit = value!;
                  setState(() {
                    dropdownValue = value;
                  });
                },
                value: dropdownValue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}