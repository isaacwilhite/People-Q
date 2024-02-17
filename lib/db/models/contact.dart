class Contact {
  int? id;
  String name;
  String birthday;
  String picturePath;
  String phoneNumber;
  String bio;
  int timesInteractedWith;

  Contact({
    this.id,
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
      id: map['id'],
      name: map['name'],
      birthday: map['birthday'],
      picturePath: map['picturePath'],
      phoneNumber: map['phoneNumber'],
      bio: map['bio'],
      timesInteractedWith: map['timesInteractedWith'],
    );
  }
}
