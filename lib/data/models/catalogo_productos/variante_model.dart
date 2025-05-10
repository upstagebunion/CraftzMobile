import 'variante_color_model.dart';

class Variante {
  final String id;
  final String? tipo;
  final List<Color> colores;

  Variante({required this.id, this.tipo, required this.colores});

  factory Variante.fromJson(Map<String, dynamic> json) {
    return Variante(
      id: json['_id'] as String,
      tipo: json['tipo'] as String?,
      colores: (json['colores'] as List)
          .map((color) => Color.fromJson(color))
          .toList()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tipo': tipo,
      'colores': colores.map((color) => color.toJson()).toList(),
    };
  }

  Variante copyWith({List<Color>? colores, String? tipo}) {
    return Variante(
      id: this.id,
      colores: colores ?? this.colores,
      tipo: tipo ?? this.tipo
      );
  }
}
