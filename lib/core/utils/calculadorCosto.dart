import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:craftz_app/providers/parametros_costos_provider.dart';
import 'package:craftz_app/data/repositories/extras_repositorie.dart';

class CalculadorCostos {
  final WidgetRef ref;

  CalculadorCostos(this.ref);

  // Calcula el precio final de un producto con sus extras
  Future<double> calcularPrecioFinal({
    required String subcategoriaId,
    required List<Extra> extras,
    required double precioBase,
  }) async {
    
    // 1. Obtener los parámetros fijos que aplican a esta subcategoría
    final costosFijos = await _obtenerCostosFijos(subcategoriaId);
    
    // 2. Ordenar los costos fijos por prioridad
    costosFijos.sort((a, b) => a.prioridad.compareTo(b.prioridad));
    
    double precioCalculado = precioBase;

    // 4. Aplicar extras de cm cuadrdado
    for (final extra in extras) {
      if (extra.unidad == UnidadExtra.cm_cuadrado) {
        final parametro = await _obtenerParametroCalculo(extra.parametroCalculoId);
        precioCalculado += extra.calcularMonto(parametro);
      }
    }

    //5. Aplicar costos fijos en orden
    for (final costo in costosFijos) {
      precioCalculado = costo.aplicarCosto(precioCalculado);
    }
    
    // 6. Aplicar extras por pieza
    for (final extra in extras) {
      if (extra.unidad == UnidadExtra.pieza) {
        precioCalculado += extra.calcularMonto(null);
      }
    }

    // 7. Redondear al siguiente múltiplo de 10 menos 1 (ej: 147.25 → 149.00)
    precioCalculado = (precioCalculado / 10).ceil() * 10 - 1;
    
    return precioCalculado;
  }

  Future<List<ParametroCostoElaboracion>> _obtenerCostosFijos(String subcategoriaId) async {
    final costos = ref.read(costosElaboracionProvider).costos;
    return costos.where((c) => 
      c.tipoAplicacion == TipoAplicacion.fijo && 
      c.subcategoriasAplica.any((subcat) => subcat.contains(subcategoriaId))
    ).toList();
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
