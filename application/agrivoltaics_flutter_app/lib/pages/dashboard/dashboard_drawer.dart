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
    final ScrollController _scrollController = ScrollController();

    return Drawer(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  children: [
                    DateRangePicker(
                      height: constraints.maxHeight * 0.65,
                    ),
                    TimeRangePicker(),
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
                ),
              ),
              // Row(
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: ElevatedButton(
              //         onPressed:() {
              //           dashboardState.finalizeState();
              //         },
              //         child: const Text('Apply')
              //       ),
              //     ),
              //   ],
              // )
            ],
          );
        }
      ),
    );
  }
}

/*

Date Range Picker

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
  // double? width;
  // double? height;

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
              child: TextField(
                keyboardType: TextInputType.number,
                maxLength: 2,
                onChanged: (value) {
                  dashboardState.timeIntervalValue = int.parse(value);
                },
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
    );
  }
}