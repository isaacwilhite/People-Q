import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:people_q/db/dao/contact_dao.dart';
import 'package:people_q/db/dao/event_dao.dart';
import 'package:people_q/db/models/contact.dart';
import 'package:people_q/db/models/event.dart';
import 'package:people_q/screens/peeple_pond.dart';
import 'package:people_q/utils/global_drag.dart';
import 'package:people_q/widgets/contact_details.dart';

import '../widgets/custom_drag.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalDragHandler _globalDragHandler = GlobalDragHandler();
  final DateTime _today = DateTime.now();
  bool _isNavigatingToContacts = false;
  Future<List<Contact>>? _contactsFuture;

  XFile? imageFile;
  bool isLoadingImage = false;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController eventDescriptionController =
      TextEditingController();

  String errorMessage = '';
  DateTime selectedDate = DateTime.now();
  TextEditingController? dateInputController;

  @override
  void initState() {
    super.initState();
    _refreshContacts();
    dateInputController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(selectedDate));
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

  void _handleContactDropped(Contact contact, DateTime date) {
    _showEventModal(contact, date);
  }

  void _showEventModal(Contact contact, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('New Event for ${contact.name}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              TextField(
                controller: eventDescriptionController,
                decoration: InputDecoration(labelText: 'Event Description'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await _submitEvent(contact, date);
                  Navigator.pop(context);
                  setState(() {});
                },
                child: Text('Submit'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitEvent(Contact contact, DateTime date) async {
    String userId = await getCurrentUserId() ?? "";
    Event event = Event(
      contactId: contact.id,
      eventDate: DateFormat('yyyy-MM-dd').format(date),
      description: eventDescriptionController.text,
    );
    try {
      await EventDao().insertEvent(event);
      eventDescriptionController.clear();
      _refreshContacts(); // Refresh contacts to update UI
    } catch (e) {
      print("Failed to insert event: $e");
    }
  }

  void _navigateToToday() {
    _globalDragHandler.pageController.jumpToPage(8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            width: 100,
            height: 100,
            child: Image.asset('assets/QIcon-gradient.png', fit: BoxFit.cover),
          ),
          onPressed: () {
            setState(() {
              _isNavigatingToContacts = true;
            });
            _globalDragHandler.pageController.jumpToPage(0);
          },
        ),
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: _globalDragHandler.handleDragUpdate,
        child: PageView.builder(
          controller: _globalDragHandler.pageController,
          onPageChanged: (int page) {
            if (!_isNavigatingToContacts && page == 0) {
              _globalDragHandler.pageController.jumpToPage(8);
            }
            if (page == 1) {
              _globalDragHandler.pageController.jumpToPage(8);
            }
            setState(() {
              _isNavigatingToContacts = false;
            });
          },
          itemCount: 16,
          itemBuilder: (_, index) {
            if (index == 0) {
              return ContactsPage(
                contactsFuture: _contactsFuture,
                onContactDropped: (contact) =>
                    _handleContactDropped(contact, _today),
                pageController: _globalDragHandler.pageController,
              );
            } else if (index == 1) {
              return Container();
            } else {
              DateTime date = _today.add(Duration(days: index - 8));
              String formattedDate = DateFormat('yyyy-MM-dd').format(date);
              if (DateFormat('yyyy-MM-dd').format(date) ==
                  DateFormat('yyyy-MM-dd').format(_today)) {
                formattedDate = 'Today';
              }
              Future<List<Contact>> contactsForDate =
                  ContactDAO().fetchContactsByEventDate(formattedDate);

              return FutureBuilder<List<Contact>>(
                future: contactsForDate,
                builder: (_, snapshot) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          DateFormat('EEEE, MMMM d').format(date),
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      Expanded(
                        child: CustomDragTarget<Contact>(
                          onWillAccept: (data) {
                            return true;
                          },
                          onAccept: (contact) {
                            _handleContactDropped(contact, date);
                          },
                          builder: (
                            _,
                            List<dynamic> accepted,
                            List<dynamic> rejected,
                          ) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text(
                                      'Error fetching contacts for this date'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                  child:
                                      Text('No contacts found for this date'));
                            } else {
                              return ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (_, index) {
                                  return _buildContactBubbles(
                                      context, snapshot.data!);
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openCreateContactModal(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<String> _uploadImage(File file) async {
    final size = file.lengthSync();
    final awsFile = AWSFile.fromStream(File(file.path).openRead(), size: size);

    try {
      final key =
          'public/uploaded-images/${DateTime.now().millisecondsSinceEpoch}-${file.path.split('/').last}';
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

  Widget _buildContactBubbles(BuildContext context, List<Contact> contacts) {
    final List<Widget> bubbles = [];
    final random = Random();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    double xOffset = 0;
    double yOffset = 0;
    double rowHeight = 0;
    double totalRowWidth = 0;
    double horizontalMargin = 20.0;
    List<Widget> rowBubbles = [];

    for (var contact in contacts) {
      double size = random.nextDouble() * 60 + 80;
      double radius = size / 2;

      if (xOffset + size > screenWidth - 2 * horizontalMargin) {
        double startX = (screenWidth - totalRowWidth) / 2 + horizontalMargin;
        for (var bubble in rowBubbles) {
          Positioned positionedBubble = bubble as Positioned;
          bubbles.add(Positioned(
            top: positionedBubble.top,
            left: positionedBubble.left! + startX,
            child: positionedBubble.child!,
          ));
        }

        rowBubbles.clear();
        xOffset = 0;
        yOffset += rowHeight + 40;
        rowHeight = 0;
        totalRowWidth = 0;
      }

      if (yOffset + size > screenHeight * 2) {
        break;
      }

      rowHeight = max(rowHeight, size);
      totalRowWidth += size + 40;

      double topVariation = random.nextDouble() * (rowHeight / 2);
      double top = yOffset + topVariation;
      double left = xOffset + random.nextDouble() * (screenWidth / 4 - size);

      left = max(horizontalMargin, left);
      left = min(screenWidth - horizontalMargin - size, left);

      xOffset += size + 40;

      String imageUrl =
          'https://image-bucket4c010-dev.s3.us-east-2.amazonaws.com/public/${contact.picturePath}';

      rowBubbles.add(
        Positioned(
          top: top,
          left: left,
          child: CustomDraggable<Contact>(
            data: contact,
            feedback: Material(
              color: Colors.transparent,
              child: CircleAvatar(
                radius: radius,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: contact.picturePath.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : null,
                child: contact.picturePath.isEmpty
                    ? Icon(Icons.person, size: radius)
                    : null,
              ),
            ),
            childWhenDragging: Container(),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.85,
                      maxChildSize: 0.95,
                      minChildSize: 0.3,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: ContactDetailsPage(contact: contact),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: CircleAvatar(
                radius: radius,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: contact.picturePath.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : null,
                child: contact.picturePath.isEmpty
                    ? Icon(Icons.person, size: radius)
                    : null,
              ),
            ),
            onDragStarted: () {
              _globalDragHandler.setContext(context);
            },
            onDragUpdate: (details) {
              _globalDragHandler.handleDragUpdate(details);
            },
            onDragEnd: (details) {
              _globalDragHandler.clearContext();
            },
          ),
        ),
      );
    }

    double startX = (screenWidth - totalRowWidth) / 2 + horizontalMargin;
    for (var bubble in rowBubbles) {
      Positioned positionedBubble = bubble as Positioned;
      bubbles.add(Positioned(
        top: positionedBubble.top,
        left: positionedBubble.left! + startX,
        child: positionedBubble.child!,
      ));
    }

    return Container(
      width: screenWidth,
      height: screenHeight * 3,
      child: Stack(children: bubbles),
    );
  }

  Future<void> _openCreateContactModal(BuildContext context) async {
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
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => pickImage(modalSetState),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor:
                                const Color.fromARGB(255, 245, 112, 112),
                            backgroundImage: imageFile != null
                                ? FileImage(File(imageFile!.path))
                                : null,
                            child: isLoadingImage
                                ? CircularProgressIndicator()
                                : (imageFile == null
                                    ? Icon(Icons.camera_alt, size: 30)
                                    : null),
                          ),
                        ),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: 'Name'),
                        ),
                        TextField(
                          controller: phoneNumberController,
                          decoration:
                              InputDecoration(labelText: 'Phone Number'),
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
                          Text(errorMessage,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 16)),
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
                                      birthday: DateFormat('yyyy-MM-dd')
                                          .parse(dateInputController!.text),
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
                                  errorMessage =
                                      "Failed to add contact. Please try again.";
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
      clearTextFields();
    });
  }

  Future<void> pickImage(StateSetter setState) async {
    setState(() {
      isLoadingImage = true;
    });
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
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
}
