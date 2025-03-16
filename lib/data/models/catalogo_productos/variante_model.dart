import 'variante_color_model.dart';

class Variante {
  final String id;
  final String? tipo;
  final List<Color> colores;
  bool isExpanded;

  Variante({required this.id, this.tipo, required this.colores, this.isExpanded = false});

  factory Variante.fromJson(Map<String, dynamic> json) {
    return Variante(
      id: json['_id'] as String,
      tipo: json['tipo'] as String?,
      colores: (json['colores'] as List)
          .map((color) => Color.fromJson(color))
          .toList(),
      isExpanded : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tipo': tipo,
      'colores': colores.map((color) => color.toJson()).toList(),
    };
  }
}
