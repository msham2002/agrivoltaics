import 'package:agrivoltaics_flutter_app/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home/home.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Spacer(flex: 2),
              const Text(
                'Vinovoltaics',
                style: TextStyle(
                  fontSize: 50
                ),
              ),
              const Spacer(),
              SignInButton(
                Buttons.Google,
                // child: const Text('Login'),
                onPressed: () {
                  if (kIsWeb) {
                    Future<UserCredential> userPromise = signInWithGoogleWeb();
                    userPromise.then((userCredential) => {
                      if (authorizeUser(userCredential)) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage()
                          )
                        )
                      }
                    });
                  } else {
                    // Future<UserCredential> userPromise = signInWithGoogleMobile();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage()
                      )
                    );
                  }
                },
              ),
              const Spacer(flex: 2),
              const Text('Developed by Da Boyz - Alex Campbell, William Hopkins, Yulia Martinez, Anthony Napolitano, Rose Saalman, Keith Springs',
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