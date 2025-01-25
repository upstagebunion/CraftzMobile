import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://craftzapp.onrender.com';

  Future<List<dynamic>> login() async {
    final Map<String, dynamic> body = {
      "correo": "fco.garcia.solis@gmail.com",
      "password" : "L2dcqal",
    };
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar productos');
    }
  }
}
