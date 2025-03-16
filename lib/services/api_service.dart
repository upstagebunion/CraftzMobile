import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'https://craftzapp.onrender.com';

  Future<List<dynamic>> getProducts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no encontrado. Debes iniciar sesión primero.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/productos'),
      headers: {
      'Content-Type': 'application/json',
      'Authorization': '$token',
      },);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  Future<void> addProduct(Map<String, dynamic> product) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no encontrado. Debes iniciar sesión primero.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/productos'),
      headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      },
      body: jsonEncode(product),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al agregar producto');
    }
  }

  Future<void> actualizarProductos(List<Map<String, dynamic>> productos) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no encontrado. Debes iniciar sesión primero.');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/api/productos/actualizar'), // Asegúrate de que esta ruta coincida con tu backend
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode(productos), // Convertir la lista de productos a JSON
    );

    if (response.statusCode != 200) {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al actualizar productos: ${mensaje}';
    }
  }

  Future<Map<String, dynamic>> agregarVariante(String productoId, String tipo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no encontrado. Debes iniciar sesión primero.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/productos/$productoId/variante'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode({
        'tipo': tipo,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al agregar la variante: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> agregarColor(String productoId, String varianteId, String color, int? stock, double? precio) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no encontrado. Debes iniciar sesión primero.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/productos/$productoId/$varianteId/color'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode({
        'color': color,
        'stock': stock,
        'precio': precio,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al agregar la variante: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> agregarTalla(String productoId, String varianteId, String colorId, String talla, int? stock, double? precio) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no encontrado. Debes iniciar sesión primero.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/productos/$productoId/$varianteId/$colorId/talla'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode({
        'talla': talla,
        'stock': stock,
        'precio': precio,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al agregar la variante: ${response.body}');
    }
  }
}
