import 'package:flutter/material.dart';
import '../db/dao/user_dao.dart';
import '../db/models/user.dart';
import './home.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _phoneNumber = '';
  String _password = '';
  String _birthdate = '';
  String _confirmEmail = '';
  String _confirmPassword = '';
  bool _isSignUpComplete = false;
  String _signUpError = '';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      try {
  // List<AuthUserAttribute> userAttributes = [
  //   AuthUserAttribute(userAttributeKey: AuthUserAttributeKey.email(), value: _email),
  //   AuthUserAttribute(userAttributeKey: AuthUserAttributeKey.name(), value: _name),
  //   AuthUserAttribute(userAttributeKey: AuthUserAttributeKey.phoneNumber(), value: '+1$_phoneNumber'),
  //   // You can't directly set birthdate as it's not a predefined key in AuthUserAttributeKey.
  //   // If you have a custom attribute for birthdate, it would look like this:
  //   // AuthUserAttribute(userAttributeKey: AuthUserAttributeKey.custom('birthdate'), value: _birthdate),
  // ];
        
        final result = await Amplify.Auth.signUp(
          username: _email,
          password: _password,
          options: SignUpOptions(
  userAttributes: {
    CognitoUserAttributeKey.email: _email,
    CognitoUserAttributeKey.name: _name,
    CognitoUserAttributeKey.phoneNumber: _phoneNumber,
  },
),
        );

        if (result.isSignUpComplete) {
          setState(() {
            _isSignUpComplete = true;
          });
          // Optionally navigate to a confirmation screen or directly to the home page
          // if you auto-confirm users in your Cognito settings
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          // Navigate to email/phone number verification page
        }
      } catch (e) {
        setState(() {
          _signUpError = e.toString();
        });
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) => _name = value!,
                validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                onSaved: (value) => _email = value!,
                validator: (value) => value!.isEmpty ? 'Email cannot be empty' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirm Email'),
                validator: (value) {
                  if (value != _email) {
                    return 'Emails must match';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true, // Hide input
                onSaved: (value) => _password = value!,
                validator: (value) => value!.isEmpty ? 'Password cannot be empty' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value != _password) {
                    return 'Passwords must match';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                onSaved: (value) => _phoneNumber = value!,
                validator: (value) => value!.isEmpty ? 'Phone number cannot be empty' : null,
              ),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Submit'),
              ),
              if (_signUpError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_signUpError, style: TextStyle(color: Colors.red)),
                ),
              TextButton(
                onPressed: () {
                  // Navigate to your sign-in page
                },
                child: Text('Already have an account? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// class SignupScreen extends StatefulWidget {
//   @override
//   _SignupScreenState createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String _name = '';
//   String _email = '';
//   String _phoneNumber = '';
//   String _password = '';
//   String _confirmEmail = '';
//   String _confirmPassword = '';

//   void _submit() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       final user = User(name: _name, email: _email, phoneNumber: _phoneNumber, password: _password);
//       await UserDao().insertUser(user);
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomePage()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Signup')),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             children: <Widget>[
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Name'),
//                 onSaved: (value) => _name = value!,
//                 validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Email'),
//                 onSaved: (value) => _email = value!,
//                 validator: (value) => value!.isEmpty ? 'Email cannot be empty' : null,
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Confirm Email'),
//                 validator: (value) {
//                   if (value != _email) {
//                     return 'Emails must match';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Phone Number'),
//                 onSaved: (value) => _phoneNumber = value!,
//                 validator: (value) => value!.isEmpty ? 'Phone number cannot be empty' : null,
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Password'),
//                 obscureText: true, // Hide input
//                 onSaved: (value) => _password = value!,
//                 validator: (value) => value!.isEmpty ? 'Password cannot be empty' : null,
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Confirm Password'),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value != _password) {
//                     return 'Passwords must match';
//                   }
//                   return null;
//                 },
//               ),
//               ElevatedButton(
//                 onPressed: _submit,
//                 child: Text('Submit'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   // Navigate to your sign-in page
//                 },
//                 child: Text('Already have an account? Sign in'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }