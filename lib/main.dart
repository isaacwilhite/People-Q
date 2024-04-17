import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:people_q/screens/signin_screen.dart';
import 'package:people_q/screens/signup.dart';
import 'package:people_q/screens/signup_screen.dart';
import 'db/database.dart';
import 'screens/home.dart';
import './services/auth_services.dart';
import './widgets/date_page.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import './utils/global_drag.dart';
import './services/page_navigation_controller.dart';
import "amplifyconfiguration.dart";
import 'package:amplify_flutter/amplify_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(MyApp());
}

Future<void> _configureAmplify() async {
  AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
  try {
    await Amplify.addPlugin(authPlugin);
    await Amplify.configure(amplifyconfig);
  } catch (e) {
    print("Could not configure Amplify: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CheckAuth(), // A widget that checks the auth status and navigates accordingly
      routes: {
        '/home': (context) => HomePage(),
        '/signup': (context) => SignUpScreen(),
        '/signin': (context) => SignInScreen()
        // Add more named routes as needed
      },
    );
  }
}

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        print(Amplify.Auth);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/signup');
      }
    } catch (e) {
      print("Error getting sign-in status: $e");
      Navigator.pushReplacementNamed(context, '/signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This widget is only responsible for checking auth status and navigating
    return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }
}
// void main() async {
//   Provider.debugCheckInvalidValueType = null;
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(
//     ChangeNotifierProvider(
//       create: (context) => PageController(),
//       child: ListenableProvider<PageController>.value(
//         value: PageController(initialPage: 0),
//         child: MyApp(),
//     ),
//   )
//   );
// }


// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   late bool _isUserLoggedIn = false;

//   @override
//   void initState() {
//     super.initState();
//     checkSignInStatus();
//   }

// void checkSignInStatus() async {
//   try {
//     final session = await Amplify.Auth.fetchAuthSession();
//     final isSignedIn = session.isSignedIn;
//     if (isSignedIn) {
//       // User is signed in; navigate to the home page
//       Navigator.pushReplacementNamed(context, '/home');
//     } else {
//       // User is not signed in; stay on or navigate to the sign-in page
//     }
//   } catch (e) {
//     print("Error checking sign-in status: $e");
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     // No need for StreamBuilder if you're not listening to a stream here
//     return MaterialApp(
//       home: Scaffold(
//         body: PageView(
//           physics: NeverScrollableScrollPhysics(), // Prevent manual swiping
//           controller: PageController(initialPage: _isUserLoggedIn ? 1 : 0), // Adjust based on sign-in status
//           children: [
//             SignUpScreen(), // Assuming this is your sign-up screen
//             HomePage(), // Assuming this is your main content page after sign-in
//             // You can add WeekView or other pages as needed
//           ],
//         ),
//       ),
//     );
//   }
// }