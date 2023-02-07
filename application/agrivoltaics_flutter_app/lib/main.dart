import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Name',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey)
      ),
      home: const LoginPage(title: 'Login')
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // State information

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Spacer(flex: 2),
              Text(
                'App Name',
                style: TextStyle(
                  fontSize: 50
                ),
              ),
              Spacer(),
              ElevatedButton(
                child: Text('Login'),
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage()
                    )
                  )
                },
              ),
              Spacer(flex: 2),
              Text('Acknowledgements',
                style: TextStyle(
                  fontWeight: FontWeight.w100
                ),
              )
            ],
          ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
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
                  print('hello')
                },
              ),
              ElevatedButton(
                child: Text('Manage Sensors'),
                onPressed: () => {
                  print('hello')
                },
              ),
              ElevatedButton(
                child: Text('Settings'),
                onPressed: () => {
                  print('hello')
                },
              )
            ],
          ),
      ),
    );
  }
}
