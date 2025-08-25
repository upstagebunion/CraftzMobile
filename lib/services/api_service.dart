import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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

  Future<Map<String, dynamic>> agregarVariante(String productoId, String? variante, int orden, bool disponibleOnline) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/productos/$productoId/variante'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode({
        'variante': variante,
        'orden': orden,
        'disponibleOnline': disponibleOnline
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al aagregar variante: ${mensaje}';
    }
  }

  Future<Map<String, dynamic>> agregarCalidad(
    String productoId,
    String varianteId,
    String? calidad,
    int orden,
    bool disponibleOnline
  ) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/productos/$productoId/$varianteId/calidad'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode({
        'calidad': calidad,
        'orden': orden,
        'disponibleOnline': disponibleOnline, 
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al agregar calidad');
    }
  }

  Future<Map<String, dynamic>> agregarColor(
    String productoId,
    String varianteId,
    String calidadId,
    String color,
    String codigoHex,
    int? stock,
    double? costo,
    int orden,
    bool disponibleOnline
    ) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/productos/$productoId/$varianteId/$calidadId/color'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode({
        'color': color,
        'codigoHex': codigoHex,
        'stock': stock,
        'costo': costo,
        'orden': orden,
        'disponibleOnline': disponibleOnline,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al agregar color: ${mensaje}';
    }
  }

  Future<Map<String, dynamic>> agregarTalla(
    String productoId,
    String varianteId,
    String calidadId,
    String colorId,
    String codigo,
    String? talla,
    int stock,
    double costo,
    int orden,
    String? suk,
    bool disponibleOnline
  ) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/productos/$productoId/$varianteId/$calidadId/$colorId/talla'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode({
        'codigo': codigo,
        'talla': talla,
        'stock': stock,
        'costo': costo,
        'orden': orden,
        'suk': suk,
        'disponibleOnline': disponibleOnline
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

  Future<void> eliminarCalidad(String productoId, String varianteId, String calidadId) async {
    String? token = await getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/api/productos/$productoId/$varianteId/$calidadId'),
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

  Future<Map<String, dynamic>> eliminarColor(String productoId, String varianteId, String calidadId, String colorId) async {
  String? token = await getToken();

  final response = await http.delete(
    Uri.parse('$baseUrl/api/productos/$productoId/$varianteId/$calidadId/$colorId'),
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

  Future<Map<String, dynamic>> eliminarTalla(String productoId, String varianteId, String calidadId, String colorId, String tallaId) async {
    String? token = await getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/api/productos/$productoId/$varianteId/$calidadId/$colorId/$tallaId'),
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

  Future<Map<String, dynamic>> agregarCategoria(Map<String, dynamic> categoria) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/categorias/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode(categoria),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['categoria'];
    } else {
      final String mensaje = jsonDecode(response.body)['message'] ?? 'Error desconocido';
      throw 'Error al crear categoria: $mensaje';
    }
  }

  Future<Map<String, dynamic>> agregarSubcategoria(String categoriaId, Map<String, dynamic> subcategoria) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/categorias/$categoriaId/subcategorias'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode(subcategoria),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['subcategoria'];
    } else {
      final String mensaje = jsonDecode(response.body)['message'] ?? 'Error desconocido';
      throw 'Error al crear subcategoria: $mensaje';
    }
  }

  Future<void> eliminarCategoria(String id) async {
    String? token = await getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/api/categorias/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode != 200) {
      final decodedBody = jsonDecode(response.body);
      final String mensaje = decodedBody.containsKey('message') ? decodedBody['message'] : 'Error desconocido';
      throw 'Error al eliminar categoria: $mensaje';
    }
  }

  Future<void> eliminarSubcategoria(String categoriaId, String subcategoriaId) async {
    String? token = await getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/api/categorias/subcategorias/$subcategoriaId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode != 200) {
      final String mensaje = jsonDecode(response.body)['message'] ?? 'Error desconocido';
      throw 'Error al eliminar subcategoria: $mensaje';
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

  Future<Map<String, dynamic>> actualizarCostoElaboracion(String parametroId, Map<String, dynamic> cotizacion) async {
    String? token = await getToken();

    final response = await http.patch(
      Uri.parse('$baseUrl/api/parametrosCostos/$parametroId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode(cotizacion),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['costo'];
    } else {
      final String mensaje = jsonDecode(response.body)['message'];
      throw 'Error al agregar talla: ${mensaje}';
    }
  }

  Future<List<dynamic>> getClientes() async {
    String? token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/clientes/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'] ?? 'Error desconocido';
      throw 'Error al cargar clientes: $mensaje';
    }
  }

  // Agregar un nuevo cliente
  Future<Map<String, dynamic>> agregarCliente(Map<String, dynamic> cliente) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/clientes/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode(cliente),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'] ?? 'Error desconocido';
      throw 'Error al crear cliente: $mensaje';
    }
  }

  // Actualizar un cliente
  Future<Map<String, dynamic>> actualizarCliente(String id, Map<String, dynamic> cliente) async {
    String? token = await getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/api/clientes/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode(cliente),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'] ?? 'Error desconocido';
      throw 'Error al actualizar cliente: $mensaje';
    }
  }

  // Eliminar un cliente
  Future<void> eliminarCliente(String id) async {
    String? token = await getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/api/clientes/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode != 200) {
      final String mensaje = jsonDecode(response.body)['message'] ?? 'Error desconocido';
      throw 'Error al eliminar cliente: $mensaje';
    }
  }

  Future<List<dynamic>> obtenerCotizaciones() async {
    String? token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/cotizaciones/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['cotizaciones'];
    } else {
      final String mensaje = jsonDecode(response.body)['message'] ?? 'Error desconocido';
      throw 'Error al cargar cotizaciones: $mensaje';
    }
  }

  Future<Map<String, dynamic>> agregarCotizacion(Map<String, dynamic> cotizacion) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/cotizaciones/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode(cotizacion),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['cotizacion'];
    } else {
      final String mensaje = jsonDecode(response.body)['message'] ?? 'Error desconocido';
      throw 'Error al crear cotizacion: $mensaje';
    }
  }

  Future<Map<String, dynamic>> actualizarCotizacion(String id, Map<String, dynamic> cotizacion) async {
    String? token = await getToken();
    cotizacion.remove('vendedor');

    final response = await http.patch(
      Uri.parse('$baseUrl/api/cotizaciones/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode(cotizacion),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['cotizacion'];
    } else {
      final decodedResponse = jsonDecode(response.body);
      final String mensaje = decodedResponse['message'] ?? 'Error';
      final String error = decodedResponse['error'] ?? 'desconocido';
      throw '$mensaje: $error';
    }
  }

  Future<void> eliminarCotizacion(String id) async {
    String? token = await getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/api/cotizaciones/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode != 200) {
      final String mensaje = jsonDecode(response.body)['message'] ?? 'Error desconocido';
      throw 'Error al eliminar cliente: $mensaje';
    }
  }
  
  Future<List<dynamic>> obtenerVentas() async {
    String? token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/ventas/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'] ?? 'Error desconocido';
      throw 'Error al cargar cotizaciones: $mensaje';
    }
  }

  Future<List<dynamic>> obtenerVentasPorFecha(DateTime fechaInicio, DateTime fechaFin) async {
    String? token = await getToken();
    
    // Formatear fechas a string (puedes ajustar el formato según lo que espere tu backend)
    final fechaInicioStr = DateFormat('yyyy-MM-dd').format(fechaInicio);
    final fechaFinStr = DateFormat('yyyy-MM-dd').format(fechaFin);
    
    final response = await http.get(
      Uri.parse('$baseUrl/api/ventas/?fecha_inicio=$fechaInicioStr&fecha_fin=$fechaFinStr'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final String mensaje = jsonDecode(response.body)['message'] ?? 'Error desconocido';
      throw 'Error al cargar ventas por fecha: $mensaje';
    }
  }

  Future<dynamic> actualizarEstadoVenta(String ventaId, String estado) async {
    try {
      String? token = await getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/api/ventas/actualizar-estado/$ventaId'),
        headers: {
            'Content-Type': 'application/json',
            'Authorization': '$token',
          },
        body: jsonEncode({'estado': estado}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final String error = jsonDecode(response.body)['message'];
        throw error;
      }
    } catch (error) {
      throw error;
    }
  }

  Future<dynamic> agregarPagoAVenta(String ventaId, Map<String, dynamic> pagoData) async {
    try{
      String? token = await getToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/ventas/agregar-pago/$ventaId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: jsonEncode(pagoData),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['venta'];
      } else {
        final String mensaje = jsonDecode(response.body)['error'] ?? 'Error desconocido';
        throw 'Error al crear cotizacion: $mensaje';
      }
    } catch (error) {
      throw Exception('Error al agregar pago: $error');
    }
  }

  Future<dynamic> liquidarVenta(String ventaId) async {
    String? token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/ventas/liquidar/$ventaId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al liquidar venta');
  }

  Future<void> convertirAVenta(String id) async {
    String? token = await getToken();

    final response = await http.patch(
      Uri.parse('$baseUrl/api/cotizaciones/convertir-a-venta/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode != 201) {
      final String mensaje = jsonDecode(response.body)['message'] ?? 'Error desconocido';
      throw 'Error al eliminar cliente: $mensaje';
    }
  }

  Future<void> revertirACotizacion(String id) async {
    String? token = await getToken();

    final response = await http.patch(
      Uri.parse('$baseUrl/api/ventas/revertir/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode != 201) {
      final String mensaje = jsonDecode(response.body)['message'] ?? 'Error desconocido';
      throw '$mensaje';
    }
  }
}
