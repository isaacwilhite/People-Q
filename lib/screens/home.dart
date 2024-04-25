
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../db/dao/contact_dao.dart';
import '../widgets/bubble.dart';
import '../widgets/contact_details.dart';
import '../db/models/contact.dart';
import '../services/page_navigation_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:aws_common/vm.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Contact>>? _contacts;
  DateTime selectedDate = DateTime.now();
  TextEditingController dateInputController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _refreshContacts();
    dateInputController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
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
      TextEditingController picturePathController = TextEditingController();
      TextEditingController bioController = TextEditingController();
      String errorMessage = '';
      DateTime selectedDate = DateTime.now();
      TextEditingController dateInputController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(selectedDate));

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
                    controller: dateInputController,
                    decoration: InputDecoration(labelText: 'Birthday'),
                    readOnly: true, 
                    onTap: () => _selectDate(context, setState),
                  ),
                  GestureDetector(
                    onTap: () => _uploadImage(context, picturePathController, setState),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(picturePathController.text.isEmpty ? 'Upload Picture' : 'Change Picture'),
                    ),
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
                          dateInputController.text.isNotEmpty &&
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
                              birthday: DateFormat('yyyy-MM-dd').parse(dateInputController.text),
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

Future<void> _selectDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() { 
        selectedDate = picked;
        dateInputController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

Future<void> _uploadImage(BuildContext context, TextEditingController picturePathController, StateSetter setState) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    withData: false,
    // Ensure to get file stream for better performance
    withReadStream: true,
    allowedExtensions: ['jpg', 'png'],
  );

  if (result == null) {
    safePrint('No file selected');
    return;
  }

  // Upload file with its filename as the key
  final platformFile = result.files.single;
  try {
    final result = await Amplify.Storage.uploadFile(
      localFile: AWSFile.fromStream(
        platformFile.readStream!,
        size: platformFile.size,
      ),
      key: platformFile.name,
      onProgress: (progress) {
        safePrint('Fraction completed: ${progress.fractionCompleted}');
      },
    ).result;
    safePrint('Successfully uploaded file: ${result.uploadedItem.key}');
  } on StorageException catch (e) {
    safePrint('Error uploading file: $e');
    rethrow;
  }
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