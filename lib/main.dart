import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:people_q/screens/signup.dart';
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
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => PageController(),
      child: ListenableProvider<PageController>.value(
        value: PageController(initialPage: 0),
        child: MyApp(),
    ),
  )
  );
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService(); 
  late PageController _pageController;
   @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }
    @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  // Assuming you have an instance of AuthService
  // late PageController _pageController;
  // late ScrollPhysics _pagePhysics = AlwaysScrollableScrollPhysics();

  // @override
  // void initState() {
  //   super.initState();
  //   // Initialize PageController here or dynamically based on auth status
  //   _authService.authStatusStream.first.then((isLoggedIn) {
  //     _pageController = PageController(initialPage: isLoggedIn ? 0 : 2); // Assuming WeekView is the first page when logged in
  //   });
  // }


  @override
  Widget build(BuildContext context) {
    // final PageController pageController = Provider.of<PageController>(context);
    return MaterialApp(
      home: Scaffold(
        body: StreamBuilder<bool>(
          stream: _authService.authStatusStream,
          builder: (context, snapshot) {
            final isLoggedIn = snapshot.data ?? false;
            return PageView(
              controller: Provider.of<PageController>(context, listen: false),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                HomePage(),
                WeekView(),
                // Additional pages as needed
              ],
                // WeekView(), 
                // isLoggedIn ? HomePage() : SignupScreen(), // Then HomePage or SignupScreen based on the login status
                // if (isLoggedIn) WeekView(), // If not logged in, allow swiping to WeekView after logging in
            );
          
          },
        ),
      ),
    );
  }
}