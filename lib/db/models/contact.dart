class Contact {
  int? id;
  String userId;
  String name;
  DateTime birthday;
  String picturePath;
  String phoneNumber;
  String bio;
  int timesInteractedWith;

  Contact({
    this.id,
    required this.userId,
    required this.name,
    required this.birthday,
    required this.picturePath,
    required this.phoneNumber,
    required this.bio,
    this.timesInteractedWith = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      "userId": userId,
      'name': name,
      'birthday': birthday,
      'picturePath': picturePath,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'timesInteractedWith': timesInteractedWith,
    };
  }

  static Contact fromMap(Map<String, dynamic> map) {
    return Contact(
id: map['id'] as int,
    userId: map['userid'] as String? ?? 'Unknown User',
    name: map['name'] as String? ?? 'No Name',
    birthday: DateTime.parse(map['birthday'] as String? ?? '1900-01-01T00:00:00.000Z'),
    picturePath: map['picturepath'] as String? ?? 'path/to/default.jpg',
    phoneNumber: map['phonenumber'] as String? ?? 'No Phone Number',
    bio: map['bio'] as String? ?? 'No Bio Available',
    timesInteractedWith: map['timesinteractedwith'] as int? ?? 0,
    );
  }
}
