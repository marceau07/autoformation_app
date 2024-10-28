class User {
  final String uuid;
  final String username;
  final String email;

  User({required this.uuid, required this.username, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uuid: json['uuid'],
      username: json['username'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'username': username,
    'email': email,
  };
}