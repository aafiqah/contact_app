// mycontact.dart
class Mycontact {
  int? id;
  String firstName;
  String lastName;
  String email;
  String? avatar;
  String? isFavorite;

  Mycontact({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
    this.isFavorite,
  });

  factory Mycontact.fromJson(Map<String, dynamic> json) => Mycontact(
        id: json['id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        email: json['email'],
        avatar: json['avatar'],
        isFavorite: json['isFavorite'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'avatar': avatar,
        'isFavorite': isFavorite,
      };
}
