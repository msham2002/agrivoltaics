import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../app_constants.dart';
import 'dashboard_state.dart';

/*

Dashboard Drawer

*/
class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var dashboardState = context.watch<DashboardState>();

    return Drawer(
      child: Column(
        children: [
          const DateRangePicker(),
          Row(
            children: [
              Expanded(child: const TimeRangePicker()),
              // Expanded(child: TextField()),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed:() {
                    dashboardState.finalizeState();
                  },
                  child: const Text('Apply')
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

/*

Date Range Picker

*/
class DateRangePicker extends StatelessWidget {
  const DateRangePicker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var dashboardState = context.watch<DashboardState>();
    
    return Center(
      child: SfDateRangePicker(
        onSelectionChanged: (args) {
          dashboardState.dateRangeSelection = args.value;
        },
        initialSelectedRange: dashboardState.dateRangeSelection,
        selectionMode: DateRangePickerSelectionMode.extendableRange
      )
    );
  }
}

/*

Time Range Picker

*/
class TimeRangePicker extends StatefulWidget {
  const TimeRangePicker({
    super.key,
  });

  @override
  State<TimeRangePicker> createState() => _TimeRangePickerState();
}

class _TimeRangePickerState extends State<TimeRangePicker> {
  @override
  Widget build(BuildContext context) {
    var dashboardState = context.watch<DashboardState>();
    TimeRange dropdownValue = dashboardState.timeInterval;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 30,
                child: TextField(
                  keyboardType: TextInputType.number,
                  // maxLength: 2,
                  onChanged: (value) {
                    dashboardState.timeIntervalValue = int.parse(value);
                  },
                )
              )
            )
          ),
          // TextField
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton(
              items: const [
                DropdownMenuItem(
                  value: TimeRange.minute,
                  child: Text('minutes')
                ),
                DropdownMenuItem(
                  value: TimeRange.hour,
                  child: Text('hours')
                ),
                DropdownMenuItem(
                  value: TimeRange.day,
                  child: Text('days')
                ),
                DropdownMenuItem(
                  value: TimeRange.week,
                  child: Text('weeks')
                ),
                DropdownMenuItem(
                  value: TimeRange.month,
                  child: Text('months')
                )
              ],
              onChanged: (value) {
                dashboardState.timeInterval = value!;
                setState(() {
                  dropdownValue = value;
                });
              },
              value: dropdownValue
            ),
          ),
        ],
      )
    );
  }
}