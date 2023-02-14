import 'package:flutter/material.dart';
import 'data.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              child: Text('View Data'),
              onPressed: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DataDashboard()
                    )
                  )
              },
            ),
            ElevatedButton(
              child: Text('Manage Sensors'),
              onPressed: () => {print('hello')},
            ),
            ElevatedButton(
              child: Text('Settings'),
              onPressed: () => {print('hello')},
            )
          ],
        ),
      ),
    );
  }
}
