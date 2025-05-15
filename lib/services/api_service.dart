import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'https://craftzapp.onrender.com';

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('Token no encontrado. Debes iniciar sesión primero.');
    }
    return token;
  }

  Future<List<dynamic>> getProducts() async {
    String? token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/productos'),
      headers: {
      'Content-Type': 'application/json',
      'Authorization': '$token',
      },);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al cargar productos: ${mensaje}';
    }
  }

  Future<Map<String, dynamic>> agregarProducto(Map<String, dynamic> product) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/productos'),
      headers: {
      'Content-Type': 'application/json',
      'Authorization': '$token',
      },
      body: jsonEncode(product),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body)['producto'];
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al crear producto: ${mensaje}';
    }
  }

  Future<void> actualizarProductos(List<Map<String, dynamic>> productos) async {
    String? token = await getToken();

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
    String? token = await getToken();

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
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al aagregar variante: ${mensaje}';
    }
  }

  Future<Map<String, dynamic>> agregarColor(String productoId, String varianteId, String color, int? stock, double? costo) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/productos/$productoId/$varianteId/color'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode({
        'color': color,
        'stock': stock,
        'costo': costo,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al agregar color: ${mensaje}';
    }
  }

  Future<Map<String, dynamic>> agregarTalla(String productoId, String varianteId, String colorId, String talla, int? stock, double? costo) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/productos/$productoId/$varianteId/$colorId/talla'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode({
        'talla': talla,
        'stock': stock,
        'costo': costo,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al agregar talla: ${mensaje}';
    }
  }

  Future<void> eliminarProducto(String productoId) async {
    String? token = await getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/api/productos/$productoId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      }
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al agregar talla: ${mensaje}';
    }
  }

  Future<void> eliminarVariante(String productoId, String varianteId) async {
    String? token = await getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/api/productos/$productoId/$varianteId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      }
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al agregar talla: ${mensaje}';
    }
  }

  Future<Map<String, dynamic>> eliminarColor(String productoId, String varianteId, String colorId) async {
  String? token = await getToken();

  final response = await http.delete(
    Uri.parse('$baseUrl/api/productos/$productoId/$varianteId/$colorId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al eliminar color: ${mensaje}';
    }
  }

  Future<Map<String, dynamic>> eliminarTalla(String productoId, String varianteId, String colorId, String tallaId) async {
    String? token = await getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/api/productos/$productoId/$varianteId/$colorId/$tallaId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al eliminar la talla: ${mensaje}';
    }
  }

  Future<List<dynamic>> getCategories() async {
    String? token = await getToken();

    final response = await http.get(
    Uri.parse('$baseUrl/api/categorias/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['categorias'];
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al obtener las categorias: ${mensaje}';
    }
  }

  Future<List<dynamic>> getExtras() async {
    String? token = await getToken();

    final response = await http.get(
    Uri.parse('$baseUrl/api/extras/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['extras'];
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al obtener las categorias: ${mensaje}';
    }
  }

  Future<Map<String, dynamic>> agregarExtra(json) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/extras/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode({
        'nombre': json['nombre'],
        'unidad': json['unidad'],
        'monto':  json['monto'],
        'anchoCm':  json['anchoCm'],
        'largoCm':  json['largoCm'],
        'parametroCalculoId':  json['parametroCalculoId'],
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['data'];
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al obtener las categorias: ${mensaje}';
    }
  }

  Future<List<dynamic>> getCostosElaboracion() async {
    String? token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/parametrosCostos/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['costos'];
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al obtener los costos de elaboración: $mensaje';
    }
  }

  Future<Map<String, dynamic>> agregarParametroCostoElaboracion(json) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/parametrosCostos/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode({
      'nombre': json['nombre'],
      'descripcion': json['descripcion'],
      'unidad': json['unidad'],
      'monto': json['monto'],
      'anchoPlancha': json['anchoPlancha'],
      'largoPlancha': json['largoPlancha'],
      'subcategoriasAplica': json['subcategoriasAplica'],
      'tipoAplicacion': json['tipoAplicacion'],
      'prioridad': json['prioridad'],
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['data'];
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al obtener las categorias: ${mensaje}';
    }
  }

  Future<void> eliminarExtra(String extraId) async {
    String? token = await getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/api/extras/$extraId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      }
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al agregar talla: ${mensaje}';
    }
  }

  Future<void> eliminarCostosElaboracion(String parametroId) async {
    String? token = await getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/api/parametrosCostos/$parametroId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      }
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al agregar talla: ${mensaje}';
    }
  }

}
