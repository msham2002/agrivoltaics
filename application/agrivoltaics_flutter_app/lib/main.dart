import 'package:flutter/material.dart';
import 'pages/login.dart';

void main() {
  runApp(const App());
}

// Root app
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Name',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey)
      ),
      home: const LoginPage()
    );
  }
}