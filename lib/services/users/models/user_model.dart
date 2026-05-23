class UserModel {
  final String? uid;
  final String email;
  final String username;
  final String phoneNumber;
  final String? password;
  final String? profilePictureUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.phoneNumber,
    this.password,
    this.profilePictureUrl,
  });

  // Convert user info to a Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'phoneNumber': phoneNumber,
      'password': password,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  // Create UserModel from a Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      password: map['password'],
    );
  }
}
