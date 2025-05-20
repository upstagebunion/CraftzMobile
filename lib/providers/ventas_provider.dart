import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftz_app/data/repositories/ventas_repositorie.dart';
import 'package:craftz_app/services/api_service.dart';

final ventasProvider = StateNotifierProvider<VentasNotifier, CatalogoVentas>((ref) {
  return VentasNotifier(ref);
});

final isLoadingVentas = StateProvider<bool>((ref) => true);

class VentasNotifier extends StateNotifier<CatalogoVentas> {
  final Ref ref;
  final ApiService apiService;
  
  VentasNotifier(this.ref)
    : apiService = ApiService(),
      super(CatalogoVentas(ventas: []));

  Future<void> cargarVentas() async {
    try {
      ref.read(isLoadingVentas.notifier).state = true;
      final data = await apiService.obtenerVentas();
      final ventas = data.map((item) => Venta.fromJson(item)).toList();
      state = CatalogoVentas(ventas: ventas);
    } catch (e) {
      throw Exception('Error al cargar ventas: $e');
    } finally {
      ref.read(isLoadingVentas.notifier).state = false;
    }
  }

  Venta? getVentaById(String ventaId) {
    try {
      return state.ventas.firstWhere((v) => v.id == ventaId);
    } catch (error) {
      return null;
    }
  }

  Future<void> actualizarEstadoVenta(String ventaId, EstadoVenta nuevoEstado) async {
    try {
      await apiService.actualizarEstadoVenta(ventaId, nuevoEstado.name);
      
      state = CatalogoVentas(
        ventas: state.ventas.map((v) {
          if (v.id == ventaId) {
            return v.copyWith(estado: nuevoEstado);
          }
          return v;
        }).toList()
      );
    } catch (e) {
      throw Exception('Error al actualizar estado de venta: $e');
    }
  }

  Future<void> agregarPagoAVenta(String ventaId, Pago pago) async {
    try {
      final response = await apiService.agregarPagoAVenta(ventaId, pago.toJson());
      final ventaActualizada = Venta.fromJson(response);
      
      state = CatalogoVentas(
        ventas: state.ventas.map((v) {
          if (v.id == ventaId) {
            return ventaActualizada;
          }
          return v;
        }).toList()
      );
    } catch (e) {
      throw Exception('Error al agregar pago: $e');
    }
  }

  Future<void> liquidarVenta(String ventaId) async {
    try {
      final response = await apiService.liquidarVenta(ventaId);
      final ventaActualizada = Venta.fromJson(response);
      
      state = CatalogoVentas(
        ventas: state.ventas.map((v) {
          if (v.id == ventaId) {
            return ventaActualizada;
          }
          return v;
        }).toList()
      );
    } catch (e) {
      throw Exception('Error al liquidar venta: $e');
    }
  }

  Future<void> revertirVentaACotizacion(String ventaId) async {
    try {
      await apiService.revertirACotizacion(ventaId);
      state = CatalogoVentas(
        ventas: state.ventas.where((v) => v.id != ventaId).toList()
      );
    } catch (e) {
      throw Exception('Error al eliminar cotización: $e');
    }
  }
}