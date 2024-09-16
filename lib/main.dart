import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:people_q/constants/amplifyconfiguration.dart';
import 'package:people_q/screens/signin_screen.dart';
import 'package:people_q/screens/signup_screen.dart';
import 'package:people_q/widgets/splash_screen.dart';

import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  // await dotenv.load();
  runApp(MyApp());
}

Future<void> _configureAmplify() async {
  AmplifyStorageS3 storagePlugin = AmplifyStorageS3();
  AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
  try {
    await Amplify.addPlugin(authPlugin);
    await Amplify.addPlugin(storagePlugin);
    await Amplify.configure(amplifyconfig);
  } catch (e) {
    print("Could not configure Amplify: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PEEPLE Q',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
          LoadingApp(), // Use LoadingApp to handle splash screen and auth check
      routes: {
        '/home': (context) => HomePage(),
        '/signup': (context) => SignUpScreen(),
        '/signin': (context) => SignInScreen(),
      },
    );
  }
}

class LoadingApp extends StatefulWidget {
  @override
  _LoadingAppState createState() => _LoadingAppState();
}

class _LoadingAppState extends State<LoadingApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApp();
  }

  Future<void> _loadApp() async {
    // Simulate some loading time
    await Future.delayed(Duration(seconds: 2)); // Adjust this as needed
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/signin');
      }
    } catch (e) {
      print("Error getting sign-in status: $e");
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? SplashScreen()
        : Container(); // Show splash screen while loading
  }
}
