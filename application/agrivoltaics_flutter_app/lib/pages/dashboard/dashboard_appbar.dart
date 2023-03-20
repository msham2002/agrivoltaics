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
                return const Center(
                  child: Expanded(
                    child: Text('Modal')
                  )
                );
              }
            );
          },
          icon: const Icon(Icons.map_outlined),
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