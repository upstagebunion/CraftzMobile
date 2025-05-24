import 'package:craftz_app/data/models/cotizacion/descuento_model.dart';
import 'package:craftz_app/data/models/cotizacion/extra_cotizado_model.dart';
import 'package:craftz_app/providers/extras_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:craftz_app/providers/parametros_costos_provider.dart';
import 'package:craftz_app/data/repositories/extras_repositorie.dart';

class CalculadorCostos {
  final WidgetRef ref;

  CalculadorCostos(this.ref);

  // Calcula el precio final de un producto con sus extras
  Future<double> calcularPrecioFinal({
    required String subcategoriaId,
    required List<ExtraCotizado> extras,
    required double precioBase,
    Descuento? descuento,
  }) async {
    
    // 1. Obtener los parámetros fijos que aplican a esta subcategoría
    final costosFijos = await _obtenerCostosFijos(subcategoriaId);
    
    // 2. Ordenar los costos fijos por prioridad
    costosFijos.sort((a, b) => a.prioridad.compareTo(b.prioridad));
    
    double precioCalculado = precioBase;

    // 4. Aplicar extras de cm cuadrdado
    for (final extra in extras) {
      if (extra.unidad == UnidadExtra.cm_cuadrado) {
        if (extra.esTemporal){
          if (extra.parametroCalculo!.id != null) {
            final parametro = await _obtenerParametroCalculo(extra.parametroCalculo!.id!);
            if (parametro != null) {
              precioCalculado += extra.calcularMonto(parametro);
            }
          } else {
            final areaExtra = extra.largoCm! * extra.anchoCm!;
            precioCalculado += areaExtra * extra.parametroCalculo!.valor;
          }
        } else {
          final extraOriginal = ref.read(extrasProvider.notifier).getExtraById(extra.extraRef!);
          if (extraOriginal != null) { 
            final parametro = await _obtenerParametroCalculo(extraOriginal.parametroCalculoId);
            precioCalculado += extraOriginal.calcularMonto(parametro);
          }
        }
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

    if(descuento != null){
      if (descuento.tipo == 'porcentaje') {
        precioCalculado = precioCalculado * (1 - descuento.valor / 100);
      } else {
        precioCalculado = precioCalculado - descuento.valor;
      }  
    }
    precioCalculado = precioCalculado + 10; //Margen de mayoreo
    precioCalculado = double.parse(precioCalculado.toStringAsFixed(2));
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
