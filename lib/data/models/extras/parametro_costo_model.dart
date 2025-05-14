enum UnidadCosto { pieza, cm_cuadrado, porcentaje }
enum TipoAplicacion { fijo, variable }

class ParametroCostoElaboracion {
  final String id;
  final String nombre;
  final String? descripcion;
  final UnidadCosto unidad;
  final double monto;
  final double? anchoPlancha; // en cm
  final double? largoPlancha; // en cm
  final TipoAplicacion tipoAplicacion;
  final int prioridad;
  final List<String> subcategoriasAplica;

  ParametroCostoElaboracion({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.unidad,
    required this.monto,
    this.anchoPlancha,
    this.largoPlancha,
    required this.tipoAplicacion,
    this.prioridad = 0,
    required this.subcategoriasAplica,
  });

  factory ParametroCostoElaboracion.fromJson(Map<String, dynamic> json) {
    return ParametroCostoElaboracion(
      id: json['_id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      unidad: UnidadCosto.values.firstWhere(
        (e) => e.toString().split('.').last == json['unidad'],
        orElse: () => UnidadCosto.pieza,
      ),
      monto: (json['monto'] as num).toDouble(),
      anchoPlancha: json['anchoPlancha'] != null ? (json['anchoPlancha'] as num).toDouble() : null,
      largoPlancha: json['largoPlancha'] != null ? (json['largoPlancha'] as num).toDouble() : null,
      tipoAplicacion: TipoAplicacion.values.firstWhere(
        (e) => e.toString().split('.').last == json['tipoAplicacion'],
        orElse: () => TipoAplicacion.fijo,
      ),
      prioridad: json['prioridad'] as int? ?? 0,
      subcategoriasAplica: (json['subcategoriasAplica'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'unidad': unidad.toString().split('.').last,
      'monto': monto,
      'anchoPlancha': anchoPlancha,
      'largoPlancha': largoPlancha,
      'tipoAplicacion': tipoAplicacion.toString().split('.').last,
      'prioridad': prioridad,
      'subcategoriasAplica': subcategoriasAplica,
    };
  }

  double costoPorUnidad() {
    if (unidad == UnidadCosto.pieza) {
      return monto;
    } else {
      // Para cm², calculamos el costo por cm² basado en el área de la plancha
      final areaPlancha = anchoPlancha! * largoPlancha!;
      return monto / areaPlancha;
    }
  }

  double aplicarCosto(double precioBase) {
    if (tipoAplicacion == TipoAplicacion.fijo) {
      if (unidad == UnidadCosto.pieza) {
        return precioBase + monto;
      } else if (unidad == UnidadCosto.porcentaje) {
        return precioBase * (1 + monto);
      } else {
        // Para cm² fijos, asumimos que se aplica a toda el área del producto
        // Esto podría necesitar ajuste según tu lógica específica
        final areaPlancha = anchoPlancha! * largoPlancha!;
        final montoASumar =  monto / areaPlancha;
        return precioBase + montoASumar;
      }
    } else {
      // Los variables se aplican a través de extras
      return precioBase;
    }
  }
}