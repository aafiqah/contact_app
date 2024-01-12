import 'dart:convert';
import 'package:contact_app/api/user_model.dart';
import 'package:http/http.dart' as http;

class APIService {
  static const String baseUrl = "https://reqres.in/api/users";

  // Fetch a list of users
  static Future<List<UserModel>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl?page=1'));

    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body)['data'];
      return List<UserModel>.from(data.map((user) => UserModel.fromJson(user)));
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Fetch a list of favourite users
  static Future<List<UserModel>> getFavoriteUsers() async {
    final response = await http.get(Uri.parse('$baseUrl?page=2'));

    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body)['data'];
      return List<UserModel>.from(data.map((user) => UserModel.fromJson(user)));
    } else {
      throw Exception('Failed to load favorite users');
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
      throw Exception('Failed to create user');
    }
  }

  // Delete a user by ID
  static Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
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
      throw Exception('Failed to update user');
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
    } else {
      throw Exception('Failed to load user');
    }
  }
}
