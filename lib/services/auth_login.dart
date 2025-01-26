import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../exceptions/custom_exception.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final email;
  final password;

  const ApiService({required this.email,  required this.password});

  final String baseUrl = 'https://craftzapp.onrender.com';

  Future<void> login() async {
    final Map<String, dynamic> body = {
      "correo": email,
      "password" : password,
    };
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (decodedResponse.containsKey('token')){
        await prefs.setString('token', decodedResponse['token']);
        print('Login Exitoso, token: ${decodedResponse['token']}');
      } else{
        throw CustomException('Respuesta invalida del servidor. ${response.body}');
      }
    } else if (response.statusCode == 401) {
      throw CustomException('Credenciales incorrectas.');
    } else {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
      throw CustomException('Error al iniciar sesion: ${errorResponse['message']}');
    }
  }
}
