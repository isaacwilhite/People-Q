
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late XFile? imageFile;
  Uint8List processedImageBytes = Uint8List(0);
  final ImagePicker _picker = ImagePicker();
  double linearProgress = 0.0;
  String apiKey = dotenv.env['REMOVE_BG_KEY']!;
  Remove removeBgService = Remove();

  TextEditingController nameController = TextEditingController();
      TextEditingController phoneNumberController = TextEditingController();
      TextEditingController bioController = TextEditingController();
      String errorMessage = '';
      DateTime selectedDate = DateTime.now();
      TextEditingController? dateInputController;

  Future<List<Contact>>? _contacts;


  @override
  void initState() {
    super.initState();
    DateTime selectedDate = DateTime.now();
dateInputController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(selectedDate));    _refreshContacts();
  }

    @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    bioController.dispose();
    dateInputController!.dispose();
    super.dispose();
  }

  void clearTextFields() {
  nameController.clear();
  phoneNumberController.clear();
  dateInputController!.clear();
  bioController.clear();
}


  void _refreshContacts() async {
    final userId = await getCurrentUserId();
    if (userId != null) {
      _contacts = ContactDAO().fetchContacts(userId);
      setState(() {});
    }
  }

  Future pickAndProcessImage(BuildContext context, StateSetter setState) async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        imageFile = pickedImage;
      });

      // Assuming you have a valid API key for remover_bg
      Remove().bg(
        File(pickedImage.path),
        privateKey: apiKey,
        onUploadProgressCallback: (progressValue) {
          print(progressValue);
        },
      ).then((data) {
        setState(() {
          processedImageBytes = data!;
        });
      }).catchError((error) {
        print("Failed to remove background: $error");
      });
    }
  }

  List<Color> bgColors = [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue];
  Color getRandomColor() => bgColors[Random().nextInt(bgColors.length)];


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
            return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // Defines the number of columns
              crossAxisSpacing: 10, // Space between columns
              mainAxisSpacing: 10, // Space between rows
              childAspectRatio: 1, // Aspect ratio for each cell
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Contact contact = snapshot.data![index];
              String imageUrl = 'https://image-bucket4c010-dev.s3.us-east-2.amazonaws.com/public/uploaded-images${contact.picturePath}';
              return GestureDetector(
                onTap: () => _navigateToContactDetailsPage(context, contact),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: getRandomColor(),
                  backgroundImage: contact.picturePath.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: contact.picturePath.isEmpty ? Icon(Icons.person, size: 40) : null,
                ),
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

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter modalSetState) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => pickAndProcessImage(context, modalSetState),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color.fromARGB(255, 245, 112, 112),
                      backgroundImage: processedImageBytes != null ? MemoryImage(processedImageBytes!) : null,
                      child: processedImageBytes == null ? Icon(Icons.camera_alt, size: 30) : null,
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
                    onTap: () => _selectDate(context, setState),
                  ),
                  // GestureDetector(
                  //   onTap: () => _pickImage(context, picturePathController, setState),
                  //   child: Container(
                  //     height: 50,
                  //     width: double.infinity,
                  //     alignment: Alignment.center,
                  //     decoration: BoxDecoration(
                  //       border: Border.all(color: Colors.grey),
                  //       borderRadius: BorderRadius.circular(5),
                  //     ),
                  //     child: Text(picturePathController.text.isEmpty ? 'Upload Picture' : 'Change Picture'),
                  //   ),
                  // ),
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
                          File imageFile = await createFileFromBytes(processedImageBytes);
                          _uploadImage(imageFile, context);
                          await ContactDAO().insertContact(
                            Contact(
                              userId: userId,
                              name: nameController.text,
                              phoneNumber: phoneNumberController.text,
                              bio: bioController.text,
                              picturePath: imageFile.path,
                              birthday: DateFormat('yyyy-MM-dd').parse(dateInputController!.text),
                            ),
                          );
                                  modalSetState(() {
          processedImageBytes = Uint8List(0); 
        });
                          clearTextFields();
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
        dateInputController!.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }


// Future _pickImage(BuildContext context) async {
//   final ImagePicker _picker = ImagePicker();
//   final image = await _picker.pickImage(source: ImageSource.gallery);

//   if (image != null) {
//     return image;
//   } else {
//     print("No image selected.");
//   }
// }

Future<void> _uploadImage (File file, BuildContext context) async {


// final file = processImageData(imageBytes);

// final size = ImageSizeGetter.getSize(FileInput(file));

final size = file.lengthSync();

XFile xFile = XFile(file.path);

final awsFile = AWSFile.fromStream(xFile.openRead(), size: size);

  try {
final key = 'uploaded-images${file.path}';
    await Amplify.Storage.uploadFile(
      localFile: awsFile,
      key: key,
      onProgress: (progress) {
        print('Upload Progress: ${progress.fractionCompleted}');
      }
    );
    print('Successfully uploaded file: $key');

  } catch (e) {
    print("Failed to upload image: $e");
  }
}

void _navigateToContactDetailsPage(BuildContext context, Contact contact) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => ContactDetailsPage(contact: contact),
  ));
}


Future<File> createFileFromBytes(Uint8List bytes) async {
  final directory = await getTemporaryDirectory();
  final path = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
  final file = File(path);
  await file.writeAsBytes(bytes);
  return file;
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