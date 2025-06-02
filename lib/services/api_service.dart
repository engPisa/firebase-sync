import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/contato.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/save'; // URL local

  static Future<bool> sendContact(Contact contact) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(contact.toJson()),
    );
    return response.statusCode == 201;
  }
}
