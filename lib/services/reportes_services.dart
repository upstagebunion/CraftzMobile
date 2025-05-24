import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReporteService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'https://craftzapp.onrender.com';

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('Token no encontrado. Debes iniciar sesión primero.');
    }
    return token;
  }

  Future<Uint8List> obtenerReporteVentas(String tipo) async {
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/reportes/ventas/$tipo'),
        headers: {'Authorization': '$token'},
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Error al obtener el reporte');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Uint8List> obtenerReporteInventario(Map<String, dynamic> filtros) async {
    try {
      String? token = await getToken();
      
      // Construir query parameters
      final params = {
        'fechaInicio': filtros['fechaInicio'],
        'fechaFin': filtros['fechaFin'],
        if (filtros['tipoMovimiento'] != null) 
          'tipoMovimiento': filtros['tipoMovimiento'],
        if (filtros['motivos'] != null && filtros['motivos'].isNotEmpty)
          'motivos': filtros['motivos'].join(','),
      };

      final response = await http.get(
        Uri.parse('$baseUrl/api/reportes/inventario/personalizado').replace(
          queryParameters: params,
        ),
        headers: {'Authorization': '$token'},
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Error al obtener el reporte');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Uint8List> generarReciboCotizacionPDF (String cotizacionId) async {
    try {
      String? token = await getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/reportes/recibo-cotizacion/$cotizacionId'),
        headers: {'Authorization': '$token'},
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Error al obtener el recibo');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Uint8List> generarReciboVentaPDF (String ventaId) async {
    try {
      String? token = await getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/reportes/recibo-venta/$ventaId'),
        headers: {'Authorization': '$token'},
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Error al obtener el recibo');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<int> getConteoClientes() async {
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/reportes/conteo-clientes'),
        headers: {'Authorization': '$token'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['count'];
      } else {
        throw Exception('Error al obtener el reporte');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<int> getConteoProductos() async {
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/reportes/conteo-productos'),
        headers: {'Authorization': '$token'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['count'];
      } else {
        throw Exception('Error al obtener el reporte');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<int> getVentasHoy() async {
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/reportes/ventas-hoy'),
        headers: {'Authorization': '$token'},
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)['count'];
        return result;
      } else {
        throw Exception('Error al obtener el reporte');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<int> getIngresosMes() async {
    try {
      String? token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/reportes/ingresos-mes'),
        headers: {'Authorization': '$token'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['totalRevenue'];
      } else {
        throw Exception('Error al obtener el reporte');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}