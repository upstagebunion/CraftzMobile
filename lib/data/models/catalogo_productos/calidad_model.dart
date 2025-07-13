import 'color_model.dart';

class Calidad {
  final String id;
  final String? calidad;
  final bool disponibleOnline;
  final int orden;
  final List<Color> colores; // <-- Contiene la lista de colores
  bool modificado;

  Calidad({
    required this.id,
    this.calidad,
    required this.disponibleOnline,
    required this.orden,
    required this.colores,
    this.modificado = false,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'calidad': calidad,
      'disponibleOnline': disponibleOnline,
      'orden': orden,
      'colores': colores.map((color) => color.toJson()).toList(),
    };
  }

  factory Calidad.fromJson(Map<String, dynamic> json) {
    return Calidad(
      id: json['_id'] as String,
      calidad: json['calidad'] as String?,
      disponibleOnline: json['disponibleOnline'] as bool,
      orden: (json['orden'] as num).toInt(),
      colores: (json['colores'] as List<dynamic>)
          .map((color) => Color.fromJson(color))
          .toList(),
    );
  }

  Calidad copyWith({
    String? calidad,
    bool? disponibleOnline,
    int? orden,
    List<Color>? colores,
    bool? modificado,
  }) {
    final coloresModificados = colores?.any((c) => c.modificado) ?? this.colores.any((c) => c.modificado);

    return Calidad(
      id: this.id,
      calidad: calidad ?? this.calidad,
      disponibleOnline: disponibleOnline ?? this.disponibleOnline,
      orden: orden ?? this.orden,
      colores: colores ?? this.colores,
      modificado: modificado ?? coloresModificados,
    );
  }
}