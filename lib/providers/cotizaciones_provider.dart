import 'package:craftz_app/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftz_app/data/repositories/cotizacion_repositories.dart';

final cotizacionesProvider = StateNotifierProvider<CotizacionesNotifier, CatalogoCotizaciones>((ref) {
  return CotizacionesNotifier(ref);
});

final isLoadingCotizaciones = StateProvider<bool>((ref) => true);

class CotizacionesNotifier extends StateNotifier<CatalogoCotizaciones> {
  final Ref ref;
  final ApiService apiService;
  CotizacionesNotifier(this.ref)
    : apiService = ApiService(),
      super(CatalogoCotizaciones(cotizaciones: []));

  Future<void> cargarCotizaciones() async {
    try {
      ref.read(isLoadingCotizaciones.notifier).state = true;

      final data = await apiService.obtenerCotizaciones();
      final cotizaciones = data.map((item) => Cotizacion.fromJson(item)).toList();
      state = CatalogoCotizaciones(cotizaciones: cotizaciones);
    } catch (e) {
      throw Exception('Error al cargar cotizaciones: $e');
    } finally {
      ref.read(isLoadingCotizaciones.notifier).state = false;
    }
  }

  Cotizacion? getCotizacionById(String cotizacionId) {
    try{
      return state.cotizaciones.firstWhere(
        (c) => c.id == cotizacionId,
      );
    } catch (error) {
      return null;
    }
  }

  // Operaciones CRUD para múltiples cotizaciones
  Future<void> agregarCotizacionTemp(Cotizacion cotizacion) async {
    try{
      state = CatalogoCotizaciones(
        cotizaciones: [...state.cotizaciones, cotizacion]
      );
    } catch (e) {
      throw Exception('Error al agregar cotización: $e');
    }
  }

  Future<void> agregarCotizacion(Cotizacion cotizacion) async {
    try {
      final cotizacionTempId = cotizacion.id;
      final response = await apiService.agregarCotizacion(cotizacion.toJson());
      final nuevaCotizacion = Cotizacion.fromJson(response);
      state = CatalogoCotizaciones(
        cotizaciones: state.cotizaciones.map((c) => 
          c.id == cotizacionTempId ? nuevaCotizacion : c
        ).toList()
      );
    } catch (e) {
      throw Exception('Error al agregar cotización: $e');
    }
  }

  Future<void> actualizarCotizacion(Cotizacion cotizacion) async {
    try {
      final response = await apiService.actualizarCotizacion(cotizacion.id, cotizacion.toJson());
      final cotizacionActualizada = Cotizacion.fromJson(response);
      state = CatalogoCotizaciones(
        cotizaciones: state.cotizaciones.map((c) => 
          c.id == cotizacion.id ? cotizacionActualizada : c
        ).toList()
      );
    } catch (e) {
      throw '$e';
    }
  }

  Future<void> actualizarCotizacionLocalmente(Cotizacion cotizacion) async {
    try {
      state = CatalogoCotizaciones(
        cotizaciones: state.cotizaciones.map((c) => 
          c.id == cotizacion.id ? cotizacion : c
        ).toList()
      );
    } catch (e) {
      throw Exception('Error al actualizar cotización: $e');
    }
  }

   Future<void> eliminarCotizacion(String id) async {
    try {
      await apiService.eliminarCotizacion(id);
      state = CatalogoCotizaciones(
        cotizaciones: state.cotizaciones.where((c) => c.id != id).toList()
      );
    } catch (e) {
      throw Exception('Error al eliminar cotización: $e');
    }
  }

  // Operaciones para la cotización actual (similar al provider anterior)
  void agregarProductoACotizacion(String cotizacionId, ProductoCotizado producto) {
    state = CatalogoCotizaciones(
      cotizaciones: state.cotizaciones.map((cotizacion) {
        if (cotizacion.id == cotizacionId) {
          final productosNuevos = [...cotizacion.productos, producto];
          return cotizacion.copyWith(
            productos: productosNuevos,
            subTotal: _calcularSubTotal(productosNuevos),
            total: _calcularTotal(productosNuevos, cotizacion.descuentoGlobal),
          );
        }
        return cotizacion;
      }).toList()
    );
    _verificarYAplicarDescuentoMayoreo(cotizacionId);
  }

