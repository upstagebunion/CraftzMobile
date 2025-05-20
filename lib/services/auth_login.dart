import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../exceptions/custom_exception.dart';
import 'package:http/http.dart' as http;

class ApiService {

  final String baseUrl = dotenv.env['API_URL'] ?? 'https://craftzapp.onrender.com';

  Future<void> login({required String email, required String password}) async {
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
        if (decodedResponse.containsKey('usuario')) {
          await prefs.setString('userData', jsonEncode(decodedResponse['usuario']));
        }
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

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> body = {
      "nombre": name,
      "correo": email,
      "password": password,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (decodedResponse.containsKey('token')) {
        await prefs.setString('token', decodedResponse['token']);

        if (decodedResponse.containsKey('usuario')) {
          await prefs.setString('userData', jsonEncode(decodedResponse['usuario']));
        }
      } else {
        throw Exception('Respuesta inválida del servidor. ${response.body}');
      }
    } else if (response.statusCode == 400) {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
      throw Exception(errorResponse['message'] ?? 'El correo ya está registrado.');
    } else {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
      throw Exception('Error al registrar: ${errorResponse['message']}');
    }
  }

  Future<bool> verifyToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try{
    final response = await http.get(
      Uri.parse('$baseUrl/auth/tokenVerify'),
      headers: {
      'Content-Type': 'application/json',
      'Authorization': '$token',
      },);

      if(response.statusCode == 200){
        return true;
      }else{
        return false;
      }
    } catch (e){
      print('Error: $e');
      return false;
    }
  }
}
