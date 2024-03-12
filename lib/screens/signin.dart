import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';


Future<void> signInWithEmail(String email, String password) async {
  try {
    SignInResult signInResult = await Amplify.Auth.signIn(
      username: email,
      password: password,
    );
    if (signInResult.isSignedIn) {
      print("Sign in successful!");
      // Navigate to your app's authenticated area
    } else {
      print("User is not signed in.");
    }
  } on AuthException catch (e) {
    print("Could not sign in - ${e.message}");
  }
}
