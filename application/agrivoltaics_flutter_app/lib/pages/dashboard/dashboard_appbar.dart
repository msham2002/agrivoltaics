import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(
            onPressed: () {
              showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return ZoneModal();
              }
            );
          },
          icon: const Icon(Icons.filter_alt_outlined),
        ),
        IconButton(
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
          icon: const Icon(Icons.analytics_outlined)
        ),
      ],
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ZoneModal extends StatefulWidget {
  const ZoneModal({
    super.key,
  });

  @override
  State<ZoneModal> createState() => _ZoneModalState();
}

class _ZoneModalState extends State<ZoneModal> {
  List zones = [];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          children: [
            for (int i = 1; i <= 3; i++)...[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Zone ${i}'),
                      Checkbox(value: false, onChanged: (null))
                    ],
                  )
                ),
              )
            ]
          ],
        ),
      )
    );
  }
}