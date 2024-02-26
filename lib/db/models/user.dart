class User {
  final int? id;
  final String name;
  final String email;
  final String phoneNumber;
  final String password;

  User({this.id, required this.name, required this.email, required this.phoneNumber, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      password: map['password'],
    );
  }
}
