import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:people_q/screens/verification.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _birthdateController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }


Future<void> signUpUser() async {
  try {
    Map<CognitoUserAttributeKey, String> userAttributes = {
      CognitoUserAttributeKey.email: _emailController.text,
      CognitoUserAttributeKey.name: _nameController.text,
      CognitoUserAttributeKey.phoneNumber: '+1${_phoneNumberController.text}', 
      CognitoUserAttributeKey.birthdate: _birthdateController.text, 
    };

    final SignUpResult result = await Amplify.Auth.signUp(
      username: _emailController.text,
      password: _passwordController.text,
      options: CognitoSignUpOptions(userAttributes: userAttributes),
    );
    
    if (result.isSignUpComplete) {
      print("Sign up successful");
    } else {
           Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VerificationPage(email: _emailController.text)),
      );
    }
  } catch (e) {
    print("An error occurred during sign up: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
                ),
                TextFormField(
                  controller: _birthdateController,
                  decoration: InputDecoration(labelText: 'Birthdate (YYYY-MM-DD)'),
                  validator: (value) => value!.isEmpty ? 'Please enter your birthdate' : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      signUpUser();
                    }
                  },
                  child: Text('Sign Up'),
                ),
                TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signin');
                },
                child: Text("Already have an account? Sign in"),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
