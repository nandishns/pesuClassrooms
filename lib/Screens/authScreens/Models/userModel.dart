class User {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime joiningDate;
  final String photoUrl;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.joiningDate,
    required this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      joiningDate: DateTime.parse(json['joiningDate']),
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'joiningDate': joiningDate.toIso8601String(),
        'photoUrl': photoUrl,
      };
}
