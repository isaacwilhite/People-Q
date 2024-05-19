
import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:image_size_getter/file_input.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
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
import 'package:image_picker/image_picker.dart';
import 'package:remove_bg/remove_bg.dart';
import 'package:people_q/screens/peeple_pond.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(initialPage: 8);
  final DateTime _today = DateTime.now();
  bool _isNavigatingToContacts = false;
  Future<List<Contact>>? _contactsFuture;

  XFile? imageFile;
  bool isLoadingImage = false;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  String errorMessage = '';
  DateTime selectedDate = DateTime.now();
  TextEditingController? dateInputController;

  @override
  void initState() {
    super.initState();
    _refreshContacts();
    dateInputController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(selectedDate));
  }

  void _refreshContacts() async {
    final userId = await getCurrentUserId();
    if (userId != null) {
      setState(() {
        _contactsFuture = ContactDAO().fetchContacts(userId);
      });
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

  void clearTextFields() {
    nameController.clear();
    phoneNumberController.clear();
    dateInputController!.clear();
    bioController.clear();
    imageFile = null;
    setState(() {
      isLoadingImage = false;
    });
  }

  Future<void> pickImage(StateSetter setState) async {
    setState(() {
      isLoadingImage = true;
    });
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      try {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedImage.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              minimumAspectRatio: 1.0,
            )
          ],
        );
        if (croppedFile != null) {
          setState(() {
            imageFile = XFile(croppedFile.path);
            isLoadingImage = false;
          });
        } else {
          setState(() {
            isLoadingImage = false;
          });
        }
      } catch (e) {
        print("Error cropping image: $e");
        setState(() {
          isLoadingImage = false;
        });
      }
    } else {
      setState(() {
        isLoadingImage = false;
      });
    }
  }

  Future<String> _uploadImage(File file) async {
    final size = file.lengthSync();
    final awsFile = AWSFile.fromStream(File(file.path).openRead(), size: size);

    try {
      final key = 'public/uploaded-images/${DateTime.now().millisecondsSinceEpoch}-${file.path.split('/').last}';
      await Amplify.Storage.uploadFile(
        localFile: awsFile,
        key: key,
        options: S3UploadFileOptions(accessLevel: StorageAccessLevel.guest),
        onProgress: (progress) {
          print('Upload Progress: ${progress.fractionCompleted}');
        },
      );
      print('Successfully uploaded file: $key');
      return key;
    } catch (e) {
      print("Failed to upload image: $e");
      throw e;
    }
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
      isScrollControlled: true,
      isDismissible: false,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.3,
          builder: (BuildContext context, ScrollController scrollController) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetState) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'New Contact',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => pickImage(modalSetState),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color.fromARGB(255, 245, 112, 112),
                            backgroundImage: imageFile != null ? FileImage(File(imageFile!.path)) : null,
                            child: isLoadingImage
                                ? CircularProgressIndicator()
                                : (imageFile == null ? Icon(Icons.camera_alt, size: 30) : null),
                          ),
                        ),
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
                          onTap: () => _selectDate(context, modalSetState),
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
                                dateInputController!.text.isNotEmpty &&
                                bioController.text.isNotEmpty) {
                              try {
                                if (imageFile != null) {
                                  File file = File(imageFile!.path);
                                  final key = await _uploadImage(file);
                                  await ContactDAO().insertContact(
                                    Contact(
                                      userId: userId,
                                      name: nameController.text,
                                      phoneNumber: phoneNumberController.text,
                                      bio: bioController.text,
                                      picturePath: key,
                                      birthday: DateFormat('yyyy-MM-dd').parse(dateInputController!.text),
                                    ),
                                  );
                                  modalSetState(() {
                                    imageFile = null;
                                  });
                                  clearTextFields();
                                  Navigator.pop(context);
                                  _refreshContacts();
                                } else {
                                  setState(() {
                                    errorMessage = "Image is required.";
                                  });
                                }
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
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            clearTextFields();
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      clearTextFields(); // Clear fields when modal is closed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Peeple Q'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              setState(() {
                _isNavigatingToContacts = true;
              });
              _pageController.jumpToPage(0); // Jump to contacts page
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (int page) {
          if (!_isNavigatingToContacts && page == 0) {
            _pageController.jumpToPage(8); // Prevent swiping back to contacts page
          }
          if (page == 1) {
            _pageController.jumpToPage(8); // Automatically navigate to today's date from the first date page
          }
          setState(() {
            _isNavigatingToContacts = false;
          });
        },
        itemCount: 16,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ContactsPage(contactsFuture: _contactsFuture);
          } else if (index == 1) {
            return Container(); // Hidden vessel page
          } else {
            DateTime date = _today.add(Duration(days: index - 8));
            return Center(
              child: Text(
                DateFormat('EEEE, MMMM d').format(date),
                style: TextStyle(fontSize: 24),
              ),
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
}  Future<void> _selectDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateInputController!.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  }