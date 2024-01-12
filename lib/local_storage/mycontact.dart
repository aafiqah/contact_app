class Mycontact {
  int? id;
  String firstname;
  String lastname;
  String fullname;
  String email;
  String? profileImage;
  String? isFavorite;

  Mycontact({
    this.id, 
    required this.firstname, 
    required this.lastname, 
    required this.email,
    this.profileImage,
    this.isFavorite,
  }) : fullname = '$firstname $lastname';

  factory Mycontact.fromJson(Map<String, dynamic> json) => Mycontact(
        id: json['id'],
        firstname: json['firstname'],
        lastname: json['lastname'],
        email: json['email'],
        profileImage: json['profileImage'],
        isFavorite: json['isFavorite'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstname': firstname,
        'lastname': lastname,
        'fullname': fullname,
        'email': email,
        'profileImage': profileImage,
        'isFavorite': isFavorite,
      };
}
