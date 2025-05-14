import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:craftz_app/providers/parametros_costos_provider.dart';
import 'package:craftz_app/providers/extras_provider.dart';
import 'package:craftz_app/data/repositories/extras_repositorie.dart';

class CalculadorCostos {
  final Ref ref;

  CalculadorCostos(this.ref);

  // Calcula el precio final de un producto con sus extras
  Future<double> calcularPrecioFinal({
    required String productoId,
    required String subcategoriaId,
    required List<String> extrasIds,
    required double precioBase,
  }) async {
    // 1. Obtener los parámetros fijos que aplican a esta subcategoría
    final costosFijos = await _obtenerCostosFijos(subcategoriaId);
    
    // 2. Ordenar los costos fijos por prioridad
    costosFijos.sort((a, b) => a.prioridad.compareTo(b.prioridad));
    
    // 3. Aplicar costos fijos en orden
    double precioCalculado = precioBase;
    for (final costo in costosFijos) {
      precioCalculado = costo.aplicarCosto(precioCalculado);
    }
    
    // 4. Aplicar extras
    final extras = await _obtenerExtras(extrasIds);
    for (final extra in extras) {
      if (extra.unidad == UnidadExtra.pieza) {
        precioCalculado += extra.calcularMonto(null);
      } else {
        final parametro = await _obtenerParametroCalculo(extra.parametroCalculoId);
        precioCalculado += extra.calcularMonto(parametro);
      }
    }
    
    return precioCalculado;
  }

  Future<List<ParametroCostoElaboracion>> _obtenerCostosFijos(String subcategoriaId) async {
    final costos = ref.read(costosElaboracionProvider).costos;
    return costos.where((c) => 
      c.tipoAplicacion == TipoAplicacion.fijo && 
      c.subcategoriasAplica.contains(subcategoriaId)
    ).toList();
  }

  Future<List<Extra>> _obtenerExtras(List<String> extrasIds) async {
    final extras = ref.read(extrasProvider).extras;
    return extras.where((e) => extrasIds.contains(e.id)).toList();
  }

  Future<ParametroCostoElaboracion?> _obtenerParametroCalculo(String? parametroId) async {
    if (parametroId == null) return null;
    final costos = ref.read(costosElaboracionProvider).costos;
    try {
      return costos.firstWhere((c) => c.id == parametroId);
    } catch (error) {
      return null;
    }
  }
}

// Provider para el calculador de costos
final calculadorCostosProvider = Provider<CalculadorCostos>((ref) {
  return CalculadorCostos(ref);
});