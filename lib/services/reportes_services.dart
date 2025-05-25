import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html_to_pdf/html_to_pdf.dart';

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
        final html = response.body;
        return await generarPDF('Reporte_ventas', html);
      } else {
        throw Exception('Error al obtener el reporte');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Uint8List> generarPDF(String fileName, String htmlContent) async {
    try {

    final directory = await getTemporaryDirectory();
    final targetPath = directory.path;
    final targetFileName = fileName;
      // 1. Convertir HTML a widgets de PDF
      final generatedPdfFile  = await HtmlToPdf.convertFromHtmlContent(
        htmlContent: htmlContent,
        printPdfConfiguration: PrintPdfConfiguration(
          targetDirectory: targetPath,
          targetName: targetFileName,
          printSize: PrintSize.A4,
          printOrientation: PrintOrientation.Portrait,
        )
      );

      // 2. Crear el documento PDF
      final pdfBytes = await File(generatedPdfFile.path!).readAsBytes();

      // 3. Eliminar archivo temporal PDF
      await File(generatedPdfFile.path).delete();

      // 4. Retornar el PDF en Bytes
      return pdfBytes;
    } catch (e) {
      print("⚠️ Error al generar PDF: $e");
      throw Exception("No se pudo generar el PDF");
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
        final html = response.body;
        return await generarPDF('Reporte_ventas', html);
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
        final html = response.body;
        return await generarPDF('Reporte_ventas', html);
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
        final html = response.body;
        return await generarPDF('Reporte_ventas', html);
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