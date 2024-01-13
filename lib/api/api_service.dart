import 'dart:convert';
import 'package:contact_app/api/user_model.dart';
import 'package:http/http.dart' as http;

class APIService {
  static const String baseUrl = "https://reqres.in/api/users";

  // Fetch a list of users
  static Future<List<UserModel>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl?page=1&per_page=12'));

    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body)['data'];
      return List<UserModel>.from(data.map((user) => UserModel.fromJson(user)));
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Get a single user by ID
  static Future<UserModel> getUserById(int userId) async {
    String url = "$baseUrl/$userId";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      UserModel user = UserModel.fromJson(json['data']);
      return user;
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception(
          'Failed to load user. Status Code: ${response.statusCode}');
    }
  }

  // Create a new user
  static Future<UserModel> createUser(UserModel user) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(user.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return UserModel.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception(
          'Failed to create user. Status Code: ${response.statusCode}');
    }
  }

  // Delete a user by ID
  static Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception(
          'Failed to delete user. Status Code: ${response.statusCode}');
    }
  }

  // Update a user by ID
  static Future<UserModel> updateUser(int id, UserModel user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      body: json.encode(user.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception(
          'Failed to update user. Status Code: ${response.statusCode}');
    }
  }
}
