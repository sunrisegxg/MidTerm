class UserInformation {
  final String username;
  final String email;
  final String image;
  final String password;

  UserInformation({
    required this.username,
    required this.email,
    required this.image,
    required this.password,
  });

  // Factory constructor để chuyển từ Map (Firestore) thành đối tượng User
  factory UserInformation.fromMap(Map<String, dynamic> map) {
    return UserInformation(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      image:
          map['image'] ??
          'https://cdn-icons-png.flaticon.com/512/3177/3177440.png',
      password: map['password'] ?? '',
    );
  }

  // Phương thức để chuyển đối tượng User thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'image': image,
      'password': password,
    };
  }
}
