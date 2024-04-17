import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../db/dao/contact_dao.dart';
import '../widgets/bubble.dart';
import '../widgets/contact_details.dart';
import '../db/models/contact.dart';
import '../services/page_navigation_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Contact>>? _contacts;

  @override
  void initState() {
    super.initState();
    _refreshContacts();
  }

  //   void _refreshContacts() {
  //   setState(() {
  //     _contacts = fetchAndSetContacts();
  //   });
  // }

  void _refreshContacts() async {
    final userId = await getCurrentUserId();
    if (userId != null) {
      _contacts = ContactDAO().fetchContacts(userId);
      setState(() {});
    }
  }

Future<String?> getCurrentUserId() async {
  try {
    AuthSession session = await Amplify.Auth.fetchAuthSession();
    if (session is CognitoAuthSession && session.isSignedIn) {
      return session.userSub;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: FutureBuilder<List<Contact>>(
        future: _contacts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data!.isEmpty) {
            return Center(child: Text('No contacts found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Contact contact = snapshot.data![index];
                return ListTile(
                  title: Text(contact.name),
                  onTap: () {
                    _navigateToContactDetailsPage(context, contact);
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openCreateContactModal(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
  void _openCreateContactModal(BuildContext context) async {
  String? userId = await getCurrentUserId();
  if (userId == null) {
    print("User ID is null. User might not be logged in.");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text('User not logged in. Please log in and try again.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
    return;
  }

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      TextEditingController nameController = TextEditingController();
      TextEditingController phoneNumberController = TextEditingController();
      TextEditingController birthdayController = TextEditingController();
      TextEditingController picturePathController = TextEditingController();
      TextEditingController bioController = TextEditingController();
      String errorMessage = '';

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: phoneNumberController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                  ),
                  TextField(
                    controller: birthdayController,
                    decoration: InputDecoration(labelText: 'Birthday'),
                  ),
                  TextField(
                    controller: picturePathController,
                    decoration: InputDecoration(labelText: 'Picture Path'),
                  ),
                  TextField(
                    controller: bioController,
                    decoration: InputDecoration(labelText: 'Bio'),
                  ),
                  SizedBox(height: 10),
                  if (errorMessage.isNotEmpty)
                    Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 16)),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isNotEmpty &&
                          phoneNumberController.text.isNotEmpty &&
                          birthdayController.text.isNotEmpty &&
                          picturePathController.text.isNotEmpty &&
                          bioController.text.isNotEmpty) {
                        try {
                          await ContactDAO().insertContact(
                            Contact(
                              userId: userId,
                              name: nameController.text,
                              phoneNumber: phoneNumberController.text,
                              bio: bioController.text,
                              picturePath: picturePathController.text,
                              birthday: birthdayController.text,
                            ),
                          );
                          Navigator.pop(context);
                          _refreshContacts();
                        } catch (e) {
                          print("Failed to add contact: $e");
                          setState(() {
                            errorMessage = "Failed to add contact. Please try again.";
                          });
                        }
                      } else {
                        setState(() {
                          errorMessage = 'All fields are required!';
                        });
                      }
                    },
                    child: Text('Save Contact'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _navigateToContactDetailsPage(BuildContext context, Contact contact) {

  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => ContactDetailsPage(contact: contact),
  ));
}



//   void _navigateToContactDetailsPage(BuildContext context, Contact contact) {
//   // Assuming you have a ContactDetailsPage that takes a Contact object
//   Navigator.of(context).push(MaterialPageRoute(
//     builder: (context) => ContactDetailsPage(contact: contact),
//   ));
// }
// void _handleDragUpdate(DragUpdateDetails details,) {
//   // Accessing PageNavigationController from Provider
//   final pageController = Provider.of<PageController>(context, listen: false);
//   final screenSize = MediaQuery.of(context).size;
//   final positionFromRightEdge = screenSize.width - details.globalPosition.dx;
//   final positionFromLeftEdge = details.globalPosition.dx;
//   if (!pageController.hasClients) return;

//   if (positionFromRightEdge < 50.0) {
//     pageController.nextPage( duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
//   } 
//   // else if (positionFromLeftEdge < 50.0) {
//   //   pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
//   // }
// }

}