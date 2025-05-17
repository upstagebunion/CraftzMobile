import 'package:craftz_app/data/models/cotizacion/producto_cotizado_model.dart';
import 'package:craftz_app/data/models/extras/extra_model.dart';
import 'package:craftz_app/data/models/extras/parametro_costo_model.dart';

class ExtraCotizado {
  final bool esTemporal;
  final String? extraRef;
  final String nombre;
  final UnidadExtra unidad;
  final double monto;
  final double? anchoCm;
  final double? largoCm;
  final ParametroCalculo? parametroCalculo;

  ExtraCotizado({
    this.esTemporal = false,
    this.extraRef,
    required this.nombre,
    required this.unidad,
    required this.monto,
    this.anchoCm,
    this.largoCm,
    this.parametroCalculo,
  });

  Map<String, dynamic> toJson() {
    return {
      'esTemporal': esTemporal,
      'extraRef': extraRef,
      'nombre': nombre,
      'unidad': unidad.toString().split('.').last,
      'monto': monto,
      'anchoCm': anchoCm,
      'largoCm': largoCm,
      'parametroCalculo': parametroCalculo?.toJson(),
    };
  }

  factory ExtraCotizado.fromJson(Map<String, dynamic> json) {
    return ExtraCotizado(
      esTemporal: json['esTemporal'] ?? false,
      extraRef: json['extraRef'],
      nombre: json['nombre'] ?? '',
      unidad: UnidadExtra.values.firstWhere(
        (e) => e.toString().split('.').last == json['unidad'],
        orElse: () => UnidadExtra.pieza,
      ),
      monto: json['monto']?.toDouble() ?? 0,
      anchoCm: json['anchoCm']?.toDouble(),
      largoCm: json['largoCm']?.toDouble(),
      parametroCalculo: json['parametroCalculo'] != null
          ? ParametroCalculo.fromJson(json['parametroCalculo'])
          : null,
    );
  }

  double calcularMonto(ParametroCostoElaboracion? parametro) {
    if (unidad == UnidadExtra.pieza) {
      return monto;
    } else {
      if (parametro == null || anchoCm == null || largoCm == null) return 0;
      
      // Calculamos el área del extra en cm²
      final areaExtra = anchoCm! * largoCm!;
      
      // Calculamos el costo por cm² del parámetro
      final costoPorCmCuadrado = parametro.costoPorUnidad();
      
      return areaExtra * costoPorCmCuadrado;
    }
  }
}
