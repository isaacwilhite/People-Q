import 'package:flutter/material.dart';
import '../db/dao/contact_dao.dart';
import '../widgets/bubble.dart';
import '../db/models/contact.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Contact>> _contacts;

  @override
  void initState() {
    super.initState();
    _refreshContacts();
  }

    void _refreshContacts() {
    setState(() {
      _contacts = ContactDao().getContacts();
    });
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
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No contacts found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ContactTile(contact: snapshot.data![index]);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateContactModal(context),
        child: Icon(Icons.add),
      ),
    );
  }
  void _openCreateContactModal(BuildContext context) {
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
                        await ContactDao().insertContact(
                          Contact(
                            name: nameController.text,
                            phoneNumber: phoneNumberController.text,
                            bio: bioController.text,
                            picturePath: picturePathController.text,
                            birthday: birthdayController.text,
                          ),
                        );
                        Navigator.pop(context);
                        _refreshContacts();
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
}