  void removerProductoDeCotizacion(String cotizacionId, int index) {
    state = CatalogoCotizaciones(
      cotizaciones: state.cotizaciones.map((cotizacion) {
        if (cotizacion.id == cotizacionId) {
          final nuevosProductos = List<ProductoCotizado>.from(cotizacion.productos);
          nuevosProductos.removeAt(index);
          return cotizacion.copyWith(
              productos: nuevosProductos,
              subTotal: _calcularSubTotal(nuevosProductos),
              total: _calcularTotal(nuevosProductos, cotizacion.descuentoGlobal),
            );
        }
        return cotizacion;
      }).toList()
    );
    _verificarYAplicarDescuentoMayoreo(cotizacionId);
  }

  void actualizarProductoEnCotizacion(String cotizacionId, int index, ProductoCotizado producto) {
    state = CatalogoCotizaciones(
      cotizaciones: state.cotizaciones.map((cotizacion) {
        if (cotizacion.id == cotizacionId) {
          final nuevosProductos = List<ProductoCotizado>.from(cotizacion.productos);
          nuevosProductos[index] = producto;
          return cotizacion.copyWith(
            productos: nuevosProductos,
            subTotal: _calcularSubTotal(nuevosProductos),
            total: _calcularTotal(nuevosProductos, cotizacion.descuentoGlobal),
          );
        }
        return cotizacion;
      }).toList()
    );
    _verificarYAplicarDescuentoMayoreo(cotizacionId);
  }

  void aplicarDescuentoGlobalACotizacion(String cotizacionId, Descuento descuento) {
    state = CatalogoCotizaciones(
      cotizaciones: state.cotizaciones.map((cotizacion) {
        if (cotizacion.id == cotizacionId) {
          return cotizacion.copyWith(
            descuentoGlobal: descuento,
            // Actualizar totales al aplicar descuento
            subTotal: _calcularSubTotal(cotizacion.productos),
            total: _calcularTotal(cotizacion.productos, descuento),
          );
        }
        return cotizacion;
      }).toList()
    );
  }

   void eliminarDescuentoGlobal(String cotizacionId) {
    state = CatalogoCotizaciones(
      cotizaciones: state.cotizaciones.map((cotizacion) {
        if (cotizacion.id == cotizacionId) {
          return cotizacion.copyWith(
            descuentoGlobal: null,
            subTotal: _calcularSubTotal(cotizacion.productos),
            total: _calcularTotal(cotizacion.productos, null),
          );
        }
        return cotizacion;
      }).toList()
    );
  }

  double _calcularSubTotal(List<ProductoCotizado> productos) {
    return productos.fold(0, (sum, p) => sum + p.precioFinal);
  }

  double _calcularTotal(List<ProductoCotizado> productos, Descuento? descuento) {
    double total = _calcularSubTotal(productos);
    if (descuento != null) {
      if (descuento.tipo == 'porcentaje') {
        total *= (1 - descuento.valor / 100);
      } else {
        total -= descuento.valor;
      }
    }
    return total;
  }

  Future<void> convetirCotizacionAVenta(String cotizacionId) async {
    try {
      await apiService.convertirAVenta(cotizacionId);
      state = CatalogoCotizaciones(
        cotizaciones: state.cotizaciones.where((c) => c.id != cotizacionId).toList()
      );
    } catch (e) {
      throw Exception('Error al eliminar cotización: $e');
    }
  }

  void _verificarYAplicarDescuentoMayoreo(String cotizacionId) {
    final cotizacion = state.cotizaciones.firstWhere((c) => c.id == cotizacionId);

    final totalProductos = cotizacion.productos.fold<int>(
      0,
      (int previousValue, ProductoCotizado producto) {
        return previousValue + producto.cantidad;
      },
    );

    if (totalProductos > 6) {
      final descuentoGlobal = Descuento(
        razon: 'Mayoreo',
        tipo: 'cantidad',
        valor: totalProductos * 10.0,
      );
      // Llama a la función existente para aplicar el descuento
      aplicarDescuentoGlobalACotizacion(cotizacionId, descuentoGlobal);
    } else if (totalProductos <= 6 && cotizacion.descuentoGlobal != null) {
      // Opcional: Si los productos bajan y el descuento de mayoreo estaba aplicado, quítalo.
      eliminarDescuentoGlobal(cotizacionId); // Pasa null para remover el descuento
    }
  }
}