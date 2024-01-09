class Mycontact {
  int? id;
  String firstname;
  String lastname;
  String fullname;
  String email;

  Mycontact({this.id, required this.firstname, required this.lastname, required this.fullname, required this.email});

  factory Mycontact.fromJson(Map<String, dynamic> json) => Mycontact(
        id: json['id'],
        firstname: json['firstname'],
        lastname: json['lastname'],
        fullname: json['fullname'],
        email: json['email'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstname': firstname,
        'lastname': lastname,
        'fullname': fullname,
        'email': email,
      };
}
