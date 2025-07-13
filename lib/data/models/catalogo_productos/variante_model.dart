import 'calidad_model.dart';

class Variante {
  final String id;
  final String? variante;
  final bool disponibleOnline;
  final int orden;
  final List<Calidad> calidades;
  bool modificado;

  Variante({
    required this.id,
    this.variante,
    required this.disponibleOnline,
    required this.orden,
    required this.calidades,
    this.modificado = false,
  });

  factory Variante.fromJson(Map<String, dynamic> json) {
    return Variante(
      id: json['_id'] as String,
      variante: json['variante'] as String?,
      disponibleOnline: json['disponibleOnline'] as bool,
      orden: (json['orden'] as num).toInt(),
      calidades: (json['calidad'] as List<dynamic>) // <-- CAMBIO CLAVE
          .map((c) => Calidad.fromJson(c))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'variante': variante,
      'disponibleOnline': disponibleOnline,
      'orden': orden,
      'calidades': calidades.map((c) => c.toJson()).toList(),
    };
  }

   Variante copyWith({
    String? variante,
    bool? disponibleOnline,
    int? orden,
    List<Calidad>? calidades,
    bool? modificado,
  }) {
    final calidadModificada = calidades?.any((c) => c.modificado) ?? this.calidades.any((c) => c.modificado);

    return Variante(
      id: this.id,
      variante: variante ?? this.variante,
      disponibleOnline: disponibleOnline ?? this.disponibleOnline,
      orden: orden ?? this.orden,
      calidades: calidades ?? this.calidades,
      modificado: modificado ?? calidadModificada,
    );
  }
}
