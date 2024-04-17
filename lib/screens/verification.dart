import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:people_q/screens/home.dart';

class VerificationPage extends StatefulWidget {
  final String email;

  const VerificationPage({Key? key, required this.email}) : super(key: key);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _formKey = GlobalKey<FormState>();
  String _verificationCode = '';

  void _submitVerification() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final result = await Amplify.Auth.confirmSignUp(
          username: widget.email,
          confirmationCode: _verificationCode,
        );
        if (result.isSignUpComplete) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
        }
      } catch (e) {
        print("An error occurred during confirmation: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify Account')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Verification Code'),
                onSaved: (value) => _verificationCode = value!,
                validator: (value) => value!.isEmpty ? 'Please enter your verification code' : null,
              ),
              ElevatedButton(
                onPressed: _submitVerification,
                child: Text('Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
