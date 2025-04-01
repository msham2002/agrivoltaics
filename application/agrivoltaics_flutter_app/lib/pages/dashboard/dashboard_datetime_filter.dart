import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../app_constants.dart';

void showDateTimeModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) {
      return const DashboardDateTimeFilter();
    },
  );
}

class DashboardDateTimeFilter extends StatelessWidget {
  const DashboardDateTimeFilter({
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return AlertDialog(
      title: const Text('Select Date and Time Range'),
      content: Column(
        // Constrain the size so it doesn't overflow the dialog
        mainAxisSize: MainAxisSize.min,
        children: [
          // The date range picker
          SizedBox(
            width: 300,
            height: 300,
            child: DateRangePicker(),
          ),
          const SizedBox(height: 16),
          // The time picker
          SizedBox(
            width: 300,
            child: TimeRangePicker(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), 
          child: const Text('Cancel')
        ),
        ElevatedButton(
          onPressed: () {
            appState.finalizeState();
            Navigator.of(context).pop();
          },
          child: const Text('Apply')
        )
      ],

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  onChanged: (value) {
                    appState.timeInterval.value = int.parse(value);
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
                  // DropdownMenuItem( // TODO: debugging purposes only
                  //   value: TimeUnit.second,
                  //   child: Text('seconds')
                  // ),
                  DropdownMenuItem(
                    value: TimeUnit.minute,
                    child: Text('15 minutes')
                  ),
                  DropdownMenuItem(
                    value: TimeUnit.hour,
                    child: Text('hours')
                  ),
                  DropdownMenuItem(
                    value: TimeUnit.day,
                    child: Text('days')
                  ),
                  DropdownMenuItem(
                    value: TimeUnit.week,
                    child: Text('weeks')
                  ),
                  DropdownMenuItem(
                    value: TimeUnit.month,
                    child: Text('months')
                  )
                ],
                onChanged: (value) {
                  appState.timeInterval.unit = value!;
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