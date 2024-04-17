

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:people_q/screens/home.dart';

// Future<void> signInUser(String email, String password) async {
//   try {
//     SignInResult result = await Amplify.Auth.signIn(
//       username: email,
//       password: password,
//     );
//     if (result.isSignedIn) {
//       print("Sign in successful");
//     Navigator.pushReplacementNamed(context, '/home');
    
//     }
//   } catch (e) {
//     print("An error occurred during sign in: $e");
//   }
// }
Future<Map<Object, String?>> fetchUserData() async {
  try {
    final userAttributes = await Amplify.Auth.fetchUserAttributes();
    final userData = { for (var attr in userAttributes) attr.userAttributeKey: attr.value };
    return userData;
  } catch (e) {
    print("Error fetching user attributes: $e");
    return {};
  }
}

