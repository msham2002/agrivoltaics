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
    var dashboardState = context.watch<DashboardState>();
    var horizontalPhone = (MediaQuery.of(context).orientation == Orientation.landscape) || (MediaQuery.of(context).size.shortestSide > 600.0);

    return Drawer(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              DateRangePicker(
                height: horizontalPhone ? constraints.maxHeight * 0.65 : null,
              ),
              TimeRangePicker(
                height: horizontalPhone ? constraints.maxHeight * (0.35 / 2) : null,
                width: constraints.maxWidth * 0.6
              ),
              SizedBox(
                height: horizontalPhone ? constraints.maxHeight * (0.35 / 2) : null,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed:() {
                      dashboardState.finalizeState();
                    },
                    child: const Text('Apply')
                  ),
                ),
              ),
            ],
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
    var dashboardState = context.watch<DashboardState>();
    
    return SizedBox(
      width: this.width,
      height: this.height,
      child: Center(
        child: SfDateRangePicker(
          onSelectionChanged: (args) {
            dashboardState.dateRangeSelection = args.value;
          },
          initialSelectedRange: dashboardState.dateRangeSelection,
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
    var dashboardState = context.watch<DashboardState>();
    TimeRange dropdownValue = dashboardState.timeInterval;

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  onChanged: (value) {
                    dashboardState.timeIntervalValue = int.parse(value);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Interval'
                  ),
                )
              )
            ),
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
      ),
    );
  }
}