import './parametro_costo_model.dart';
enum UnidadExtra { pieza, cm_cuadrado }

class Extra {
  final String id;
  final String nombre;
  final UnidadExtra unidad; // 'pieza' o 'cm_cuadrado'
  final double? monto;
  final double? anchoCm; // Solo para unidad == cmCuadrado
  final double? largoCm; // Solo para unidad == cmCuadrado
  final String? parametroCalculoId; // Solo para unidad == cmCuadrado

  Extra({
    required this.id,
    required this.nombre,
    required this.unidad,
    this.monto,
    this.anchoCm,
    this.largoCm,
    this.parametroCalculoId
  });

  factory Extra.fromJson(Map<String, dynamic> json) {
    return Extra(
      id: json['_id'] as String,
      nombre: json['nombre'] as String,
      unidad: UnidadExtra.values.firstWhere(
        (e) => e.toString().split('.').last == json['unidad'],
        orElse: () => UnidadExtra.pieza,
      ),
      monto: json['monto'] != null ? (json['monto'] as num).toDouble() : null,
      anchoCm: json['anchoCm'] != null ? (json['anchoCm'] as num).toDouble() : null,
      largoCm: json['largoCm'] != null ? (json['largoCm'] as num).toDouble() : null,
      parametroCalculoId: json['parametroCalculoId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nombre': nombre,
      'unidad': unidad.toString().split('.').last,
      'monto': monto,
      'anchoCm': anchoCm,
      'largoCm': largoCm,
      'parametroCalculoId': parametroCalculoId
    };
  }

  double calcularMonto(ParametroCostoElaboracion? parametro) {
    if (unidad == UnidadExtra.pieza) {
      return monto ?? 0;
    } else {
      if (parametro == null || anchoCm == null || largoCm == null) return 0;
      
      // Calculamos el área del extra en cm²
      final areaExtra = anchoCm! * largoCm!;
      
      // Calculamos el costo por cm² del parámetro
      final costoPorCmCuadrado = parametro.costoPorUnidad();
      
      return areaExtra * costoPorCmCuadrado;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Extra &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}